/* -*- c -*-
 *
 * -- Various color white points / standard observers
 */

#include <whitepoint.h>

extern aktive_whitepoint*
aktive_whitepoint_get (aktive_whitepoint_id w) {

#define WP(name) { AKTIVE_WP_ ## name ## _X, AKTIVE_WP_ ## name ## _Y, AKTIVE_WP_ ## name ## _Z }

    static aktive_whitepoint wp[] = { WP (A),     WP (B),   WP (C),
				      WP (D3250), WP (D50), WP (D55),
				      WP (D65),   WP (D75), WP (D93),
				      WP (E) };

    return &wp [w];
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
