/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Matrix operation support
 *
 * Small matrices (NxN, N <=4) are inverted directly, using cofactor expansion
 * and determinants. For N > 4 LU decomposition as provided by LAPACK is used.
 * More specifically, LAPACKe, a highlevel C/C++ wrapper around the LAPACK base.
 */

#include <op/matrix.h>
#include <rt.h>
#include <math.h>
#include <lapacke.h>		// LAPACKe for inverting larger matrices

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

#define LEADER								\
    TRACE_FUNC ("((block* mat) %p, --> (block* out) %p)", mat, out);	\
    aktive_uint width = mat->domain.width;				\
    ASSERT (mat->domain.depth == 1, "unexpected multi-band")

#define SINGULAR							\
    if (fabs (det) < LIMIT) {						\
	aktive_error_add ("unable to invert (near-)singular matrix");	\
	TRACE_RETURN_VOID;						\
    }

/*
 * Lower limit for the determinant of a matrix. A value below this threshold is
 * too small, and causes the matrix to be reported as singular, non-invertible.
 */

#define LIMIT (2.0 * DBL_MIN)

/*
 * Access to the main local pixel blocks, the input MAT'rix, and the RES'ult.
 * Both have the same row geometry, both are single band.
 */

#define MAT(row,col) (mat->pixel [(row)*width + (col)])
#define RES(row,col) (out->pixel [(row)*width + (col)])

/*
 * Direct calculation of the determinants for small matrices (2x2, 3x3, 4x4).
 *
 * All use co-factor expansion along the first column with recursion to
 * calculating the determinants of the smaller sub-matrix
 *
 * | a b | => ad - cb
 * | c d |
 */
#define DET2(a,b,c,d) \
    (  (a)*(d) \
     - (c)*(b))

#define DET3(a,b,c,d,e,f,g,h,i)			\
    (  (a) * DET2 (e, f, h, i)			\
     - (d) * DET2 (b, c, h, i)			\
     + (g) * DET2 (b, c, e, f))

#define DET4(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p)	\
    (  (a) * DET3 (f, g, h, j, k, l, n, o, p)	\
     - (e) * DET3 (b, c, d, j, k, l, n, o, p)	\
     + (i) * DET3 (b, c, d, f, g, h, n, o, p)	\
     - (m) * DET3 (b, c, d, f, g, h, j, k, l))

/*
 * - - -- --- ----- -------- -------------
 * the direct inversion use the cofactor method, i.e. are based on the fact that
 *
 *            1
 * inverse = --- * adjoint, where adjoint = transposed cofactor matrix.
 *           det
 *
 * and the cofactor matrix is the matrix of co-factors for all locations
 * of the input, with alternating signs, i.e.
 *
 * co_ij = (-1)^(i+j) * DET (m/ij)
 * m/ij  = m with row i and column j removed
 */

extern void
aktive_matrix_invert_1x1 (aktive_block* mat, aktive_block* out)
{
    LEADER;
    // 1x1 matrix is a scalar, determinant is value itself.
    double det = MAT (0,0);
    SINGULAR;
    double scale = 1.0 / det;
    RES(0,0) = scale;

    TRACE_RETURN_VOID;
}

extern void
aktive_matrix_invert_2x2 (aktive_block* mat, aktive_block* out)
{
    LEADER;
    // | a b |-1 = |  d -b | / (a*d-b*c)
    // | c d |     | -c  a |
    double a = MAT (0,0), b = MAT (0,1);
    double c = MAT (1,0), d = MAT (1,1);
    double det = DET2 (a, b, c, d);
    SINGULAR;
    // this code trades 4 fp-div ops against 4 fp-mul and 1 fp-div.
    // it assumes that the latter is faster than the former, due to the
    // expensive nature of fp-div.
    double scale = 1.0 / det;
    RES (0,0) =  d * scale; RES (0,1) = -b * scale;
    RES (1,0) = -c * scale; RES (1,1) =  a * scale;

    TRACE_RETURN_VOID;
}

extern void
aktive_matrix_invert_3x3 (aktive_block* mat, aktive_block* out)
{
    LEADER;
    // | a b c |-1 = adjoint * determinant
    // | d e f |     \-> transposed cofactor matrix
    // | g h i |
    double a = MAT (0,0), b = MAT (0,1), c = MAT (0,2);
    double d = MAT (1,0), e = MAT (1,1), f = MAT (1,2);
    double g = MAT (2,0), h = MAT (2,1), i = MAT (2,2);
    double det = DET3 (a, b, c, d, e, f, g, h, i);
    SINGULAR;
    double ca = DET2 (e, f, h, i);	// cofactor matrix
    double cb = DET2 (d, f, g, i);	// | +ca -cb +cc |
    double cc = DET2 (d, e, g, h);	// | -cd +ce -cf |
    double cd = DET2 (b, c, h, i);	// | +cg -ch +ci |
    double ce = DET2 (a, c, g, i);	//
    double cf = DET2 (a, b, g, h);	// transposed cofactors
    double cg = DET2 (b, c, e, f);	// |  ca -cd  cg |
    double ch = DET2 (a, c, d, f);	// | -cb  ce -ch |
    double ci = DET2 (a, b, d, e);  // |  cc -cf  ci |
    // this code trades 9 fp-div ops against 9 fp-mul and 1 fp-div.
    // it assumes that the latter is faster than the former, due to the
    // expensive nature of fp-div.
    double scale = 1.0 / det;
    RES (0,0) =  ca * scale; RES (0,1) = -cd * scale; RES (0,2) =  cg * scale;
    RES (1,0) = -cb * scale; RES (1,1) =  ce * scale; RES (1,2) = -ch * scale;
    RES (2,0) =  cc * scale; RES (2,1) = -cf * scale; RES (2,2) =  ci * scale;

    TRACE_RETURN_VOID;
}

