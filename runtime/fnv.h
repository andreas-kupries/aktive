/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API
 * -- Fowler, Noll and Vo - FNV - Hashing
 *
 * References:
 *
 *  - http://isthe.com/chongo/tech/comp/fnv/
 *  - https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
 */
#ifndef AKTIVE_FNV_H
#define AKTIVE_FNV_H

#include <tclpre9compat.h>
#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 */

#define aktive_fnv_base (0x811C9DC5)

extern aktive_uint aktive_fnv_step          (aktive_uint hash);
extern aktive_uint aktive_fnv_merge_bytes   (aktive_uint hash, aktive_uint c, unsigned char* v);
extern aktive_uint aktive_fnv_merge_uint8   (aktive_uint hash, unsigned char x);
extern aktive_uint aktive_fnv_merge_uint32  (aktive_uint hash, aktive_uint x);
extern aktive_uint aktive_fnv_merge_uint64  (aktive_uint hash, Tcl_WideInt x);
extern aktive_uint aktive_fnv_merge_float64 (aktive_uint hash, double x);

extern double      aktive_fnv_gauss (aktive_uint hash);

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
#endif /* AKTIVE_FNV_H */
