
set r [aktive image sines 256 256 0.3 0.4]
set g [aktive image sines 256 256 2   0.5]
set b [aktive image sines 256 256 1   3  ]
#
set i [aktive op montage z $r [aktive op montage z $g $b]]

set chan [open sines.ppm]
puts -nonewline $chan [aktive format as ppm byte 2string $i]
close $chan
