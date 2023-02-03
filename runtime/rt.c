/* -*- c -*-
 */

#include <types_int.h>

/*
 * - - -- --- ----- -------- -------------
 */

#define MIN(a,b) (((a) < (b)) ? (a) : (b))
#define MAX(a,b) (((a) > (b)) ? (a) : (b))

/* - - -- --- ----- -------- -------------
 * Images - Construction, Destruction
 */

static aktive_image
aktive_image_new (aktive_image_type*   opspec,
		  void*                param ,
		  aktive_image_vector* srcs  ) {

    TRACE_FUNC("((opspec) %p '%s', (param) %p, (srcs) %p)", opspec, opspec->name, param, srcs);

    /* Create new and clean image structure ... */

    aktive_image r = ALLOC(struct aktive_image);
    memset (r, 0, sizeof(struct aktive_image));

    /* Initialize input images, if any */

    if (srcs) {
	r->srcs = *srcs;
	aktive_image_vector_heapify (&r->srcs);
	for (aktive_uint i = 0; i++; i < r->srcs.c) { aktive_image_ref (r->srcs.v [i]); }
    }

    /* Initialize parameters, if any */

    r->param = param;
    if (param) {
	void* p = NALLOC (char, opspec->sz_param);
	memcpy (p, param, opspec->sz_param);
	if (opspec->param_init) { opspec->param_init (p); }
	r->param = p;
    }

    /* Initialize custom state, if any */

    if (opspec->setup) { r->state = opspec->setup (r->param, &r->srcs); }

    /* Initialize location, geometry, and domain */

    opspec->geo_setup (r->param, &r->srcs, r->state, &r->location, &r->geometry);

    aktive_rectangle_set_location (&r->domain, &r->location);
    aktive_rectangle_set_geometry (&r->domain, &r->geometry);
    
    /* Initialize type information and reference management */

    r->opspec   = opspec;
    r->refcount = 0;

    // TODO meta     -- opspec hook taking param, srcs -- returning Tcl_Obj*

    /* Done and return */
    TRACE_RETURN("(aktive_image) %p", r);
}

static void
aktive_image_destroy (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);

    /* Release custom state, if any, and necessary */

    if (image->state) {
	if (image->opspec->final) { image->opspec->final (image->state); }
	ckfree ((char*) image->state);
    }

    /* Release parameters, if any, and necessary */

    if (image->param) {
	if (image->opspec->param_finish) { image->opspec->param_finish (image->param); }
	ckfree ((char*) image->param);
    }

    // TODO meta

    /* Release inputs, if any */

    aktive_image_vector_free (&image->srcs);
    for (aktive_uint i = 0; i++; i < image->srcs.c) { aktive_image_unref (image->srcs.v [i]); }

    /* Nothing to do for location and geometry */

    /* Release main structure */
    ckfree ((char*) image);

    TRACE_RETURN_VOID;
}

/* - - -- --- ----- -------- -------------
 * Images - Lifecycle management, including destruction
 */

static aktive_image
aktive_image_check (Tcl_Interp* ip, aktive_image src) {
    if (!src) { aktive_error_set (ip); }
    return src;
}

static int
aktive_image_unused (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(used) %d", image->refcount <= 0);
}

static void
aktive_image_ref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);

    image->refcount ++;

    TRACE_RETURN_VOID;
}

static void
aktive_image_unref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);

    if (image->refcount > 1) {
	image->refcount --;

	TRACE ("refcount = %d", image->refcount);
	TRACE_RETURN_VOID;
    }

    aktive_image_destroy (image);

    TRACE_RETURN_VOID;
}

/* - - -- --- ----- -------- -------------
 */

#include <objtype_image.c>

/* - - -- --- ----- -------- -------------
 * Regions -- Construction, Destruction
 */

