/* -*- c -*-
 */
#ifndef AKTIVE_TYPES_INT_H
#define AKTIVE_TYPES_INT_H

/* - - -- --- ----- -------- -------------
 */

typedef struct aktive_image {
  int                  refcount ; /* Number of places holding a reference to the image          */
  aktive_image_type*   opspec   ; /* Operational hooks, type identification, parameter metadata */
  void*                param    ; /* Operation parameters */
  aktive_image_vector  srcs     ; /* Input images, if any */

  // %% TODO %% image geometry
  // %% TODO %% image meta data
  
} *aktive_image;

/* - - -- --- ----- -------- -------------
 */

typedef struct aktive_image_region {
  aktive_image          origin ; /* Image / Operation the region is part of */
  aktive_region_vector  srcs   ; /* Input regions, if any */

  // %% TODO %% region state outside the srcs - These would 
  
  /* Local copies of image information */
  
  void*                param    ; /* Operation parameters */
  aktive_image_type*   opspec   ; /* Operational hooks, type identification, parameter metadata */
  
} *aktive_image_region;

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_TYPES_INT_H */
