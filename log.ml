open Batteries

type level_t = [
  | `trace
  | `debug
  | `info
  | `warn
  | `error
  | `fatal
  | `always
]

let string_of_level : (level_t -> string) = function
  | `trace -> "TRACE"
  | `debug -> "DEBUG"
  | `info -> "INFO"
  | `warn -> "WARN"
  | `error -> "ERROR"
  | `fatal -> "FATAL"
  | `always -> "ALWAYS"

let int_of_level : (level_t -> int) = function
  | `trace -> 0
  | `debug -> 1
  | `info -> 2
  | `warn -> 3
  | `error -> 4
  | `fatal -> 5
  | `always -> 6

let compare_level a b =
  Int.compare (int_of_level a) (int_of_level b)

(** By default, the logger does nothing *)
let logger : (level_t -> string -> unit) ref = ref (const ignore)

(** By default, the prefix string is empty *)
let prefix : (unit -> string) ref = ref (const "")

(** By default, the log level is `always *)
let level : level_t ref = ref `always

let default_prefix () =
  let open Unix in
  let now = gmtime (time ()) in
  Printf.sprintf "%d-%02d-%02d %02d:%02d:%02d"
    (now.tm_year + 1900) (now.tm_mon + 1) now.tm_mday
    now.tm_hour now.tm_min now.tm_sec

let default_logger out level message =
  IO.nwrite out (!prefix ());
  IO.nwrite out " ";
  IO.nwrite out (string_of_level level);
  IO.nwrite out "> ";
  IO.nwrite out message;
  IO.nwrite out "\n"

(** Set a custom logger function *)
let set_logger f =
  logger := f

(** Set a custom prefix function *)
let set_prefix f =
  prefix := f

(** Set log level *)
let set_level l =
  level := l

(** Get current logger function *)
let get_logger () = !logger

(** Get current prefix function *)
let get_prefix () = !prefix

(** Get log level *)
let get_level () = !level

(** Initialize the logging system using the default logger and prefix
    functions *)
let init l =
  set_logger (default_logger stdout);
  set_prefix default_prefix;
  set_level l

(** Main logging function *)
let log l m =
  if compare_level l !level >= 0 then
    !logger l m
  else
    ()
