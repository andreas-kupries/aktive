# -*- tcl -*-
# ------------------------------------------------------------------------------

package require aktive

# ------------------------------------------------------------------------------

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have   aktive v[aktive version] / cpu count [aktive processors]"
puts "shell  [info nameofexecutable]"
puts "script $argv0"
puts ""

# ------------------------------------------------------------------------------

namespace eval tcltest [list variable testsDirectory $tests]

source [file join $tests support builtin.tcl]
source [file join $tests support image.tcl]
source [file join $tests support match.tcl]
source [file join $tests support files.tcl]
source [file join $tests support paths.tcl]

# ------------------------------------------------------------------------------

proc pvs {is args} {
    set itail [lassign $is   ifirst]
    set ntail [lassign $args nfirst]
    pv $ifirst $nfirst
    foreach n $ntail i $itail { pv+ $i $n }
    return
}

proc pv {i {title {}}} {
    package require aktive::tk
    view-core [topl] $i $title
}

proc pv+ {i {title {}}} {
    package require aktive::tk
    view-core $::top $i $title
}

proc view-core {w i title} {
    global photo
    set photo [aktive tk photo $i]
    set n [nxt]
    frame $w.f$n
    label $w.f$n.t -text  $title ; pack $w.f$n.t -fill both -side top
    label $w.f$n.p -image $photo ; pack $w.f$n.p -fill both -side top -expand 1
    pack  $w.f$n -fill both -side left -expand 1
    # allow chaining
    return $i
}

proc plot {series {title {}}} {
    package require aktive::plot
    plot-core [topl] $series $title
    return
}

proc plot+ {series {title {}}} {
    package require aktive::plot
    plot-core $::top $series $title
    return
}

proc plot-core {w series title} {
    set v ::s[nxt]
    set $v $series

    if {$title ne {}} { set title [list -title $title] }
    set n [cid]
    aktive::plot $w.plot$n -variable $v -xlocked 0 -ylocked 0 {*}$title
    pack         $w.plot$n -expand 1 -fill both -side left
    return
}

set ::windows 0  ;# number of open windows
set ::counter 0  ;# id counter for windows, photos, labels, etc.
set ::photo   {} ;# last loaded photo for dislay
set ::top     {} ;# last new toplevel

proc topl {{title {}}} {
    package require Tk
    wm withdraw .

    global windows top

    set top .t[nxt]
    toplevel    $top
    wm protocol $top WM_DELETE_WINDOW [list window-close $top]
    incr windows

    if {$title ne {}} { wm title $top $title }
    return $top
}

proc nxt {} { global counter ; incr counter ; return $counter }
proc cid {} { global counter ; return $counter }

proc window-close {w} {
    global windows
    destroy $w
    incr windows -1
    return
}

proc wait-on-windows {} {
    global windows
    while {$windows} { puts windows=$windows ; vwait ::windows }
    return
}

rename exit __exit
proc   exit {args} { wait-on-windows ; __exit {*}$args }

# ------------------------------------------------------------------------------

proc perf {label sz args} {
    set base [clock milliseconds]

    set r [uplevel 1 $args]

    set delta [expr {[clock milliseconds] - $base}]

    set vms [expr {double($sz) / double ($delta)}]
    set msv [expr {double ($delta) / double($sz)}]

    puts "perf: $label ($sz values) :: $delta millis :: $vms v/ms :: $msv ms/v"
    return $r
}

proc to {path g args} {
    puts "writing to $path"
    set dst [open $path w]
    lappend args 2chan $g into $dst
    uplevel 1 $args
    close $dst
}

proc null       {src} { aktive format as null   2string $src }
proc nulls      {src} { aktive format as null-s 2string $src }
proc ppm   {path src} { to $path $src aktive format as ppm byte }
proc pgm   {path src} { to $path $src aktive format as pgm byte }
proc ppm16 {path src} { to $path $src aktive format as ppm short }
proc pgm16 {path src} { to $path $src aktive format as pgm short }
proc ppmt  {path src} { to $path $src aktive format as ppm text }
proc pgmt  {path src} { to $path $src aktive format as pgm text }
proc ppmet {path src} { to $path $src aktive format as ppm etext }
proc pgmet {path src} { to $path $src aktive format as pgm etext }
proc akt   {path src} { to $path $src aktive format as aktive }
proc ppms  {src} { aktive format as ppm text 2string $src }
proc pgms  {src} { aktive format as pgm text 2string $src }
proc akts  {src} { aktive format as aktive   2string $src }

