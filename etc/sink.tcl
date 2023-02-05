## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
## Image sinks

## # # ## ### ##### ######## ############# #####################

operator format::tcl {
    # As written technically a getter, as the operator has a return value

    note Sink. Serializes image to readable Tcl structures (dict with flat pixel list)

    input ignore

    return object0 { aktive_op_astcl (ip, src); }
}

##
## # # ## ### ##### ######## ############# #####################
::return
