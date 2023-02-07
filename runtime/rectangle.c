/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * -- Rectangle methods
 */

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <geometry.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

#define MIN(a,b) (((a) < (b)) ? (a) : (b))
#define MAX(a,b) (((a) > (b)) ? (a) : (b))

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_rectangle_obj(aktive_rectangle* r) {
    Tcl_Obj* el[4];

    el[0] = Tcl_NewIntObj (r->x);
    el[1] = Tcl_NewIntObj (r->y);
    el[2] = Tcl_NewIntObj (r->width);
    el[3] = Tcl_NewIntObj (r->height);

    return Tcl_NewListObj (4, el);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_rectangle_set (aktive_rectangle* dst, int x, int y, aktive_uint w, aktive_uint h)
{
    TRACE_FUNC("((dst*) %p = %d %d : %u %u)", dst, x, y, w, h);
    
    dst->x      = x;
    dst->y      = y;
    dst->width  = w;
    dst->height = h;

    TRACE_RETURN_VOID;
}

extern void
aktive_rectangle_copy (aktive_rectangle* dst, aktive_rectangle* src)
{
    TRACE_FUNC("((dst*) %p = (src*) %p)", dst, src);
    
    *dst = *src;

    TRACE_RETURN_VOID;
}

extern void
aktive_rectangle_set_point (aktive_rectangle* dst, aktive_point* src)
{
    aktive_point_copy ((aktive_point*) dst, src);
}

extern void
aktive_rectangle_from_geometry (aktive_rectangle* dst, aktive_geometry* src)
{
    aktive_rectangle_copy (dst, (aktive_rectangle*) src);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_rectangle_is_equal (aktive_rectangle* a, aktive_rectangle* b)
{
    TRACE_FUNC("((rect*) %p == (rect*) %p)", a, b);

    int is_equal = 
	(a->x      == b->x     ) &&
	(a->y      == b->y     ) &&
	(a->width  == b->width ) &&
	(a->height == b->height)
	;

    TRACE_RETURN("(bool) %d", is_equal);
}

extern int
aktive_rectangle_is_subset (aktive_rectangle* a, aktive_rectangle* b)
{
    TRACE_FUNC("((rect*) %p <= (rect*) %p)", a, b);

    int is_subset =
	(a->x               >= b->x              ) &&
	((a->x + a->width)  <= (b->x + b->width )) &&
	(a->y               >= b->y              ) &&
	((a->y + a->height) <= (b->y + b->height))
	;

    TRACE_RETURN("(bool) %d", is_subset);
}

extern int
aktive_rectangle_is_empty  (aktive_rectangle* r)
{
    TRACE_FUNC("((rect*) %p empty?", r);

    int is_empty = (r->width == 0) || (r->height == 0);

    TRACE_RETURN("(bool) %d", is_empty);
}

extern int
aktive_rectangle_contains (aktive_rectangle* r, aktive_point* p)
{
    TRACE_FUNC("((rect*) %p contain? ((point*)) %p", r, p);

    int outside =
	(p->x < r->x)               ||
	(p->y < r->y)               ||
	(p->x >= (r->x + r->width)) ||
	(p->y >= (r->y + r->height));

    TRACE_RETURN("(bool) %d", !outside);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_rectangle_move (aktive_rectangle* dst, int dx, int dy)
{
    aktive_point_move ((aktive_point*) dst, dx, dy);
}

extern void
aktive_rectangle_add (aktive_rectangle* dst, aktive_point* delta)
{
    aktive_point_add ((aktive_point*) dst, delta);
}

extern void
aktive_rectangle_grow (aktive_rectangle* dst, int left, int right, int top, int bottom)
{
    TRACE_FUNC("((dst*) %p <-%d %d-> ^%d v%d)",
	       dst, left, right, top, bottom);
    
    dst->x      -= left;
    dst->y      -= top;
    dst->width  += left + right;
    dst->height += top  + bottom;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_rectangle_union (aktive_rectangle* dst, aktive_rectangle* a, aktive_rectangle* b)
{
    TRACE_FUNC("((dst*) %p = (rect*) %p + (rect*) %p)", dst, a, b);
    
    /*
     * Compute the bounding box first, as min and max of the individual
     * boundaries. The upper values are one too high, which is canceled when
     * computing the dimensions. This is actually the dual of the intersection
     * calculation.
     */

    int a_xmax = a->x + a->width;
    int a_ymax = a->y + a->height;
    int b_xmax = b->x + b->width;
    int b_ymax = b->y + b->height;

    int nx    = MIN (b->x,   a->x);
    int ny    = MIN (b->y,   a->y);
    int nxmax = MAX (b_xmax, a_xmax);
    int nymax = MAX (b_ymax, a_ymax);

    dst->x      = nx;
    dst->y      = ny;
    dst->width  = nxmax - nx;
    dst->height = nymax - ny;

    TRACE_RETURN_VOID;
}

extern void
aktive_rectangle_intersect (aktive_rectangle* dst, aktive_rectangle* a, aktive_rectangle* b)
{
    TRACE_FUNC("((dst*) %p = (rect*) %p * (rect*) %p)", dst, a, b);

    /* No intersections in X, nor Y => empty.
     * Beware uint/int mix
     */
    if (((a->x + (int) a->width ) <= b->x) || /* A left of B */
	((b->x + (int) b->width ) <= a->x) || /* B left of A */
	((a->y + (int) a->height) <= b->y) || /* A above B   */
	((b->y + (int) b->height) <= a->y)) { /* B above A   */
	
	dst->x      = 0;
	dst->y      = 0;
	dst->width  = 0;
	dst->height = 0;
	return;
    }

    /* Compute boundaries of the intersection as the max and min of the
     * individual boundaries, and then compute the dimensions from that
     * again. The upper values are one too high, which is canceled when
     * computing the dimensions. This is actually the dual of the union
     * calculation.
     */

    int a_xmax = a->x + a->width;
    int a_ymax = a->y + a->height;
    int b_xmax = b->x + b->width;
    int b_ymax = b->y + b->height;

    int nx    = MAX (b->x,   a->x);
    int ny    = MAX (b->y,   a->y);
    int nxmax = MIN (b_xmax, a_xmax);
    int nymax = MIN (b_ymax, a_ymax);

    dst->x      = nx;
    dst->y      = ny;
    dst->width  = nxmax - nx;
    dst->height = nymax - ny;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_rectangle_outzones (aktive_rectangle* domain, aktive_rectangle* request,
			   aktive_uint* c, aktive_rectangle* v)
{
    TRACE_FUNC("((domain*) %p ~ (request*) %p ~ *c %p $v %p", domain, request, c, v);

    *c = 0;

    aktive_rectangle_intersect (&v[0], domain, request);

    // __aktive_rectangle_dump ("\t- intersection", &v[0]);
	
    if (aktive_rectangle_is_empty (&v[0])) {
	// fprintf(stderr,"\tNO intersection\n");fflush (stderr);	
	return;
    }

    aktive_uint count = 1;
    
    /* General case. Request has inside and outside parts (*). These parts can
     * reside above, below, left, or right of the image, in all
     * combinations. The following code handles the above and below strips
     * first, and then looks at the left/right blocks at the some height as
     * the image.
     *
     * (*) We already know that it is not fully outside, nor fully inside
     *     (See caller), so partial overlap is the only thing left.
     *
     * ASCII diagram
     *
     *            0      d.x-r.x *-r.x   r.w
     *            |      |       |       |
     *       0 -- A----------------------+ -- r.y
     *            |        top           |
     * d.y-r.y -- C------+-------D-------+ -- d.y
     *            | left | image | right |
     *   *-r.y -- B------+-------+-------+ -- d.y+d.h
     *            |        bottom        |
     *     r.h -- +----------------------+ -- r.y+r.h
     *            |      |       |       |
     *            r.x    d.x     d.x+d.w r.x+r.w
     *
     * Note, the zone setup integrates the aforementioned translation.
     * In other words, while the intersection is in the virtual coordinate system,
     * the zones are 0-based physical coordinates!
     *
     * HADJ is the height adjustment needed for left/right when the top/bottom
     * stripes do not exist.
     *
     * TP is the similar adjustment of the left/right y-coordinate.
     */

    int top    = domain->y - request->y;
    int bottom = request->height - domain->height - top;
    int left   = domain->x - request->x;
    int right  = request->width - domain->width - left;

    TRACE ("D %3d %3d %3u %3u\n", domain->x,  domain->y,  domain->width,  domain->height);
    TRACE ("R %3d %3d %3u %3u\n", request->x, request->y, request->width, request->height);
    TRACE ("top    %d\n", top);
    TRACE ("bottom %d\n", bottom);
    TRACE ("left   %d\n", left);
    TRACE ("right  %d\n", right);

#define ARS  aktive_rectangle_set
#define DST  &v[count]
#define NXT  count ++
#define HADJ (((top    < 0) ? top    : 0) + ((bottom < 0) ? bottom : 0))
#define TP    ((top    > 0) ? top    : 0)
#define DH   domain->height
#define DW   domain->width
#define RW   request->width
    
    if (top    > 0) { /* A */ ARS (DST, 0,         0,        RW,    top       ); NXT; }
    if (bottom > 0) { /* B */ ARS (DST, 0,         top + DH, RW,    bottom    ); NXT; }
    if (left   > 0) { /* C */ ARS (DST, 0,         TP,       left,  DH + HADJ ); NXT; }
    if (right  > 0) { /* D */ ARS (DST, left + DW, TP,       right, DH + HADJ ); NXT; }

#undef ARS
#undef DST
#undef NXT
#undef HADJ
#undef TP
#undef DH
#undef DW
#undef RW

    *c = count;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 *
 * debug support -- -------- -------------
 *
 * - - -- --- ----- -------- -------------
 */
#define CHAN stderr

extern void
__aktive_rectangle_dump (char* prefix, aktive_rectangle* r) {
    fprintf (CHAN, "%s %p = rectangle {", prefix, r);

    fprintf (CHAN, " @ %d", r->x);
    fprintf (CHAN, ", %d",  r->y);
    fprintf (CHAN, ": %u",  r->width);
    fprintf (CHAN, " x %u", r->height);
    fprintf (CHAN, " }\n");
    fflush  (CHAN);
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
