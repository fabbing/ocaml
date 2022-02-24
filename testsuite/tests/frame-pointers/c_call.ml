(* TEST
 * frame_pointers
 readonly_files = "fp_backtrace.c stack_args.c"
 ** setup-ocamlopt.opt-build-env
 *** ocamlopt.opt
 flags = "-ccopt -fno-omit-frame-pointer"
 program = "${test_build_directory}/c_call.opt"
 all_modules = "fp_backtrace.c stack_args.c c_call.ml"
 reference = "${test_source_directory}/c_call.reference"
 **** run
 output = "c_call.output"
 ***** check-program-output
*)

external fp_backtrace : unit -> unit = "fp_backtrace"
external fp_backtrace_no_alloc : unit -> unit = "fp_backtrace" [@@noalloc]
external fp_backtrace_many_args : int -> int -> int -> int -> int -> int -> int
  -> int -> int -> int -> int -> unit =
  "fp_backtrace_many_args_argv" "fp_backtrace_many_args"

let[@inline never] f () =
  (* Check backtrace through caml_c_call_stack_args *)
  fp_backtrace_many_args 1 2 3 4 5 6 7 8 9 10 11;
  (* Check backtrace through caml_c_call.
   * Also check that caml_c_call_stack_args correclty restores rbp register *)
  fp_backtrace ();
  (* Check caml_c_call correclty restores rbp register *)
  fp_backtrace_no_alloc ();
  42

let () = ignore (f ())
