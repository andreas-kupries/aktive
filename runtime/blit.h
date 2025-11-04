/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Pixel blocks, types and methods
 */
#ifndef AKTIVE_BLIT_H
#define AKTIVE_BLIT_H

/*
 * - - -- --- ----- -------- -------------
 * Shorthands for blit nests, generated, or manually written
 */

// base scan, dst and source handled outside
#define BLIT_SCAN(label, count)		\
    aktive_uint iter_ ## label ;	\
    for (iter_ ## label = 0       ;	\
         iter_ ## label < (count) ;	\
	 iter_ ## label ++		\
	 )

// scan destination only
#define BLIT_SCAN_D(label, count, dstv, start, stride)	\
    aktive_uint iter_ ## label ;			\
    for (iter_ ## label = 0       , dstv = (start) ;	\
         iter_ ## label < (count) ;			\
	 iter_ ## label ++	  , dstv += (stride)	\
	 )

// scan destination and single source
#define BLIT_SCAN_DS(label, count, dstv, dstart, dstride, srcv, sstart, sstride) \
    aktive_uint iter_ ## label ;					\
    for (iter_ ## label = 0       , dstv = (dstart),   srcv = (sstart) ; \
         iter_ ## label < (count) ;					\
	 iter_ ## label ++	  , dstv += (dstride), srcv += (sstride) \
	 )

// scan destination and two sources - this is the max at the moment
#define BLIT_SCAN_DSS(label, count, dstv, dstart, dstride, srca, astart, astride, srcb, bstart, bstride) \
    aktive_uint iter_ ## label ;					\
    for (iter_ ## label = 0       , dstv = (dstart),   srca = (astart),   srcb = (bstart) ; \
         iter_ ## label < (count) ;					\
	 iter_ ## label ++	  , dstv += (dstride), srca += (astride), srcb += (bstride) \
	 )

// scan destination and source, source is fractional
#define BLIT_SCAN_DSF(label, count, dstv, dstart, dstride, srcv, sstart, sstride, fstep) \
    aktive_uint iter_ ## label ;					\
    for (iter_ ## label = 0       , dstv = (dstart),   srcv = (sstart) ; \
         iter_ ## label < (count) ;					\
	 iter_ ## label ++	  , dstv += (dstride), phase ## label ++, phase ## label %= (fstep), srcv = srcv + ((phase ## label) ? 0: (sstride)) \
	 )

