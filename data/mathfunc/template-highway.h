/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Vector Operations. Highway implementation (SIMD)
 */
#ifndef AKTIVE_VECTOR_HIGHWAY_H
#define AKTIVE_VECTOR_HIGHWAY_H

#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 * copy, clear, const
 */

#define aktive_highway_unary_copy(dst,num,src)	memcpy ((dst), (src), (num)*sizeof (*dst))
#define aktive_highway_unary_clear(dst,num)	memset ((dst), 0,     (num)*sizeof (*dst))
// Note: The value 0b'00000000 represents (double) 0.0.
extern void aktive_highway_unary_const (double* dst, aktive_uint num, double value);

/*
 * - - -- --- ----- -------- -------------
 * highway function declarations
 */

@hdecl@

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_VECTOR_HIGHWAY_H */
