/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Rectangle API
 */
#ifndef AKTIVE_RECTANGLE_H
#define AKTIVE_RECTANGLE_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <geometry.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_rectangle_obj (aktive_rectangle* r);

extern void aktive_rectangle_copy         (aktive_rectangle* dst, aktive_rectangle* src);
extern void aktive_rectangle_set          (aktive_rectangle* dst, int x, int y, aktive_uint w, aktive_uint h);
extern void aktive_rectangle_set_geometry (aktive_rectangle* dst, aktive_geometry* src);
extern void aktive_rectangle_set_location (aktive_rectangle* dst, aktive_point* src);

extern void aktive_rectangle_move         (aktive_rectangle* dst, int dx, int dy);
extern void aktive_rectangle_grow         (aktive_rectangle* dst, int left, int right, int top, int bottom);

extern void aktive_rectangle_union     (aktive_rectangle* dst, aktive_rectangle* a, aktive_rectangle* b);
extern void aktive_rectangle_intersect (aktive_rectangle* dst, aktive_rectangle* a, aktive_rectangle* b);

extern int aktive_rectangle_is_equal  (aktive_rectangle* a, aktive_rectangle* b);
extern int aktive_rectangle_is_subset (aktive_rectangle* a, aktive_rectangle* b);
extern int aktive_rectangle_is_empty  (aktive_rectangle* r);

// Compute intersection of request with domain, and the zones of request outside of the domain.
// The array `v` has to have enough space for 5 results (intersection + at most 4 zones.
// The intersection is always stored in v[0].
extern void aktive_rectangle_outzones  (aktive_rectangle* domain, aktive_rectangle* request,
					aktive_uint* c, aktive_rectangle* v);

/*
 * - - -- --- ----- -------- -------------
 *
 * debug support -- -------- -------------
 *
 * - - -- --- ----- -------- -------------
 */

extern void __aktive_rectangle_dump (char* prefix, aktive_rectangle* r);

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
#endif /* AKTIVE_RECTANGLE_H */
