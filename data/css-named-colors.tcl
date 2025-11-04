# -*- mode: tcl; fill-column: 90 -*-

apply {{} {
    # read color table
    set chan [open data/cssNamedColors.csv r]
    set colors [lrange [split [string trim [read $chan]] \n] 1 end]
    close $chan

    # create database :: dict (name -> list (red green blue))
    foreach color $colors {
	lassign [split $color ,] _ name hex

	set code [expr 0x[string range $hex 1 end]] ;#note: not braced

	set red   [expr {double(($code >> 16) & 0xFF)/255}]
	set green [expr {double(($code >>  8) & 0xFF)/255}]
	set blue  [expr {double(($code >>  0) & 0xFF)/255}]
	set rgb   [list $red $green $blue]

	lappend map "\t    $name\t[list $rgb]"
    }
    set map [join [lsort -dict $map] \n]

    # save database together with its access command

    set   chan [open generated/color.tcl w]
    puts $chan [string map [list "\n\t" "\n" "\n    " "\n" @@@@ $map] {
	proc aktive::color::css {name} {
	    try {
		return [dict get {
	@@@@
		} $name]
	    } on error {e} {
		return -code error "Unknown color '$name', expected a valid CSS color name"
	    }
	}
    }]
    close $chan
    return
}}
