## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- AKTIVE format

# critcl::csources ../../op/aktive.c	;# C-level support code

operator {dendian} {
    format::as::aktive::2file    /LE
    format::as::aktive-be::2file /BE
} {
    section sink writer

    note Writes image to the destination file, \
	serialized with the \[AKTIVE${dendian}\](ff-aktive.md) format.

    input

    strict single \
	The computed pixels are not materialized. \
	They are immediately saved to the destination file.

    str into \
	Destination file the image data is written to.

    body {
	aktive::2file $into $src 2chan
    }
}

operator {endian dendian} {
    format::as::aktive::2chan    le /LE
    format::as::aktive-be::2chan be /BE
} {
    section sink writer

    note Writes image to the DST channel, \
	serialized with the \[AKTIVE$dendian\](ff-aktive.md) format.

    input

    strict single \
	The computed pixels are not materialized. \
	They are immediately saved to the destination channel.

    channel into \
	Destination channel the image data is written to

    void {
	TRACE ("AKTIVE starting", 0);

	aktive_writer dst;
	aktive_write_channel (&dst, param->into, 1);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_aktive_@@endian@@_sink (&dst), src);
	// Note: The sink self-destroys in its state finalization.
    }
}

operator {endian dendian} {
    format::as::aktive::2string    le /LE
    format::as::aktive-be::2string be /BE
} {
    section sink writer

    note Returns byte array containing the image, \
	serialized with the \[AKTIVE${dendian}\](ff-aktive.md) format.

    input

    strict single \
	The computed pixels __are__ materialized into the returned string.

    return object0 {
	TRACE ("AKTIVE starting", 0);

	aktive_writer dst;
	Tcl_Obj*      ba = Tcl_NewObj();
	aktive_write_bytearray (&dst, ba);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_aktive_@@endian@@_sink (&dst), src);
	// Note: The sink self-destroys in its state finalization.

	return ba;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
