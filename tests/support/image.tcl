# -*- tcl -*-
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands -- Image Matching

customMatch image matchImage

# Force image Tcl representation
proc astcl  {args} { astcl/ [{*}$args] }
proc astcl/ {i}    { aktive format tcl $i }

proc dag {i} {
    lappend r [aktive query type $i]
    foreach c [aktive query inputs $i] { lappend r [dag $c] }
    return $r
}

# Match two lists of numbers to N digits fractional precision
# Assume n > 0
proc matchNdigits {n expected actual} {
    set x 1e-$n
    foreach a $actual e $expected {
        if {abs($e-$a) > $x} {
	    #puts MF|$e|$a|[expr {abs($e-$a)}]|$x|
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
		# strip non numeric elements used to highlight structue (band separation, ...).
		# only used in the expected value, nicer to be symmetric.
		set evalue [lmap v $evalue { if {![string is double $v]} continue ; set v }]
		set avalue [lmap v $avalue { if {![string is double $v]} continue ; set v }]

		if {![matchNdigits 4 $evalue $avalue]} {
		    #puts "image pixels"
		    return 0
		}
	    }
	}
    }

    return 1
}