static aktive_region
aktive_region_new (aktive_image image)
{
    TRACE_FUNC("((image) %p '%s'", image, image->opspec->name);

    /* Create new and clean image structure ... */

    aktive_region r = ALLOC(struct aktive_region);
    memset (r, 0, sizeof(struct aktive_region));

    /* Reference origin */

    r->origin = image; aktive_image_ref (image);

    /* Generate regions representing the inputs, if any */

    if (image->srcs.c) {
	aktive_region_vector_new (&r->srcs, image->srcs.c);
	for (unsigned int i = 0; i < r->srcs.c; i++) {
	    r->srcs.v [i] = aktive_region_new (image->srcs.v [i]);
	}
    }

    /* Initialize local pointers to important structures */

    r->param    = image->param;
    r->opspec   = image->opspec;

    /* Note: The width and height values will be later replaced with data from
     * the area requested to be fetched
     */
    aktive_geometry_copy (&r->pixels.geo, &image->geometry);

    r->pixels.region = r;

    /* Initialize custom state, if any */

    if (image->opspec->region_setup) {
	r->state = image->opspec->region_setup (r->param,
						&r->srcs,
						image->state);
    }

    /* Done and return */
    TRACE_RETURN("(aktive_region) %p", r);
}

static void
aktive_region_destroy (aktive_region region)
{
    TRACE_FUNC("((region) %p '%s'", region, region->opspec->name);

    /* Release custom state, if any, and necessary */

    if (region->state) {
	if (region->opspec->region_final) { region->opspec->final (region->state); }
	ckfree ((char*) region->state);
    }

    /* Release inputs, if any */

    aktive_region_vector_free (&region->srcs);

    /* Release owner */

    aktive_image_unref (region->origin);

    /* Release pixel data from the internal block, if any */

    if (region->pixels.pixel) { ckfree ((char*) region->pixels.pixel); }

    /* Nothing to do for the remaining fields. These are only pointers to
     * image structures not owned by the region
     */

    /* Release main structure */
    ckfree ((char*) region);

    TRACE_RETURN_VOID;
}

/* - - -- --- ----- -------- -------------
 * Error management
 */

static void
aktive_error_set (Tcl_Interp* interp) {
    // TODO: store collected errors into interpreter
}

/* - - -- --- ----- -------- -------------
 * Type support
 */

static Tcl_Obj* aktive_new_uint_obj (aktive_uint x) {
    Tcl_WideInt w = x;
    return Tcl_NewWideIntObj (w);
}

static Tcl_Obj* aktive_new_point_obj(aktive_point* p) {
    Tcl_Obj* el[2];

    el[0] = Tcl_NewIntObj (p->x);
    el[1] = Tcl_NewIntObj (p->y);

    return Tcl_NewListObj (2, el);
}

static Tcl_Obj* aktive_new_rectangle_obj(aktive_rectangle* r) {
    Tcl_Obj* el[4];

    el[0] = Tcl_NewIntObj (r->x);
    el[1] = Tcl_NewIntObj (r->y);
    el[2] = Tcl_NewIntObj (r->width);
    el[3] = Tcl_NewIntObj (r->height);

    return Tcl_NewListObj (4, el);
}

/* - - -- --- ----- -------- -------------
 * -- Image accessors
 *
 * Notes:
 *  - `image->opspec` references generated variables
 *    See `*_opspec` in file `generated/op-funcs.c`
 */

static int
aktive_image_get_x (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(x) %d", image->location.x);
}

static int
aktive_image_get_xmax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(xmax) %d", image->location.x + image->geometry.width - 1);
}

static int
aktive_image_get_y (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(y) %d", image->location.y);
}

static int
aktive_image_get_ymax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(ymax) %d", image->location.y + image->geometry.height -1);
}

static aktive_uint
aktive_image_get_width (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(width) %u", image->geometry.width);
}

static aktive_uint
aktive_image_get_height (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(height) %u", image->geometry.height);
}

static aktive_uint
aktive_image_get_depth (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(depth) %u", image->geometry.depth);
}

static aktive_uint
aktive_image_get_pixels (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint pixels =
	image->geometry.width *
	image->geometry.height;

    TRACE_RETURN ("(pixels) %u", pixels);
}

static aktive_uint
aktive_image_get_pitch (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint pitch =
	image->geometry.width *
	image->geometry.depth;

    TRACE_RETURN ("(pitch) %u", pitch);
}

static aktive_uint
aktive_image_get_size (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint size =
	image->geometry.width  *
	image->geometry.height *
	image->geometry.depth;

    TRACE_RETURN ("(size) %u", size);
}

static const aktive_image_type*
aktive_image_get_type (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(type) '%p'", image->opspec);
}

static aktive_uint
aktive_image_get_nsrcs (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(nsrcs) %d", image->srcs.c);
}

static aktive_image
aktive_image_get_src (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->srcs.c) {
	TRACE_RETURN ("(src) %p", 0);
    }

    TRACE_RETURN ("(src) '%p'", image->srcs.v [i]);
}

