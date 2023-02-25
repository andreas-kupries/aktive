## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- AKTIVE format
#
# See op/aktive.c for the format specification.

operator {
    format::as::aktive::2chan
    format::as::aktive::2string
} {
    def dst	[set dst     [dict get {
	2chan channel
	2string string
    } [lindex [split $__op :] 6]]]

    note Sink. \
	Serializes image into the $dst, using the AKTIVE raw format.

    input

    if {$dst eq "channel"} {
	channel dst \
	    Channel the image data is written to
    }

    def write-result-setup [dict get {
	channel { aktive_write_channel (&dst, param->dst, 1); }
	string	{
	    Tcl_Obj* ba = Tcl_NewByteArrayObj (0,0);
	    aktive_write_bytearray (&dst, ba);
	}
    } $dst]

    def write-result-return [dict get {
	channel {}
	string	{ TRACE_RETURN ("(Tcl_Obj*) %p", ba); }
    } $dst]

    {*}[dict get {
	channel void
	string	{return object0}
    } $dst] {
	TRACE ("AKTIVE starting", 0);

	aktive_writer dst;

	@@write-result-setup@@

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_aktive_sink (&dst), src);
	// Note: The sink self-destroys in its state finalization.

	@@write-result-return@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
