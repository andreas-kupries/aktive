# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Fixed commands, not generated
#
## Wrap dict commands as meta data modifiers.
## Exceptions: `info`, `update`, and `with`.

namespace eval ::aktive::meta {}

proc ::aktive::meta::K {x y} { return $x }
proc ::aktive::meta::M {i} { aktive query meta $i }

proc ::aktive::meta::exists {src args} { dict exists [M $src] {*}$args }
proc ::aktive::meta::get    {src args} { dict get    [M $src] {*}$args }
proc ::aktive::meta::keys   {src}      { dict keys   [M $src] }
proc ::aktive::meta::size   {src}      { dict size   [M $src] }
proc ::aktive::meta::values {src}      { dict values [M $src] }

proc ::aktive::meta::merge   {src args} { ::set m [M $src]; aktive op meta set [K $src [::unset src]] [dict merge   $m {*}$args] }
proc ::aktive::meta::remove  {src args} { ::set m [M $src]; aktive op meta set [K $src [::unset src]] [dict remove  $m {*}$args] }
proc ::aktive::meta::replace {src args} { ::set m [M $src]; aktive op meta set [K $src [::unset src]] [dict replace $m {*}$args] }

proc ::aktive::meta::for    {src vars body} { uplevel 1 [list dict for $vars [M $src] $body] }
proc ::aktive::meta::map    {src vars body} {
    ::set m [M $src]
    aktive op meta set [K $src [::unset src]] [uplevel 1 [list dict map $vars $m $body]]
}

proc ::aktive::meta::filter {src type args} {
    ::set m [M $src]
    aktive op meta set [K $src [::unset src]] [uplevel 1 [list dict filter $m $type {*}$args]]
}

proc ::aktive::meta::append {src key args} {
    ::set       meta [M $src]
    dict append meta $key {*}$args
    aktive op meta set [K $src [::unset src]] $meta
}

proc ::aktive::meta::incr {src key {increment 1}} {
    ::set     meta [M $src]
    dict incr meta $key $increment
    aktive op meta set [K $src [::unset src]] $meta
}

proc ::aktive::meta::lappend {src key args} {
    ::set        meta [M $src]
    dict lappend meta $key {*}$args
    aktive op meta set [K $src [::unset src]] $meta
}

proc ::aktive::meta::set {src args} {
    ::set    meta [M $src]
    dict set meta {*}$args
    aktive op meta set [K $src [::unset src]] $meta
}

proc ::aktive::meta::unset {src args} {
    ::set      meta [M $src]
    dict unset meta {*}$args
    aktive op meta set [K $src [::unset src]] $meta
}

proc ::aktive::meta::create {src args} {
    aktive op meta set [K $src [::unset src]] [dict create {*}$args]
}

# # ## ### ##### ######## ############# #####################
return

