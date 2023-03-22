#!/home/aku/opt/ActiveTcl/bin/tclsh

package require aktive

# ------------------------------------------------------------------------------

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have aktive v[aktive version] / cpu count [aktive processors]"
puts ""

# ------------------------------------------------------------------------------

set top   [file dirname [file dirname [file normalize [info script]]]]
set tests [file join $top tests]

namespace eval tcltest [list variable testsDirectory $tests]

source [file join $tests support builtin.tcl]
source [file join $tests support image.tcl]
source [file join $tests support match.tcl]
source [file join $tests support files.tcl]
source [file join $tests support paths.tcl]

# ------------------------------------------------------------------------------

proc to {path g args} {
    puts "writing to $path"
    set dst [open $path w]
    uplevel 1 [linsert $args end 2chan $dst $g]
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

proc rgb {r g b} { aktive op montage z $r [aktive op montage z $g $b] }

proc graybig  {} { aktive image gradient 256 256 1 0 1 }
proc colorbig {} { set r [graybig] ; rgb $r [aktive op rotate cw $r] [aktive op rotate half $r] }
proc sines {} { rgb [aktive image sines 256 256 0.3 0.4] [aktive image sines 256 256 2 0.5] [aktive image sines 256 256 1 3] }

proc showbasic {i} {
    puts "[aktive query type $i] \{"
    puts "  pa ([aktive query params $i])"
    puts "  x,y [aktive query x $i]..[aktive query xmax $i],[aktive query y $i]..[aktive query ymax $i]"
    puts "  whd [set w [aktive query width  $i]] x [set h [aktive query height $i]] x [set d [aktive query depth  $i]]"
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

proc show {i} {
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
	puts -nonewline " [format %8.4f $v]"
	incr i
    }
    puts ""
    flush stdout
    puts "\}"
    puts ""
}

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

exit
