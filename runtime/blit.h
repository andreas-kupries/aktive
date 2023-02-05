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
    aktive_region   region   ; // Region owning and managing the block.                      
    aktive_geometry domain   ; // Area and bands covered by the `pixel` data 
    double*         pixel    ; // Pixel data in row-major order (row, column, band)          
    aktive_uint     capacity ; // Allocated size of the pixel data. in elements              
    aktive_uint     used     ; // Used part (width * height * depth)                         
} aktive_block;

typedef double (*aktive_unary_transform)  (double x);
typedef double (*aktive_unary_transform1) (double x, double a);
typedef double (*aktive_unary_transform2) (double x, double a, double b);

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
extern void aktive_blit_fill       (aktive_block* dst, aktive_rectangle* area, double v);
extern void aktive_blit_fill_bands (aktive_block* dst, aktive_rectangle* area,
				    aktive_double_vector* bands);

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

// This function assumes depth == 1. If depth > 1 caller has to manipulate the
// point's x coordinate to reach the desired cell (band in the column)
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
