# -*- tcl -*-
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands -- Image Matching

proc 4f  {xs} { lmap x $xs { format %.4f $x }}
proc u8f {xs} { lmap x $xs { expr { $x / 255. } } }
proc fu8 {xs} { lmap x $xs { expr { int ($x * 255.) } } }

# Run image operation. Record operation (coverage)

proc check {args} {
    if {[info exists ::suite-command-coverage]} {if {[lindex $args 0] eq "aktive"} {
	set ws [lmap w $args { skiparg $w ; set w }]
	puts "AKTIVE [join $ws ::]"
    }}
    {*}$args
}

proc skiparg {w} {
    if {$w eq "<aktive::image>"}    { return -code break    } ;# images are followed by more images and parameters
    if {$w in {
	width height delta points path
    }}                              { return -code break } ;# *::from parameters
    if {$w eq "X"}                  { return -code continue }
    if {$w eq "FOO"}                { return -code continue }
    if {[string match file*    $w]} { return -code continue }
    if {[string match *assets* $w]} { return -code continue }
    if {[numbers $w]}               { return -code continue }
    return
}

proc numbers {w} {
    if {[string is double $w]} { return 1 }
    foreach x $w { if {![string is double $x]} { return 0 } }
    return 1
}

# Save to file
proc save-to {path image args} {
    set path [file join [td] $path]
    # args = format command - extend
    lappend args 2file $image into $path
    uplevel 1 [linsert $args 0 check]
    return $path
}

# Get image Tcl representation

proc astcl  {args} { astcl/ [check {*}$args] }
proc astcl/ {i}    {
    set x [aktive format as tcl $i]
    #puts //$x//
    return $x
}

proc aspgm  {args} { aspgm/ [check {*}$args] }
proc aspgm/ {i}    { aktive format as pgm byte 2string $i }

proc asppm  {args} { asppm/ [check {*}$args] }
proc asppm/ {i}    { aktive format as ppm byte 2string $i }

proc save-pgm  {path args} { save-pgm/ $path [check {*}$args] }
proc save-pgm/ {path i}    { save-to $path $i aktive format as pgm byte }

proc save-aktive  {path args} { save-aktive/ $path [check {*}$args] }
proc save-aktive/ {path i}    { save-to $path $i aktive format as aktive }

# Get image input graph

proc dag  {args} { dag/ [{*}$args] }
proc dag/ {i} {
    lappend r [aktive query type   $i]
    lappend r [aktive query id     $i]
    lappend r [aktive query params $i]
    foreach c [aktive query inputs $i] { lappend r [dag/ $c] }
    return $r
}

proc dag+  {args} { dag+/ [{*}$args] }
proc dag+/ {i} {
    lappend r [aktive query type     $i]
    lappend r [aktive query id       $i]
    lappend r [aktive query geometry $i]
    lappend r [aktive query params   $i]
    foreach c [aktive query inputs   $i] { lappend r [dag+/ $c] }
    return $r
}

# Just the pixels

proc pixels  {args} { pixels/ [{*}$args] }
proc pixels/ {i} { aktive query values $i }

# Just the meta data

proc meta  {args} { meta/ [{*}$args] }
proc meta/ {i} { aktive query meta $i }

proc m {x y i} { aktive op location move to $i x $x y $y }

proc bw {x} { string map {_ 0 * 1} $x }

# Construct image in tcl representation for comparisons
proc makei {op x y w h d config pixels {meta {}}} {
    dict set domain x      $x
    dict set domain y      $y
    dict set domain width  $w
    dict set domain height $h
    dict set domain depth  $d

    dict set i type   $op
    dict set i domain $domain
    if {$meta   ne {}} { dict set i meta   $meta }
    if {$config ne {}} { dict set i config $config }
    dict set i pixels $pixels

    return $i
}

proc slice-row {row w h d pixels} {
    set pixels [lmap v $pixels { if {![string is double $v]} continue ; set v }]

    set w [expr {$w * $d}]
    while {[llength $pixels]} {
	lappend rows [lrange   $pixels 0 ${w}-1]
	set pixels   [lreplace $pixels 0 ${w}-1]
    }
    return [lindex $rows $row]
}

proc slice-col {col w h d pixels} {
    set pixels [lmap v $pixels { if {![string is double $v]} continue ; set v }]

    set w [expr {$w * $d}]
    while {[llength $pixels]} {
	lappend rows [lrange   $pixels 0 ${w}-1]
	set pixels   [lreplace $pixels 0 ${w}-1]
    }

    set col [expr {$col*$d}]
    set next $col ; incr next $d ; incr next -1

    return [concat {*}[lmap r $rows {
	lrange $r $col $next
    }]]
}

proc slice-band {band w h d pixels} {
    set pixels [lmap v $pixels { if {![string is double $v]} continue ; set v }]

    set w [expr {$w * $d}]
    while {[llength $pixels]} {
	lappend rows [lrange   $pixels 0 ${w}-1]
	set pixels   [lreplace $pixels 0 ${w}-1]
    }

    set rows [lmap r $rows {
	set cols {}
	while {[llength $r]} {
	    lappend cols [lrange   $r 0 ${d}-1]
	    set r        [lreplace $r 0 ${d}-1]
	}
	set cols
    }]

    set res {}
    foreach cs $rows {
	foreach c $cs {
	    lappend res [lindex $c $band]
	}
    }

    return $res
}

##
# # ## ### ##### ######## ############# #####################
return
