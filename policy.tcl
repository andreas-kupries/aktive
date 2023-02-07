# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Fixed command, not generated

namespace eval aktive {
    namespace export version
    namespace ensemble create
}

namespace eval aktive::image::const {
    namespace export for
    namespace ensemble create
}

proc aktive::image::const::for {src v} {
    set g [lrange [aktive query geometry $src] 2 end]
    return [aktive image constant {*}$g $v]
}

# # ## ### ##### ######## ############# #####################
## Math functions for pre-application of operations to constant inputs.
## See op/op.c for the C level runtime equivalents
##
## The functions here are applied during image construction time, as peep-hole constant
## folding

proc ::tcl::mathfunc::aktive_clamp      x { expr {$x < 0 ? 0 : ($x > 1 ? 1 : $x)} }
proc ::tcl::mathfunc::aktive_wrap       x { expr {$x > 1 ? fmod($x, 1) : ($x < 0 ? (1 + fmod($x - 1, 1)) : $x)} }
proc ::tcl::mathfunc::aktive_invert     x { expr {1 - $x} }
proc ::tcl::mathfunc::aktive_neg        x { expr {- $x} }
proc ::tcl::mathfunc::aktive_sign       x { expr {$x < 0 ? 0 : ($x > 0 ? 1 : 0)} }
proc ::tcl::mathfunc::aktive_signb      x { expr {$x < 0 ? -1 : 1} }
proc ::tcl::mathfunc::aktive_reciprocal x { expr {1.0 / $x} }
proc ::tcl::mathfunc::aktive_cbrt       x { expr { pow ($x, 1./3.) } }
proc ::tcl::mathfunc::aktive_exp2       x { expr { pow ( 2, $x) } }
proc ::tcl::mathfunc::aktive_exp10      x { expr { pow (10, $x) } }
proc ::tcl::mathfunc::aktive_log2       x { expr { log($x) / log(2) } }

# # ## ### ##### ######## ############# #####################

return

proc replace {name args newbody} {
    set     ns   [namespace qualifiers $name]
    set     stem [namespace tail $name]
    set     impl aktive::${ns}::I$stem

    append newbody "\n  " $impl { } [concat {*}[lmap a $args { string cat " \$$a"}]]

    rename aktive::$name $impl
    proc ::aktive::$name $args $newbody
}

# # ## ### ##### ######## ############# #####################

replace op::math1::abs src {
    #on src "image::constant" const-for abs
    #on src @self pass

    if {[aktive query type $src] eq "image::constant"} {
puts SHORT
	set v [dict get [aktive query params $src] value]
puts IN:$v
	set v [expr { abs ($v) }]
puts OUT:$v
        return [aktive image const for $src $v]
    }
    if {[aktive query type $src] eq "op::math1::abs"} {
puts IDEM
	return $src
    }

puts CALL
}


rename replace {}
# # ## ### ##### ######## ############# #####################
return

