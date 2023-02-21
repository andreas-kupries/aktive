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
    
    aktive_geometry_set_rectangle     (&dst->domain, request);
    aktive_point_set ((aktive_point*) &dst->domain, 0, 0);
    
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

    memset (dst->pixel, '\0', sizeof(double) * dst->used);

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

#if 1 // TODO :: switch when optimized properly
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#include <generated/blit/clearall.c>
#else    
    memset (dst->pixel, 0, dst->used * sizeof (double));
    // Note: The value 0b'00000000 represents (double) 0.0.
#endif
    TRACE_RETURN_VOID;
}

extern void
aktive_blit_clear (aktive_block* dst, aktive_rectangle* area)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
#if 1 // TODO :: switch when optimized properly
#define AH     (area->height)
#define AW     (area->width)
#define AX     (area->x)
#define AY     (area->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#include <generated/blit/clear.c>
#else    
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
#endif
    TRACE_RETURN_VOID;
}

extern void
aktive_blit_clear_bands_from (aktive_block* dst, aktive_rectangle* area,
			      aktive_uint first, aktive_uint n)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);

#define AH     (area->height)
#define AW     (area->width)
#define AX     (area->x)
#define AY     (area->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#include <generated/blit/clear_bands_from.c>

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_fill (aktive_block* dst, aktive_rectangle* area, double v)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);

#define AH     (area->height)
#define AW     (area->width)
#define AX     (area->x)
#define AY     (area->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#include <generated/blit/fill.c>

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

#if 1 // TODO :: switch when optimized
#define AH     (dstarea->height)
#define AW     (dstarea->width)
#define AX     (dstarea->x)
#define AY     (dstarea->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#define SD     (src->domain.depth)
#define SH     (src->domain.height)
#define SRC    (src->pixel)
#define SRCCAP (src->used)
#define SW     (src->domain.width)
#define SX     (srcloc->x)
#define SY     (srcloc->y)
#include <generated/blit/copy.c>
#else    
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
#endif
    TRACE_RETURN_VOID;
}

extern void
aktive_blit_copy0 (aktive_block* dst, aktive_rectangle* dstarea,
		   aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    TRACE_GEOMETRY_M ("domain_", &dst->domain);
    TRACE_RECTANGLE   (dstarea);
    TRACE_GEOMETRY_M ("srcdom_", &src->domain);

#define AH     (dstarea->height)
#define AW     (dstarea->width)
#define AX     (dstarea->x)
#define AY     (dstarea->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#define SD     (src->domain.depth)
#define SH     (src->domain.height)
#define SRC    (src->pixel)
#define SRCCAP (src->used)
#define SW     (src->domain.width)
#include <generated/blit/copy0.c>

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

#define AH     (dstarea->height)
#define AW     (dstarea->width)
#define AX     (dstarea->x)
#define AY     (dstarea->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#define SD     (src->domain.depth)
#define SH     (src->domain.height)
#define SRC    (src->pixel)
#define SRCCAP (src->used)
#define SW     (src->domain.width)
#include <generated/blit/unary0.c>

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_unary1 (aktive_block* dst, aktive_rectangle* dstarea,
		    aktive_unary_transform1 op, double a, aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
#define AH     (dstarea->height)
#define AW     (dstarea->width)
#define AX     (dstarea->x)
#define AY     (dstarea->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#define SD     (src->domain.depth)
#define SH     (src->domain.height)
#define SRC    (src->pixel)
#define SRCCAP (src->used)
#define SW     (src->domain.width)
#include <generated/blit/unary1.c>

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_unary2 (aktive_block* dst, aktive_rectangle* dstarea,
		    aktive_unary_transform2 op, double a, double b,
		    aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);
    
#define AH     (dstarea->height)
#define AW     (dstarea->width)
#define AX     (dstarea->x)
#define AY     (dstarea->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#define SD     (src->domain.depth)
#define SH     (src->domain.height)
#define SRC    (src->pixel)
#define SRCCAP (src->used)
#define SW     (src->domain.width)
#include <generated/blit/unary2.c>

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_binary (aktive_block* dst, aktive_rectangle* dstarea,
		    aktive_binary_transform op,
		    aktive_block* srca, aktive_block* srcb)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);

#define AH      (dstarea->height)
#define AW      (dstarea->width)
#define AX      (dstarea->x)
#define AY      (dstarea->y)
#define DD      (dst->domain.depth)
#define DH      (dst->domain.height)
#define DST     (dst->pixel)
#define DSTCAP  (dst->used)
#define DW      (dst->domain.width)
#include <generated/blit/binary.c>

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_cunary (aktive_block* dst, aktive_rectangle* dstarea,
		    aktive_cunary_transform op, aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);

#define AH     (dstarea->height)
#define AW     (dstarea->width)
#define AX     (dstarea->x)
#define AY     (dstarea->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#include <generated/blit/complex_unary.c>

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_cbinary (aktive_block* dst, aktive_rectangle* dstarea,
		     aktive_cbinary_transform op,
		     aktive_block* srca, aktive_block* srcb)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);

