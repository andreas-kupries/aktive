proc cc.max {ccs} {
    # keep only the max sized cc's
    # find max
    set maxarea -1
    dict for {id spec} $ccs {
	set a [dict get $spec area]
	if {$a < $maxarea} continue
	set maxarea $a
    }
    # extract max
    set single {}
    dict for {id spec} $ccs {
	if {[dict get $spec area] < $maxarea} continue
	set single $id
	dict set new $id $spec
    }
    # relabel if single
    if {([dict size $new] == 1) && ($single != 1)} {
	dict set new 1 [dict get $new $single]
	dict unset new $single
    }
    # done
    return $new
}
proc cc.norm {ccs} {
    # convert the ccs dict into a standard form we can compare to.
    set norm {}
    foreach id [lsort -dict [dict keys $ccs]] {
	set spec [dict get $ccs $id]
	set new {}
	foreach el [lsort -dict [dict keys $spec]] {
	    set val [dict get $spec $el]
	    switch -exact -- $el {
		parts   { set val [lsort -dict $val] }
		default {}
	    }
	    lappend new $el $val
	}
	lappend norm $id $new
    }
    return $norm
}
proc cc.pretty {ccs} {
    # convert the ccs dict into a prettily formatted standard form,
    # easy to compare also expects a html table context inside a
    # markdown table => br instead of new-lines, and non-breaking
    # spaces for indenting
    set norm {}
    foreach id [lsort -dict [dict keys $ccs]] {
	lappend norm "$id[s]\{"
	set spec [dict get $ccs $id]
	foreach el [lsort -dict [dict keys $spec]] {
	    set val [dict get $spec $el]
	    switch -exact -- $el {
		parts   {
		    lappend norm "[s 4]parts[s]\{"
		    set line ""
		    foreach range [lsort -dict $val] {
			append line "[s][list $range]"
			if {[string length $line] < 60} continue
			lappend norm "[s 7]$line"
			set line ""
		    }
		    if {$line ne ""} {
			lappend norm "[s 7]$line"
		    }
		    lappend norm "[s 4]\}"
		}
		default {
		    lappend norm "[s 4]$el[s][list $val]"
		}
	    }
	}


	lappend norm "\}"
    }
    return [join $norm "<br/>"]
}
proc s {{n 1}} { string repeat "&nbsp;" $n }
#
# show commands
#
proc domain        {x}   { aktive query domain $x }
proc meta-of       {x}   { aktive query meta $x }
proc sdf-fit       {x}   { aktive op sdf 2image fit       $x }
proc sdf-smooth    {x}   { aktive op sdf 2image smooth    $x }
proc sdf-pixelated {x}   { aktive op sdf 2image pixelated $x }
proc height-times  {n x} { aktive op sample replicate y  $x by $n }
proc width-times   {n x} { aktive op sample replicate x  $x by $n }
proc times         {n x} { aktive op sample replicate xy $x by $n }
#
# asset access
#
proc butterfly {} { aktive read from netpbm path tests/assets/butterfly.ppm }
proc sines     {} { aktive read from netpbm path tests/assets/sines.ppm }
proc scancrop  {} { aktive read from netpbm path tests/assets/crop.pgm }
#
# place overlays on images, dot/line/poly, red/green/blue - also show cmds!
#
proc bframe {x} { poly red   {{0 0} {379 0} {379 249} {0 249} {0 0}} $x }
proc sframe {x} { poly green {{0 0} {0 255} {255 255} {255 0} {0 0}} $x }
proc oframe {w h x} {
    poly green [list {0 0} [list 0 $h] [list $w $h] [list $w 0] {0 0}] $x
}
#
proc dot {color p i} {
    lassign [aktive query geometry $i] _ _ w h d
    aktive op draw circle on $i color [$color $d] radius 5 center $p
}
proc line {color a b i} {
    lassign [aktive query geometry $i] _ _ w h d
    aktive op draw line on $i color [$color $d] from $a to $b
}
proc poly {color ps i} {
    lassign [aktive query geometry $i] _ _ w h d
    aktive op draw polyline on $i color [$color $d] points {*}$ps
}
proc red   {d} { dict get { 1 1 3 {1 0 0} } $d }
proc green {d} { dict get { 1 1 3 {0 1 0} } $d }
proc blue  {d} { dict get { 1 1 3 {0 0 1} } $d }

## ### ##### ######## ############# #####################
# #
##
# type specific result writers
#
proc emit-text {dst int src} {
    lappend map * \\*
    lappend map "\\n" "\\\\n"
    lappend map \n "<br>&nbsp;"
    fileutil::writeFile $dst "&nbsp;[string map $map [string trim $src]]"
    # debug
    puts |[join [split [fileutil::cat $dst] \n] "|\n|"]|
    return
}
proc emit-image {dst int src} {
    set depth  [aktive query depth $src]
    set format [dict get {3 ppm 1 pgm} $depth]
    close      [file tempfile tmp aktive-example]
    aktive format as $format byte 2file $src into $tmp
    exec convert $tmp $dst
    # save geometry as well
    fileutil::writeFile ${dst}.txt "geometry([string trim [aktive query geometry $src]])"
    file delete  $tmp
    return
}
proc emit-matrix {dst int src} {
    set chan   [open $dst w]
    set width  [aktive query width  $src]
    set values [aktive query values $src]
    switch -exact -- $int {
	0 {
	    # limited decimals
	    set values [lmap v $values { format %.4f $v }]
	}
	1 {
	    # no decimals
	    set values [lmap v $values { format %.0f $v }]
	}
	2 {
	    # all the decimals
	}
    }
    # aggregate bands into cells, if needed
    set depth [aktive query depth $src]
    if {$depth > 1} {
	set cells {}
	while {[llength $values]} {
	    lappend cells ([join [lrange $values 0 ${depth}-1] {, }])
	    set values [lrange $values $depth end]
	}
	set values $cells
    }

    # emit data
    puts -nonewline $chan <table>
    while {[llength $values]} {
	puts -nonewline $chan <tr>
	puts -nonewline $chan <td>[join [lrange $values 0 ${width}-1] </td><td>]</td>
	set values [lrange $values $width end]
	puts -nonewline $chan </tr>
    }
    puts -nonewline $chan </table>
    puts  $chan ""
    close $chan
    # debug
    puts |[join [split [fileutil::cat $dst] \n] "|\n|"]|
}