extern void
aktive_matrix_invert_4x4 (aktive_block* mat, aktive_block* out)
{
    LEADER;
    // https://semath.info/src/inverse-cofactor-ex4.html
    // | a b c d |-1 = adjoint * determinant
    // | e f g h |     \-> transposed cofactor matrix
    // | i j k l |
    // | m n o p |
    double a = MAT (0,0), b = MAT (0,1), c = MAT (0,2), d = MAT (0,3);
    double e = MAT (1,0), f = MAT (1,1), g = MAT (1,2), h = MAT (1,3);
    double i = MAT (2,0), j = MAT (2,1), k = MAT (2,2), l = MAT (2,3);
    double m = MAT (3,0), n = MAT (3,1), o = MAT (3,2), p = MAT (3,3);
    double det = DET4 (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p);
    SINGULAR;
    double ca = DET3 (f, g, h, j, k, l, n, o, p);  // cofactor matrix
    double cb = DET3 (e, g, h, i, k, l, m, o, p);  // | +ca -cb +cc -cd |
    double cc = DET3 (e, f, h, i, j, l, m, n, p);  // | -ce +cf -cg +ch |
    double cd = DET3 (e, f, g, i, j, k, m, n, o);  // | +ci -cj +ck -cl |
    double ce = DET3 (b, c, d, j, k, l, n, o, p);  // | -cm +cn -co +cp |
    double cf = DET3 (a, c, d, i, k, l, m, o, p);
    double cg = DET3 (a, b, d, i, j, l, m, n, p);
    double ch = DET3 (a, b, c, i, j, k, m, n, o);
    double ci = DET3 (b, c, d, f, g, h, n, o, p);
    double cj = DET3 (a, c, d, e, g, h, m, o, p);
    double ck = DET3 (a, b, d, e, f, h, m, n, p);
    double cl = DET3 (a, b, c, e, f, g, m, n, o);  // transposed cofactors
    double cm = DET3 (b, c, d, f, g, h, j, k, l);  // |  ca -ce  ci -cm |
    double cn = DET3 (a, c, d, e, g, h, i, k, l);  // | -cb  cf -cj  cn |
    double co = DET3 (a, b, d, e, f, h, i, j, l);  // |  cc -cg  ck -co |
    double cp = DET3 (a, b, c, e, f, g, i, j, k);  // | -cd  ch -cl  cp |
    // this code trades 9 fp-div ops against 9 fp-mul and 1 fp-div.
    // it assumes that the latter is faster than the former, due to the
    // expensive nature of fp-div.
    double scale = 1.0 / det;
    RES (0,0) =  ca * scale; RES (0,1) = -ce * scale; RES (0,2) =  ci * scale; RES (0,3) = -cm * scale;
    RES (1,0) = -cb * scale; RES (1,1) =  cf * scale; RES (1,2) = -cj * scale; RES (1,3) =  cn * scale;
    RES (2,0) =  cc * scale; RES (2,1) = -cg * scale; RES (2,2) =  ck * scale; RES (2,3) = -co * scale;
    RES (3,0) = -cd * scale; RES (3,1) =  ch * scale; RES (3,2) = -cl * scale; RES (3,3) =  cp * scale;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * https://www.arndt-bruenner.de/mathe/scripts/inversematrix.htm
 */

extern void
aktive_matrix_invert_lup (aktive_block* mat, aktive_block* out)
{
    LEADER;
    /*
     * https://www.netlib.org/lapack/lapacke.html
     *
     * The LAPACKe LU decomposition is done in place. As is the inversion
     * using it. The only workspace we have to provide is the int vector for
     * the permutation indices.
     */

    memcpy (&RES (0,0), &MAT (0,0), width * width * sizeof (double));

    lapack_int* permute = NALLOC (int, width);
    lapack_int  err     = LAPACKE_dgetrf (LAPACK_ROW_MAJOR,
					  width, width, out->pixel, width, permute);

    if (err == 0) {
	TRACE_DO (__aktive_block_dump ("LU result", out));
	err = LAPACKE_dgetri (LAPACK_ROW_MAJOR,
			      width, out->pixel, width, permute);
    }

    FREE (permute);

    if (err == 0) {
	TRACE_DO (__aktive_block_dump ("inversion result", out));
    } else if (err == LAPACK_WORK_MEMORY_ERROR) {
	aktive_error_add ("unable to allocate work memory");
    } else if (err == LAPACK_TRANSPOSE_MEMORY_ERROR) {
	aktive_error_add ("unable to allocate transposition memory");
    } else if (err < 0) {
	aktive_error_add ("illegal NaN in input");
    } else if (err > 0) {
	// U (err, err) == 0 --> singular matrix
	aktive_error_add ("unable to invert (near-)singular matrix");
    }

    TRACE_RETURN_VOID;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