static aktive_uint
aktive_image_get_nparams (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(nparams) %d", image->opspec->n_param);
}

static const char*
aktive_image_get_param_name (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(name) %p", 0);
    }

    const char* name = image->opspec->param [i].name;

    TRACE_RETURN ("(name) '%s'", name);
}

static const char*
aktive_image_get_param_desc (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(desc) %p", 0);
    }

    const char* desc = image->opspec->param [i].desc;
    
    TRACE_RETURN ("(desc) '%s'", desc);
}

static Tcl_Obj*
aktive_image_get_param_value (aktive_image image, aktive_uint i, Tcl_Interp* interp)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(value) %p", 0);
    }

    void*              field  = image->param  + image->opspec->param [i].offset;
    aktive_param_value to_obj = image->opspec->param [i].to_obj;

    Tcl_Obj* obj = to_obj (interp, field);

    TRACE_RETURN ("(value) %p", obj);
}

/*
 * - - -- --- ----- -------- -------------
 * -- Region accessors
 */

static aktive_image
aktive_region_owner (aktive_region region)
{
    TRACE_FUNC("((aktive_region) %p '%s')", region, region->opspec->name);
    TRACE_RETURN ("(aktive_image) %p", region->origin);
}

static aktive_block*
aktive_region_fetch_area (aktive_region region, aktive_rectangle* request)
{    
    TRACE_FUNC("((aktive_region) %p '%s' (@ %d,%d : %ux%u))",
	       region, region->opspec->name,
	       request->x, request->y, request->width, request->height);

    // region
    //   pixels
    //	   geo	- block dimensions
    //   origin
    //     domain	area covered by the image
    // request		area to get pixels for

    //    fprintf(stderr,"FETCH %p (%s)\n", region, region->opspec->name);fflush (stderr);
    //    __aktive_rectangle_dump ("\trequest", request);
    //    __aktive_rectangle_dump ("\tdomain ", &region->origin->domain);

    /* Initialize or update the pixel block with the dimensions of the
     * requested area, and ensure that the pixel memory is large enough to
     * hald all the requested pixels.
     */

    /* Update the desired request to fill */

    aktive_geometry_set_rect (&region->pixels.geo, request);

    aktive_uint size = request->width * request->height * region->pixels.geo.depth;
    region->pixels.used = size;

    if (!region->pixels.pixel) {
	region->pixels.pixel    = NALLOC (double, size);
	region->pixels.capacity = size;
    } else if (region->pixels.capacity < size) {
	region->pixels.pixel    = REALLOC (region->pixels.pixel, double, size);
	region->pixels.capacity = size;
    } // else: have enough space already, do nothing
    //// future: maybe realloc down if used <= 1/2*capacity

    /* Computing the pixels is done in multiple phases:
     *
     * 1. Split the request into subareas inside and outside of the image domain.
     * 2. Clear the areas outside the domain.
     * 3. Invoke the fetch callback for the area inside the domain.
     *
     * Special cases are:
     * a. Request is a subset of the image's domain.
     * b. Request is fully outside of the image's domain.
     *
     * Coordinate systems
     *  domain, request are in the 2D plane with arbitrary location.
     *  pixel however is physical, rooted in (0,0).
     *
     * For blitting virtual locations have to be translated to physical.
     * As request.location maps to (0,0)
     * the translation is -(request.location).
     */

    aktive_rectangle domain; aktive_rectangle_copy (&domain, &region->origin->domain);
    
    if (aktive_rectangle_is_subset (&domain, request)) {
	// fprintf(stderr,"SUBSET\n");fflush (stderr);
    
	// Special case (a). The entire request has to be served by the fetcher.
	aktive_rectangle phys = { 0, 0, request->width, request->height };

	// __aktive_rectangle_dump ("\t- full req ", request);
	// __aktive_rectangle_dump ("\t- full preq", &phys);

	region->opspec->region_fetch (region->param, &region->srcs,
				      region->state, request, &phys,
				      &region->pixels);
	goto done;
    }

    /* Compute the inside and outside zones. The intersection, i.e. the inside
     * part, is always stored in zv[0].
     */

    aktive_rectangle zv [5];
    aktive_uint      zc;
    aktive_rectangle_outzones (&domain, request, &zc, zv);

    if (zc == 0) {
	// fprintf(stderr,"OUTSIDE\n");fflush (stderr);
	
	// Special case (b). No data comes from the image itself.
	aktive_blit_clear_all (&region->pixels);
	goto done;
    }

    // fprintf(stderr,"IN PIECES\n");fflush (stderr);
    
    /* Clear the outside zones, if any */
    for (aktive_uint i = 1; i < zc; i++) { aktive_blit_clear (&region->pixels, &zv [i]); }
    
    // The overlap is the only remaining part to handle, and this is done by
    // the fetcher.

    aktive_rectangle phys;
    aktive_rectangle_copy (&phys, &zv [0]);
    aktive_rectangle_move (&phys, -request->x, -request->y);

    // __aktive_rectangle_dump ("\t- inside req ", &zv[0]);
    // __aktive_rectangle_dump ("\t- inside preq", &phys);
    
    region->opspec->region_fetch (region->param, &region->srcs, region->state,
				  &zv [0], &phys, &region->pixels);
 done:
    /* And return them */

    // __aktive_block_dump (region->opspec->name, &region->pixels);
    
    TRACE_RETURN ("(aktive_block*) %p", &region->pixels);
}

