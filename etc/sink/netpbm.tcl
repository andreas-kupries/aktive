## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- Netpbm PPM, PGM formats

# critcl::csources ../../op/netpbm.c	;# C-level support code

operator {
    format::as::pgm::text::2file
    format::as::pgm::etext::2file
    format::as::pgm::byte::2file
    format::as::pgm::short::2file
    format::as::ppm::text::2file
    format::as::ppm::etext::2file
    format::as::ppm::byte::2file
    format::as::ppm::short::2file
} {
    op -> _ _ thing variant _

    section sink writer

    note Writes image to the destination file, serialized \
	with [string toupper $thing]'s $variant format.

    input

    str into \
	Destination file the $thing $variant image data is written to.

    body {
	aktive::2file $into $src 2chan
    }
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
    op -> _ _ thing variant _

    section sink writer

    note Writes image to the destination channel, serialized \
	with [string toupper $thing]'s $variant format.

    input

    channel into \
	Destination channel the $thing $variant image data is written to.

    void {
	TRACE ("@@thing@@ starting", 0);

	aktive_uint depth = aktive_image_get_depth (src);
	if (depth != @@bands@@) {
	    TRACE ("band mismatch, have %d, wanted %d", depth, @@bands@@);
	    aktive_failf ("@@thing@@ does not support images with %d bands, expects @@bands@@",
			  depth);
	}

	aktive_writer dst;
	aktive_write_channel (&dst, param->into, 1);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_netpbm_sink (&dst, '@@type@@', @@maxval@@), src);
	// Note: The sink self-destroys in its state finalization.
    }
}

operator {bands type maxval} {
    format::as::pgm::text::2string    1 2	  255
    format::as::pgm::etext::2string   1 2 65535
    format::as::pgm::byte::2string    1 5	  255
    format::as::pgm::short::2string   1 5 65535

    format::as::ppm::text::2string    3 3	  255
    format::as::ppm::etext::2string   3 3 65535
    format::as::ppm::byte::2string    3 6	  255
    format::as::ppm::short::2string   3 6 65535
} {
    op -> _ _ thing variant _

    section sink writer

    note Returns byte array containing the image serialized \
	with [string toupper $thing]'s $variant format.

    input

    return object0 {
	TRACE ("@@thing@@ starting", 0);

	aktive_uint depth = aktive_image_get_depth (src);
	if (depth != @@bands@@) {
	    TRACE ("band mismatch, have %d, wanted %d", depth, @@bands@@);
	    aktive_failf ("@@thing@@ does not support images with %d bands, expects @@bands@@",
			  depth);
	}

	aktive_writer dst;
	Tcl_Obj*      ba = Tcl_NewObj();
	aktive_write_bytearray (&dst, ba);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_netpbm_sink (&dst, '@@type@@', @@maxval@@), src);
	// Note: The sink self-destroys in its state finalization.

	return ba;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
