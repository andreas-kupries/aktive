
# this row reducer uses custom unrolled loops for the common image depths, and a
# generic loop for uncommon depths it generally attempts to concurrently compute
# the reductions over the available bands as that is the easiest data-parallel
# way, without requiring merges at the end.

# For bands <= 3 the cost is that we do not use the 4 possible lanes, only a
# subset. Especially for single-band the reduction should only be minimal faster
# than baseline, because it does not perform any unrolling at all.

def-func row perdepth0 {
    lappend map @name@    $name
    lappend map @once@    $once
    #
    # bands == 1
    #
    lappend map @setup@           [map $setup    @N pixels @A acc]                         ;# loop setup
    lappend map @reduce@          [map $reduce   @N pixels @A acc @V *src @I column]       ;# generic loop
    lappend map @final@     [trim [map $finalize @N pixels @A acc @R *dst]]                ;# post-processing
    #
    # bands in (2,3,4)
    #
    lappend map @setup/lane0@        [map $setup    @N pixels @A acc0]                        ;# loop setup
    lappend map @reduce/lane0@       [map $reduce   @N pixels @A acc0 @V {src[0]} @I column]  ;# unrolled pixels
    lappend map @final/lane0@  [trim [map $finalize @N pixels @A acc0 @R {dst[0]}]]           ;# post-processing

    lappend map @setup/lane1@        [map $setup    @N pixels @A acc1]                        ;# s.a
    lappend map @reduce/lane1@       [map $reduce   @N pixels @A acc1 @V {src[1]} @I column]  ;# s.a
    lappend map @final/lane1@  [trim [map $finalize @N pixels @A acc1 @R {dst[1]}]]           ;# s.a

    lappend map @setup/lane2@        [map $setup    @N pixels @A acc2]                        ;# s.a
    lappend map @reduce/lane2@       [map $reduce   @N pixels @A acc2 @V {src[2]} @I column]  ;# s.a
    lappend map @final/lane2@  [trim [map $finalize @N pixels @A acc2 @R {dst[2]}]]           ;# s.a

    lappend map @setup/lane3@        [map $setup    @N pixels @A acc3]                        ;# s.a
    lappend map @reduce/lane3@       [map $reduce   @N pixels @A acc3 @V {src[3]} @I column]  ;# s.a
    lappend map @final/lane3@  [trim [map $finalize @N pixels @A acc3 @R {dst[3]}]]           ;# s.a
    #
    # bands > 4
    #
    lappend map @setup/lane@         [map $setup    @N pixels @A acc]                         ;# loop setup
    lappend map @reduce/lane@        [map $reduce   @N pixels @A acc @I column @V *src]       ;# generic loop
    lappend map @final/lane@   [trim [map $finalize @N pixels @A acc @R *dst]]                ;# post-processing
} {
    @once@;
    // pixels ...   0            1        ... N-1
    // bands ...    0 1 .. D-1 0 1 .. D-1 ... 0 1 .. D-1
    // src[] =    { x x .. x   x x .. x   ... x x .. x   }
    //              *                          *       ... -->  dst/0
    //                *                          *     ... -->  dst/1
    //                  :                          :            :
    //                     *                           ... -->  dst/depth-1

#define ITER_PIXELS(step) aktive_uint column; for (column = 0; column < pixels; column++, src += (step))
#define ITER_BANDS        aktive_uint band;   for (band   = 0; band   < depth;  sbase++, dst++, band++)

    switch (depth) {
	case 1: {
	    // reducing the single band along the row
	    TRACE ("depth %d /plain", depth);
	    // src[] = [ s0, s1, s2 ... ]
	    //           *   *   *  ... --> d/0
	    @setup@;
	    ITER_PIXELS(1) {
		@reduce@;
	    }
	    @final@;
	} ; break;
	case 2: {
	    // reducing both bands concurrently
	    TRACE ("depth %d /custom, both bands concurrently", depth);

	    // s[] = [ s0/0, s0/1, s1/0, s1/1, s2/0, s2/1, ... ]
	    //         *           *           *           ...  d/0
	    //               *           *           *     ...  d/1

	    @setup/lane0@;
	    @setup/lane1@;
	    ITER_PIXELS(2) {
		@reduce/lane0@;
		@reduce/lane1@;
	    }
	    @final/lane0@;
	    @final/lane1@;
	} ; break;
	case 3: {
	    // reducing all three bands concurrently
	    TRACE ("depth %d /custom, all bands concurrently", depth);

	    // s[] = [ s0/0, s0/1, s0/2, s1/0, s1/1, s1/2, s2/0, s2/1, ... ]
	    //       | *               | *               | *           ...  d/0
	    //       |       *         |       *         |       *     ...  d/1
	    //       |             *   |             *   |             ...  d/2

	    @setup/lane0@;
	    @setup/lane1@;
	    @setup/lane2@;
	    ITER_PIXELS(3) {
		@reduce/lane0@;
		@reduce/lane1@;
		@reduce/lane2@;
	    }
	    @final/lane0@;
	    @final/lane1@;
	    @final/lane2@;
	} ; break;
	case 4: {
	    // reducing all four bands concurrently
	    TRACE ("depth %d /custom, all bands concurrently", depth);

	    // s[] = [ s0/0, s0/1, s0/2, s0/3, s1/0, s1/1, s1/2, s1/3, s2/0, s2/1, ... ]
	    //       | *                     | *                     | *           ...  d/0
	    //       |       *               |       *               |       *     ...  d/1
	    //       |             *         |             *         |             ...  d/2
	    //       |                   *   |                   *   |             ...  d/4

	    @setup/lane0@;
	    @setup/lane1@;
	    @setup/lane2@;
	    @setup/lane3@;
	    ITER_PIXELS(4) {
		@reduce/lane0@;
		@reduce/lane1@;
		@reduce/lane2@;
		@reduce/lane3@;
	    }
	    @final/lane0@;
	    @final/lane1@;
	    @final/lane2@;
	    @final/lane3@;
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

	    ITER_BANDS {
		src = sbase;
		@setup/lane@;
		ITER_PIXELS (depth) {
		    @reduce/lane@;
		}
		@final/lane@;
	    }
	} ; break;
    }

#undef ITER_BANDS
#undef ITER_PIXELS
}
