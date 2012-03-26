open Batteries
module E = Log4ml.Easy

let () =
  let oc = IO.output_string () in
  E.init oc `error;
  E.set_prefix (fun _ -> "PREFIX: ");
  E.log `error "test";
  assert (IO.close_out oc = "PREFIX: test\n");
  print_endline "ok"

