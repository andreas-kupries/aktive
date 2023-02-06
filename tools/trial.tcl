package require aktive

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have aktive v[aktive version]"
puts ""

proc show {i} {
    puts "[aktive query type $i] \{"
    puts "  pa ([aktive query params $i])"
    foreach x [aktive query inputs $i] {
	puts "  in ([aktive format tcl $x])"
    }
    flush stdout
    puts "  x  [aktive query x      $i]..[aktive query xmax   $i]"
    puts "  y  [aktive query y      $i]..[aktive query ymax   $i]"
    puts "  w  [aktive query width  $i]"
    puts "  h  [aktive query height $i]"
    puts "  d  [aktive query depth  $i]"
    puts "  pi [aktive query pitch  $i] (w*d)"
    puts "  px [aktive query pixels $i] (w*h)"
    puts "  sz [aktive query size   $i] (w*h*d)"
    puts ""
    puts "  location [aktive query location $i]"
    puts "  domain   [aktive query domain   $i]"
    puts "  geometry [aktive query geometry $i]"
    puts ""
    puts "  raw (([aktive format tcl $i]))"
    flush stdout
    puts "\}"
    puts ""
        #puts "raw (([aktive format tcl [aktive op view {80 80 2 2} $i]]))" ;# outside! zeros expected
    #puts "raw (([aktive format tcl [aktive op view {-2 2 8 2} $i]]))"  ;# partial
    puts ""
}

set g [aktive image gradient 3 4 2  1 12.5]
# input/gradient 3x4x2
##
##       0 ....   1......   2...... - 3 columns
##     --------  --------  --------
#	 1  1.5    2  2.5    3  3.5  0
#	 4  4.5    5  5.5    6  6.5  1
#	 7  7.5    8  8.5    9  9.5  2
#	10 10.5   11 11.5   12 12.5  3
##     --- ----  --- ----  --- ----  \ 4 rows
##      0. 1...   0. 1...   0. 1... - 2 bands
#
#   0  1  2  3  4  5
#   6  7  8  9 10 11
#  12 13 14 15 16 17
#  18 19 29 21 22 23

#show [aktive op view {-2 2 8 2} $g]
#show [aktive op view {2 -2 2 8} $g]

show [aktive op select z 1 $g]

exit

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
