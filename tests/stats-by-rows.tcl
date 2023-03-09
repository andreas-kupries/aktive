# -*- tcl -*- tcl.tk//DSL tcltest//EN//2.0 tcl.tk//DSL tcltest//EN//2.0
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## AKTIVE. Row statistics (min, max, mean, sum, sum squared, variance, std deviation)

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
} {aktive op row}

# # ## ### ##### ######## ############# #####################
##
## =  1  1.5 =  2  2.5 =  3  3.5
## =  4  4.5 =  5  5.5 =  6  6.5
## =  7  7.5 =  8  8.5 =  9  9.5
## = 10 10.5 = 11 11.5 = 12 12.5

foreach {op expected} {
    max {
	=  3  3.5 =
	=  6  6.5 =
	=  9  9.5 =
	= 12 12.5 =
    }
    mean {
	=  2  2.5 =
	=  5  5.5 =
	=  8  8.5 =
	= 11 11.5 =
    }
    min {
	=  1  1.5 =
	=  4  4.5 =
	=  7  7.5 =
	= 10 10.5 =
    }
    stddev {
	= 0.8165 0.8165
	= 0.8165 0.8165
	= 0.8165 0.8165
	= 0.8165 0.8165
    }
    sum {
	=  6  7.5 =
	= 15 16.5 =
	= 24 25.5 =
	= 33 34.5 =
    }
    sumsquared {
	=  14  20.75 =
	=  77  92.75 =
	= 194 218.75 =
	= 365 398.75 =
    }
    variance {
	= 0.6667 0.6667
	= 0.6667 0.6667
	= 0.6667 0.6667
	= 0.6667 0.6667
    }
} {
    test aktive-op-row-${op}-2.0 "aktive op row $op" -body {
	astcl aktive op row $op [grad]
    } -match image -result [makei op::row::$op 0 0 1 4 2 {} $expected]

    test aktive-op-row-${op}-2.1 "aktive op row $op, dag" -body {
	dag aktive op row $op [grad]
    } -match glob -result "op::row::$op * {} {image::gradient *}"
}

# # ## ### ##### ######## ############# #####################
cleanupTests
return
