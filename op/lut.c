/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Utility functions. Lookup tables.
 */

#include <lut.h>
#include <amath.h>

#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * Core functionality
 */

extern double
aktive_lut_index (double x, aktive_lut_config* lut, aktive_uint z)
{
    TRACE_FUNC("(%f, (lut) %p [%ux1x%u] @ %u)", x, lut, lut->width, lut->depth, z);
    aktive_uint i;

    x = aktive_clamp (x);
    i =     x * (lut->width-1);
    i = z + i * lut->depth;

    ASSERT_VA (i < lut->cap, "LUT access out of bounds", "@ %u >= cap %u", i, lut->cap);

    double r = lut->pixel [i];

    TRACE_RETURN("(double) %f", r);
}

extern double
aktive_lut_index_linear (double x, aktive_lut_config* lut, aktive_uint z)
{
    TRACE_FUNC("(%f, (lut) %p [%ux1x%u] @ %u)", x, lut, lut->width, lut->depth, z);

    aktive_uint i, j, t;

    x = aktive_clamp (x);
    t = x - (int)x;
    i =     x * (lut->width-1);
    i = z + i * lut->depth;

    ASSERT_VA (i < lut->cap, "LUT access out of bounds", "@ %u >= cap %u", i, lut->cap);

    double r = lut->pixel [i];

    j = i + lut->depth;

    if (j >= lut->cap) {
	// @ last lut element ... extend linear interpolation from previous.
	// make sure that previous also exists. no interpolation if not.
	if (i >= lut->depth) {
	    j = i - lut->depth;
	    t += 1;
	    r = (1-t)*lut->pixel[j] + t*r;
	}
    } else {
	// interpolate linear between current and next
	r = (1-t)*r + t*lut->pixel[j];
    }

    TRACE_RETURN("(double) %f", r);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
