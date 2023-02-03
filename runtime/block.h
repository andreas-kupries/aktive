/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Pixel blocks, types and methods
 */
#ifndef AKTIVE_BLOCK_H
#define AKTIVE_BLOCK_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <geometry.h>
#include <rtgen/vector-types.h>

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_block {
    aktive_geometry geo      ; // Area and bands covered by the `pixel` data 
    aktive_region   region   ; // Region owning and managing the block.                      
    double*         pixel    ; // Pixel data in row-major order (row, column, band)          
    aktive_uint     capacity ; // Allocated size of the pixel data. in elements              
    aktive_uint     used     ; // Used part (width * height * depth)                         
} aktive_block;

/*
 * - - -- --- ----- -------- -------------
 */

extern void aktive_blit_clear_all  (aktive_block* block);
extern void aktive_blit_clear      (aktive_block* block, aktive_rectangle* area);
extern void aktive_blit_fill       (aktive_block* block, aktive_rectangle* area, double v);
extern void aktive_blit_fill_bands (aktive_block* block, aktive_rectangle* area,
				    aktive_double_vector* bands);

extern void aktive_blit_copy (aktive_block* dst, aktive_rectangle* dstarea,
			      aktive_block* src, aktive_point*     srcloc);

extern void aktive_blit_copy0 (aktive_block* dst, aktive_rectangle* dstarea,
			       aktive_block* src);

/*
 * - - -- --- ----- -------- -------------
 *
 * debug support -- -------- -------------
 *
 * - - -- --- ----- -------- -------------
 */

extern void __aktive_block_dump (char* prefix, aktive_block* block);

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
#endif /* AKTIVE_BLOCK_H */
