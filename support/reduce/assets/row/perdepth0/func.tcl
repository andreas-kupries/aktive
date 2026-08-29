
# this row reducer uses custom unrolled loops for the common image depths, and a
# generic loop for uncommon depths it generally attempts to concurrently compute
# the reductions over the available bands as that is the easiest data-parallel
# way, without requiring merges at the end.

# For bands <= 3 the cost is that we do not use the 4 possible lanes, only a
# subset. Especially for single-band the reduction should only be minimal faster
# than baseline, because it does not perform any unrolling at all.

def-func row perdepth0 {
    aktive_uint depth = stride, pixels = count;
    <<<once>>>
    // pixels ...   0            1        ... N-1
    // bands ...    0 1 .. D-1 0 1 .. D-1 ... 0 1 .. D-1
    // src[] =    { x x .. x   x x .. x   ... x x .. x   }
    //              *                          *       ... -->  dst/0
    //                *                          *     ... -->  dst/1
    //                  :                          :            :
    //                     *                           ... -->  dst/depth-1

#define ITER_PIXELS(step) aktive_uint column; for (column = 0; column < pixels; column++, src += (step))
#define ITER_BANDS        aktive_uint band;   for (band   = 0; band   < depth;  sbase++,  dst++, band++)

    switch (depth) {
	case 1: {
	    // reducing the single band along the row
	    TRACE ("depth %d /plain", depth);
	    // src[] = [ s0, s1, s2 ... ]
	    //           *   *   *  ... --> d/0

	    if (pixels == 1) { *dst = <<<single pixels>>>; return; }

	    <<<setup      @N pixels @A acc>>>
	    ITER_PIXELS(1) {
		<<<reduce @N pixels @A acc @V *src @I column>>>
	    }
	    <<<finalize   @N pixels @A acc @R *dst>>>
	} ; break;
	case 2: {
	    // reducing both bands concurrently
	    TRACE ("depth %d /custom, both bands concurrently", depth);

	    // s[] = [ s0/0, s0/1, s1/0, s1/1, s2/0, s2/1, ... ]
	    //         *           *           *           ...  d/0
	    //               *           *           *     ...  d/1

	    if (pixels == 1) {
		dst[0] = <<<single pixels *src {src[0]}>>>;
		dst[1] = <<<single pixels *src {src[1]}>>>;
		return;
	    }

	    <<<setup      @N pixels @A acc0>>>
	    <<<setup      @N pixels @A acc1>>>
	    ITER_PIXELS(2) {
		<<<reduce @N pixels @A acc0 @V {src[0]} @I column>>>
		<<<reduce @N pixels @A acc1 @V {src[1]} @I column>>>
	    }
	    <<<finalize   @N pixels @A acc0 @R {dst[0]}>>>
	    <<<finalize   @N pixels @A acc1 @R {dst[1]}>>>
	} ; break;
	case 3: {
	    // reducing all three bands concurrently
	    TRACE ("depth %d /custom, all bands concurrently", depth);

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

	    <<<setup      @N pixels @A acc0>>>
	    <<<setup      @N pixels @A acc1>>>
	    <<<setup      @N pixels @A acc2>>>
	    ITER_PIXELS(3) {
		<<<reduce @N pixels @A acc0 @V {src[0]} @I column>>>
		<<<reduce @N pixels @A acc1 @V {src[1]} @I column>>>
		<<<reduce @N pixels @A acc2 @V {src[2]} @I column>>>
	    }
	    <<<finalize   @N pixels @A acc0 @R {dst[0]}>>>
	    <<<finalize   @N pixels @A acc1 @R {dst[1]}>>>
	    <<<finalize   @N pixels @A acc2 @R {dst[2]}>>>
	} ; break;
	case 4: {
	    // reducing all four bands concurrently
	    TRACE ("depth %d /custom, all bands concurrently", depth);

	    // s[] = [ s0/0, s0/1, s0/2, s0/3, s1/0, s1/1, s1/2, s1/3, s2/0, s2/1, ... ]
	    //       | *                     | *                     | *           ...  d/0
	    //       |       *               |       *               |       *     ...  d/1
	    //       |             *         |             *         |             ...  d/2
	    //       |                   *   |                   *   |             ...  d/4

	    if (pixels == 1) {
		dst[0] = <<<single pixels *src {src[0]}>>>;
		dst[1] = <<<single pixels *src {src[1]}>>>;
		dst[2] = <<<single pixels *src {src[2]}>>>;
		dst[3] = <<<single pixels *src {src[3]}>>>;
		return;
	    }

	    <<<setup      @N pixels @A acc0>>>
	    <<<setup      @N pixels @A acc1>>>
	    <<<setup      @N pixels @A acc2>>>
	    <<<setup      @N pixels @A acc3>>>
	    ITER_PIXELS(4) {
		<<<reduce @N pixels @A acc0 @V {src[0]} @I column>>>
		<<<reduce @N pixels @A acc1 @V {src[1]} @I column>>>
		<<<reduce @N pixels @A acc2 @V {src[2]} @I column>>>
		<<<reduce @N pixels @A acc3 @V {src[3]} @I column>>>
	    }
	    <<<finalize   @N pixels @A acc0 @R {dst[0]}>>>
	    <<<finalize   @N pixels @A acc1 @R {dst[1]}>>>
	    <<<finalize   @N pixels @A acc2 @R {dst[2]}>>>
	    <<<finalize   @N pixels @A acc3 @R {dst[3]}>>>
	} ; break;
	default: {
	    // generic reduction of more than 4 bands. no concurrency. each band
	    // separately, in sequence
	    TRACE ("depth %d /generic, serial", depth);

	    double* sbase = src;
	    // s[] = [ s0/0, p0/1, ..., s0/depth, s1/0, s1/1, ... ]
	    //       | *                        | *                 d/0
	    //       |       *                  |       *           d/1
	    //       |             :            |          :        :
	    //       |                  *       |             ...   d/depth

	    if (pixels == 1) {
		ITER_BANDS { src = sbase; *dst = <<<single pixels>>>; }
		return;
	    }

	    ITER_BANDS {
		src = sbase;
		<<<setup      @N pixels @A acc>>>
		ITER_PIXELS (depth) {
		    <<<reduce @N pixels @A acc @I column @V *src>>>
		}
		<<<finalize   @N pixels @A acc @R *dst>>>
	    }
	} ; break;
    }

#undef ITER_BANDS
#undef ITER_PIXELS
}
