# -*- tcl -*-
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands - Standard images for tests

proc flat  {x} { aktive image constant 3 4 2 $x }
proc grad  {}  { aktive image gradient 3 4 2  1 12.5 }
proc bands {}  { aktive image const bands 4 2  1 2 3 }
proc matrix {} { aktive image const matrix 4 2  1 2 3 4  5 6 7 8 }

# input/gradient 3x4x2
##
##       0 ....   1......   2...... --- 3 columns
##     --------  --------  --------
#	 1  1.5    2  2.5    3  3.5  0
#	 4  4.5    5  5.5    6  6.5  1
#	 7  7.5    8  8.5    9  9.5  2
#	10 10.5   11 11.5   12 12.5  3
##     --- ----  --- ----  --- ----  \- 4 rows
##      0. 1...   0. 1...   0. 1... --- 2 bands
