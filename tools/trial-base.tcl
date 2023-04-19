# -*- tcl -*-
# ------------------------------------------------------------------------------

package require aktive

# ------------------------------------------------------------------------------

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have aktive v[aktive version] / cpu count [aktive processors]"
puts ""

# ------------------------------------------------------------------------------

namespace eval tcltest [list variable testsDirectory $tests]

source [file join $tests support builtin.tcl]
source [file join $tests support image.tcl]
source [file join $tests support match.tcl]
source [file join $tests support files.tcl]
source [file join $tests support paths.tcl]

# ------------------------------------------------------------------------------

proc photo {i {title {}}} {
    set w [topl]
    set n [cid]
    set f ._photo$n

    if {$title ne {}} { wm title $w $title }

    switch -exact -- [aktive query depth $i] {
	1 { append f .pgm ; pgm $f $i }
	3 { append f .ppm ; ppm $f $i }
	default { error UNKNOWN	}
    }

    set p [image create photo p$n -file $f]
    file delete $f

    label $w.l -image $p
    pack  $w.l -expand 1 -fill both -side left
    return
}

proc plot {series {title {}}} {
    package require aktive::plot

    set w [topl]
    set v ::s[cid]

    set $v $series

    if {$title ne {}} {
	wm title $w $title
	set title [list -title $title]
    }

    aktive::plot $w.plot -variable $v -xlocked 0 -ylocked 0 {*}$title
    pack $w.plot -expand 1 -fill both -side left
    return
}

set ::windows 0
set ::counter 0

proc topl {} {
    package require Tk
    wm withdraw .

    global counter windows

    set w .t$counter
    incr counter

    toplevel    $w
    wm protocol $w WM_DELETE_WINDOW [list window-close $w]
    incr windows

    return $w
}

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

    puts "perf: $label ($sz values :: $delta millis :: $vms v/ms :: $msv ms/v"
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



proc showbasic {i} {
    puts "[aktive query type $i] \{"
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

    puts "[format %5d $count] :: $indent$id  [aktive query type $i]"
    set children [aktive query inputs $i]
    if {![llength $children]} {
	puts "      :: ${indent}***"
	return
    }
    foreach x $children { dagc $x "$indent  " }
    puts "      :: ${indent}\\-- $me"
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

    set t  [aktive format as tcl $i]

    puts -nonewline "\n\t= "
    set i 0
    foreach v [dict get $t pixels] {
	if {$i} {
	    if {($i % $pi) == 0} {
		puts -nonewline "\n\t= "
	    } elseif {($i % $d) == 0} {
		puts -nonewline " ="
	    }
	}

	if {$scale ne {}} {
	    set v [expr {$v * $scale}]
	    puts -nonewline " [format %3.0f $v]"
	} else {
	    puts -nonewline " [format %8.4f $v]"
	}
	incr i
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
return
