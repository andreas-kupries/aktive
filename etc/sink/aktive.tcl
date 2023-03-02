## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- AKTIVE format
#
# See op/aktive.c for the format specification.

tcl-operator {
    format::as::aktive::2string
} {
    section sink writer

    note Returns byte array containing the image serialized \
	with the AKTIVE raw format.

    arguments src
    body { aktive::2string $src 2chan }
}

operator {
    format::as::aktive::2chan
} {
    section sink writer

    note Writes image to the DST channel, serialized \
	with the AKTIVE raw format.

    input

    channel dst \
	Channel the image data is written to

    void {
	TRACE ("AKTIVE starting", 0);

	aktive_writer dst;
	aktive_write_channel (&dst, param->dst, 1);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_aktive_sink (&dst), src);
	// Note: The sink self-destroys in its state finalization.
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
