package require aktive

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have aktive v[aktive version]"
puts ""

proc show {i} {
    puts "[aktive query type $i] \{"
    puts "  pa ([aktive query params $i])"
    puts "  in ([aktive query inputs $i])"
    puts "  x  [aktive query x      $i]..[aktive query xmax   $i]"
    puts "  y  [aktive query y      $i]..[aktive query ymax   $i]"
    puts "  w  [aktive query width  $i]"
    puts "  h  [aktive query height $i]"
    puts "  d  [aktive query depth  $i]"
    puts "  pi [aktive query pitch  $i] (w*d)"
    puts "  px [aktive query pixels $i] (w*h)"
    puts "  sz [aktive query size   $i] (w*h*d)"
    puts "\}"
    puts ""
    puts "raw (([aktive format tcl $i]))"
    puts "raw (([aktive format tcl [aktive op view {80 80 2 2} $i]]))" ;# outside! zeros expected
    puts ""
}

show [aktive image constant     4 6 1  0.5]
show [aktive image const planes 4 6    0 0.5 1]

exit
