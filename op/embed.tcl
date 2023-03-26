# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Common support for embed operators

namespace eval aktive::op::embed {}

proc aktive::op::embed::Check {} {
    upvar 1 left left right right top top bottom bottom

    if {($left   < 0) ||
	($right  < 0) ||
	($top    < 0) ||
	($bottom < 0)} {
	aktive error "Unable to crop image with embed" EMBED
    }

    if {($left   == 0) &&
	($right  == 0) &&
	($top    == 0) &&
	($bottom == 0)} {
	upvar 1 src src
	return -code return $src
    }

    return
}

proc aktive::op::embed::Count {border tilesize} {
    set part   [expr {$border % $tilesize}]	;# partial tile ?
    set border [expr {$border / $tilesize}]	;# full tiles fitting in the border
    if {$part} { incr border }

    list $part $border
}

proc aktive::op::embed::Directions {tiles} {
    if {!$tiles} { return {} }
    # assert: tiles > 0
    set inverted 1
    while {$tiles} {
	lappend dirs $inverted
	set inverted [expr {!$inverted}]
	incr tiles -1
    }
    return $dirs
}

proc aktive::op::embed::Tiles {dirs op src} {
    set isrc [aktive op flip $op $src]

    return [aktive op montage $op \
		{*}[lmap inverted $dirs {
		    expr {$inverted ? $isrc : $src}
		}]]
}

proc aktive::op::embed::Crop {lpart rpart tpart bpart w h src} {

    set left   [expr {($lpart > 0) ? ($w - $lpart) : 0}]
    set right  [expr {($rpart > 0) ? ($w - $rpart) : 0}]
    set top    [expr {($tpart > 0) ? ($h - $tpart) : 0}]
    set bottom [expr {($bpart > 0) ? ($h - $bpart) : 0}]

    return [aktive op crop $src left $left right $right top $top bottom $bottom]
}

# # ## ### ##### ######## ############# #####################
return