/*
 * - - -- --- ----- -------- -------------
 * Geometry operations
 */

static void
aktive_point_set (aktive_point* dst, int x, int y)
{
    TRACE_FUNC("((dst*) %p = %d, %d)", dst, x, y);

    dst->x = x;
    dst->y = y;

    TRACE_RETURN_VOID;
}

static void
aktive_point_set_rect (aktive_point* dst, aktive_rectangle* rect)
{
    TRACE_FUNC("((dst*) %p = (rect*) %p %d %d)", dst, rect, rect->x, rect->y);

    dst->x = rect->x;
    dst->y = rect->y;

    TRACE_RETURN_VOID;
}

static void
aktive_point_move (aktive_point* dst, int dx, int dy)
{
    TRACE_FUNC("((dst*) %p += %d, %d)", dst, dx, dy);

    dst->x += dx;
    dst->y += dy;

    TRACE_RETURN_VOID;
}

static void
aktive_point_add (aktive_point* dst, aktive_point* delta)
{
    TRACE_FUNC("((dst*) %p += (point*) %p %d %d)", dst, delta, delta->x, delta->y);

    dst->x += delta->x;
    dst->y += delta->y;

    TRACE_RETURN_VOID;
}

static void
aktive_geometry_set (aktive_geometry* dst, aktive_uint w, aktive_uint h, aktive_uint d)
{
    TRACE_FUNC("((dst*) %p = %u %u %u)", dst, w, h, d);

    dst->width  = w;
    dst->height = h;
    dst->depth  = d;

    TRACE_RETURN_VOID;
}

static void
aktive_geometry_set_rect (aktive_geometry* dst, aktive_rectangle* rect)
{
    TRACE_FUNC("((dst*) %p = (rect*) %p %u %u)", dst, rect, rect->width, rect->height);

    dst->width  = rect->width;
    dst->height = rect->height;

    TRACE_RETURN_VOID;
}

static void
aktive_geometry_copy (aktive_geometry* dst, aktive_geometry* src)
{
    TRACE_FUNC("((dst*) %p = (src*) %p)", dst, src);
    
    *dst = *src;

    TRACE_RETURN_VOID;
}

static void
aktive_rectangle_copy (aktive_rectangle* dst, aktive_rectangle* src)
{
    TRACE_FUNC("((dst*) %p = (src*) %p)", dst, src);
    
    *dst = *src;

    TRACE_RETURN_VOID;
}

static void
aktive_rectangle_set (aktive_rectangle* dst, int x,  int y, aktive_uint w, aktive_uint h)
{
    TRACE_FUNC("((dst*) %p = %d %d %u %u)", dst, x, y, w, h);
    
    dst->x      = x;
    dst->y      = y;
    dst->width  = w;
    dst->height = h;

    TRACE_RETURN_VOID;
}

static void
aktive_rectangle_set_geometry (aktive_rectangle* dst, aktive_geometry* src)
{
    TRACE_FUNC("((dst*) %p = (src*) %p)", dst, src);
    
    dst->width  = src->width;
    dst->height = src->height;

    TRACE_RETURN_VOID;
}

