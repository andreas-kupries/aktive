## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sink -- Tcl structures, materialized

operator format::as::tcl {
    # As written technically a getter, as the operator has a return value

    note Sink. Serializes image to readable Tcl structures (dict with flat pixel list)

    input

    return object0 { aktive_op_astcl (ip, src); }
}

##
# # ## ### ##### ######## ############# #####################
::return
