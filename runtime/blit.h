/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Pixel blocks, types and methods
 */
#ifndef AKTIVE_BLIT_H
#define AKTIVE_BLIT_H

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

typedef struct aktive_block {
    aktive_region   region   ; // Region owning and managing the block. NULL for independent blocks.
    aktive_geometry domain   ; // Area and bands covered by the `pixel` data
    double*         pixel    ; // Pixel data in row-major order (row, column, band)
    aktive_uint     capacity ; // Allocated size of the pixel data. in elements
    aktive_uint     used     ; // Used part (width * height * depth)
} aktive_block;

typedef double (*aktive_unary_transform)   (double x);
typedef double (*aktive_unary_transform1)  (double x, double a);
typedef double (*aktive_unary_transform2)  (double x, double a, double b);
typedef double (*aktive_binary_transform)  (double x, double y);

typedef double         (*aktive_cunary_reduce)     (double complex x);
typedef double complex (*aktive_cunary_transform)  (double complex x);
typedef double complex (*aktive_cbinary_transform) (double complex x, double complex y);

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

extern void aktive_blit_binary (aktive_block*           dst,
				aktive_rectangle*       dstarea,
				aktive_binary_transform op,
				aktive_block*           srca,
				aktive_block*           srcb);

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

extern void __aktive_block_dump (char* prefix, aktive_block* src);

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
