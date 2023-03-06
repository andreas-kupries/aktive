## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- NULL format - IOW the equivalent of /dev/null

# critcl::csources ../../op/null.c	;# C-level support code

operator sequential {
    format::as::null::2string    0
    format::as::null-s::2string  1
} {
    def slabel [dict get {
	0 out-of-order
	1 in-order
    } $sequential]

    section sink writer

    note Returns nothing, while triggering full pixel calculation for the input.

    input

    void {
	TRACE ("NULL @@slabel@@ starting", 0);

	TRACE ("create and execute sink", 0);
	aktive_sink_run (aktive_null_sink (@@sequential@@), src);
	// Note: The sink self-destroys in its state finalization.
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
