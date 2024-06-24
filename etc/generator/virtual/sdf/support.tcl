## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- signed distance fields
##
## Core definitions shared between SDF and drawing ops.

global __sdf
set    __sdf {}

proc sdf-known {{prefix {}} {suffix {}}} {
    global __sdf
    lmap sdf [dict keys $__sdf] { string cat $prefix $sdf $suffix }
}

proc sdf-def {name {label {}}} {
    if {$label eq {}} { set label $name }
    global   __sdf
    dict set __sdf $name $label
}

proc sdf-label {name} {
    global    __sdf
    dict get $__sdf $name
}

##
# # ## ### ##### ######## ############# #####################
::return
