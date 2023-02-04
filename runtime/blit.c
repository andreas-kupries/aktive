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
aktive_blit_setup (aktive_block* block, aktive_rectangle* request)
{
    aktive_geometry_set_rectangle (&block->domain, request);

    aktive_uint size =
	request->width * request->height * block->domain.depth;

    block->used = size;

    if (!block->pixel) {
	// No memory present, create
	
	block->pixel    = NALLOC (double, size);
	block->capacity = size;
    } else if (block->capacity < size) {
	// Memory present without enough capacity, size up
	block->pixel    = REALLOC (block->pixel, double, size);
	block->capacity = size;
    } // else: have enough space already, do nothing

    //// future: maybe size down if used <= 1/2 * capacity
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_blit_clear_all (aktive_block* block) {
    memset (block->pixel, 0, block->used * sizeof (double));
    // Note: The value 0b'00000000 represents (double) 0.0.
}

extern void
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

    aktive_uint w = block->domain.width;
    aktive_uint d = block->domain.depth;

    aktive_uint stride = d * w ; /* pitch */
    aktive_uint width  = d * area->width * sizeof (double);
    double*     start  = block->pixel + area->y * stride + area->x * d;

    for (aktive_uint row = 0;
	 row < area->height;
	 row++, start += stride) {
	memset (start, 0, width);
    }
}

extern void
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

    aktive_uint w = block->domain.width;
    aktive_uint d = block->domain.depth;

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

extern void
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

    aktive_uint w = block->domain.width;
    aktive_uint d = block->domain.depth; // assert: == bands.c

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
 *
 * debug support -- -------- -------------
 *
 * - - -- --- ----- -------- -------------
 */
#define CHAN stderr

extern void
__aktive_block_dump (char* prefix, aktive_block* block) {
    fprintf (CHAN, "%s %p = block {\n", prefix, block);
    fprintf (CHAN, "\tdomain   = { %d, %d : %u x %u x %u }\n",
	     block->domain.x, block->domain.y,
	     block->domain.width, block->domain.height, block->domain.depth);
    fprintf (CHAN, "\tregion   = %p\n", block->region);
    fprintf (CHAN, "\tcapacity = %d\n", block->capacity);
    fprintf (CHAN, "\tused     = %d\n", block->used);
    fprintf (CHAN, "\tpixels   = {");

    if (block->used) {
	fprintf (CHAN, "\n\t\t");
	for (aktive_uint i = 0 ; i < block->used; i++) {
	    if (i) {
		if (i % (block->domain.width * block->domain.depth) == 0) {
		    fprintf (CHAN, "\n\t\t");
		} else if (i % block->domain.depth == 0) {
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
