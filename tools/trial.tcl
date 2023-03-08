#!/home/aku/opt/ActiveTcl/bin/tclsh

package require aktive

# ------------------------------------------------------------------------------

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have aktive v[aktive version] / cpu count [aktive processors]"
puts ""

# ------------------------------------------------------------------------------

proc to {path g args} {
    puts "writing to $path"
    set dst [open $path w]
    uplevel 1 [linsert $args end 2chan $dst $g]
    close $dst
}

proc null      {src} { aktive format as null   2string $src }
proc nulls     {src} { aktive format as null-s 2string $src }
proc ppm  {path src} { to $path $src aktive format as ppm byte }
proc pgm  {path src} { to $path $src aktive format as pgm byte }
proc ppmt {path src} { to $path $src aktive format as ppm text }
proc pgmt {path src} { to $path $src aktive format as pgm text }
proc akt  {path src} { to $path $src aktive format as aktive }

proc ppms {src} { aktive format as ppm text 2string $src }
proc pgms {src} { aktive format as pgm text 2string $src }
proc akts {src} { aktive format as aktive   2string $src }

proc rgb {r g b} { aktive op montage z $r [aktive op montage z $g $b] }
proc grad  {} { aktive image gradient 3 4 2  1 12.5 }
proc gradx {} { aktive image gradient 20 1 1  0 19 }
proc grady {} { aktive image gradient 1 20 1  0 19 }
proc gradz {} { aktive image gradient 1 1 20  0 19 }
proc graybox  {} { aktive image gradient 8 8 1 0 1 }
proc graybig  {} { aktive image gradient 256 256 1 0 1 }
proc colorbox {} { set r [graybox] ; rgb $r [aktive op rotate cw $r] [aktive op rotate half $r] }
proc colorbig {} { set r [graybig] ; rgb $r [aktive op rotate cw $r] [aktive op rotate half $r] }
proc sines {} { rgb [aktive image sines 256 256 0.3 0.4] [aktive image sines 256 256 2 0.5] [aktive image sines 256 256 1 3] }

proc webcolors {} {
    # Rewrite uint8 rgb tuples into separate columns, and rescale to interval [0,1]
    foreach {r g b} {
        0   0   0    0   0   51   0   0   102  0   0   153  0   0   204  0   0   255  0   51  0    0   51  51
        0   51  102  0   51  153  0   51  204  0   51  255  0   102 0    0   102 51   0   102 102  0   102 153
        0   102 204  0   102 255  0   153 0    0   153 51   0   153 102  0   153 153  0   153 204  0   153 255
        0   204 0    0   204 51   0   204 102  0   204 153  0   204 204  0   204 255  0   255 0    0   255 51
        0   255 102  0   255 153  0   255 204  0   255 255  51  0   0    51  0   51   51  0   102  51  0   153
        51  0   204  51  0   255  51  51  0    51  51  51   51  51  102  51  51  153  51  51  204  51  51  255
        51  102 0    51  102 51   51  102 102  51  102 153  51  102 204  51  102 255  51  153 0    51  153 51
        51  153 102  51  153 153  51  153 204  51  153 255  51  204 0    51  204 51   51  204 102  51  204 153
        51  204 204  51  204 255  51  255 0    51  255 51   51  255 102  51  255 153  51  255 204  51  255 255
        102 0   0    102 0   51   102 0   102  102 0   153  102 0   204  102 0   255  102 51  0    102 51  51
        102 51  102  102 51  153  102 51  204  102 51  255  102 102 0    102 102 51   102 102 102  102 102 153
        102 102 204  102 102 255  102 153 0    102 153 51   102 153 102  102 153 153  102 153 204  102 153 255
        102 204 0    102 204 51   102 204 102  102 204 153  102 204 204  102 204 255  102 255 0    102 255 51
        102 255 102  102 255 153  102 255 204  102 255 255  153 0   0    153 0   51   153 0   102  153 0   153
        153 0   204  153 0   255  153 51  0    153 51  51   153 51  102  153 51  153  153 51  204  153 51  255
        153 102 0    153 102 51   153 102 102  153 102 153  153 102 204  153 102 255  153 153 0    153 153 51
        153 153 102  153 153 153  153 153 204  153 153 255  153 204 0    153 204 51   153 204 102  153 204 153
        153 204 204  153 204 255  153 255 0    153 255 51   153 255 102  153 255 153  153 255 204  153 255 255
        204 0   0    204 0   51   204 0   102  204 0   153  204 0   204  204 0   255  204 51  0    204 51  51
        204 51  102  204 51  153  204 51  204  204 51  255  204 102 0    204 102 51   204 102 102  204 102 153
        204 102 204  204 102 255  204 153 0    204 153 51   204 153 102  204 153 153  204 153 204  204 153 255
        204 204 0    204 204 51   204 204 102  204 204 153  204 204 204  204 204 255  204 255 0    204 255 51
        204 255 102  204 255 153  204 255 204  204 255 255  255 0   0    255 0   51   255 0   102  255 0   153
        255 0   204  255 0   255  255 51  0    255 51  51   255 51  102  255 51  153  255 51  204  255 51  255
        255 102 0    255 102 51   255 102 102  255 102 153  255 102 204  255 102 255  255 153 0    255 153 51
        255 153 102  255 153 153  255 153 204  255 153 255  255 204 0    255 204 51   255 204 102  255 204 153
        255 204 204  255 204 255  255 255 0    255 255 51   255 255 102  255 255 153  255 255 204  255 255 255
    } {
        lappend rs [expr {$r/255.}] ; lappend gs [expr {$g/255.}] ; lappend bs [expr {$b/255.}]
    }
    set w [llength $rs] ;# assert :: w == 216 == 12*18
    # Construct image planes and aggregate into single color image
    aktive op montage z \
	[aktive image const matrix 12 18 {*}$rs] \
	[aktive op montage z \
	     [aktive image const matrix 12 18 {*}$gs] \
	     [aktive image const matrix 12 18 {*}$bs]]
}

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
