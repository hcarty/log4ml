(** Signature required to implement a logging module *)
module type Level_sig = sig
  type t
  (** Possible debug levels *)

  (** [to_string l] returns a string describing or naming the log level [l] *)
  val to_string : t -> string

  (** The default log level *)
  val default_level : t

  (** [compare a b] should be [0] if [a] and [b] are equal, [< 0] if [a] is
      less restrictive than [b], and [> 0] if [a] is more restrictive than
      [b] *)
  val compare : t -> t -> int
end

(** Signature of a logging module *)
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
      date/time stamp.  The default logger outputs log entries on [stdout]. *)
  val init : 'a Batteries.IO.output -> level_t -> unit

  (** [log l m] logs the message [m] using the current logging function if the
      current log level is greater than or equal to [l]. *)
  val log : level_t -> string -> unit
end

(** A functor to create a logging module using the log levels defined in [L] *)
module Make : functor (L : Level_sig) -> S with type level_t = L.t

(** A basic logging level structure *)
module Basic : sig
  type t = [
    | `trace
    | `debug
    | `info
    | `warn
    | `error
    | `fatal
    | `always
  ]
  val to_string : t -> string
  val default_level : t
  val compare : t -> t -> int
end

(** Logging module using the {!Basic} log levels *)
module Easy : S with type level_t = Basic.t
