
# this row reducer uses custom unrolled loops for the common image depths, and a
# generic loop for uncommon depths it generally attempts to concurrently compute
# the reductions over the available bands as that is the easiest data-parallel
# way, without requiring merges at the end.

# in contrast to `perdepth0`, which this one is derived from the custom loops
# attempt higher scalarity by unrolling the pixel loop as well to reach 4x
# unrolling.

# i.e. for depth == 1 the pixel loop is unrolled 4x - for 1x 4x = 4x
# and  for depth == 2 the pixel loop is unrolled 2x - for 2x 2x = 4x
# and  for depth == 3 the pixel loop is unrolled 2x - for 3x 2x = 6x
#      for depth == 4 the pixel loop is not unrolled
#      for depth > 4 the bands are handled sequentially still, with 4x pixel unrolling

def-func row perdepth1 {
    aktive_uint depth = stride, pixels = count;
    <<<once>>>
    // pixels ...   0            1        ... N-1
    // bands ...    0 1 .. D-1 0 1 .. D-1 ... 0 1 .. D-1
    // src[] =    { x x .. x   x x .. x   ... x x .. x   }
    //              *                          *       ... -->  dst/0
    //                *                          *     ... -->  dst/1
    //                  :                          :            :
    //                     *                           ... -->  dst/depth-1

    aktive_uint column = 0, k = pixels;

#define ITER_PIXELS(col,step)               for (; k > (col-1); k -= (col), column += (col), src += (step))
#define ITER_BANDS        aktive_uint band; for (band = 0; band   < depth;  sbase++,  dst++, band++)

    switch (depth) {
	case 1: {
	    // reducing the single band along the row, using 4x pixel unrolling
	    TRACE ("depth %d /4x pixel unroll", depth);
	    // src[] = [ s0, s1, s2 ... ]
	    //           *   *   *  ... --> d/0

	    if (pixels == 1) { *dst =  <<<single pixels>>>; return; }

	    <<<setup    @N pixels @A acc0>>>
	    <<<setup    @N pixels @A acc1>>>
	    <<<setup    @N pixels @A acc2>>>
	    <<<setup    @N pixels @A acc3>>>

	    ITER_PIXELS(4,4) {
		/* pix 0, band 0 */ <<<reduce @N pixels @A acc0 @V {src[0]} @I (column+0)>>>
		/* pix 1, band 0 */ <<<reduce @N pixels @A acc1 @V {src[1]} @I (column+1)>>>
		/* pix 2, band 0 */ <<<reduce @N pixels @A acc2 @V {src[2]} @I (column+2)>>>
		/* pix 3, band 0 */ <<<reduce @N pixels @A acc3 @V {src[3]} @I (column+3)>>>
	    }

	    <<<merge @AD acc2 @AS acc3>>>

	    ITER_PIXELS(2,2) {
		/* pix 0, band 0 */ <<<reduce @N pixels @A acc0 @V {src[0]} @I (column+0)>>>
		/* pix 1, band 0 */ <<<reduce @N pixels @A acc1 @V {src[1]} @I (column+1)>>>
	    }
	    ITER_PIXELS(1,1) {
		/* pix 0, band 0 */ <<<reduce @N pixels @A acc0 @V {src[0]} @I (column+0)>>>
	    }

	     <<<merge @AD acc0 @AS acc1>>>
	     <<<merge @AD acc0 @AS acc2>>>

	    <<<finalize @N pixels @A acc0 @R *dst>>>
	} ; break;
	case 2: {
	    // reducing both bands concurrently, plus 2x pixel unrolling
	    TRACE ("depth %d /custom, both bands concurrently, 2x pixels", depth);

	    // s[] = [ s0/0, s0/1, s1/0, s1/1, s2/0, s2/1, ... ]
	    //         *           *           *           ...  d/0
	    //               *           *           *     ...  d/1

	    if (pixels == 1) {
		dst[0] = <<<single pixels *src {src[0]}>>>;
		dst[1] = <<<single pixels *src {src[1]}>>>;
		return;
	    }

	    <<<setup    @N pixels @A acc0>>>
	    <<<setup    @N pixels @A acc1>>>
	    <<<setup    @N pixels @A acc2>>>
	    <<<setup    @N pixels @A acc3>>>

	    ITER_PIXELS(2,4) {
		/* pix 0, band 0 */ <<<reduce   @N pixels @A acc0 @V {src[0]} @I (column+0)>>>
		/*        band 1 */ <<<reduce   @N pixels @A acc1 @V {src[1]} @I (column+0)>>>
		/* pix 1, band 0 */ <<<reduce   @N pixels @A acc2 @V {src[2]} @I (column+1)>>>
		/*        band 1 */ <<<reduce   @N pixels @A acc3 @V {src[3]} @I (column+1)>>>
	    }
	    ITER_PIXELS(1,2) {
		/* pix 0, band 0 */ <<<reduce   @N pixels @A acc0 @V {src[0]} @I (column+0)>>>
		/*        band 1 */ <<<reduce   @N pixels @A acc1 @V {src[1]} @I (column+0)>>>
	    }

	    <<<merge    @AD acc0 @AS acc2>>>
	    <<<merge    @AD acc1 @AS acc3>>>

	    <<<finalize @N pixels @A acc0 @R {dst[0]}>>>
	    <<<finalize @N pixels @A acc1 @R {dst[1]}>>>
	} ; break;
	case 3: {
	    // reducing all three bands concurrently, plus 2x pixel unrolling
	    TRACE ("depth %d /custom, all bands concurrently, 2x pixels", depth);

	    // s[] = [ s0/0, s0/1, s0/2, s1/0, s1/1, s1/2, s2/0, s2/1, ... ]
	    //       | *               | *               | *           ...  d/0
	    //       |       *         |       *         |       *     ...  d/1
	    //       |             *   |             *   |             ...  d/2

	    if (pixels == 1) {
		dst[0] = <<<single pixels *src {src[0]}>>>;
		dst[1] = <<<single pixels *src {src[1]}>>>;
		dst[2] = <<<single pixels *src {src[2]}>>>;
		return;
	    }

	    <<<setup    @N pixels @A acc0>>>
	    <<<setup    @N pixels @A acc1>>>
	    <<<setup    @N pixels @A acc2>>>
	    <<<setup    @N pixels @A acc3>>>
	    <<<setup    @N pixels @A acc4>>>
	    <<<setup    @N pixels @A acc5>>>

	    ITER_PIXELS(2,6) {
		/* pix 0, band 0 */ <<<reduce   @N pixels @A acc0 @V {src[0]} @I (column+0)>>>
		/*        band 1 */ <<<reduce   @N pixels @A acc1 @V {src[1]} @I (column+0)>>>
		/*        band 2 */ <<<reduce   @N pixels @A acc2 @V {src[2]} @I (column+0)>>>
		/* pix 1, band 0 */ <<<reduce   @N pixels @A acc3 @V {src[3]} @I (column+1)>>>
		/*        band 1 */ <<<reduce   @N pixels @A acc4 @V {src[4]} @I (column+1)>>>
		/*        band 2 */ <<<reduce   @N pixels @A acc5 @V {src[5]} @I (column+1)>>>
	    }
	    ITER_PIXELS(1,3) {
		/* pix 0, band 0 */ <<<reduce   @N pixels @A acc0 @V {src[0]} @I (column+0)>>>
		/*        band 1 */ <<<reduce   @N pixels @A acc1 @V {src[1]} @I (column+0)>>>
		/*        band 2 */ <<<reduce   @N pixels @A acc2 @V {src[2]} @I (column+0)>>>
	    }

	    <<<merge    @AD acc0 @AS acc3>>>
	    <<<merge    @AD acc1 @AS acc4>>>
	    <<<merge    @AD acc2 @AS acc5>>>

	    <<<finalize @N pixels @A acc0 @R {dst[0]}>>>
	    <<<finalize @N pixels @A acc1 @R {dst[1]}>>>
	    <<<finalize @N pixels @A acc2 @R {dst[2]}>>>
	} ; break;
	case 4: {
	    // reducing all four bands concurrently, no pixel unrolling
	    TRACE ("depth %d /custom, all bands concurrently, 1x pixel", depth);

	    // s[] = [ s0/0, s0/1, s0/2, s0/3, s1/0, s1/1, s1/2, s1/3, s2/0, s2/1, ... ]
	    //       | *                     | *                     | *           ...  d/0
	    //       |       *               |       *               |       *     ...  d/1
	    //       |             *         |             *         |             ...  d/2
	    //       |                   *   |                   *   |             ...  d/4

	    if (pixels == 1) {
		dst[0] = <<<single pixels   *src {src[0]}>>>;
		dst[1] = <<<single pixels   *src {src[1]}>>>;
		dst[2] = <<<single pixels   *src {src[2]}>>>;
		dst[3] = <<<single pixels   *src {src[3]}>>>;
		return;
	    }

	    <<<setup @N pixels @A acc0>>>
	    <<<setup @N pixels @A acc1>>>
	    <<<setup @N pixels @A acc2>>>
	    <<<setup @N pixels @A acc3>>>

	    ITER_PIXELS(1,4) {
		/* pix 0, band 0 */ <<<reduce   @N pixels @A acc0 @V {src[0]} @I column>>>
		/*        band 1 */ <<<reduce   @N pixels @A acc1 @V {src[1]} @I column>>>
		/*        band 2 */ <<<reduce   @N pixels @A acc2 @V {src[2]} @I column>>>
		/*        band 3 */ <<<reduce   @N pixels @A acc3 @V {src[3]} @I column>>>
	    }

	    <<<finalize @N pixels @A acc0 @R {dst[0]}>>>
	    <<<finalize @N pixels @A acc1 @R {dst[1]}>>>
	    <<<finalize @N pixels @A acc2 @R {dst[2]}>>>
	    <<<finalize @N pixels @A acc3 @R {dst[3]}>>>
	} ; break;
	default: {
	    // generic reduction of more than 4 bands.
	    // bands sequentially, with 4x pixel unrolling separately, in sequence
	    TRACE ("depth %d /generic, band serial, 4x pixels", depth);

	    double*     sbase = src;
	    aktive_uint cbase = column;

	    // s[] = [ s0/0, p0/1, ..., s0/depth, s1/0, s1/1, ... ]
	    //       | *                        | *                 d/0
	    //       |       *                  |       *           d/1
	    //       |             :            |          :        :
	    //       |                  *       |             ...   d/depth

	    if (pixels == 1) {
		ITER_BANDS { src = sbase; *dst = <<<single pixels>>>; }
		return;
	    }

	    const aktive_uint d0 = 0 * depth;
	    const aktive_uint d1 = 1 * depth;
	    const aktive_uint d2 = 2 * depth;
	    const aktive_uint d3 = 3 * depth;
	    const aktive_uint d4 = 4 * depth;

	    ITER_BANDS {
		src    = sbase;
		column = cbase;
		k      = pixels;

		<<<setup    @N pixels @A acc0>>>
		<<<setup    @N pixels @A acc1>>>
		<<<setup    @N pixels @A acc2>>>
		<<<setup    @N pixels @A acc3>>>

		ITER_PIXELS (4,d4) {
		    <<<reduce   @N pixels @A acc0 @V {src[d0]} @I (column+0)>>>
		    <<<reduce   @N pixels @A acc1 @V {src[d1]} @I (column+1)>>>
		    <<<reduce   @N pixels @A acc2 @V {src[d2]} @I (column+2)>>>
		    <<<reduce   @N pixels @A acc3 @V {src[d3]} @I (column+3)>>>
		}

	        <<<merge    @AD acc2 @AS acc3>>>

		ITER_PIXELS (2,d2) {
		    <<<reduce   @N pixels @A acc0 @V {src[d0]} @I (column+0)>>>
		    <<<reduce   @N pixels @A acc1 @V {src[d1]} @I (column+1)>>>
		}
		ITER_PIXELS (1,d1) {
		    <<<reduce   @N pixels @A acc0 @V {src[d0]} @I (column+0)>>>
		}

		<<<merge    @AD acc0 @AS acc1>>>
		<<<merge    @AD acc0 @AS acc2>>>

		<<<finalize @N pixels @A acc0 @R *dst>>>
	    }
	} ; break;
    }

#undef ITER_BANDS
#undef ITER_PIXELS
}
