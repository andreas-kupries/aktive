# -*- tcl -*- tcl.tk//DSL tcltest//EN//2.0 tcl.tk//DSL tcltest//EN//2.0
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## AKTIVE. Column statistics (min, max, mean, sum, sum squared, variance, std deviation)

kt check Tcl     8.6
kt check tcltest 2

# # ## ### ##### ######## ############# #####################

kt local testing aktive

kt source support/util.tcl

# # ## ### ##### ######## ############# #####################
## Syntax

syntax {
    max        src
    mean       src
    min        src
    stddev     src
    sum        src
    sumsquared src
    variance   src
} {aktive op column}

# # ## ### ##### ######## ############# #####################
##
## =  1.00  1.50 =  2.00  2.50 =  3.00  3.50
## =  4.00  4.50 =  5.00  5.50 =  6.00  6.50
## =  7.00  7.50 =  8.00  8.50 =  9.00  9.50
## = 10.00 10.50 = 11.00 11.50 = 12.00 12.50

foreach {op expected} {
    max        { =  10       10.5    =  11       11.5    =  12       12.5    = }
    mean       { =   5.5      6      =   6.5      7      =   7.5      8	   = }
    min        { =   1        1.5    =   2        2.5    =   3        3.5    = }
    stddev     { =   3.3541   3.3541 =   3.3541   3.3541 =   3.3541   3.3541 = }
    sum        { =  22       24      =  26       28      =  30       32      = }
    sumsquared { = 166      189      = 214      241      = 270      301      = }
    variance   { =  11.25    11.25   = 11.25     11.25   =  11.25    11.25   = }
} {
    test aktive-op-column-${op}-2.0 "aktive op column $op" -body {
	astcl aktive op column $op [grad]
    } -match image -result [makei op::column::$op 0 0 3 1 2 {} $expected]

    test aktive-op-column-${op}-2.1 "aktive op column $op, dag" -body {
	dag aktive op column $op [grad]
    } -match glob -result "op::column::$op * {} {image::gradient *}"
}

# # ## ### ##### ######## ############# #####################
cleanupTests
return
