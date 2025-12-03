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

set reduce {
    once {
	variance { typedef struct { kahan sum; kahan squared; } sas; }
	stddev   @variance
	argmax   { typedef struct { double extremum; aktive_uint eindex } args; }
	argmin   @argmax
    }
    setup {
	max        { double @A = -INF; }
	min        { double @A =  INF; }
	sum        { kahan  @A; aktive_kahan_init (&@A); }
	sumsquared @sum
	mean       @sum
	variance {
	    sas @A;
	    aktive_kahan_init (&@A.sum);
	    aktive_kahan_init (&@A.squared);
	}
	stddev @variance
	argmax { args @A; @A.extremum = -INF; @A.e_index = 0; }
	argmin { args @A; @A.extremum =  INF; @A.e_index = 0; }
    }
    reduce {
	max        { @A = fmax (@A, @V); }
	min        { @A = fmin (@A, @V); }
	sum        { aktive_kahan_add (@A, @V); }
	sumsquared { aktive_kahan_add (@A, @V * @V); }
	mean       @sum
	variance {
	    aktive_kahan_add (@A.sum, @V);
	    aktive_kahan_add (@A.squared, @V*@V);
	}
	stddev @stddev
	argmax {
	    @A.e_index  = @V > @A.extremum ? @I : @A.e_index;
	    @A.extremum = @V > @A.extremum ? @V : @A.extremum;
	}
	argmin {
	    @A.e_index  = @V < @A.extremum ? @I : @A.e_index;
	    @A.extremum = @V < @A.extremum ? @V : @A.extremum;
	}
    }
    merge {
	max             { @AD = fmax (@AD, @AS); }
	min             { @AD = fmin (@AD, @AS); }
	sum             { aktive_kahan_add (@AD, aktive_kahan_final (@AS)); }
	sumsquared      @sum
	mean            @sum
	variance {
	    aktive_kahan_add (@AD.sum, aktive_kahan_final (@AS.sum));
	    aktive_kahan_add (@AD.squared, aktive_kahan_final (@AS.squared));
	}
	stddev @variance
	argmax {
	    @AD.e_index  = @AS.extremum > @AD.extremum ? @AS.e_index  : @AD.e_index;
	    @AD.extremum = @AS.extremum > @AD.extremum ? @AS.extremum : @AD.extremum;
	}
	argmin {
	    @AD.e_index  = @AS.extremum < @AD.extremum ? @AS.e_index  : @AD.e_index;
	    @AD.extremum = @AS.extremum < @AD.extremum ? @AS.extremum : @AD.extremum;
	}
    }
    finalize {
	max        { double @R = @A; }
	min        @max
	sum        { double @R = aktive_kahan_final (@A); }
	sumsquared @sum
	mean       { double @R = aktive_kahan_final (@A) / (double) @N; }
	variance {
	    double mean = aktive_kahan_final (&@A.sum)     / (double) @N;
	    double sq   = aktive_kahan_final (&@A.squared) / (double) @N;
	    @R = sq - mean*mean;
	}
	stddev {
	    double mean = aktive_kahan_final (&@A.sum)     / (double) @N;
	    double sq   = aktive_kahan_final (&@A.squared) / (double) @N;
	    @R = sqrt (sq - mean*mean);
	}
	argmax { @R = @A.e_index; }
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
