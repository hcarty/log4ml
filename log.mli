module type Level_sig = sig
  type t
  (** Possible debug levels *)

  (** [to_string l] returns a string describing or naming the log level [l] *)
  val to_string : t -> string

  (** The maximum/most restrictive available log level *)
  val max_level : t

  (** [compare a b] should be [0] if [a] and [b] are equal, [< 0] if [a] is
      less restrictive than [b], and [> 0] if [a] is more restrictive than
      [b] *)
  val compare : t -> t -> int
end

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
  val max_level : t
  val compare : t -> t -> int
end

module Make : functor (L : Level_sig) -> sig
  val set_logger : (L.t -> string -> unit) -> unit
  val set_prefix : (L.t -> string) -> unit
  val set_level : L.t -> unit
  (** [set_*] set the current functions and levels for the active logger *)

  val get_logger : unit -> L.t -> string -> unit
  val get_prefix : unit -> L.t -> string
  val get_level : unit -> L.t
  (** [get_*] get the current functions and levels used by the active logger *)

  (** [init l] (re)sets logging to use the default logging and prefix functions
      and sets the logging level to [l].  The default prefix is the current
      time stamp.  The default logger outputs log entries on [stdout]. *)
  val init : 'a Batteries.IO.output -> L.t -> unit

  (** [log l m] logs the message [m] using the current logging function if the
      current log level is greater than or equal to [l]. *)
  val log : L.t -> string -> unit
end

module Easy : module type of Make(Basic)
