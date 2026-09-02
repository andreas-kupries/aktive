/* -*- c -*-
 *
 * -- Direct operator support - op::cache filler and context
 */
#ifndef AKTIVE_OCACHE_H
#define AKTIVE_OCACHE_H

#include <rt.h>

typedef struct {
    aktive_geometry* domain;
    aktive_image     src;
} aktive_ocache;

extern void aktive_op_ocache (aktive_block* out, aktive_ocache* context);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_OCACHE_H */
