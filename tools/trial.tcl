#!/home/aku/opt/ActiveTcl/bin/tclsh

package require aktive

# ------------------------------------------------------------------------------

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have aktive v[aktive version]"
puts ""

# ------------------------------------------------------------------------------

proc to {path g args} {
    puts "writing to $path"
    set dst [open $path w]
    uplevel 1 [linsert $args end 2chan $dst $g]
    close $dst
}

proc rgb {r g b} { aktive op montage z $r [aktive op montage z $g $b] }
proc grad  {} { aktive image gradient 3 4 2  1 12.5 }
proc gradx {} { aktive image gradient 20 1 1  0 19 }
proc grady {} { aktive image gradient 1 20 1  0 19 }
proc gradz {} { aktive image gradient 1 1 20  0 19 }
proc graybox  {} { aktive image gradient 8 8 1 0 1 }
proc colorbox {} { set r [graybox] ; rgb $r [aktive op rotate cw $r] [aktive op rotate half $r] }

proc showbasic {i} {
    puts "[aktive query type $i] \{"
    puts "  pa ([aktive query params $i])"
    puts "  x,y [aktive query x $i]..[aktive query xmax $i],[aktive query y $i]..[aktive query ymax $i]"
    puts "  whd [set w [aktive query width  $i]] x [set h [aktive query height $i]] x [set d [aktive query depth  $i]]"
    puts "\}"
    flush stdout
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
	puts -nonewline " [format %6.4f $v]"
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
