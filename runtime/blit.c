/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * API implementation - Pixel blocks, blitting
 */

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <geometry.h>
#include <blit.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_blit_setup (aktive_block* dst, aktive_rectangle* request)
{
    TRACE_FUNC("((block*) %p, (rect*) %p = {%d %d : %u %u})",
	       dst, request, request->x, request->y, request->width, request->height);
    
    aktive_geometry_set_rectangle (&dst->domain, request);

    aktive_uint size =
	request->width * request->height * dst->domain.depth;

    dst->used = size;

    if (!dst->pixel) {
	// No memory present, create
	TRACE ("Initialize to %d", size);
	
	dst->pixel    = NALLOC (double, size);
	dst->capacity = size;
    } else if (dst->capacity < size) {
	TRACE ("Extend to %d", size);
	
	// Memory present without enough capacity, size up
	dst->pixel    = REALLOC (dst->pixel, double, size);
	dst->capacity = size;
    } // else: have enough space already, do nothing
    //// future: maybe size down if used <= 1/2 * capacity

    TRACE ("Using %d of %d", dst->used, dst->capacity);
    TRACE_RETURN_VOID;
}

extern void
aktive_blit_close (aktive_block* dst)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    if (dst->pixel) { ckfree ((char*) dst->pixel); }
    dst->used     = 0;
    dst->capacity = 0;

    TRACE_RETURN_VOID;
}
/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_uint
aktive_blit_index (aktive_block* src, int x, int y, int z)
{
    aktive_uint stride = aktive_geometry_get_pitch (&src->domain);

    return y * stride + x * src->domain.depth + z;
}
    
/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_blit_clear_all (aktive_block* dst) {
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    memset (dst->pixel, 0, dst->used * sizeof (double));
    // Note: The value 0b'00000000 represents (double) 0.0.
    TRACE_RETURN_VOID;
}

extern void
aktive_blit_clear (aktive_block* dst, aktive_rectangle* area)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    // dst  = (0, 0, dw, dh)
    // area = (x, y, w, h) < dst [== can be handled, hower clear_all should be more efficient]
    //
    // Note: The `area` is in the same (physical) coordinate system as the block.
    //
    // Compute row start  [double*],
    //         row stride [#double],
    // and     row size   [byte]     (accounts for bands)

    aktive_uint w = dst->domain.width;
    aktive_uint d = dst->domain.depth;

    aktive_uint stride = d * w ; /* pitch */
    aktive_uint width  = d * area->width * sizeof (double);
    double*     start  = dst->pixel + area->y * stride + area->x * d;

    for (aktive_uint row = 0;
	 row < area->height;
	 row++, start += stride) {
	memset (start, 0, width);
    }

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_fill (aktive_block* dst, aktive_rectangle* area, double v)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    // block area = (0, 0, w, h)
    // clear area = (x, y, w', h') < (0, 0, w, h)	[Not <=, not equal]
    //
    // Note: The `area` is in the same (physical) coordinate system as the block.
    //
    // Compute row start  [double*],
    //         row stride [#double],
    // and     row size   [byte]     (accounts for bands)

    aktive_uint w = dst->domain.width;
    aktive_uint d = dst->domain.depth;

    aktive_uint stride = d * w ; /* pitch */
    aktive_uint width  = d * area->width;
    double*     start  = dst->pixel + area->y * stride + area->x * d;

    for (aktive_uint row = 0;
	 row < area->height;
	 row++, start += stride) {

	// blit single line
	double* cell = start;
	for (aktive_uint col = 0; col < width; col ++, cell++) { *cell = v; }
    }

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_fill_bands (aktive_block* dst, aktive_rectangle* area, aktive_double_vector* bands)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    // block area = (0, 0, w, h)
    // clear area = (x, y, w', h') < (0, 0, w, h)	[Not <=, not equal]
    //
    // Note: The `area` is in the same (physical) coordinate system as the block.
    //
    // Compute row start  [double*],
    //         row stride [#double],
    // and     row size   [byte]     (accounts for bands)

    aktive_uint w = dst->domain.width;
    aktive_uint d = dst->domain.depth; // assert: == bands.c

    aktive_uint stride = d * w ; /* pitch */
    aktive_uint width  = d * area->width;
    double*     start  = dst->pixel + area->y * stride + area->x * d;

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