// fraction stepping support, unintegrated scanner
#define BLIT_STEP_FRACTION(label, step, varop)	\
    phase ## label ++ ;				\
    phase ## label %= (step) ;			\
    if (!phase ## label ) {			\
	TRACE (".... phase" #label " done", 0);	\
	varop ;					\
    }

// bounds checks a position against capacity
#define BLIT_BOUNDS(prefix, pos, cap)				\
    if ((pos) >= (cap)) {						\
	TRACE_CLOSER;							\
	TRACE("ASSERT", 0);						\
	ASSERT_VA (0, #prefix " out of bounds", "%d / %d", (pos), (cap)); \
    }

/*
 * - - -- --- ----- -------- -------------
 */

#include <complex.h>
#include <geometry.h>
#include <rtgen/vector-types.h>

/*
 * - - -- --- ----- -------- -------------
 *
 * NOTE
 *
 *  - `aktive_block` is a proper extension of `aktive_geometry`, see
 *    `geometry.h`.
 */

A_STRUCTURE (aktive_block) {
    A_FIELD (aktive_uint,     initialized) ; // Fully initialized (pixel, capacity, etc)
    A_FIELD (aktive_region,   owner)       ; // Region owning and managing the block.
    //                                          NULL indicates an independent block.
    A_FIELD (aktive_region,   reader)      ; // Primary reader region for the block. Conflict detection.
    //                                          NULL indicates that nobody has read the block yet
    A_FIELD (aktive_point,    location)    ; // Logical location in the originating image.
    A_FIELD (aktive_geometry, domain)      ; // Physical area and bands covered by the `pixel` data.
    A_FIELD (double*,         pixel)       ; // Pixel data in row-major order (row, column, band)
    A_FIELD (aktive_uint,     capacity)    ; // Allocated size of the pixel data. in elements
    A_FIELD (aktive_uint,     used)        ; // Used part (width * height * depth)
} A_END (aktive_block);

typedef double (*aktive_unary_transform)   (double x);
typedef double (*aktive_unary_transform1)  (double x, double a);
typedef double (*aktive_unary_transform2)  (double x, double a, double b);
typedef double (*aktive_unary_transformgz) (double x, void* param, aktive_uint z);
typedef double (*aktive_binary_transform)  (double x, double y);

typedef double         (*aktive_cunary_reduce)     (double complex x);
typedef double complex (*aktive_cunary_transform)  (double complex x);
typedef double complex (*aktive_cbinary_transform) (double complex x, double complex y);

/*
 * - - -- --- ----- -------- -------------
 * memcopy, memset for []double
 */

extern void aktive_blit_dcopy (double* dst, aktive_uint num, aktive_uint stride, double* src);
#define     aktive_blit_dcopy1(dst,num,src) memcpy ((dst), (src), (num)*sizeof (double))

extern void aktive_blit_dset  (double* dst, aktive_uint num, aktive_uint stride, double value);
extern void aktive_blit_dset1 (double* dst, aktive_uint num, double value);

extern void aktive_blit_dclear (double* dst, aktive_uint num);
#define     aktive_blit_dclear1(dst,num) memset (dst, 0, (num)*sizeof (double))
// Note: The value 0b'00000000 represents (double) 0.0.

/*
 * - - -- --- ----- -------- -------------
 */

extern void aktive_blit_setup (aktive_block* dst, aktive_rectangle* request);
extern void aktive_blit_close (aktive_block* dst);

extern aktive_uint aktive_blit_index (aktive_block* src, int x, int y, int z);

/*
 * - - -- --- ----- -------- -------------
 */

extern void aktive_blit_clear_all  (aktive_block* dst);
extern void aktive_blit_clear      (aktive_block* dst, aktive_rectangle* area);

extern void aktive_blit_clear_bands_from (aktive_block* dst, aktive_rectangle* area,
					  aktive_uint first, aktive_uint n);

extern void aktive_blit_fill         (aktive_block* dst, aktive_rectangle* area, double v);
extern void aktive_blit_fill_bands   (aktive_block* dst, aktive_rectangle* area,
				      aktive_double_vector* bands);
extern void aktive_blit_fill_rows    (aktive_block* dst, aktive_rectangle* area,
				      int x, aktive_double_vector* row);
extern void aktive_blit_fill_columns (aktive_block* dst, aktive_rectangle* area,
				      int y, aktive_double_vector* column);

extern void aktive_blit_copy (aktive_block* dst, aktive_rectangle* dstarea,
			      aktive_block* src, aktive_point*     srcloc);

extern void aktive_blit_copy0 (aktive_block* dst, aktive_rectangle* dstarea,
			       aktive_block* src);

extern void aktive_blit_unary0 (aktive_block* dst, aktive_rectangle* dstarea,
				aktive_unary_transform op, aktive_block* src);

extern void aktive_blit_unary1 (aktive_block* dst, aktive_rectangle* dstarea,
				aktive_unary_transform1 op, double a, aktive_block* src);

extern void aktive_blit_unary2 (aktive_block* dst, aktive_rectangle* dstarea,
				aktive_unary_transform2 op, double a, double b,
				aktive_block* src);

extern void aktive_blit_unarygz (aktive_block* dst, aktive_rectangle* dstarea,
				 aktive_unary_transformgz op, void* param,
				 aktive_block* src);

extern void aktive_blit_binary (aktive_block*           dst,
				aktive_rectangle*       dstarea,
				aktive_binary_transform op,
				aktive_block*           srca,
				aktive_block*           srcb);

/* Accumulate the `src` data into the destination by means of `op`.
 * In other words:
 *
 *	`dst = dst "op" src`  <==> `dst = op (dst, src)`
 */
extern void aktive_blit_binary_acc (aktive_block*           dst,
				    aktive_rectangle*       dstarea,
				    aktive_binary_transform op,
				    aktive_block*           src);

extern void aktive_blit_cunary (aktive_block* dst, aktive_rectangle* dstarea,
				aktive_cunary_transform op, aktive_block* src);

extern void aktive_blit_cbinary (aktive_block*            dst,
				 aktive_rectangle*        dstarea,
				 aktive_cbinary_transform op,
				 aktive_block*            srca,
				 aktive_block*            srcb);

extern void aktive_blit_creduce (aktive_block* dst, aktive_rectangle* dstarea,
				 aktive_cunary_reduce op, aktive_block* src);

extern void aktive_blit_copy0_bands (aktive_block* dst, aktive_rectangle* dstarea,
				     aktive_block* src, aktive_uint first, aktive_uint last);

extern void aktive_blit_copy0_bands_to (aktive_block* dst, aktive_rectangle* dstarea,
					aktive_block* src, aktive_uint first);
//                                                     in destination -^ :: all src bands are taken

// This function assumes depth == 1. If depth > 1 caller has to manipulate the
// point's x coordinate to reach the desired cell (band in the column)
// A single cell is set to the specified value.

extern void aktive_blit_set (aktive_block* dst, aktive_point* location, double v);

/*
 * - - -- --- ----- -------- -------------
 *
 * debug support -- -------- -------------
 *
 * - - -- --- ----- -------- -------------
 */

extern void __aktive_block_dump (const char* prefix, aktive_block* src);

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
#endif /* AKTIVE_BLIT_H */
