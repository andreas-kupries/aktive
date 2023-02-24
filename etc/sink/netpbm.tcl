## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- Netpbm PPM, PGM formats
#
## Portable Grey Map	1-band grey values
## Portable Pixel Map	3-band RGB values
#
# References:
# - http://en.wikipedia.org/wiki/Netpbm_format
# - http://wiki.tcl.tk/4530
#
# Format Description/Specification Recap
#
#  - PPM data represents a byte- or short-quantized RGB image (i.e. it has 3 bands). It
#    consists of a minimal header followed by a list of integer triples. The integer
#    values can be coded in binary (bytes or shorts), or as ASCII decimal numbers
#    (unsigned, >= 0 always). The header indicates the coding in use.
#
#  - PGM data represents a byte- or short-quantized gray image (i.e. it has 1 band). The
#    header is identical to PPM, except in the type indicator up front. The possible
#    encodings for the integer values is the same.
#
#  - The header is always plain text. It consists of type indicator, image width and
#    height, and the possible maximal integer value, in this order. The `maximal value` is
#    a scaling factor in the range 1 to 65535. Values <= 255 indicate bytes for binary
#    coding, otherwise shorts.
#
#  - The format supports #-based single-line comments in the header H which may start
#    __anywhere__ in H. IOW even in the middle of a number.
#
#    This writer does not generate any comments - TODO FUTURE :: use for meta data
#
#    The formats writing encoding the pixel values as text support #-based single-line
#    comments in the pixel data section as well.
#
#  - With this parsing the header can be done in a state machine supporting a single level
#    of stack/context.
#
#  - Whitespace (Space, TAB, VT, CR, LF) is used to terminate all values in the header.
#    Whitespace is also used to terminate text encoded pixel values. Binary coded pixel
#    values on the other hand are __not__ terminated at all.
#
#  - Binary coded data is written in __big endian__ order.
#

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