#define AH      (dstarea->height)
#define AW      (dstarea->width)
#define AX      (dstarea->x)
#define AY      (dstarea->y)
#define DD      (dst->domain.depth)
#define DH      (dst->domain.height)
#define DST     (dst->pixel)
#define DSTCAP  (dst->used)
#define DW      (dst->domain.width)
#include <generated/blit/complex_binary.c>

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_creduce (aktive_block* dst, aktive_rectangle* dstarea,
		    aktive_cunary_reduce op, aktive_block* src)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);

#define AH     (dstarea->height)
#define AW     (dstarea->width)
#define AX     (dstarea->x)
#define AY     (dstarea->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#include <generated/blit/complex_reduce.c>

    TRACE_RETURN_VOID;
}

extern void
aktive_blit_copy0_bands (aktive_block* dst, aktive_rectangle* dstarea,
			 aktive_block* src, aktive_uint first, aktive_uint last)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);

#define SRC src->domain
#define DST dst->domain
#define DAR dstarea
    TRACE ("...  x   y   | w   h   d   | pit )", 0);
    TRACE ("src (%3d %3d | %3d %3d %3d | %3d )", SRC.x, SRC.y, SRC.width, SRC.height, SRC.depth, SRC.width * SRC.depth);
    TRACE ("dst (%3d %3d | %3d %3d %3d | %3d )", DST.x, DST.y, DST.width, DST.height, DST.depth, DST.width * DST.depth);
    TRACE ("dar (%3d %3d | %3d %3d     |     )", DAR->x, DAR->y, DAR->width, DAR->height);
    TRACE ("bands %d..%d", first, last);

    // assert : dst.domain.depth <= src.domain.depth -- dst gets a subset of src bands

    aktive_uint dstpos, dsty, dstx, dstz;
    aktive_uint srcpos, srcy, srcx, srcz;
    aktive_uint row, col;

    // Unoptimized loop nest to copy the selected bands
    TRACE ("sy  sx  sz  | in  | dy  dx  dz  | out |", 0);
    
    for (srcy = SRC.y, dsty = DST.y, row = 0; row < DST.height; srcy++, dsty++, row++) {
	for (srcx = SRC.x, dstx = DST.x, col = 0; col < DST.width; srcx++, dstx++, col++) {
	    for (srcz = first, dstz = 0; dstz < DST.depth ; srcz++, dstz++) {

		srcpos = srcy * SRC.width * SRC.depth + srcx * SRC.depth + srcz;
		dstpos = dsty * DST.width * DST.depth + dstx * DST.depth + dstz;

		double value = src->pixel [srcpos];

		TRACE ("%3d %3d %3d | %3d | %3d %3d %3d | %3d | %.2f",
		       srcy, srcx, srcz, srcpos, dsty, dstx, dstz, dstpos, value);
		    
		dst->pixel [dstpos] = value; // inlined blit set, we already have the coordinates
	    }
	}
    }    
#undef SRC
#undef DST
#undef DAR
    TRACE_RETURN_VOID;
}

extern void
aktive_blit_copy0_bands_to (aktive_block* dst, aktive_rectangle* dstarea,
			 aktive_block* src, aktive_uint first)
{
    TRACE_FUNC("((block*) %p (%d of %d @ %p)", dst, dst->used, dst->capacity, dst->pixel);

#define AH     (dstarea->height)
#define AW     (dstarea->width)
#define AX     (dstarea->x)
#define AY     (dstarea->y)
#define DD     (dst->domain.depth)
#define DH     (dst->domain.height)
#define DST    (dst->pixel)
#define DSTCAP (dst->used)
#define DW     (dst->domain.width)
#define SD     (src->domain.depth)
#define SH     (src->domain.height)
#define SRC    (src->pixel)
#define SRCCAP (src->used)
#define SW     (src->domain.width)
#define SX     (srcloc->x)
#define SY     (srcloc->y)
#define DZ     (first)
#include <generated/blit/copy_bands.c>

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

    TRACE ("%s %p = block {", prefix, src);
    TRACE ("  domain  = { %d..%d, %d..%d : %u x %u x %u }",
	   src->domain.x, src->domain.x + src->domain.width  - 1,
	   src->domain.y, src->domain.y + src->domain.height - 1,
	   src->domain.width, src->domain.height, src->domain.depth);
    TRACE ("  region  = %p", src->region);
    TRACE ("  use/cap = %d/%d", src->used, src->capacity);

    TRACE_HEADER(1) ; TRACE_ADD ("  pixels  = {", 0);
    if (src->used) {
	TRACE_CLOSER; TRACE_HEADER (1); TRACE_ADD ("    ", 0);
	for (aktive_uint i = 0 ; i < src->used; i++) {
	    if (i) {
		if (i % (src->domain.width * src->domain.depth) == 0) {
		    TRACE_CLOSER; TRACE_HEADER (1); TRACE_ADD ("    ", 0);
		} else if (i % src->domain.depth == 0) {
		    TRACE_ADD (" /", 0);
		}
	    }

	    TRACE_ADD (" %f", src->pixel [i]);

	}
	TRACE_CLOSER; TRACE_HEADER (1); TRACE_ADD ("  ", 0);
    }
    TRACE_ADD ("}", 0); TRACE_CLOSER;
    TRACE ("}", 0);
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
