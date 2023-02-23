#!/home/aku/opt/ActiveTcl/bin/tclsh

package require aktive

proc grad  {} { aktive image gradient 3 4 2  1 12.5 }
proc gradx {} { aktive image gradient 20 1 1  0 19 }
proc grady {} { aktive image gradient 1 20 1  0 19 }
proc gradz {} { aktive image gradient 1 1 20  0 19 }

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have aktive v[aktive version]"
puts ""

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
    set pi [aktive query pitch  $i]
#    puts "  pi  [set pi [aktive query pitch  $i]] (w*d)"
#    puts "  px  [aktive query pixels $i] (w*h)"
#    puts "  sz  [aktive query size   $i] (w*h*d)"
#    puts ""
#    puts "  location [aktive query location $i]"
#    puts "  domain   [aktive query domain   $i]"
#    puts "  geometry [aktive query geometry $i]"
#    puts ""
    set t [aktive format as tcl $i]
    #puts "  raw (($t))"
    flush stdout

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
	puts -nonewline " [format %6.2f $v]"
	incr i
    }
    puts ""
    flush stdout
    puts "\}"
    puts ""
    #puts "raw (([aktive format as tcl [aktive op view {80 80 2 2} $i]]))" ;# outside! zeros expected
    #puts "raw (([aktive format as tcl [aktive op view {-2 2 8 2} $i]]))"  ;# partial
    #puts ""
}



proc graybox {} {
    aktive image gradient 256 256 1 0 1
}

proc colorbox {} {
    set r [graybox]
    set g [aktive op rotate cw   $r]
    set b [aktive op rotate half $r]
    aktive op montage z $r [aktive op montage z $g $b]

    #aktive image gradient 8 8 3 0 1
}


#set g  [aktive image gradient 256 1 1 0 1]
#set g  [aktive image gradient 8 8 1 0 1]
#set g [aktive op math1 gamma-compress $g]

#set r [aktive op flip x $g]
#set b [aktive op rotate cw $g]

#set gc [aktive op math1 gamma-compress $g]
#set ge [aktive op math1 gamma-expand $g]

#set g [aktive op montage y $g [aktive op montage y $gc $ge]]
#set g [aktive op montage z $g [aktive op montage z $gc $ge]]
#set g [aktive op montage z $r [aktive op montage z $g $b]]

#set g [aktive op select z 0 0 $g]
#set g [aktive op math1 scale 0.08 $g]

set g [colorbox]
#set g [aktive op upsample xrep 16 $g]
#set g [aktive op upsample yrep 16 $g]

set h [graybox]
set k [aktive op rotate cw   $h]
set m [aktive op rotate half $h]
set h [aktive op montage y [aktive op montage x $h $k] $m]

#show $g
#exit

proc to {path g args} {
    set dst [open $path w]
    uplevel 1 [linsert $args end 2chan $dst $g]
    close $dst
}

puts [time {to x-text.ppm  $g aktive format as ppm text } 1]
puts [time {to x-etext.ppm $g aktive format as ppm etext} 1]
puts [time {to x-byte.ppm  $g aktive format as ppm byte } 1]
puts [time {to x-short.ppm $g aktive format as ppm short} 1]

puts [time {to x-text.pgm  $h aktive format as pgm text } 1]
puts [time {to x-etext.pgm $h aktive format as pgm etext} 1]
puts [time {to x-byte.pgm  $h aktive format as pgm byte } 1]
puts [time {to x-short.pgm $h aktive format as pgm short} 1]

exit

set g [aktive op upsample x 3 0 [grad]]

show $g

if 0 {foreach col [aktive op split x $g] {
    puts [dict get [aktive format tcl $col] pixels]
}}


#set g [aktive image const sparse deltas 7   0 20 5 15]
#set g [aktive image const sparse points {0 0} {4 3} {5 5} {6 2}]

exit


set a [aktive op select x 0 4 [gradx]]
set b [aktive op select y 0 4 [grady]]

show $a
show $b

set g [aktive op montage x $a $b]

#set g [aktive op select x 5 10 $g]
set g [aktive image gradient 7 1 1  0 6]
set g [aktive op upsample x 3 0 $g]

#
# 0     1     2     3     4     5     6     gradient	7
# 0 . . 1 . . 2 . . 3 . . 4 . . 5 . . 6 . . upsample 3	/21
# = = = = = = = = = = = = = = = = = = = = =
# 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
#                     1                   2
#           |=========|                     select 5 10
#           . 2 . . 3 .
#           0 1 2 3 4 5
#           1 2 2 2 3 3
# = = = = = = = = = = = = = = = = = = = = =
# 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 phase
# 0 2 1 0 2 1 0 2 1 0 2 1 0 2 1 0 2 1 0 2 1 forward correction
#
# i = index
# p = phase
# c = correction
#
# i  p  c == (3-(i%3))%3 (C semantics. Tcl: (-i)%3)
# -  -  -
# 0  0  0
# 1  1  2
# 2  2  1
# 3  0  0
# 4  1  2
# 5  2  1
# 6  0  0
# 7  1  2
# -  -  -
#

#set g [aktive op flip x $g]

show [aktive op select z 1 1 $g]
show [aktive op select z 0 0 $g]

#set op x
#show [aktive op upsample $op 2 0 $g]

show [aktive op upsample $op 3 0 [aktive op upsample $op 2 0 $g]]
set op y
show [aktive op upsample $op 3 0 [aktive op upsample $op 2 0 $g]]
set op z
show [aktive op upsample $op 3 0 [aktive op upsample $op 2 0 $g]]

#show [aktive op view {-2 2 8 2} $g]
#show [aktive op view {2 -2 2 8} $g]

#show $g
#show [aktive op swap yz $g]
#show [aktive op flip y [aktive op flip z [aktive op flip x $g]]]
#show [aktive image constant     4 6 1  NaN]

show $c
show [aktive op math1 abs $c]
show [aktive op math1 abs [aktive op math1 abs $g]]

exit

show [aktive op flip z $g]

show [aktive op select z 1 $g]
show [aktive op select y 1 $g]
show [aktive op select x 1 $g]

show [aktive op math1 abs [aktive image gradient 7 1 1   -3 3]]
show [aktive image gradient 7 1 1   -3 3]
show [aktive image constant     4 6 1  1]
show [aktive image const bands  4 6    1 2 3]
show [aktive image const matrix 8 8 \
	  1 1 1 1 1 1 1 1 \
	  1 1 1 2 2 1 1 1 \
	  1 1 1 2 2 1 1 1 \
	  1 2 2 2 2 2 2 1 \
	  1 2 2 2 2 2 2 1 \
	  1 1 1 2 2 1 1 1 \
	  1 1 1 2 2 1 1 1 \
	  1 1 1 1 1 1 1 1]

show [aktive image const sparse points \
	  {0 0} \
	  {6 3} \
	  {5 5} \
	  {4 2}]

exit


proc c {i n} { expr { ($n - ($i % $n)) % $n } }

proc t {n} {
    puts ""
    puts "$n ..............."
    foreach k {
	0 1 2 3 4 5 6 7 8 9
    } {
	puts \t$k\t[c $k $n]
    }
}

t 7
t 3
t 5
t 2

exit
if 0 {
	    for (int k = 0;k < 10; k++) fprintf (stderr, "ZZZZ %3d -- %3d %3d %3d\n",
						k, CORR(k,2), CORR(k,3), CORR(k,5));
	    fflush (stderr);
}