static void
aktive_rectangle_set_location (aktive_rectangle* dst, aktive_point* src)
{
    TRACE_FUNC("((dst*) %p = (src*) %p)", dst, src);
    
    dst->x = src->x;
    dst->y = src->y;

    TRACE_RETURN_VOID;
}

static void
aktive_rectangle_move (aktive_rectangle* dst, int dx, int dy)
{
    TRACE_FUNC("((dst*) %p += %d, %d)", dst, dx, dy);
    
    dst->x += dx;
    dst->y += dy;

    TRACE_RETURN_VOID;
}

static void
aktive_rectangle_grow (aktive_rectangle* dst, int left, int right, int top, int bottom)
{
    TRACE_FUNC("((dst*) %p <-> %d %d %d %d)", dst, left, right, top, bottom);
    
    dst->x      -= left;
    dst->y      -= top;
    dst->width  += left + right;
    dst->height += top  + bottom;

    TRACE_RETURN_VOID;
}

static void
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

static void
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

static int
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

static int
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

static int
aktive_rectangle_is_empty  (aktive_rectangle* r)
{
    TRACE_FUNC("((rect*) %p empty?", r);

    int is_empty = (r->width == 0) || (r->height == 0);

    TRACE_RETURN("(bool) %d", is_empty);
}

static void
aktive_rectangle_outzones (aktive_rectangle* domain, aktive_rectangle* request,
			   aktive_uint* c, aktive_rectangle* v)
{
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

#if 0
    fprintf (stdout, "D %3d %3d %3u %3u\n", domain->x,  domain->y,  domain->width,  domain->height);
    fprintf (stdout, "R %3d %3d %3u %3u\n", request->x, request->y, request->width, request->height);
    fprintf (stdout, "top    %d\n", top);
    fprintf (stdout, "bottom %d\n", bottom);
    fprintf (stdout, "left   %d\n", left);
    fprintf (stdout, "right  %d\n", right);
    fflush  (stdout);
#endif

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
}

/* - - -- --- ----- -------- -------------
 * Runtime API -- Blitter ops for pixels blocks
 */

static void
aktive_blit_clear_all (aktive_block* block) {
    memset (block->pixel, 0, block->used * sizeof (double));
    // Note: The value 0b'00000000 represents (double) 0.0.
}

static void
aktive_blit_clear (aktive_block* block, aktive_rectangle* area)
{
    // dst  = (0, 0, dw, dh)
    // area = (x, y, w, h) < dst [== can be handled, hower clear_all should be more efficient]
    //
    // Note: The `area` is in the same (physical) coordinate system as the block.
    //
    // Compute row start  [double*],
    //         row stride [#double],
    // and     row size   [byte]     (accounts for bands)

    aktive_uint w = block->geo.width;
    aktive_uint d = block->geo.depth;

    aktive_uint stride = d * w ; /* pitch */
    aktive_uint width  = d * area->width * sizeof (double);
    double*     start  = block->pixel + area->y * stride + area->x * d;

    for (aktive_uint row = 0;
	 row < area->height;
	 row++, start += stride) {
	memset (start, 0, width);
    }
}

static void
aktive_blit_fill (aktive_block* block, aktive_rectangle* area, double v)
{
    // block area = (0, 0, w, h)
    // clear area = (x, y, w', h') < (0, 0, w, h)	[Not <=, not equal]
    //
    // Note: The `area` is in the same (physical) coordinate system as the block.
    //
    // Compute row start  [double*],
    //         row stride [#double],
    // and     row size   [byte]     (accounts for bands)

    aktive_uint w = block->geo.width;
    aktive_uint d = block->geo.depth;

    aktive_uint stride = d * w ; /* pitch */
    aktive_uint width  = d * area->width;
    double*     start  = block->pixel + area->y * stride + area->x * d;

    for (aktive_uint row = 0;
	 row < area->height;
	 row++, start += stride) {

	// blit single line
	double* cell = start;
	for (aktive_uint col = 0; col < width; col ++, cell++) { *cell = v; }
    }
}

