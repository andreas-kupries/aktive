## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- Netpbm PPM, PGM formats

# critcl::csources ../../op/netpbm.c	;# C-level support code

tcl-operator {
    format::as::pgm::text::2string
    format::as::pgm::etext::2string
    format::as::pgm::byte::2string
    format::as::pgm::short::2string
    format::as::ppm::text::2string
    format::as::ppm::etext::2string
    format::as::ppm::byte::2string
    format::as::ppm::short::2string
} {
    def thing	[set thing   [lindex [split $__op :] 4]]
    def variant [set variant [lindex [split $__op :] 6]]

    section sink writer

    note Returns byte array containing the image serialized \
	with [string toupper $thing]'s $variant format.

    arguments src
    body { aktive::2string $src 2chan }
}

operator {bands type maxval} {
    format::as::pgm::text::2chan    1 2	  255
    format::as::pgm::etext::2chan   1 2 65535
    format::as::pgm::byte::2chan    1 5	  255
    format::as::pgm::short::2chan   1 5 65535

    format::as::ppm::text::2chan    3 3	  255
    format::as::ppm::etext::2chan   3 3 65535
    format::as::ppm::byte::2chan    3 6	  255
    format::as::ppm::short::2chan   3 6 65535
} {
    def thing	[set thing   [lindex [split $__op :] 4]]
    def variant [set variant [lindex [split $__op :] 6]]

    section sink writer

    note Writes image to the DST channel, serialized \
	with [string toupper $thing]'s $variant format.

    input

    channel dst \
	Channel the $thing $variant image data is written to.

    void {
	TRACE ("@@thing@@ starting", 0);

	aktive_uint depth = aktive_image_get_depth (src);
	if (depth != @@bands@@) {
	    TRACE ("band mismatch, have %d, wanted %d", depth, @@bands@@);
	    aktive_failf ("@@thing@@ does not support images with %d bands, expects @@bands@@",
			  depth);
	}

	aktive_writer dst;
	aktive_write_channel (&dst, param->dst, 1);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_netpbm_sink (&dst, '@@type@@', @@maxval@@), src);
	// Note: The sink self-destroys in its state finalization.
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
