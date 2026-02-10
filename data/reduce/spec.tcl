# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

# # ## ### ##### ######## #############
## Reducer function cores.
##
## code fragments and environment
#
#  - `once` executed once per function, optional, no environment
#
#  - `setup` state declaration and setup, once per lane, before the loop
#    environment:
#
#      - `@A` :: reduction accumulator of the lane
#      - `@N` :: count of input values
#
#  - `reduce` reduction operation, once per lane, loop body
#    environment:
#
#      - `@V` :: input value to reduce
#      - `@I` :: index of input value in vector
#      - `@A` :: reduction accumulator of the lane, input and output
#      - `@N` :: count of input values
#
#  - `merge` reduction of lanes, after the loop, binary merge tree
#    environment:
#
#      - `@AD` :: destination accumulator
#      - `@AS` :: source accumulator to merge into destination
#
#  - `finalize` transform accumulator into result, after merging
#    environment:
#
#      - `@A` :: result accumulator
#      - `@N` :: count of input values
#      - `@R` :: final result derived from the accumulator.
#
#  - `single` result of the reduction when only a single value is available.
#             legal values: `pass`, `square`, `zero`, `forn`, and `lorn`.
#
#      - `pass`   :: pass single input to output
#      - `zero`   :: set output to 0.
#      - `square` :: set output to square of input
#      - `forn`   :: short for `first or nothing`, set 0 if input != 0, else width
#      - `lorn`   :: short for `last or nothing`,  set 0 if input != 0, else -1.
#
set reduce {
    once {
	variance { typedef struct { kahan sum; kahan squared; } sas; }
	stddev   @variance
	argmax   { typedef struct { double extremum; aktive_uint eindex; } args; }
	argmin   @argmax
    }
    single {
	max        pass
	min        pass
	sum        pass
	sumsquared square
	mean       pass
	variance   zero
	stddev     zero
	argmax     zero
	argmin     zero
	profile    forn
	rprofile   lorn
    }
    setup {
	max        { double @A = -INFINITY; }
	min        { double @A =  INFINITY; }
	sum        { kahan  @A; aktive_kahan_init (@A); }
	sumsquared @sum
	mean       @sum
	variance   { sas @A; aktive_kahan_init (@A.sum); aktive_kahan_init (@A.squared); }
	stddev     @variance
	argmax     { args @A; @A.extremum = -INFINITY; @A.eindex = 0; }
	argmin     { args @A; @A.extremum =  INFINITY; @A.eindex = 0; }
	profile    { int @A = @N; }
	rprofile   { int @A = -1; }
    }
    reduce {
	max         { @A = fmax (@A, @V); }
	min         { @A = fmin (@A, @V); }
	sum         { aktive_kahan_add (@A, @V); }
	sumsquared {{ double vv = @V*@V; aktive_kahan_add (@A, vv); }}
	mean        @sum
	variance   {{ double vv = @V*@V; aktive_kahan_add (@A.sum, @V); aktive_kahan_add (@A.squared, vv); }}
	stddev      @variance
	argmax     {{ aktive_uint gt = @V > @A.extremum; @A.eindex = gt ? @I : @A.eindex; @A.extremum = gt ? @V : @A.extremum; }}
	argmin     {{ aktive_uint lt = @V < @A.extremum; @A.eindex = lt ? @I : @A.eindex; @A.extremum = lt ? @V : @A.extremum; }}
	profile     { @A = (@I < @A) && (@V != 0) ? @I : @A; }
	rprofile    { @A = (@I > @A) && (@V != 0) ? @I : @A; }
    }
    merge {
	max        { @AD = fmax (@AD, @AS); }
	min        { @AD = fmin (@AD, @AS); }
	sum        { aktive_kahan_add_kahan (@AD, @AS); }
	sumsquared @sum
	mean       @sum
	variance   { aktive_kahan_add_kahan (@AD.sum, @AS.sum); aktive_kahan_add_kahan (@AD.squared, @AS.squared); }
	stddev     @variance
	argmax    {{ aktive_uint gt = @AS.extremum > @AD.extremum; @AD.eindex = gt ? @AS.eindex : @AD.eindex; @AD.extremum = gt ? @AS.extremum : @AD.extremum; }}
	argmin    {{ aktive_uint lt = @AS.extremum < @AD.extremum; @AD.eindex = lt ? @AS.eindex : @AD.eindex; @AD.extremum = lt ? @AS.extremum : @AD.extremum; }}
	profile    { @AD = (@AD < @AS) ? @AD : @AS }
	rprofile   { @AD = (@AD > @AS) ? @AD : @AS }
    }
    finalize {
	max        { @R = @A; }
	min        @max
	sum        { @R = aktive_kahan_final (@A); }
	sumsquared @sum
	mean       { @R = aktive_kahan_final (@A) / (double) @N; }
	variance  {{ double mean = aktive_kahan_final (@A.sum) / (double) @N; double sq = aktive_kahan_final (@A.squared) / (double) @N; @R =       sq - mean*mean;  }}
	stddev    {{ double mean = aktive_kahan_final (@A.sum) / (double) @N; double sq = aktive_kahan_final (@A.squared) / (double) @N; @R = sqrt (sq - mean*mean); }}
	argmax     { @R = @A.eindex; }
	argmin     @argmax
	profile    { @R = (double) @A; }
	rprofile   @profile
    }
}

# # ## ### ##### ######## #############
## Templated code fragments to assemble the functions from.

set here [file dirname [info script]]
source $here/fragments.tcl

# # ## ### ##### ######## #############
# full set of known reduction ops, computed from the spec above

lappend reducers {*}[dict keys [dict get $reduce once]]
lappend reducers {*}[dict keys [dict get $reduce setup]]
lappend reducers {*}[dict keys [dict get $reduce reduce]]
lappend reducers {*}[dict keys [dict get $reduce merge]]
lappend reducers {*}[dict keys [dict get $reduce finalize]]
set     reducers [lsort -unique -dict $reducers]

# # ## ### ##### ######## #############

return
