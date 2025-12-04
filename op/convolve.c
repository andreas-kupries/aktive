/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Convolver utility functions.
 *
 * - - -- --- ----- -------- -------------
 * Spatial convolution support.
 *
 *  - v[]	Tile center, values to access, part of a larger 2d block
 *  - base	Tile center as index of `v` in the block. IOW v = block [base].
 *  - cap	Max legal index in the block.
 *  - pitch	Distance between rows of the block.
 *  - stride	Distance btween columns of the block.
 *
 *  - m[]       Convolution matrix values, from top-left
 *  - mwidth    Matrix width
 *  - mheight   Matrix height
 *  - wradius   Matrix width radius (width/2)
 *  - hradius   Matrix height radius (height/2)
 *
 * Note that the matrix width and height are odd values.
 */

#include <convolve.h>
#include <kahan.h>

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern double
aktive_tile_convolve (double*     v,
		      aktive_uint base,
		      aktive_uint cap,
		      aktive_uint pitch,
		      aktive_uint stride,
		      double*     m,
		      aktive_uint mcap,
		      aktive_uint mwidth,
		      aktive_uint mheight,
		      aktive_uint wradius,
		      aktive_uint hradius)
{
    TRACE_FUNC("((%u %u %u %u), (%u %u %u %u %u))", base, cap, pitch, stride, mcap, mwidth, mheight, wradius, hradius);

    kahan sum; aktive_kahan_init (sum);

    int wr = wradius;
    int hr = hradius;

    // y : -hr  .. hr, up  ; x : -wr  .. wr, up
    // my: mh-1 .. 0,  down; mx: mw-1 .. 0, down (matrix access is reflected)
    //
    // NOTE: Rewrite to use of generated blitter.

    int y, my, x, mx;

    for (y = -hr, my = mheight-1 ; y <= hr; y++, my--) {
	for (x = -wr, mx = mwidth-1; x <= wr; x++, mx--) {

	    int index  = y*pitch + x*stride;
	    int aindex = (int) base + index;
	    int mindex = my * mwidth + mx ; // stride == 1

	    TRACE_HEADER (1);
	    TRACE_ADD   ("S@(%d,%d) = %u[%d] = [%d]", x, y, base, index, aindex);
	    TRACE_ADD (", M@(%d,%d) = [%d]",          mx, my, mindex);

	    if ((aindex < 0) || (aindex >= cap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "src out of bounds", "%d / %d", aindex, cap);
	    }
	    if ((mindex < 0) || (mindex >= mcap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "matrix out of bounds", "%d / %d", mindex, mcap);
	    }

	    double val    = v [index];
	    double weight = m [mindex];

	    TRACE_ADD ("=> %f = %f * %f", val * weight, val, weight);
	    TRACE_CLOSER;
	    aktive_kahan_add (sum, val * weight);
	}
    }

    double res = aktive_kahan_final (sum);
    TRACE_RETURN ("(convolve) %f", res);
}

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
