open Batteries

module type Level_sig = sig
  type t
  val to_string : t -> string
  val default_level : t
  val compare : t -> t -> int
end

module type S = sig
  type level_t

  val set_logger : (level_t -> string -> unit) -> unit
  val set_prefix : (level_t -> string) -> unit
  val set_level : level_t -> unit
  (** [set_*] set the current functions and levels for the active logger *)

  val get_logger : unit -> level_t -> string -> unit
  val get_prefix : unit -> level_t -> string
  val get_level : unit -> level_t
  (** [get_*] get the current functions and levels used by the active logger *)

  (** [init l] (re)sets logging to use the default logging and prefix functions
      and sets the logging level to [l].  The default prefix is the current
      time stamp.  The default logger outputs log entries on [stdout]. *)
  val init : 'a Batteries.IO.output -> level_t -> unit

  (** [log l m] logs the message [m] using the current logging function if the
      current log level is greater than or equal to [l]. *)
  val log : level_t -> string -> unit
end

module Make(L : Level_sig) = struct
  type level_t = L.t

  (** By default, the logger does nothing *)
  let logger : (L.t -> string -> unit) ref = ref (const ignore)

  (** By default, the prefix string is empty *)
  let prefix : (L.t -> string) ref = ref (const "")

  (** By default, the log level is the largest (most restrictive) *)
  let level : L.t ref = ref L.default_level

  let default_prefix level =
    let open Unix in
    let now = gmtime (time ()) in
    Printf.sprintf "%d-%02d-%02d %02d:%02d:%02d %s> "
      (now.tm_year + 1900) (now.tm_mon + 1) now.tm_mday
      now.tm_hour now.tm_min now.tm_sec
      (L.to_string level)

  let default_logger out level message =
    IO.nwrite out (!prefix level);
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
  let init out l =
    set_logger (default_logger out);
    set_prefix default_prefix;
    set_level l

  (** Main logging function *)
  let log l m =
    if L.compare l !level >= 0 then
      !logger l m
    else
      ()
end

module Basic = struct
  type t = [
    | `trace
    | `debug
    | `info
    | `warn
    | `error
    | `fatal
    | `always
  ]

  let to_string : (t -> string) = function
    | `trace -> "TRACE"
    | `debug -> "DEBUG"
    | `info -> "INFO"
    | `warn -> "WARN"
    | `error -> "ERROR"
    | `fatal -> "FATAL"
    | `always -> "ALWAYS"

  let to_int : (t -> int) = function
    | `trace -> 0
    | `debug -> 1
    | `info -> 2
    | `warn -> 3
    | `error -> 4
    | `fatal -> 5
    | `always -> 6

  let default_level = `always

  let compare a b =
    Int.compare (to_int a) (to_int b)
end

module Easy = Make(Basic)
