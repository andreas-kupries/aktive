
# this band reducer chooses different, custom loops for the most used image
# depths (1 to 6), and a generic loop handling everything else.
#
# note that only the code run per pixel is optimized.
# the pixels themselves are handled sequentially.

def-func band perdepth {
    aktive_uint pixels = count, depth = stride;
    <<<once>>>
    #define ITER_PIXELS(step) aktive_uint col;  for (col  = 0; col  < pixels; col ++, dst ++, src += (step))
    #define ITER_BANDS        aktive_uint band; for (band = 0; band < depth; band++)

    switch (depth) {
	case 1: {
	    // note - due to highlevel simplifications this case should not be reached,
	    // except during benchmarking
	    TRACE ("depth %d unrolled/none", depth);

	    ITER_PIXELS(1) { *dst = <<<single depth>>>; }
	} ; break;
	case 2: {
	    TRACE ("depth %d unrolled/2x", depth);

	    ITER_PIXELS(2) {
		<<<setup         @N depth @A acc>>>
		<<<reduce   @I 0 @N depth @A acc @V {src[0]}>>>
		<<<reduce   @I 1 @N depth @A acc @V {src[1]}>>>
		<<<finalize      @N depth @A acc @R *dst>>>
	    }
	} ; break;
	case 3: {
	    TRACE ("depth %d unrolled/3x", depth);

	    ITER_PIXELS(3) {
		<<<setup         @N depth @A acc>>>
		<<<reduce   @I 0 @N depth @A acc @V {src[0]}>>>
		<<<reduce   @I 1 @N depth @A acc @V {src[1]}>>>
		<<<reduce   @I 2 @N depth @A acc @V {src[2]}>>>
		<<<finalize      @N depth @A acc @R *dst>>>
	    }
	} ; break;
	case 4: {
	    TRACE ("depth %d unrolled/4x", depth);

	    ITER_PIXELS(4) {
		<<<setup         @N depth @A acc>>>
		<<<reduce   @I 0 @N depth @A acc @V {src[0]}>>>
		<<<reduce   @I 1 @N depth @A acc @V {src[1]}>>>
		<<<reduce   @I 2 @N depth @A acc @V {src[2]}>>>
		<<<reduce   @I 3 @N depth @A acc @V {src[3]}>>>
		<<<finalize      @N depth @A acc @R *dst>>>
	    }
	} ; break;
	default: {
	    TRACE ("depth %d unrolled/none, generic", depth);

	    ITER_PIXELS(1) {
		<<<setup              @N depth @A acc>>>
		ITER_BANDS {
		    <<<reduce @I band @N depth @A acc @V {src[band]}>>>
		}
		<<<finalize           @N depth @A acc @R *dst>>>
	    }
	} ; break;
    }

    #undef ITER_BANDS
    #undef ITER_PIXELS
}
