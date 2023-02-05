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
    aktive_geometry_set_rectangle (&dst->domain, request);

    aktive_uint size =
	request->width * request->height * dst->domain.depth;

    dst->used = size;

    if (!dst->pixel) {
	// No memory present, create
	
	dst->pixel    = NALLOC (double, size);
	dst->capacity = size;
    } else if (dst->capacity < size) {
	// Memory present without enough capacity, size up
	dst->pixel    = REALLOC (dst->pixel, double, size);
	dst->capacity = size;
    } // else: have enough space already, do nothing

    //// future: maybe size down if used <= 1/2 * capacity
}

extern void
aktive_blit_close (aktive_block* dst)
{
    if (dst->pixel) { ckfree ((char*) dst->pixel); }
    dst->used     = 0;
    dst->capacity = 0;
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
    memset (dst->pixel, 0, dst->used * sizeof (double));
    // Note: The value 0b'00000000 represents (double) 0.0.
}

extern void
aktive_blit_clear (aktive_block* dst, aktive_rectangle* area)
{
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
}

extern void
aktive_blit_fill (aktive_block* dst, aktive_rectangle* area, double v)
{
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
}

extern void
aktive_blit_fill_bands (aktive_block* dst, aktive_rectangle* area, aktive_double_vector* bands)
{
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
}

extern void
aktive_blit_copy0 (aktive_block* dst, aktive_rectangle* dstarea,
		   aktive_block* src)
{
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
