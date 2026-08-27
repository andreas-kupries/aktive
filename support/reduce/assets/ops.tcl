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
#	      legal values: `pass`, `square`, `zero`, `forn`, and `lorn`.
#
#      - `pass`	  :: return the single input as output
#      - `zero`	  :: set output to 0.
#      - `square` :: set output to square of the single input
#      - `forn`	  :: short for `first or nothing`, set 0 if input != 0, else width
#      - `lorn`	  :: short for `last or nothing`,  set 0 if input != 0, else -1.
#

def-reduce max {
    single   pass
    setup    { double @A = -INFINITY; }
    reduce   { @A = fmax (@A, @V); }
    merge    { @AD = fmax (@AD, @AS); }
    finalize { @R = @A; }
}

def-reduce min {
    single   @max
    setup    { double @A = INFINITY; }
    reduce   { @A = fmin (@A, @V); }
    merge    { @AD = fmin (@AD, @AS); }
    finalize @max
}

def-reduce sum {
    single   pass
    setup    { kahan @A; aktive_kahan_init (@A);   fprintf(stderr, "initial    @A (%f, %f)\n", @A.sum, @A.correction);						   }
    reduce   { aktive_kahan_add (@A, @V);	   fprintf(stderr, "reduce @%d @A (%f, %f) <- %f\n", @A.sum, @I, @A.correction, @V);				   }
    merge    { aktive_kahan_add_kahan (@AD, @AS);  fprintf(stderr, "merge      @AD (%f, %f) <- @AS (%F, %f)\n", @AD.sum, @AD.correction, @AS.sum, @AS.correction); }
    finalize { @R = aktive_kahan_final (@A);	   fprintf(stderr, "final      @R = @A (%f, %f)\n", @R, @A.sum, @A.correction);					   }

    setup    { kahan @A; aktive_kahan_init (@A);  }
    reduce   { aktive_kahan_add (@A, @V);	  }
    merge    { aktive_kahan_add_kahan (@AD, @AS); }
    finalize { @R = aktive_kahan_final (@A);	  }
}

def-reduce sumsquared {
    single   square
    setup    @sum
    reduce   {{ double vv = @V*@V; aktive_kahan_add (@A, vv); }}
    merge    @sum
    finalize @sum
}

def-reduce mean {
    single   pass
    setup    @sum
    reduce   @sum
    merge    @sum
    finalize { @R = aktive_kahan_final (@A) / (double) @N; }
}

def-reduce variance {
    once     { typedef struct { kahan sum; kahan squared; } sas; }
    single   zero
    setup    { sas @A; aktive_kahan_init (@A.sum); aktive_kahan_init (@A.squared); }
    reduce   {{ double vv = @V*@V;
		aktive_kahan_add (@A.sum, @V);
		aktive_kahan_add (@A.squared, vv); }}
    merge    {  aktive_kahan_add_kahan (@AD.sum, @AS.sum);
		aktive_kahan_add_kahan (@AD.squared, @AS.squared); }
    finalize {{ double mean = aktive_kahan_final (@A.sum)     / (double) @N;
		double sq   = aktive_kahan_final (@A.squared) / (double) @N;
		@R =	      sq - mean*mean;  }}
}

def-reduce stddev {
    once     @variance
    single   zero
    setup    @variance
    reduce   @variance
    merge    @variance
    finalize {{ double mean = aktive_kahan_final (@A.sum)     / (double) @N;
		double sq   = aktive_kahan_final (@A.squared) / (double) @N;
		@R = sqrt (sq - mean*mean); }}
}

def-reduce argmax {
    once     { typedef struct { double extremum; aktive_uint eindex; } args; }
    single   zero
    setup    { args @A; @A.extremum = -INFINITY; @A.eindex = 0; }
    reduce   {{ aktive_uint gt = @V > @A.extremum;
		@A.eindex   = gt ? @I : @A.eindex;
		@A.extremum = gt ? @V : @A.extremum; }}
    merge    {{ aktive_uint gt = @AS.extremum > @AD.extremum;
		@AD.eindex   = gt ? @AS.eindex	 : @AD.eindex;
		@AD.extremum = gt ? @AS.extremum : @AD.extremum; }}
    finalize { @R = @A.eindex; }
}

def-reduce argmin {
    once     @argmax
    single   zero
    setup    { args @A; @A.extremum =  INFINITY; @A.eindex = 0; }
    reduce   {{ aktive_uint lt = @V < @A.extremum;
		@A.eindex   = lt ? @I : @A.eindex;
		@A.extremum = lt ? @V : @A.extremum; }}
    merge    {{ aktive_uint lt = @AS.extremum < @AD.extremum;
		@AD.eindex   = lt ? @AS.eindex	 : @AD.eindex;
		@AD.extremum = lt ? @AS.extremum : @AD.extremum; }}
    finalize @argmax
}

# Beware: Do not directly compare uint against int. Ensure int/int comparison via cast.

def-reduce profile {
    single   forn
    setup    { int @A = @N;                                           fprintf(stderr, "init @A (%d)\n", @N);                           }
    reduce   { @A = (@V != 0) && (((int) @I) < @A) ? ((int) @I) : @A; fprintf(stderr, "redu @A (%d) <- (@V=%f, @I=%d)\n", @A, @V, @I); }
    merge    { @AD = (@AD < @AS) ? @AD : @AS;                         fprintf(stderr, "merg @AD (%d) <- @AS (%d)\n", @AD, @AS);        }
    finalize { @R = (double) @A;                                      fprintf(stderr, "fini @R (%f) = @A (%d)\n", @R, @A);             }

    setup    { int @A = @N;                                           }
    reduce   { @A = (@V != 0) && (((int) @I) < @A) ? ((int) @I) : @A; }
    merge    { @AD = (@AD < @AS) ? @AD : @AS;                         }
    finalize { @R = (double) @A;                                      }
}

def-reduce rprofile {
    single   lorn
    setup    { int @A = -1; }
    reduce   { @A = (@V != 0) && (((int) @I) > @A) ? ((int) @I) : @A; }
    merge    { @AD = (@AD > @AS) ? @AD : @AS; }
    finalize @profile
}

# # ## ### ##### ######## #############

return
