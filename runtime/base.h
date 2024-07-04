/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Base types
 */
#ifndef AKTIVE_BASE_H
#define AKTIVE_BASE_H

/*
 * - - -- --- ----- -------- -------------
 */

typedef unsigned int                 aktive_uint;
typedef char*                        aktive_string;
typedef struct aktive_image_type*    aktive_image_type_ptr;
typedef struct aktive_image*         aktive_image;
typedef struct aktive_image_vector*  aktive_image_vector_ptr;
typedef struct aktive_region*        aktive_region;
typedef struct aktive_region_vector* aktive_region_vector_ptr;

/*
 * - - -- --- ----- -------- -------------
 * Macro definitions supporting the extraction of type structures for the
 * internal documentation.
 */

#define A_STRUCTURE(n) typedef struct n
#define A_FIELD(t,n)   t n
#define A_END(n)       n
#define A_END_PTR(n)   *n
#define A_OP_DEPENDENT void*
#define A_CSTRING      const char*
#define A_STRING       char*
#define A_FUNC         /**/

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
#endif /* AKTIVE_BASE_H */
