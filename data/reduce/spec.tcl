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
#             legal values: `pass`, `twice`, and `zero`.
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
	sumsquared twice
	mean       pass
	variance   zero
	stddev     zero
	argmax     zero
	argmin     zero
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
    }
    reduce {
	max        { @A = fmax (@A, @V); }
	min        { @A = fmin (@A, @V); }
	sum        { aktive_kahan_add (@A, @V); }
	sumsquared { aktive_kahan_add (@A, @V*@V); }
	mean       @sum
	variance   { aktive_kahan_add (@A.sum, @V); aktive_kahan_add (@A.squared, @V*@V); }
	stddev @variance
	argmax {
	    @A.eindex   = @V > @A.extremum ? @I : @A.eindex;
	    @A.extremum = @V > @A.extremum ? @V : @A.extremum;
	}
	argmin {
	    @A.eindex   = @V < @A.extremum ? @I : @A.eindex;
	    @A.extremum = @V < @A.extremum ? @V : @A.extremum;
	}
    }
    merge {
	max        { @AD = fmax (@AD, @AS); }
	min        { @AD = fmin (@AD, @AS); }
	sum        { aktive_kahan_add_kahan (@AD, @AS); }
	sumsquared @sum
	mean       @sum
	variance   { aktive_kahan_add_kahan (@AD.sum, @AS.sum); aktive_kahan_add_kahan (@AD.squared, @AS.squared); }
	stddev     @variance
	argmax     {
	    @AD.eindex   = @AS.extremum > @AD.extremum ? @AS.eindex   : @AD.eindex;
	    @AD.extremum = @AS.extremum > @AD.extremum ? @AS.extremum : @AD.extremum;
	}
	argmin     {
	    @AD.eindex   = @AS.extremum < @AD.extremum ? @AS.eindex   : @AD.eindex;
	    @AD.extremum = @AS.extremum < @AD.extremum ? @AS.extremum : @AD.extremum;
	}
    }
    finalize {
	max        { @R = @A; }
	min        @max
	sum        { @R = aktive_kahan_final (@A); }
	sumsquared @sum
	mean       { @R = aktive_kahan_final (@A) / (double) @N; }
	variance {
	    double mean = aktive_kahan_final (@A.sum)     / (double) @N;
	    double sq   = aktive_kahan_final (@A.squared) / (double) @N;
	    @R = sq - mean*mean;
	}
	stddev {
	    double mean = aktive_kahan_final (@A.sum)     / (double) @N;
	    double sq   = aktive_kahan_final (@A.squared) / (double) @N;
	    @R = sqrt (sq - mean*mean);
	}
	argmax { @R = @A.eindex; }
	argmin @argmax
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
