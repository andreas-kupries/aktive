
# this band reducer chooses different, custom loops for the most used image
# depths (1 to 6), and a generic loop handling everything else.
#
# note that only the code run per pixel is optimized.
# the pixels themselves are handled sequentially.

def-func band perdepth {
    placeholder @name@    $name
    placeholder @once@    $once
    #
    placeholder @single@  [single $single stride]
    #
    placeholder @setup@         [map $setup    @N stride @A acc]			;# loop setup
    placeholder @final@   [trim [map $finalize @N stride @A acc @R *dst]]		;# post-processing
    placeholder @reduce@        [map $reduce   @N stride @A acc @I j @V {src[j]}]	;# generic loop
    #
    placeholder @reduce0@ [map $reduce   @I 0 @N stride @A acc @V {src[0]}] ;# unrolled inner
    placeholder @reduce1@ [map $reduce   @I 1 @N stride @A acc @V {src[1]}] ;# s.a
    placeholder @reduce2@ [map $reduce   @I 2 @N stride @A acc @V {src[2]}] ;# s.a
    placeholder @reduce3@ [map $reduce   @I 3 @N stride @A acc @V {src[3]}] ;# s.a
} {
    @once@
    #define PIXELS(step) aktive_uint k; for (k = 0; k < count; k++, dst++, src += (step))
    #define BANDS        aktive_uint j; for (j = 0; j < stride; j++)

    switch (stride) {
	case 1: {
	    // note - due to highlevel simplifications this case should not be reached
	    // except in benchmarking
	    TRACE ("depth %d unrolled/none", stride);
	    PIXELS(1) { *dst = @single@; }
	} ; break;
	case 2: {
	    TRACE ("depth %d unrolled/2x", stride);
	    PIXELS(2) {
		@setup@
		@reduce0@
		@reduce1@
		@final@
	    }
	} ; break;
	case 3: {
	    TRACE ("depth %d unrolled/3x", stride);
	    PIXELS(3) {
		@setup@
		@reduce0@
		@reduce1@
		@reduce2@
		@final@
	    }
	} ; break;
	case 4: {
	    TRACE ("depth %d unrolled/4x", stride);
	    PIXELS(4) {
		@setup@
		@reduce0@
		@reduce1@
		@reduce2@
		@reduce3@
		@final@
	    }
	} ; break;
	default: {
	    TRACE ("depth %d unrolled/none, generic", stride);
	    PIXELS(1) {
		@setup@
		BANDS {
		    @reduce@
		}
		@final@
	    }
	} ; break;
    }

    #undef BANDS
    #undef PIXELS
}
