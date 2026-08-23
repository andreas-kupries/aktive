/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Vector Operations. Scalar loops.
 *
 * Generated code. See
 *
 * - support/math/assets/template.h	Template
 * - support/math/generator.tcl		Generator
 */
#ifndef AKTIVE_VECTOR_SCALAR_H
#define AKTIVE_VECTOR_SCALAR_H

#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 * copy, clear, const
 */

#define aktive_vector_unary_copy(dst,num,src)	memcpy ((dst), (src), (num)*sizeof (*dst))
#define aktive_vector_unary_clear(dst,num)	memset ((dst), 0,     (num)*sizeof (*dst))
// Note: The value 0b'00000000 represents (double) 0.0.
extern void aktive_vector_unary_const (double* dst, aktive_uint num, double value);

/*
 * - - -- --- ----- -------- -------------
 * vector function declarations
 */

@declarations@

/*
 * - - -- --- ----- -------- -------------
 * system integration
 */

@linkage@

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_VECTOR_SCALAR_H */