static void
aktive_blit_fill_bands (aktive_block* block, aktive_rectangle* area, aktive_double_vector* bands)
{
    // block area = (0, 0, w, h)
    // clear area = (x, y, w', h') < (0, 0, w, h)	[Not <=, not equal]
    //
    // Note: The `area` is in the same (physical) coordinate system as the block.
    //
    // Compute row start  [double*],
    //         row stride [#double],
    // and     row size   [byte]     (accounts for bands)

    aktive_uint w = block->geo.width;
    aktive_uint d = block->geo.depth; // assert: == bands.c

    aktive_uint stride = d * w ; /* pitch */
    aktive_uint width  = d * area->width;
    double*     start  = block->pixel + area->y * stride + area->x * d;

    for (aktive_uint row = 0;
	 row < area->height;
	 row++, start += stride) {

	// blit single line
	double* cell = start;
	for (aktive_uint col = 0; col < width; col += d, cell += d) {
	    memcpy (cell, bands->v, d * sizeof(double));
	}
    }
}

static void
aktive_blit_copy (aktive_block* dst, aktive_rectangle* dstarea,
		  aktive_block* src, aktive_point*     srcloc)
{
    // assert : dst.geo.depth == src.geo.depth / dd == sd (*)

    // dst  = (0, 0, dw, dh)
    // src  = (0, 0, sw, hh)
    // area = (x, y, w, h) < src, < dst

    aktive_uint dw = dst->geo.width;
    aktive_uint sw = src->geo.width;
    aktive_uint sd = dst->geo.depth;
    
    aktive_uint stride = sd * sw;				// (*)
    aktive_uint width  = sd * dstarea->width * sizeof (double);	// (*)

    double*     dstart  = dst->pixel + dstarea->y * stride + dstarea->x * sd; // (*)
    double*     sstart  = src->pixel + srcloc->y  * stride + srcloc->x  * sd;

    for (aktive_uint row = 0;
	 row < dstarea->height;
	 row++, sstart += stride, dstart += stride) {
	memcpy (dstart, sstart, width); 
    }
}

static void
aktive_blit_copy0 (aktive_block* dst, aktive_rectangle* dstarea,
		   aktive_block* src)
{
    // assert : dst.geo.depth == src.geo.depth / dd == sd (*)

    // dst  = (0, 0, dw, dh)
    // src  = (0, 0, sw, hh)
    // area = (x, y, w, h) < src, < dst

    aktive_uint dw = dst->geo.width;
    aktive_uint sw = src->geo.width;
    aktive_uint sd = dst->geo.depth;
    
    aktive_uint stride = sd * sw;				// (*)
    aktive_uint width  = sd * dstarea->width * sizeof (double);	// (*)

    double*     dstart  = dst->pixel + dstarea->y * stride + dstarea->x * sd; // (*)
    double*     sstart  = src->pixel; // (0,0)

    for (aktive_uint row = 0;
	 row < dstarea->height;
	 row++, sstart += stride, dstart += stride) {
	memcpy (dstart, sstart, width); 
    }
}

/*
 * - - -- --- ----- -------- -------------
 *
 * debug support -- -------- -------------
 *
 * - - -- --- ----- -------- -------------
 */
#define CHAN stderr

static void
__aktive_rectangle_dump (char* prefix, aktive_rectangle* r) {
    fprintf (CHAN, "%s %p = rectangle {", prefix, r);

    fprintf (CHAN, " @ %d", r->x);
    fprintf (CHAN, ", %d",  r->y);
    fprintf (CHAN, ": %u",  r->width);
    fprintf (CHAN, " x %u", r->height);
    fprintf (CHAN, " }\n");
    fflush  (CHAN);
}

static void
__aktive_block_dump (char* prefix, aktive_block* block) {
    fprintf (CHAN, "%s %p = block {\n", prefix, block);
    fprintf (CHAN, "\tgeo      = { %u x %u x %u }\n",
	     block->geo.width, block->geo.height, block->geo.depth);
    fprintf (CHAN, "\tregion   = %p\n", block->region);
    fprintf (CHAN, "\tcapacity = %d\n", block->capacity);
    fprintf (CHAN, "\tused     = %d\n", block->used);
    fprintf (CHAN, "\tpixels   = {");

    if (block->used) {
	fprintf (CHAN, "\n\t\t");
	for (aktive_uint i = 0 ; i < block->used; i++) {
	    if (i) {
		if (i % (block->geo.width * block->geo.depth) == 0) {
		    fprintf (CHAN, "\n\t\t");
		} else if (i % block->geo.depth == 0) {
		    fprintf (CHAN, " /");
		}
	    }

	    fprintf (CHAN, " %f", block->pixel [i]);

	}
	fprintf (CHAN, "\n\t");
    }
    fprintf (CHAN, "}\n");
    fprintf (CHAN, "}\n");
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
