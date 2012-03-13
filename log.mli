(** Possible debug levels *)
type level_t = [
  | `trace
  | `debug
  | `info
  | `warn
  | `error
  | `fatal
  | `always
]

(** [string_of_level l] returns a string matching [l] *)
val string_of_level : level_t -> string

(** [set_logger f] will use [f] as the logging function *)
val set_logger : (level_t -> string -> unit) -> unit

(** [set_prefix f] will use [f] to get the prefix for each log entry *)
val set_prefix : (unit -> string) -> unit

(** [set_level l] sets the current log level *)
val set_level : level_t -> unit

val get_logger : unit -> level_t -> string -> unit
val get_prefix : unit -> unit -> string
val get_level : unit -> level_t
(** [get_*] are the counter-parts to [set_*] *)

(** [init l] (re)sets logging to use the default logging and prefix functions
    and sets the logging level to [l].  The default prefix is the current
    time stamp.  The default logger outputs log entries on [stdout]. *)
val init : level_t -> unit

(** [log l m] logs the message [m] using the current logging function if the
    current log level is greater than or equal to [l]. *)
val log : level_t -> string -> unit
