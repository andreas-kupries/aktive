## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- AKTIVE format

# critcl::csources ../../op/aktive.c	;# C-level support code

operator {
    format::as::aktive::2file
} {
    section sink writer

    note Writes image to the destination file, serialized \
	with the AKTIVE format.

    input

    str into \
	Destination file the image data is written to.

    body {
	aktive::2file $into $src 2chan
    }
}

operator {
    format::as::aktive::2chan
} {
    section sink writer

    note Writes image to the DST channel, serialized \
	with the AKTIVE raw format.

    input

    channel into \
	Destination channel the image data is written to

    void {
	TRACE ("AKTIVE starting", 0);

	aktive_writer dst;
	aktive_write_channel (&dst, param->into, 1);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_aktive_sink (&dst), src);
	// Note: The sink self-destroys in its state finalization.
    }
}

operator {
    format::as::aktive::2string
} {
    section sink writer

    note Returns byte array containing the image serialized \
	with the AKTIVE raw format.

    input

    return object0 {
	TRACE ("AKTIVE starting", 0);

	aktive_writer dst;
	Tcl_Obj*      ba = Tcl_NewObj();
	aktive_write_bytearray (&dst, ba);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_aktive_sink (&dst), src);
	// Note: The sink self-destroys in its state finalization.

	return ba;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
