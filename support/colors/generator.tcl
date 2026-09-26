# -*- mode: tcl; fill-column: 90 -*-

apply {{} {
    # read color table
    set chan   [open support/colors/spec.csv r]
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
	lappend shades $name

    }
    set map    [join [lsort -dict $map] \n]
    set shades [lsort -dict $shades]

    # embed database into its accessor commands, and save
    lappend xmap "\n\t" "\n"
    lappend xmap "\n    " "\n"
    lappend xmap @@@@   $map
    lappend xmap @names $shades

    set   chan [open generated/color.tcl w]
    puts $chan [string map $xmap {
	proc aktive::color::css {name} {
	    try {
		return [dict get {
	@@@@
		} $name]
	    } on error {e} {
		return -code error "Unknown color '$name', expected a valid CSS color name"
	    }
	}
	proc aktive::color::css-names {} {
	    return {@names}
	}
    }]
    close $chan
    return
}}
