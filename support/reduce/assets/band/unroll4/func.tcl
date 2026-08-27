
# this band reducer is a variant of the `perdepth` reducer which also unrolls
# the outer (pixel) loop.

def-func band unroll4 {
    placeholder @name@    $name
    placeholder @once@    $once
    #
    placeholder @single@       [single $single stride]
    placeholder @single0@ [map [single $single stride] *src {src[0]}]
    placeholder @single1@ [map [single $single stride] *src {src[1]}]
    placeholder @single2@ [map [single $single stride] *src {src[2]}]
    placeholder @single3@ [map [single $single stride] *src {src[3]}]
    #
    placeholder @setup@   [map $setup         @N stride @A acc]           ;# loop setup
    placeholder @final@   [map $finalize      @N stride @A acc @R *dst]     ;# post-processing
    placeholder @reduce@  [map $reduce   @I j @N stride @A acc @V {src[j]}] ;# generic loop
    placeholder @reduce0@ [map $reduce   @I 0 @N stride @A acc @V {src[0]}] ;# unrolled inner
    placeholder @reduce1@ [map $reduce   @I 1 @N stride @A acc @V {src[1]}] ;# s.a
    placeholder @reduce2@ [map $reduce   @I 2 @N stride @A acc @V {src[2]}] ;# s.a
    placeholder @reduce3@ [map $reduce   @I 3 @N stride @A acc @V {src[3]}] ;# s.a
    #
    #
    placeholder @setup0@     [map $setup             @N stride @A acc0]              ;# loop setup, lane 0
    placeholder @final0@     [map $finalize          @N stride @A acc0 @R {dst[0]}]    ;# post-processing
    placeholder @reduce0*@   [map $reduce   @I (0+j) @N stride @A acc0 @V {src[0+j]}]  ;# unrolled inner
    placeholder @reduce0/0@  [map $reduce   @I 0     @N stride @A acc0 @V {src[d0+0]}] ;# unrolled inner
    placeholder @reduce0/1@  [map $reduce   @I 1     @N stride @A acc0 @V {src[d0+1]}] ;# unrolled inner
    placeholder @reduce0/2@  [map $reduce   @I 2     @N stride @A acc0 @V {src[d0+2]}] ;# unrolled inner
    placeholder @reduce0/3@  [map $reduce   @I 3     @N stride @A acc0 @V {src[d0+3]}] ;# unrolled inner
    #
    placeholder @setup1@     [map $setup             @N stride @A acc1]              ;# loop setup, lane 1
    placeholder @final1@     [map $finalize          @N stride @A acc1 @R {dst[1]}]    ;# post-processing
    placeholder @reduce1*@   [map $reduce   @I (1+j) @N stride @A acc1 @V {src[1+j]}]  ;# s.a
    placeholder @reduce1/0@  [map $reduce   @I 0     @N stride @A acc1 @V {src[d1+0]}] ;# unrolled inner
    placeholder @reduce1/1@  [map $reduce   @I 1     @N stride @A acc1 @V {src[d1+1]}] ;# unrolled inner
    placeholder @reduce1/2@  [map $reduce   @I 2     @N stride @A acc1 @V {src[d1+2]}] ;# unrolled inner
    placeholder @reduce1/3@  [map $reduce   @I 3     @N stride @A acc1 @V {src[d1+3]}] ;# unrolled inner
    #
    placeholder @setup2@     [map $setup             @N stride @A acc2]              ;# loop setup, lane 2
    placeholder @final2@     [map $finalize          @N stride @A acc2 @R {dst[2]}]    ;# post-processing
    placeholder @reduce2*@   [map $reduce   @I (2+j) @N stride @A acc2 @V {src[2+j]}]  ;# s.a
    placeholder @reduce2/0@  [map $reduce   @I 0     @N stride @A acc2 @V {src[d2+0]}] ;# unrolled inner
    placeholder @reduce2/1@  [map $reduce   @I 1     @N stride @A acc2 @V {src[d2+1]}] ;# unrolled inner
    placeholder @reduce2/2@  [map $reduce   @I 2     @N stride @A acc2 @V {src[d2+2]}] ;# unrolled inner
    placeholder @reduce2/3@  [map $reduce   @I 3     @N stride @A acc2 @V {src[d2+3]}] ;# unrolled inner
    #
    placeholder @setup3@     [map $setup             @N stride @A acc3]              ;# loop setup, lane 3
    placeholder @final3@     [map $finalize          @N stride @A acc3 @R {dst[3]}]    ;# post-processing
    placeholder @reduce3*@   [map $reduce   @I (3+j) @N stride @A acc3 @V {src[3+j]}]  ;# s.a
    placeholder @reduce3/0@  [map $reduce   @I 0     @N stride @A acc3 @V {src[d3+0]}] ;# unrolled inner
    placeholder @reduce3/1@  [map $reduce   @I 1     @N stride @A acc3 @V {src[d3+1]}] ;# unrolled inner
    placeholder @reduce3/2@  [map $reduce   @I 2     @N stride @A acc3 @V {src[d3+2]}] ;# unrolled inner
    placeholder @reduce3/3@  [map $reduce   @I 3     @N stride @A acc3 @V {src[d3+3]}] ;# unrolled inner
} {
    @once@
    #define PIXELS4(step) for (k = count; k > 4; k-= 4, dst += 4, src += 4*(step))
    #define PIXELS2(step) for (         ; k > 2; k-= 2, dst += 2, src += 2*(step))
    #define PIXELS1(step) for (         ; k > 0; k--  , dst += 1, src +=   (step))
    #define BANDS         aktive_uint j; for (j = 0; j < stride; j++)

    const aktive_uint d0 = 0;
    const aktive_uint d1 = d0 + stride;
    const aktive_uint d2 = d1 + stride;
    const aktive_uint d3 = d2 + stride;
    const aktive_uint d4 = d3 + stride;

    switch (stride) {
	case 1: {
	    // note - due to highlevel simplifications this case should not be reached
	    // except in benchmarking
	    TRACE ("depth %d unrolled/none", stride);
	    aktive_uint k;
	    PIXELS4(1) { dst[0] = @single0@; dst[1] = @single1@; dst[2] = @single2@; dst[3] = @single3@; }
	    PIXELS2(1) { dst[0] = @single0@; dst[1] = @single1@; }
	    PIXELS1(1) { *dst   = @single@; }
	} ; break;
	case 2: {
	    TRACE ("depth %d unrolled/2", stride);
	    aktive_uint k;
	    PIXELS4(2) {
		@setup0@
		@setup1@
		@setup2@
		@setup3@
		@reduce0/0@
		@reduce1/0@
		@reduce2/0@
		@reduce3/0@
		@reduce0/1@
		@reduce1/1@
		@reduce2/1@
		@reduce3/1@
		@final0@
		@final1@
		@final2@
		@final3@
	    }
	    PIXELS2(2) {
		@setup0@
		@setup1@
		@reduce0/0@
		@reduce1/0@
		@reduce0/1@
		@reduce1/1@
		@final0@
		@final1@
	    }
	    PIXELS1(2) {
		@setup@
		@reduce0@
		@reduce1@
		@final@
	    }
	} ; break;
	case 3: {
	    TRACE ("depth %d unrolled/3", stride);
	    aktive_uint k;
	    PIXELS4(3) {
		@setup0@
		@setup1@
		@setup2@
		@setup3@
		@reduce0/0@
		@reduce1/0@
		@reduce2/0@
		@reduce3/0@
		@reduce0/1@
		@reduce1/1@
		@reduce2/1@
		@reduce3/1@
		@reduce0/2@
		@reduce1/2@
		@reduce2/2@
		@reduce3/2@
		@final0@
		@final1@
		@final2@
		@final3@
	    }
	    PIXELS2(3) {
		@setup0@
		@setup1@
		@reduce0/0@
		@reduce1/0@
		@reduce0/1@
		@reduce1/1@
		@reduce0/2@
		@reduce1/2@
		@final0@
		@final1@
	    }
	    PIXELS1(3) {
		@setup@
		@reduce0@
		@reduce1@
		@reduce2@
		@final@
	    }
	} ; break;
	case 4: {
	    TRACE ("depth %d unrolled/4", stride);
	    aktive_uint k;
	    PIXELS4(4) {
		@setup0@
		@setup1@
		@setup2@
		@setup3@
		@reduce0/0@
		@reduce1/0@
		@reduce2/0@
		@reduce3/0@
		@reduce0/1@
		@reduce1/1@
		@reduce2/1@
		@reduce3/1@
		@reduce0/2@
		@reduce1/2@
		@reduce2/2@
		@reduce3/2@
		@reduce0/3@
		@reduce1/3@
		@reduce2/3@
		@reduce3/3@
		@final0@
		@final1@
		@final2@
		@final3@
	    }
	    PIXELS2(4) {
		@setup0@
		@setup1@
		@reduce0/0@
		@reduce1/0@
		@reduce0/1@
		@reduce1/1@
		@reduce0/2@
		@reduce1/2@
		@reduce0/3@
		@reduce1/3@
		@final0@
		@final1@
	    }
	    PIXELS1(4) {
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
	    aktive_uint k;
	    PIXELS4(1) {
		@setup0@
		@setup1@
		@setup2@
		@setup3@
		BANDS {
		    @reduce0*@
		    @reduce1*@
		    @reduce2*@
		    @reduce3*@
		}
		@final0@
		@final1@
		@final2@
		@final3@
	    }
	    PIXELS2(1) {
		@setup0@
		@setup1@
		BANDS {
		    @reduce0*@
		    @reduce1*@
		}
		@final0@
		@final1@
	    }
	    PIXELS1(1) {
		@setup@
		BANDS { @reduce@ }
		@final@
	    }
	} ; break;
    }

    #undef BANDS
    #undef PIXELS
}