extern void
aktive_blit_copy (aktive_block* dst, aktive_rectangle* dstarea,
		  aktive_block* src, aktive_point*     srcloc)

{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
     
    // assert : dst.domain.depth == src.domain.depth / dd == sd (*)

    // dst  = (0, 0, dw, dh)
    // src  = (0, 0, sw, hh)
    // area = (x, y, w, h) < src, < dst

    aktive_uint dw = dst->domain.width;
    aktive_uint sw = src->domain.width;
    aktive_uint sd = dst->domain.depth;
    
    aktive_uint stride = sd * sw;				// (*)
    aktive_uint width  = sd * dstarea->width * sizeof (double);	// (*)

    double*     dstart  = dst->pixel + dstarea->y * stride + dstarea->x * sd; // (*)
    double*     sstart  = src->pixel + srcloc->y  * stride + srcloc->x  * sd;

    for (aktive_uint row = 0;
	 row < dstarea->height;
	 row++, sstart += stride, dstart += stride) {
	memcpy (dstart, sstart, width); 
    }

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_copy0 (aktive_block* dst, aktive_rectangle* dstarea,
		   aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    // assert : dst.domain.depth == src.domain.depth / dd == sd (*)

    // dst  = (0, 0, dw, dh)
    // src  = (0, 0, sw, hh)
    // area = (x, y, w, h) < src, < dst

    aktive_uint dw = dst->domain.width;
    aktive_uint sw = src->domain.width;
    aktive_uint sd = dst->domain.depth;
    
    aktive_uint stride = sd * sw;				// (*)
    aktive_uint width  = sd * dstarea->width * sizeof (double);	// (*)

    double*     dstart  = dst->pixel + dstarea->y * stride + dstarea->x * sd; // (*)
    double*     sstart  = src->pixel; // (0,0)

    for (aktive_uint row = 0;
	 row < dstarea->height;
	 row++, sstart += stride, dstart += stride) {
	memcpy (dstart, sstart, width); 
    }

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * NOTE: This function should/could be generated from the DSL, with inlined `op`.
 *       Where `op` could be a macro.
 */

extern void
aktive_blit_unary0 (aktive_block* dst, aktive_rectangle* dstarea,
		    aktive_unary_transform op, aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    // assert : dst.domain.depth == src.domain.depth / dd == sd (*)

    // dst  = (0, 0, dw, dh)
    // src  = (0, 0, sw, hh)
    // area = (x, y, w, h) < src, < dst

    aktive_uint dw = dst->domain.width;
    aktive_uint sw = src->domain.width;
    aktive_uint sd = dst->domain.depth;
    
    aktive_uint stride = sd * sw;	// (*)
    aktive_uint width  = sd * dw;	// (*)

    TRACE ("- width %d, stride %d", width, stride);
    
    double*     dstart  = dst->pixel + dstarea->y * stride + dstarea->x * sd; // (*)
    double*     sstart  = src->pixel; // (0,0)

    ASSERT (sstart - src->pixel < src->used, "pixel source out of bounds"); 
    ASSERT (dstart - dst->pixel < dst->used, "pixel destin out of bounds");
    
    for (aktive_uint row = 0;
	 row < dstarea->height;
	 row++, sstart += stride, dstart += stride) {

	// blit line with data transformation
	double* dpos = dstart;
	double* spos = sstart;

	for(aktive_uint k = 0;
	    k < width;
	    k++, dpos++, spos++) {

	    TRACE ("cell (y%d %d (x%d z%d)) - src:%u dst:%u", row, k, k/sd, k % sd,
		   spos - src->pixel, dpos - dst->pixel);
	    ASSERT (spos - src->pixel <= src->used, "pixel read out of bounds"); 
	    ASSERT (dpos - dst->pixel <= dst->used, "pixel write out of bounds");
	    
	    *dpos = op (*spos);
	}
    }

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_unary1 (aktive_block* dst, aktive_rectangle* dstarea,
		    aktive_unary_transform1 op, double a, aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    // assert : dst.domain.depth == src.domain.depth / dd == sd (*)

    // dst  = (0, 0, dw, dh)
    // src  = (0, 0, sw, hh)
    // area = (x, y, w, h) < src, < dst

    aktive_uint dw = dst->domain.width;
    aktive_uint sw = src->domain.width;
    aktive_uint sd = dst->domain.depth;
    
    aktive_uint stride = sd * sw;	// (*)
    aktive_uint width  = sd * dw;	// (*)

    TRACE ("- width %d, stride %d", width, stride);
    
    double*     dstart  = dst->pixel + dstarea->y * stride + dstarea->x * sd; // (*)
    double*     sstart  = src->pixel; // (0,0)

    ASSERT (sstart - src->pixel < src->used, "pixel source out of bounds"); 
    ASSERT (dstart - dst->pixel < dst->used, "pixel destin out of bounds");
    
    for (aktive_uint row = 0;
	 row < dstarea->height;
	 row++, sstart += stride, dstart += stride) {

	// blit line with data transformation
	double* dpos = dstart;
	double* spos = sstart;

	for(aktive_uint k = 0;
	    k < width;
	    k++, dpos++, spos++) {

	    TRACE ("cell (y%d %d (x%d z%d)) - src:%u dst:%u", row, k, k/sd, k % sd,
		   spos - src->pixel, dpos - dst->pixel);
	    ASSERT (spos - src->pixel <= src->used, "pixel read out of bounds"); 
	    ASSERT (dpos - dst->pixel <= dst->used, "pixel write out of bounds");
	    
	    *dpos = op (*spos, a);
	}
    }

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_unary2 (aktive_block* dst, aktive_rectangle* dstarea,
		    aktive_unary_transform2 op, double a, double b,
		    aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
    // assert : dst.domain.depth == src.domain.depth / dd == sd (*)

    // dst  = (0, 0, dw, dh)
    // src  = (0, 0, sw, hh)
    // area = (x, y, w, h) < src, < dst

    aktive_uint dw = dst->domain.width;
    aktive_uint sw = src->domain.width;
    aktive_uint sd = dst->domain.depth;
    
    aktive_uint stride = sd * sw;	// (*)
    aktive_uint width  = sd * dw;	// (*)

    TRACE ("- width %d, stride %d", width, stride);
    
    double*     dstart  = dst->pixel + dstarea->y * stride + dstarea->x * sd; // (*)
    double*     sstart  = src->pixel; // (0,0)

    ASSERT (sstart - src->pixel < src->used, "pixel source out of bounds"); 
    ASSERT (dstart - dst->pixel < dst->used, "pixel destin out of bounds");
    
    for (aktive_uint row = 0;
	 row < dstarea->height;
	 row++, sstart += stride, dstart += stride) {

	// blit line with data transformation
	double* dpos = dstart;
	double* spos = sstart;

	for(aktive_uint k = 0;
	    k < width;
	    k++, dpos++, spos++) {

	    TRACE ("cell (y%d %d (x%d z%d)) - src:%u dst:%u", row, k, k/sd, k % sd,
		   spos - src->pixel, dpos - dst->pixel);
	    ASSERT (spos - src->pixel <= src->used, "pixel read out of bounds"); 
	    ASSERT (dpos - dst->pixel <= dst->used, "pixel write out of bounds");
	    
	    *dpos = op (*spos, a, b);
	}
    }

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_blit_set (aktive_block* dst, aktive_point* location, double v)
{
    dst->pixel [location->y * dst->domain.width + location->x] = v;
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
__aktive_block_dump (char* prefix, aktive_block* src) {
    fprintf (CHAN, "%s %p = block {\n", prefix, src);
    fprintf (CHAN, "\tdomain   = { %d, %d : %u x %u x %u }\n",
	     src->domain.x, src->domain.y,
	     src->domain.width, src->domain.height, src->domain.depth);
    fprintf (CHAN, "\tregion   = %p\n", src->region);
    fprintf (CHAN, "\tcapacity = %d\n", src->capacity);
    fprintf (CHAN, "\tused     = %d\n", src->used);
    fprintf (CHAN, "\tpixels   = {");

    if (src->used) {
	fprintf (CHAN, "\n\t\t");
	for (aktive_uint i = 0 ; i < src->used; i++) {
	    if (i) {
		if (i % (src->domain.width * src->domain.depth) == 0) {
		    fprintf (CHAN, "\n\t\t");
		} else if (i % src->domain.depth == 0) {
		    fprintf (CHAN, " /");
		}
	    }

	    fprintf (CHAN, " %f", src->pixel [i]);

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
