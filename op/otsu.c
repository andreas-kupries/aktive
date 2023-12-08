
/*
 * - - -- --- ----- -------- -------------
 */

#include <otsu.h>
#include <kahan.h>

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern double
aktive_otsu (double* src, aktive_uint n, aktive_uint stride)
{
    TRACE_FUNC ("(src %p [%u:%u])", src, n, stride);

    double total = 0;
    double sum   = 0;
    aktive_uint t;
    for (t = 0 ; t < n ; t++) {
	double v = src[t*stride];

	sum   += t * v;
	total +=     v;

	TRACE ("%2u count=%7.4f total=%3d mass=%7.4f", t, v, total, sum);
    }

    // total is sum of the pixel counts. I.e the number of pixels in the image
    // the histogram was made from. the intermediate totals, scaled by it are
    // `probability(v <= T), for each T`.

    // starting point : threshold = 0, t = -1! everything is background
    double      sumB = 0;
    double      sumF = sum;
    double      wB   = 0;
    double      wF   = total;
    double      vmax = 0;
    aktive_uint threshold = 0;

    // incrementally include more levels into the background
    // BWARE: the index into the histogram is one less than the indicated threshold.
    // see above, we are starting with threshold 0 at effectively t -1.

    for (t = 0 ; t < n ; t++) {
	double v = src[t*stride];

	// weights of fore- and background
	wB += (int) v;			TRACE ("%d wB    %f", t, wB);
	if (wB == 0) continue;

	wF = total - wB;		TRACE ("%d wF    %f", t, wF);
	/* .......... */		TRACE ("%d wB+F  %f", t, wB+wF);
	if (wF == 0) break;

	sumB += t * v;			TRACE ("%d sumB  %7.4f", t, sumB);
	sumF = sum - sumB;		TRACE ("%d sumF  %7.4f", t, sumF);
	/* .................. */	TRACE ("%d sB+F  %7.4f", t, sumB+sumF);

	// means of fore- and background
	double mB = sumB / wB;		TRACE ("%d meanB %7.4f", t, mB);
	double mF = sumF / wF;		TRACE ("%d meanF %7.4f", t, mF);

	// inter-class variance
	double md = mB - mF;		TRACE ("%d meanD %7.4f", t, md);
	double vi = wB * wF * md * md;	TRACE ("%d varI  %7.4f varM %7.4f", t, vi, vmax, threshold);

	// check if better variance and threshold (max)
	if (vi <= vmax) continue;

	vmax = vi;
	threshold = t + 1;
	TRACE ("threshold = %d", threshold);
    }

    TRACE_RETURN ("(otsu) %f", (double) threshold);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
