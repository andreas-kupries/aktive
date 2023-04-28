## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Meta data changes

# # ## ### ##### ######## ############# #####################
## Core operator for setting new meta data into an image.

operator op::meta::set {
    section transform metadata
    external!

    note Returns input with specified meta data replacing the old.

    image  src  Input to modify
    object meta	New meta data dictionary replacing the input's.
}

# # ## ### ##### ######## ############# #####################
## Dict wrapper operators

operator {imgresult} {
    meta::append  1
    meta::create  1
    meta::exists  0
    meta::filter  1
    meta::for     0
    meta::get     0
    meta::incr    1
    meta::info    0
    meta::keys    0
    meta::lappend 1
    meta::map     1
    meta::merge   1
    meta::remove  1
    meta::replace 1
    meta::set     1
    meta::size    0
    meta::unset   1
    meta::values  0
} {
    external!

    ::set method [lindex [split $__op :] 2]

    note Wraps the dict method \"$method\" for image meta data management.

    if {$imgresult} {
	note Returns input with meta data dictionary modified by application of \"dict $method\"

	section transform metadata
	image  src Input to modify

    } else {
	note Returns result of \"dict $method\" applied to the input's meta data dictionary

	section accessor metadata
	image  src Input queried
    }

    str... args  Dict command arguments, except for dict value or variable.
}

##
# # ## ### ##### ######## ############# #####################
::return
