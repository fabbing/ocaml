(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*               Olivier Nicole, Paris-Saclay University                  *)
(*                                                                        *)
(*                      Copyright 2016 OCaml Labs                         *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

let run_static ppf lam =
  let splices =
    if Sys.backend_type = Sys.Bytecode then begin
      ignore (Symtable.init_static ());
      let (init_code, fun_code) = Bytegen.compile_phrase lam in
      let (code, code_size, reloc, _) =
        Emitcode.to_memory init_code fun_code
      in
      Bytelink.load_deps ppf 1 !Clflags.static_deps reloc;
      Symtable.patch_object 1 code reloc;
      Symtable.check_global_initialized 1 reloc;
      Symtable.update_global_table ();
      Printf.eprintf "before reify\n%!";
      let splices = (Meta.reify_bytecode code code_size) () in
      Printf.eprintf "after reify\n%!";
      let splices : Parsetree.expression array = Obj.obj splices in
      splices
    end else if Sys.backend_type = Sys.Native then begin
      let open Filename in
      let (objfilename, oc) =
        open_temp_file ~mode:[Open_binary] "camlstatic" ".cmm"
      in
      let modulename = String.capitalize_ascii @@
        Filename.chop_extension @@ Filename.basename objfilename in
      let bytecode = Bytegen.compile_implementation modulename lam in
      Emitcode.to_file oc modulename objfilename
        ~required_globals:Ident.Set.empty bytecode;
      close_out oc;
      let execfilename = temp_file "camlstatic" "" in
      begin try
        Bytelink.link ppf 1 (!Clflags.static_deps @ [objfilename]) execfilename
      with exn ->
          Sys.remove objfilename; raise exn
      end;
      Sys.remove objfilename;
      let resultfilename = temp_file "camlsplice" "" in
      let command =
        (* Call ocamlrun on the generated bytecode file, passing the temporary
           file as an argument to write the results in *)
        Config.standard_runtime ^ " " ^ execfilename ^ " " ^ resultfilename
      in
      if Sys.command command <> 0 then begin
        Sys.remove execfilename;
        Sys.remove resultfilename;
        Misc.fatal_error @@
          "Something went wrong when executing splice generation command: "
          ^ command
      end;
      Sys.remove execfilename;
      let ic = open_in resultfilename in
      let splices : Parsetree.expression array = Marshal.from_channel ic in
      close_in ic;
      Sys.remove resultfilename;
      splices
    end else assert false (* other backends not supported *)
  in
  Symtable.reset ();
  Bytelink.reset ();
  let n = Array.length splices in
  if !Clflags.dump_parsetree then
    for i = 0 to n-1 do
      Format.fprintf ppf "splice #%d:\n" (i + 1);
      Printast.expression 0 ppf splices.(i);
      Format.pp_print_flush ppf ()
    done
  ;
  if !Clflags.dump_source then
    for i = 0 to n-1 do
      Format.fprintf ppf "splice #%d:\n" (i + 1);
      Pprintast.expression ppf splices.(i);
      Format.pp_print_newline ppf ()
    done
  ;
  splices

let load_static_deps ppf reloc =
  if Sys.backend_type = Sys.Bytecode then
    Bytelink.load_deps ppf 1 !Clflags.static_deps reloc
  else if Sys.backend_type = Sys.Native then
    () (* This function should not be used in native programs *)
  else assert false (* other backends not supported *)

