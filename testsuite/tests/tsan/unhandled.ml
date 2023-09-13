(* TEST

 ocamlopt_flags = "-g -runtime-variant d";
 include unix;
 set TSAN_OPTIONS="detect_deadlocks=0";

 tsan;
 native;

*)

open Printf
open Effect
open Effect.Deep

let print_endline s = Stdlib.print_endline s; flush stdout

type _ t += E : int -> int t

let g_ref = ref 0

let [@inline never] race () =
  g_ref := 1

let [@inline never] h () =
  print_endline "entering h";
  let v =
    try perform (E 0)
    with Unhandled _ -> race (); 1
  in
  print_endline "leaving h";
  v

let [@inline never] g () =
  print_endline "entering g";
  let v = h () in
  print_endline "leaving g";
  v

let f () =
  print_endline "entering f";
  let v = g () in
  print_endline "leaving f";
  v + 1

let [@inline never] fiber2 () =
  ignore @@ match_with f ()
  { retc = Fun.id;
    exnc = raise;
    effc = (fun (type a) (e : a t) -> None) };
  42

let effh : type a. a t -> ((a, 'b) continuation -> 'b) option = fun _ -> None

let [@inline never] fiber1 () =
  ignore @@ match_with fiber2 ()
  { retc = (fun v ->
      print_endline "value handler"; v + 1);
    exnc = (fun e -> raise e);
    effc = effh };
  1338

let[@inline never] main () =
  let v = fiber1 () in
  v + 1

let[@inline never] other_domain () =
  ignore @@ !g_ref;
  Unix.sleepf 0.66

let () =
  let d = Domain.spawn other_domain in
  Unix.sleepf 0.33;
  let v = main () in
  printf "result=%d\n%!" v;
  Domain.join d
