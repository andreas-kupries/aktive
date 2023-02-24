## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- Netpbm PPM, PGM formats
#
# See op/netpbm.c for the format specification.

operator {bands type maxval} {
    format::as::pgm::text::2chan    1 2	  255
    format::as::pgm::etext::2chan   1 2 65535
    format::as::pgm::byte::2chan    1 5	  255
    format::as::pgm::short::2chan   1 5 65535

    format::as::ppm::text::2chan    3 3	  255
    format::as::ppm::etext::2chan   3 3 65535
    format::as::ppm::byte::2chan    3 6	  255
    format::as::ppm::short::2chan   3 6 65535

    format::as::pgm::text::2string  1 2	  255
    format::as::pgm::etext::2string 1 2 65535
    format::as::pgm::byte::2string  1 5	  255
    format::as::pgm::short::2string 1 5 65535

    format::as::ppm::text::2string  3 3	  255
    format::as::ppm::etext::2string 3 3 65535
    format::as::ppm::byte::2string  3 6	  255
    format::as::ppm::short::2string 3 6 65535
} {
    def thing	[set thing   [lindex [split $__op :] 4]]
    def variant [set variant [lindex [split $__op :] 6]]
    def dst	[set dst     [dict get {
	2chan channel
	2string string
    } [lindex [split $__op :] 8]]]

    note Sink. \
	Serializes image into the $dst, using [string toupper $thing]'s $variant format.

    input

    if {$dst eq "channel"} {
	channel dst \
	    Channel the $thing $variant image data is written to
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
	TRACE ("@@thing@@ starting", 0);

	aktive_uint depth = aktive_image_get_depth (src);
	if (depth != @@bands@@) {
	    TRACE ("band mismatch, have %d, wanted %d", depth, @@bands@@);
	    aktive_failf ("@@thing@@ does not support images with %d bands, expects @@bands@@",
			  depth);
	}

	aktive_writer dst;

	@@write-result-setup@@

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_netpbm_sink (&dst, '@@type@@', @@maxval@@), src);
	// Note: The sink self-destroys in its state finalization.

	@@write-result-return@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