proc rgb {r g b} { aktive op montage z $r $g $b }

proc graybig  {} { aktive image gradient width 256 height 256 depth 1 first 0 last 1 }
proc colorbig {} { set r [graybig] ; rgb $r [aktive op rotate cw $r] [aktive op rotate half $r] }
proc sines {} { rgb \
		    [aktive image sines width 256 height 256 hf 0.3 vf 0.4] \
		    [aktive image sines width 256 height 256 hf 2   vf 0.5] \
		    [aktive image sines width 256 height 256 hf 1   vf 3] }

proc dots {i} {
    set i [aktive op upsample xrep $i by 8]
    set i [aktive op upsample yrep $i by 8]
    return $i
}

proc showbasic {label i} {
    puts "$label = [aktive query type $i] \{"
    puts "  pa ([aktive query params $i])"
    puts "  x,y [aktive query x $i]..[aktive query xmax $i],[aktive query y $i]..[aktive query ymax $i]"
    puts "  whd [set w [aktive query width $i]] x [set h [aktive query height $i]] x [set d [aktive query depth  $i]]"
    puts "\}"
    flush stdout
}

proc dag {i} { set count 0 ; set have {} ; dagc $i }
proc dagc {i {indent {}}} {
    upvar 1 have have count count
    set id [aktive query id $i]
    if {[dict exists $have $id]} { puts "      :: ${indent}---> [dict get $have $id]" ; return }
    incr count ; set me $count
    dict set have $id $count

    puts "[format %5d $count] :: $indent$id  [aktive query type $i] ([aktive query params $i])"
    set children [aktive query inputs $i]
    if {![llength $children]} {
	puts "      :: ${indent}***"
	return
    }
    foreach x $children { dagc $x "$indent  " }
    puts "      :: ${indent}\\-- $me"
}

proc insn {i} {
    upvar 1 have have count count

    set id [aktive query id $i]
    if {![info exists have] || ![dict exists $have $id]} {
	set cids [join [lmap child [aktive query inputs $i] {
	    string cat "\$i" [insn $child]
	}] { }]
	if {$cids ne {}} { set cids " $cids" }

	set pa [aktive query params $i]
	if {$pa ne {}} { set pa " $pa" }

	set op [string map {:: { }} [aktive query type $i]]

	incr count
	puts "set [format %6s i$count] \[aktive $op$cids$pa\]"

	dict set have $id $count
    }

    return [dict get $have $id]
}

proc show {i {scale {}}} {
    puts "[aktive query type $i] \{"
    puts "  pa ([aktive query params $i])"
    if 0 {foreach x [aktive query inputs $i] {
	set x [aktive format as tcl $x]
	dict unset x pixels
	puts "  in ($x)"
    }}
    flush stdout
    puts "  x,y [aktive query x $i]..[aktive query xmax $i],[aktive query y $i]..[aktive query ymax $i]"
    puts "  whd [set w [aktive query width  $i]] x [set h [aktive query height $i]] x [set d [aktive query depth  $i]]"
    flush stdout

    set pi [aktive query pitch  $i]
    puts "  pi  $pi"

    puts -nonewline "\n\t= "
    set k 0
    foreach v [aktive query values $i] {
	if {$k} {
	    if {($k % $pi) == 0} {
		puts -nonewline "\n\t= "
	    } elseif {($k % $d) == 0} {
		puts -nonewline " ="
	    }
	}

	if {$scale ne {}} {
	    set v [expr {$v * $scale}]
	    puts -nonewline " [format %3.0f $v]"
	} else {
	    puts -nonewline " [format %8.4f $v]"
	}
	incr k
    }
    puts ""
    flush stdout
    puts "\}"
    puts ""
}

# ------------------------------------------------------------------------------

proc a {args} {
    global stack
    lappend stack [aktive {*}$args]
    return [lindex $stack end]
}

proc top {} { global stack ; lindex $stack end }
proc pop {} {
    global stack
    set top [lindex $stack end]
    set stack [lreplace $stack end end]
    return $top
}

proc / {label} {}

# ------------------------------------------------------------------------------
## validate memory, if supported by the interpreter

catch { memory validate on }

# ------------------------------------------------------------------------------
return
