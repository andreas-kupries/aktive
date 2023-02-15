# -*- tcl -*-
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands -- Image Matching

customMatch image   matchImage
customMatch listpix matchPixelLists
customMatch pixels  matchPixels

# Force image Tcl representation
proc astcl  {args} { astcl/ [{*}$args] }
proc astcl/ {i}    { aktive format tcl $i }

proc dag  {args} { dag/ [{*}$args] }
proc dag/ {i} {
    lappend r [aktive query type   $i]
    lappend r [aktive query id     $i]
    lappend r [aktive query params $i]
    foreach c [aktive query inputs $i] { lappend r [dag/ $c] }
    return $r
}

# Match two lists of numbers to N digits fractional precision
# Assume n > 0
proc matchNdigits {n expected actual} {
    set x 1e-$n
    foreach a $actual e $expected {
        if {abs($e-$a) > $x} {
	    #puts MISMATCH-FP$n|$e|$a|[expr {abs($e-$a)}]|$x|
	    return 0
        }
    }
    return 1
}

proc matchDict {expected actual} {
    set ekeys [lsort -dict [dict keys $expected]]
    set akeys [lsort -dict [dict keys $actual]]

    if {$ekeys ne $akeys} {
	#puts "dict keys ($ekeys) ne ($akeys)"
	return 0
    }

    foreach key $akeys {
	set evalue [dict get $expected $key]
	set avalue [dict get $actual   $key]
	if {$evalue ne $avalue} {
	    #puts "dict value ($evalue) ne ($avalue)"
	    return 0
	}
    }
    return 1
}

# Both values have to the in image Tcl representation
proc matchImage {expected actual} {
    set ekeys [lsort -dict [dict keys $expected]]
    set akeys [lsort -dict [dict keys $actual]]

    if {$ekeys ne $akeys} {
	#puts "image keys ($ekeys) != ($akeys)"
	return 0
    }
    foreach key $akeys {
	set evalue [dict get $expected $key]
	set avalue [dict get $actual   $key]
	switch -exact -- $key {
	    type {
		if {$evalue ne $avalue} {
		    #puts "image type"
		    return 0
		}
	    }
	    config - domain {
		if {![matchDict $evalue $avalue]} {
		    #puts "image config"
		    return 0
		}
	    }
	    pixels {
		if {![matchPixels $evalue $avalue]} {
		    #puts "image pixels"
		    return 0
		}
	    }
	}
    }

    return 1
}

proc matchPixelLists {expected actual} {
    if {[llength $expected] != [llength $actual]} { return 0 }

    foreach evalue $expected avalue $actual {
	if {![matchPixels $evalue $avalue]} { return 0 }
    }

    return 1
}

proc matchPixels {expected actual} {
    # strip non numeric elements used to highlight structue (band separation, ...).
    # only used in the expected value, nicer to be symmetric.

    set expected [lmap v $expected { if {![string is double $v]} continue ; set v }]
    set actual   [lmap v $actual   { if {![string is double $v]} continue ; set v }]

    if {[llength $expected] != [llength $actual]} {
	# puts XXXXX\t/[llength $expected]/ne/[llength $actual]/
	return 0
    }

    set ok [matchNdigits 4 $expected $actual]
    #if {!$ok} { puts XXXXX\t/digits }
    return $ok
}
