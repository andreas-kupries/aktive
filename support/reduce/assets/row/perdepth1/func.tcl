
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
    placeholder @name@    $name
    placeholder @once@    $once
    #
    #
    # bands == 1
    #
    placeholder @single1@                [single $single pixels]                                  ;# short row
    placeholder @setup1/lane0@           [map $setup    @N pixels @A acc0]                        ;# lane setup
    placeholder @setup1/lane1@           [map $setup    @N pixels @A acc1]                        ;#
    placeholder @setup1/lane2@           [map $setup    @N pixels @A acc2]                        ;#
    placeholder @setup1/lane3@           [map $setup    @N pixels @A acc3]                        ;#
    placeholder @reduce1/lane0@          [map $reduce   @N pixels @A acc0 @V {src[0]} @I (column+0)]  ;# lane loop
    placeholder @reduce1/lane1@          [map $reduce   @N pixels @A acc1 @V {src[1]} @I (column+1)]  ;#
    placeholder @reduce1/lane2@          [map $reduce   @N pixels @A acc2 @V {src[2]} @I (column+2)]  ;#
    placeholder @reduce1/lane3@          [map $reduce   @N pixels @A acc3 @V {src[3]} @I (column+3)]  ;#
    placeholder @final1@           [trim [map $finalize @N pixels @A acc0 @R *dst]]                   ;# lane final
    #
    # bands == 2, 2x pixel unrolling
    #
    placeholder @single2/lane0@       [map [single $single pixels] *src {src[0]}]	           ;# short row
    placeholder @setup2/lane0@        [map $setup    @N pixels @A acc0]                            ;# lane setup
    placeholder @reduce2/lane0@       [map $reduce   @N pixels @A acc0 @V {src[0]} @I (column+0)]  ;# lane ops
    placeholder @final2/lane0@  [trim [map $finalize @N pixels @A acc0 @R {dst[0]}]]               ;# lane complete

    placeholder @single2/lane1@       [map [single $single pixels] *src {src[1]}]
    placeholder @setup2/lane1@        [map $setup    @N pixels @A acc1]                            ;# s.a
    placeholder @reduce2/lane1@       [map $reduce   @N pixels @A acc1 @V {src[1]} @I (column+0)]  ;# s.a
    placeholder @final2/lane1@  [trim [map $finalize @N pixels @A acc1 @R {dst[1]}]]               ;# s.a

    placeholder @single2/lane2@       [map [single $single pixels] *src {src[2]}]
    placeholder @setup2/lane2@        [map $setup    @N pixels @A acc2]                            ;# s.a
    placeholder @reduce2/lane2@       [map $reduce   @N pixels @A acc2 @V {src[2]} @I (column+1)]  ;# s.a
    # lane 2 merges into lane 0, not finalize

    placeholder @single2/lane3@       [map [single $single pixels] *src {src[3]}]
    placeholder @setup2/lane3@        [map $setup    @N pixels @A acc3]                            ;# s.a
    placeholder @reduce2/lane3@       [map $reduce   @N pixels @A acc3 @V {src[3]} @I (column+1)]  ;# s.a
    # lane 3 merges into lane 1, not finalize
    #
    # bands == 3, 2x pixel unrolling
    #
    placeholder @single3/lane0@       [map [single $single pixels] *src {src[0]}]	           ;# short row
    placeholder @setup3/lane0@        [map $setup    @N pixels @A acc0]                            ;# lane setup
    placeholder @reduce3/lane0@       [map $reduce   @N pixels @A acc0 @V {src[0]} @I (column+0)]  ;# lane ops
    placeholder @final3/lane0@  [trim [map $finalize @N pixels @A acc0 @R {dst[0]}]]               ;# lane complete

    placeholder @single3/lane1@       [map [single $single pixels] *src {src[1]}]
    placeholder @setup3/lane1@        [map $setup    @N pixels @A acc1]                            ;# s.a
    placeholder @reduce3/lane1@       [map $reduce   @N pixels @A acc1 @V {src[1]} @I (column+0)]  ;# s.a
    placeholder @final3/lane1@  [trim [map $finalize @N pixels @A acc1 @R {dst[1]}]]               ;# s.a

    placeholder @single3/lane2@       [map [single $single pixels] *src {src[2]}]
    placeholder @setup3/lane2@        [map $setup    @N pixels @A acc2]                            ;# s.a
    placeholder @reduce3/lane2@       [map $reduce   @N pixels @A acc2 @V {src[2]} @I (column+0)]  ;# s.a
    placeholder @final3/lane2@  [trim [map $finalize @N pixels @A acc2 @R {dst[2]}]]               ;# s.a

    placeholder @single3/lane3@       [map [single $single pixels] *src {src[3]}]
    placeholder @setup3/lane3@        [map $setup    @N pixels @A acc3]                            ;# s.a
    placeholder @reduce3/lane3@       [map $reduce   @N pixels @A acc3 @V {src[3]} @I (column+1)]  ;# s.a
    # lane 3 merges into lane 0, no finalize

    placeholder @single3/lane4@       [map [single $single pixels] *src {src[4]}]
    placeholder @setup3/lane4@        [map $setup    @N pixels @A acc4]                            ;# s.a
    placeholder @reduce3/lane4@       [map $reduce   @N pixels @A acc4 @V {src[4]} @I (column+1)]  ;# s.a
    # lane 4 merges into lane 1, no finalize

    placeholder @single3/lane5@       [map [single $single pixels] *src {src[5]}]
    placeholder @setup3/lane5@        [map $setup    @N pixels @A acc5]                            ;# s.a
    placeholder @reduce3/lane5@       [map $reduce   @N pixels @A acc5 @V {src[5]} @I (column+1)]  ;# s.a
    # lane 5 merges into lane 2, no finalize
    #
    # bands == 4
    #
    placeholder @single4/lane0@       [map [single $single pixels]   *src {src[0]}]	           ;# short row
    placeholder @setup4/lane0@        [map $setup    @N pixels @A acc0]                            ;# lane setup
    placeholder @reduce4/lane0@       [map $reduce   @N pixels @A acc0 @V {src[0]} @I column]      ;# lane ops
    placeholder @final4/lane0@  [trim [map $finalize @N pixels @A acc0 @R {dst[0]}]]               ;# lane complete

    placeholder @single4/lane1@       [map [single $single pixels]   *src {src[1]}]	           ;# short row
    placeholder @setup4/lane1@        [map $setup    @N pixels @A acc1]                            ;# lane setup
    placeholder @reduce4/lane1@       [map $reduce   @N pixels @A acc1 @V {src[1]} @I column]      ;# lane op
    placeholder @final4/lane1@  [trim [map $finalize @N pixels @A acc1 @R {dst[1]}]]               ;# lane complete

    placeholder @single4/lane2@       [map [single $single pixels]   *src {src[2]}]	           ;# short row
    placeholder @setup4/lane2@        [map $setup    @N pixels @A acc2]                            ;# lane setup
    placeholder @reduce4/lane2@       [map $reduce   @N pixels @A acc2 @V {src[2]} @I column]      ;# lane op
    placeholder @final4/lane2@  [trim [map $finalize @N pixels @A acc2 @R {dst[2]}]]               ;# lane complete

    placeholder @single4/lane3@       [map [single $single pixels]   *src {src[3]}]	           ;# short row
    placeholder @setup4/lane3@        [map $setup    @N pixels @A acc3]                            ;# lane setup
    placeholder @reduce4/lane3@       [map $reduce   @N pixels @A acc3 @V {src[3]} @I column]      ;# lane op
    placeholder @final4/lane3@  [trim [map $finalize @N pixels @A acc3 @R {dst[3]}]]               ;# lane complete
    #
    # bands > 4
    #
    placeholder @setupN/lane0@       [map $setup    @N pixels @A acc0]                        ;# loop setup
    placeholder @setupN/lane1@       [map $setup    @N pixels @A acc1]                        ;#
    placeholder @setupN/lane2@       [map $setup    @N pixels @A acc2]                        ;#
    placeholder @setupN/lane3@       [map $setup    @N pixels @A acc3]                        ;#

    placeholder @reduceN/lane0@      [map $reduce   @N pixels @A acc0 @V {src[d0]} @I (column+0)] ;# generic loop
    placeholder @reduceN/lane1@      [map $reduce   @N pixels @A acc1 @V {src[d1]} @I (column+1)] ;#
    placeholder @reduceN/lane2@      [map $reduce   @N pixels @A acc2 @V {src[d2]} @I (column+2)] ;#
    placeholder @reduceN/lane3@      [map $reduce   @N pixels @A acc3 @V {src[d3]} @I (column+3)] ;#

    placeholder @finalN/lane0@  [trim [map $finalize @N pixels @A acc0 @R *dst]]              ;# post-processing
    #
    # merges for all multi-lane setups with unrolled pixel loop
    #
    placeholder @merge/lane01@       [map $merge    @AD acc0 @AS acc1]                        ;# lane merge
    placeholder @merge/lane02@       [map $merge    @AD acc0 @AS acc2]                        ;#
    placeholder @merge/lane03@       [map $merge    @AD acc0 @AS acc3]                        ;#
    #
    placeholder @merge/lane13@       [map $merge    @AD acc1 @AS acc3]                        ;#
    placeholder @merge/lane14@       [map $merge    @AD acc1 @AS acc4]                        ;#
    #
    placeholder @merge/lane23@       [map $merge    @AD acc2 @AS acc3]                        ;#
    placeholder @merge/lane25@       [map $merge    @AD acc2 @AS acc5]                        ;#
} {
    aktive_uint depth = stride, pixels = count;
    @once@
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

	    if (pixels == 1) { *dst = @single1@; return; }

	    @setup1/lane0@
	    @setup1/lane1@
	    @setup1/lane2@
	    @setup1/lane3@

	    ITER_PIXELS(4,4) {
		/* pix 0, band 0 */ @reduce1/lane0@
		/* pix 1, band 0 */ @reduce1/lane1@
		/* pix 2, band 0 */ @reduce1/lane2@
		/* pix 3, band 0 */ @reduce1/lane3@
	    }

	    @merge/lane23@

	    ITER_PIXELS(2,2) {
		/* pix 0, band 0 */ @reduce1/lane0@
		/* pix 1, band 0 */ @reduce1/lane1@
	    }
	    ITER_PIXELS(1,1) {
		/* pix 0, band 0 */ @reduce1/lane0@
	    }

	    @merge/lane01@
	    @merge/lane02@

	    @final1@
	} ; break;
	case 2: {
	    // reducing both bands concurrently, plus 2x pixel unrolling
	    TRACE ("depth %d /custom, both bands concurrently, 2x pixels", depth);

	    // s[] = [ s0/0, s0/1, s1/0, s1/1, s2/0, s2/1, ... ]
	    //         *           *           *           ...  d/0
	    //               *           *           *     ...  d/1

	    if (pixels == 1) {
		dst[0] = @single2/lane0@;
		dst[1] = @single2/lane1@;
		return;
	    }

	    @setup2/lane0@
	    @setup2/lane1@
	    @setup2/lane2@
	    @setup2/lane3@

	    ITER_PIXELS(2,4) {
		/* pix 0, band 0 */ @reduce2/lane0@
		/*        band 1 */ @reduce2/lane1@
		/* pix 1, band 0 */ @reduce2/lane2@
		/*        band 1 */ @reduce2/lane3@
	    }
	    ITER_PIXELS(1,2) {
		/* pix 0, band 0 */ @reduce2/lane0@
		/*        band 1 */ @reduce2/lane1@
	    }

	    @merge/lane02@
	    @merge/lane13@

	    @final2/lane0@
	    @final2/lane1@
	} ; break;
	case 3: {
	    // reducing all three bands concurrently, plus 2x pixel unrolling
	    TRACE ("depth %d /custom, all bands concurrently, 2x pixels", depth);

	    // s[] = [ s0/0, s0/1, s0/2, s1/0, s1/1, s1/2, s2/0, s2/1, ... ]
	    //       | *               | *               | *           ...  d/0
	    //       |       *         |       *         |       *     ...  d/1
	    //       |             *   |             *   |             ...  d/2

	    if (pixels == 1) {
		dst[0] = @single3/lane0@;
		dst[1] = @single3/lane1@;
		dst[2] = @single3/lane2@;
		return;
	    }

	    @setup3/lane0@
	    @setup3/lane1@
	    @setup3/lane2@
	    @setup3/lane3@
	    @setup3/lane4@
	    @setup3/lane5@

	    ITER_PIXELS(2,6) {
		/* pix 0, band 0 */ @reduce3/lane0@
		/*        band 1 */ @reduce3/lane1@
		/*        band 2 */ @reduce3/lane2@
		/* pix 1, band 0 */ @reduce3/lane3@
		/*        band 1 */ @reduce3/lane4@
		/*        band 2 */ @reduce3/lane5@
	    }
	    ITER_PIXELS(1,3) {
		/* pix 0, band 0 */ @reduce3/lane0@
		/*        band 1 */ @reduce3/lane1@
		/*        band 2 */ @reduce3/lane2@
	    }

	    @merge/lane03@
	    @merge/lane14@
	    @merge/lane25@

	    @final3/lane0@
	    @final3/lane1@
	    @final3/lane2@
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
		dst[0] = @single4/lane0@;
		dst[1] = @single4/lane1@;
		dst[2] = @single4/lane2@;
		dst[3] = @single4/lane3@;
		return;
	    }

	    @setup4/lane0@
	    @setup4/lane1@
	    @setup4/lane2@
	    @setup4/lane3@

	    ITER_PIXELS(1,4) {
		/* pix 0, band 0 */ @reduce4/lane0@
		/*        band 1 */ @reduce4/lane1@
		/*        band 2 */ @reduce4/lane2@
		/*        band 3 */ @reduce4/lane3@
	    }

	    @final4/lane0@
	    @final4/lane1@
	    @final4/lane2@
	    @final4/lane3@
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
		ITER_BANDS { src = sbase; *dst = @single1@; }
		return;
	    }

	    aktive_uint d0 = 0*depth;
	    aktive_uint d1 = 1*depth;
	    aktive_uint d2 = 2*depth;
	    aktive_uint d3 = 3*depth;
	    aktive_uint d4 = 4*depth;

	    ITER_BANDS {
		src    = sbase;
		column = cbase;
		k      = pixels;

		@setupN/lane0@
		@setupN/lane1@
		@setupN/lane2@
		@setupN/lane3@

		ITER_PIXELS (4,d4) {
		    @reduceN/lane0@
		    @reduceN/lane1@
		    @reduceN/lane2@
		    @reduceN/lane3@
		}

		@merge/lane23@

		ITER_PIXELS (2,d2) {
		    @reduceN/lane0@
		    @reduceN/lane1@
		}
		ITER_PIXELS (1,d1) {
		    @reduceN/lane0@
		}

		@merge/lane01@
		@merge/lane02@

		@finalN/lane0@

		cbase++;
	    }
	} ; break;
    }

#undef ITER_BANDS
#undef ITER_PIXELS
}
