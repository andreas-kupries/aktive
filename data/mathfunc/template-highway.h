/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Vector Operations. Highway implementation (SIMD)
 *
 * -- TODO :: compile time conditional to prevent compilation
 */
#ifndef AKTIVE_VECTOR_HIGHWAY_H
#define AKTIVE_VECTOR_HIGHWAY_H

// Avoid including the entirety of base.h. The `foreach_target` does not play
// nice with the opaque forwarding declarations of image, region, etc.
typedef unsigned int aktive_uint;

/*
 * - - -- --- ----- -------- -------------
 * copy, clear, const
 */

#define aktive_highway_unary_copy(dst,num,src)	memcpy ((dst), (src), (num)*sizeof (*dst))
#define aktive_highway_unary_clear(dst,num)	memset ((dst), 0,     (num)*sizeof (*dst))
// Note: The value 0b'00000000 represents (double) 0.0.

#ifdef __cplusplus
extern "C" {
#endif /*__cplusplus*/

    void aktive_highway_unary_const (double* dst, aktive_uint num, double value);

#ifdef __cplusplus
}
#endif /*__cplusplus*/

/*
 * - - -- --- ----- -------- -------------
 * generated function declarations
 */

#ifdef __cplusplus
extern "C" {
#endif /*__cplusplus*/

@hdecl@

#ifdef __cplusplus
}
#endif /*__cplusplus*/

/*
 * - - -- --- ----- -------- -------------
 * generated function integration
 */

@hlink@

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_VECTOR_HIGHWAY_H */
