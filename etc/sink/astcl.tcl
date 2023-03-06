## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sink -- Tcl structures, materialized

# critcl::csources ../../op/astcl.c	;# C-level support code

operator format::as::tcl {
    # As written technically a getter, as the operator has a return value

    section sink writer

    note Returns string containing the image serialized \
	into readable Tcl structures. Dictionary with flat pixel list.

    input

    return object0 {
	Tcl_Obj* r = aktive_op_astcl (ip, src);
	return r;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
