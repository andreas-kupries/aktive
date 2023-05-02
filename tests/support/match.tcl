# -*- tcl -*-
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands -- Image Matching

# Match two lists of rational numbers to N digits fractional precision
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
	    config - domain - meta {
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

proc clearValues {xs} {
    lmap v $xs { if {![string is double $v]} continue ; set v }
}

proc matchPixels {expected actual} {
    # strip non numeric elements used to highlight structue (band separation, ...).
    # only used in the expected value, nicer to be symmetric.

    set expected [clearValues $expected]
    set actual   [clearValues $actual]

    if {[llength $expected] != [llength $actual]} {
	# puts XXXXX\t/[llength $expected]/ne/[llength $actual]/
	return 0
    }

    set ok [matchNdigits 4 $expected $actual]
    #if {!$ok} { puts XXXXX\t/digits }
    return $ok
}

proc matchFileContent {expected actual} {
    string equal [cat $expected] [cat $actual]
}

proc matchFileContentString {expected actual} {
    string equal [cat $expected] $actual
}

proc match4 {expected actual} {
  matchNdigits 4 $expected $actual
}

proc match3 {expected actual} {
  matchNdigits 3 $expected $actual
}

##
# # ## ### ##### ######## ############# #####################
return
