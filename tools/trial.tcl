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

if 0 {
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

show [aktive image gradient 7 1 1   -3 3]
}

show [aktive op math1 abs [aktive image gradient 7 1 1   -3 3]]

exit
