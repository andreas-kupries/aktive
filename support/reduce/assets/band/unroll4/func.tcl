
# this band reducer is a variant of the `perdepth` reducer which also unrolls
# the outer (pixel) loop.

def-func band unroll4 {
    <<<once>>>
    #define PIXELS4(step) for (k = count; k > 4; k -= 4, dst += 4, src += 4*(step))
    #define PIXELS2(step) for (         ; k > 2; k -= 2, dst += 2, src += 2*(step))
    #define PIXELS1(step) for (         ; k > 0; k --  , dst += 1, src +=   (step))
    #define BANDS         aktive_uint band; for (band = 0; band < stride; band ++)

    const aktive_uint d0 = 0 * stride;
    const aktive_uint d1 = 1 * stride;
    const aktive_uint d2 = 2 * stride;
    const aktive_uint d3 = 3 * stride;
    const aktive_uint d4 = 4 * stride;

    switch (stride) {
	case 1: {
	    // note - due to highlevel simplifications this case should not be reached
	    // except in benchmarking
	    TRACE ("depth %d unrolled/none", stride);
	    aktive_uint k;
	    PIXELS4(1) {
		dst[0] = <<<single stride *src {src[0]}>>>;
		dst[1] = <<<single stride *src {src[1]}>>>;
		dst[2] = <<<single stride *src {src[2]}>>>;
		dst[3] = <<<single stride *src {src[3]}>>>;
	    }
	    PIXELS2(1) {
		dst[0] = <<<single stride *src {src[0]}>>>;
		dst[1] = <<<single stride *src {src[1]}>>>;
	    }
	    PIXELS1(1) {
		*dst   = <<<single stride *src {src[0]}>>>;
	    }
	} ; break;
	case 2: {
	    TRACE ("depth %d unrolled/2", stride);
	    aktive_uint k;
	    PIXELS4(2) {
		<<<setup         @N stride @A acc0>>>
		<<<setup         @N stride @A acc1>>>
		<<<setup         @N stride @A acc2>>>
		<<<setup         @N stride @A acc3>>>
		<<<reduce   @I 0 @N stride @A acc0 @V {src[d0+0]}>>>
		<<<reduce   @I 0 @N stride @A acc1 @V {src[d1+0]}>>>
		<<<reduce   @I 0 @N stride @A acc2 @V {src[d2+0]}>>>
		<<<reduce   @I 0 @N stride @A acc3 @V {src[d3+0]}>>>
		<<<reduce   @I 1 @N stride @A acc0 @V {src[d0+1]}>>>
		<<<reduce   @I 1 @N stride @A acc1 @V {src[d1+1]}>>>
		<<<reduce   @I 1 @N stride @A acc2 @V {src[d2+1]}>>>
		<<<reduce   @I 1 @N stride @A acc3 @V {src[d3+1]}>>>
		<<<finalize      @N stride @A acc0 @R {dst[0]}>>>
		<<<finalize      @N stride @A acc1 @R {dst[1]}>>>
		<<<finalize      @N stride @A acc2 @R {dst[2]}>>>
		<<<finalize      @N stride @A acc3 @R {dst[3]}>>>
	    }
	    PIXELS2(2) {
		<<<setup         @N stride @A acc0>>>
		<<<setup         @N stride @A acc1>>>
		<<<reduce   @I 0 @N stride @A acc0 @V {src[d0+0]}>>>
		<<<reduce   @I 0 @N stride @A acc1 @V {src[d1+0]}>>>
		<<<reduce   @I 1 @N stride @A acc0 @V {src[d0+1]}>>>
		<<<reduce   @I 1 @N stride @A acc1 @V {src[d1+1]}>>>
		<<<finalize      @N stride @A acc0 @R {dst[0]}>>>
		<<<finalize      @N stride @A acc1 @R {dst[1]}>>>
	    }
	    PIXELS1(2) {
		<<<setup         @N stride @A acc>>>
		<<<reduce   @I 0 @N stride @A acc @V {src[0]}>>>
		<<<reduce   @I 1 @N stride @A acc @V {src[1]}>>>
		<<<finalize      @N stride @A acc @R *dst>>>
	    }
	} ; break;
	case 3: {
	    TRACE ("depth %d unrolled/3", stride);
	    aktive_uint k;
	    PIXELS4(3) {
		<<<setup         @N stride @A acc0>>>
		<<<setup         @N stride @A acc1>>>
		<<<setup         @N stride @A acc2>>>
		<<<setup         @N stride @A acc3>>>
		<<<reduce   @I 0 @N stride @A acc0 @V {src[d0+0]}>>>
		<<<reduce   @I 0 @N stride @A acc1 @V {src[d1+0]}>>>
		<<<reduce   @I 0 @N stride @A acc2 @V {src[d2+0]}>>>
		<<<reduce   @I 0 @N stride @A acc3 @V {src[d3+0]}>>>
		<<<reduce   @I 1 @N stride @A acc0 @V {src[d0+1]}>>>
		<<<reduce   @I 1 @N stride @A acc1 @V {src[d1+1]}>>>
		<<<reduce   @I 1 @N stride @A acc2 @V {src[d2+1]}>>>
		<<<reduce   @I 1 @N stride @A acc3 @V {src[d3+1]}>>>
		<<<reduce   @I 2 @N stride @A acc0 @V {src[d0+2]}>>>
		<<<reduce   @I 2 @N stride @A acc1 @V {src[d1+2]}>>>
		<<<reduce   @I 2 @N stride @A acc2 @V {src[d2+2]}>>>
		<<<reduce   @I 2 @N stride @A acc3 @V {src[d3+2]}>>>
		<<<finalize      @N stride @A acc0 @R {dst[0]}>>>
		<<<finalize      @N stride @A acc1 @R {dst[1]}>>>
		<<<finalize      @N stride @A acc2 @R {dst[2]}>>>
		<<<finalize      @N stride @A acc3 @R {dst[3]}>>>
	    }
	    PIXELS2(3) {
		<<<setup         @N stride @A acc0>>>
		<<<setup         @N stride @A acc1>>>
		<<<reduce   @I 0 @N stride @A acc0 @V {src[d0+0]}>>>
		<<<reduce   @I 0 @N stride @A acc1 @V {src[d1+0]}>>>
		<<<reduce   @I 1 @N stride @A acc0 @V {src[d0+1]}>>>
		<<<reduce   @I 1 @N stride @A acc1 @V {src[d1+1]}>>>
		<<<reduce   @I 2 @N stride @A acc0 @V {src[d0+2]}>>>
		<<<reduce   @I 2 @N stride @A acc1 @V {src[d1+2]}>>>
		<<<finalize      @N stride @A acc0 @R {dst[0]}>>>
		<<<finalize      @N stride @A acc1 @R {dst[1]}>>>
	    }
	    PIXELS1(3) {
		<<<setup         @N stride @A acc>>>
		<<<reduce   @I 0 @N stride @A acc @V {src[0]}>>>
		<<<reduce   @I 1 @N stride @A acc @V {src[1]}>>>
		<<<reduce   @I 2 @N stride @A acc @V {src[2]}>>>
		<<<finalize      @N stride @A acc @R *dst>>>
	    }
	} ; break;
	case 4: {
	    TRACE ("depth %d unrolled/4", stride);
	    aktive_uint k;
	    PIXELS4(4) {
		<<<setup             @N stride @A acc0>>>
		<<<setup             @N stride @A acc1>>>
		<<<setup         @N stride @A acc2>>>
		<<<setup         @N stride @A acc3>>>
		<<<reduce   @I 0 @N stride @A acc0 @V {src[d0+0]}>>>
		<<<reduce   @I 0 @N stride @A acc1 @V {src[d1+0]}>>>
		<<<reduce   @I 0 @N stride @A acc2 @V {src[d2+0]}>>>
		<<<reduce   @I 0 @N stride @A acc3 @V {src[d3+0]}>>>
		<<<reduce   @I 1 @N stride @A acc0 @V {src[d0+1]}>>>
		<<<reduce   @I 1 @N stride @A acc1 @V {src[d1+1]}>>>
		<<<reduce   @I 1 @N stride @A acc2 @V {src[d2+1]}>>>
		<<<reduce   @I 1 @N stride @A acc3 @V {src[d3+1]}>>>
		<<<reduce   @I 2 @N stride @A acc0 @V {src[d0+2]}>>>
		<<<reduce   @I 2 @N stride @A acc1 @V {src[d1+2]}>>>
		<<<reduce   @I 2 @N stride @A acc2 @V {src[d2+2]}>>>
		<<<reduce   @I 2 @N stride @A acc3 @V {src[d3+2]}>>>
		<<<reduce   @I 3 @N stride @A acc0 @V {src[d0+3]}>>>
		<<<reduce   @I 3 @N stride @A acc1 @V {src[d1+3]}>>>
		<<<reduce   @I 3 @N stride @A acc2 @V {src[d2+3]}>>>
		<<<reduce   @I 3 @N stride @A acc3 @V {src[d3+3]}>>>
		<<<finalize      @N stride @A acc0 @R {dst[0]}>>>
		<<<finalize      @N stride @A acc1 @R {dst[1]}>>>
		<<<finalize      @N stride @A acc2 @R {dst[2]}>>>
		<<<finalize      @N stride @A acc3 @R {dst[3]}>>>
	    }
	    PIXELS2(4) {
		<<<setup         @N stride @A acc0>>>
		<<<setup         @N stride @A acc1>>>
		<<<reduce   @I 0 @N stride @A acc0 @V {src[d0+0]}>>>
		<<<reduce   @I 0 @N stride @A acc1 @V {src[d1+0]}>>>
		<<<reduce   @I 1 @N stride @A acc0 @V {src[d0+1]}>>>
		<<<reduce   @I 1 @N stride @A acc1 @V {src[d1+1]}>>>
		<<<reduce   @I 2 @N stride @A acc0 @V {src[d0+2]}>>>
		<<<reduce   @I 2 @N stride @A acc1 @V {src[d1+2]}>>>
		<<<reduce   @I 3 @N stride @A acc0 @V {src[d0+3]}>>>
		<<<reduce   @I 3 @N stride @A acc1 @V {src[d1+3]}>>>
		<<<finalize      @N stride @A acc0 @R {dst[0]}>>>
		<<<finalize      @N stride @A acc1 @R {dst[1]}>>>
	    }
	    PIXELS1(4) {
		<<<setup         @N stride @A acc>>>
		<<<reduce   @I 0 @N stride @A acc @V {src[0]}>>>
		<<<reduce   @I 1 @N stride @A acc @V {src[1]}>>>
		<<<reduce   @I 2 @N stride @A acc @V {src[2]}>>>
		<<<reduce   @I 3 @N stride @A acc @V {src[3]}>>>
		<<<finalize      @N stride @A acc @R *dst>>>
	    }
	} ; break;
	default: {
	    TRACE ("depth %d unrolled/none, generic", stride);
	    aktive_uint k;
	    PIXELS4(1) {
		<<<setup                  @N stride @A acc0>>>
		<<<setup                  @N stride @A acc1>>>
		<<<setup                  @N stride @A acc2>>>
		<<<setup                  @N stride @A acc3>>>
		BANDS {
		    <<<reduce @I (0+band) @N stride @A acc0 @V {src[0+band]}>>>
		    <<<reduce @I (1+band) @N stride @A acc1 @V {src[1+band]}>>>
		    <<<reduce @I (2+band) @N stride @A acc2 @V {src[2+band]}>>>
		    <<<reduce @I (3+band) @N stride @A acc3 @V {src[3+band]}>>>
		}
		<<<finalize               @N stride @A acc0 @R {dst[0]}>>>
		<<<finalize               @N stride @A acc1 @R {dst[1]}>>>
		<<<finalize               @N stride @A acc2 @R {dst[2]}>>>
		<<<finalize               @N stride @A acc3 @R {dst[3]}>>>
	    }
	    PIXELS2(1) {
		<<<setup                  @N stride @A acc0>>>
		<<<setup                  @N stride @A acc1>>>
		BANDS {
		    <<<reduce @I (0+band) @N stride @A acc0 @V {src[0+band]}>>>
		    <<<reduce @I (1+band) @N stride @A acc1 @V {src[1+band]}>>>
		}
		<<<finalize               @N stride @A acc0 @R {dst[0]}>>>
		<<<finalize               @N stride @A acc1 @R {dst[1]}>>>
	    }
	    PIXELS1(1) {
		<<<setup              @N stride @A acc>>>
		BANDS {
		    <<<reduce @I band @N stride @A acc @V {src[band]}>>>
		}
		<<<finalize           @N stride @A acc @R *dst>>>
	    }
	} ; break;
    }

    #undef BANDS
    #undef PIXELS
}
