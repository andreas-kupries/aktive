## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- NULL format - IOW the equivalent of /dev/null
#
# See op/null.c for the supporting code

operator {
    format::as::null::2string
} {
    section sink writer

    note Returns nothing, while triggering full pixel calculation for the input.

    input

    void {
	TRACE ("NULL starting", 0);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_null_sink (), src);
	// Note: The sink self-destroys in its state finalization.
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
