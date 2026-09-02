
/*
 * - - -- --- ----- -------- -------------
 */

#include <kahan.h>
#include <dotproduct.h>

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_dotproduct_base (double* dst, double* srca, double* srcb, aktive_uint n, aktive_uint bands)
{
    TRACE_FUNC ("(dst %p [%u] <-- srca %p [%u*%u], srcb %p [%u*%u])",
		dst, bands, srca, n, bands, srcb, n, bands);

    // iterate over bands
    aktive_uint band; for (band = 0; band < bands; band ++, dst ++, srca ++, srcb ++) {
	TRACE_DO (__aktive_vector_dump ("a  ", srca, n, bands));
	TRACE_DO (__aktive_vector_dump ("b  ", srcb, n, bands));

	// iterate over the pixels of the band
	double *av;
	double *bv;
	aktive_uint i;
	kahan acc; aktive_kahan_init (acc);
	TRACE_HEADER (1); TRACE_ADD ("[%d]double/1 a*b = {", n);
	for (i = 0, av = srca, bv = srcb; i < n; i ++, av += bands, bv += bands) {
	    double a = *av, b = *bv, z = a*b;
	    aktive_kahan_add (acc, z);
	    TRACE_ADD (" %f", z);
	}
	dst[0] = aktive_kahan_final (acc);
	TRACE_ADD (" } --> %f", dst[0]); TRACE_CLOSER;
    }

    TRACE_RETURN_VOID;
}

extern void
aktive_dotproduct_u4 (double* dst, double* srca, double* srcb, aktive_uint n, aktive_uint bands)
{
    TRACE_FUNC ("(dst %p [%u] <-- srca %p [%u*%u], srcb %p [%u*%u])",
		dst, bands, srca, n, bands, srcb, n, bands);

    // Unroll the loops ... Schedule depends on the number of bands to handle.
    switch (bands) {
    case 1: {
	TRACE_DO (__aktive_vector_dump ("a  ", srca, n, bands));
	TRACE_DO (__aktive_vector_dump ("b  ", srcb, n, bands));

	// Run 4 lanes of partial sums and merge at the end
	kahan acc0; aktive_kahan_init (acc0);
	kahan acc1; aktive_kahan_init (acc1);
	kahan acc2; aktive_kahan_init (acc2);
	kahan acc3; aktive_kahan_init (acc3);

	double *av = srca, *bv = srcb;

	aktive_uint count;
	for (count = n; count > 4; count --, srca += 4, srcb += 4) {
	    double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc0, z0);
	    double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc1, z1);
	    double a2 = av[2], b2 = bv[2], z2 = a2 * b2; aktive_kahan_add (acc2, z2);
	    double a3 = av[3], b3 = bv[3], z3 = a3 * b3; aktive_kahan_add (acc3, z3);
	}
	for (         ; count > 2; count --, srca += 2, srcb += 2) {
	    double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc0, z0);
	    double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc1, z1);
	}
	for (         ; count > 1; count --, srca += 1, srcb += 1) {
	    double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc0, z0);
	}

	aktive_kahan_add_kahan (acc2, acc3);
	aktive_kahan_add_kahan (acc0, acc1);
	aktive_kahan_add_kahan (acc0, acc2);

	dst[0] = aktive_kahan_final (acc0);
    }; break;
    case 2: {
	TRACE_DO (__aktive_vector_dump ("a0 ", srca+0, n, bands));
	TRACE_DO (__aktive_vector_dump ("b0 ", srcb+0, n, bands));
	TRACE_DO (__aktive_vector_dump ("a1 ", srca+1, n, bands));
	TRACE_DO (__aktive_vector_dump ("b1 ", srcb+1, n, bands));

	// Run 2 lanes of partial sums for 2 bands, and merge at the end
	kahan acc00; aktive_kahan_init (acc00);
	kahan acc01; aktive_kahan_init (acc01);
	//       |\- pixel
	//       \-- band
	kahan acc10; aktive_kahan_init (acc10);
	kahan acc11; aktive_kahan_init (acc11);

	double *av = srca, *bv = srcb;

	aktive_uint count;
	for (count = n; count > 4; count --, srca += 4, srcb += 4) {
	    double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc00, z0);
	    double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc10, z1);

	    double a2 = av[2], b2 = bv[2], z2 = a2 * b2; aktive_kahan_add (acc01, z2);
	    double a3 = av[3], b3 = bv[3], z3 = a3 * b3; aktive_kahan_add (acc11, z3);
	}
	for (         ; count > 2; count --, srca += 2, srcb += 2) {
	    double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc00, z0);
	    double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc10, z1);
	}

	aktive_kahan_add_kahan (acc00, acc01); // band 0 merge pixels
	aktive_kahan_add_kahan (acc10, acc11); // band 1 merge pixels

	dst[0] = aktive_kahan_final (acc00); // band 0 result
	dst[1] = aktive_kahan_final (acc10); // band 1 result
    }; break;
    case 3: {
	TRACE_DO (__aktive_vector_dump ("a0 ", srca+0, n, bands));
	TRACE_DO (__aktive_vector_dump ("b0 ", srcb+0, n, bands));
	TRACE_DO (__aktive_vector_dump ("a1 ", srca+1, n, bands));
	TRACE_DO (__aktive_vector_dump ("b1 ", srcb+1, n, bands));
	TRACE_DO (__aktive_vector_dump ("a2 ", srca+2, n, bands));
	TRACE_DO (__aktive_vector_dump ("b2 ", srcb+2, n, bands));

	// Run 2 lanes of partial sums for 3 bands, and merge at the end
	kahan acc00; aktive_kahan_init (acc00);
	kahan acc10; aktive_kahan_init (acc10);
	kahan acc20; aktive_kahan_init (acc20);
	//       |\- pixel
	//       \-- band
	kahan acc01; aktive_kahan_init (acc01);
	kahan acc11; aktive_kahan_init (acc11);
	kahan acc21; aktive_kahan_init (acc21);

	double *av = srca, *bv = srcb;

	aktive_uint count;
	for (count = n; count > 6; count --, srca += 6, srcb += 6) {
	    double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc00, z0);
	    double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc10, z1);
	    double a2 = av[2], b2 = bv[2], z2 = a2 * b2; aktive_kahan_add (acc20, z2);

	    double a3 = av[3], b3 = bv[3], z3 = a3 * b3; aktive_kahan_add (acc01, z3);
	    double a4 = av[4], b4 = bv[4], z4 = a4 * b4; aktive_kahan_add (acc11, z4);
	    double a5 = av[5], b5 = bv[5], z5 = a5 * b5; aktive_kahan_add (acc21, z5);
	}
	for (         ; count > 3; count --, srca += 3, srcb += 3) {
	    double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc00, z0);
	    double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc10, z1);
	    double a2 = av[2], b2 = bv[2], z2 = a2 * b2; aktive_kahan_add (acc20, z2);
	}

	aktive_kahan_add_kahan (acc00, acc01); // band 0 merge pixels
	aktive_kahan_add_kahan (acc10, acc11); // band 1 merge pixels
	aktive_kahan_add_kahan (acc20, acc21); // band 2 merge pixels

	dst[0] = aktive_kahan_final (acc00); // band 0 result
	dst[1] = aktive_kahan_final (acc10); // band 1 result
	dst[2] = aktive_kahan_final (acc20); // band 2 result
    }; break;
    case 4: {
	TRACE_DO (__aktive_vector_dump ("a0 ", srca+0, n, bands));
	TRACE_DO (__aktive_vector_dump ("b0 ", srcb+0, n, bands));
	TRACE_DO (__aktive_vector_dump ("a1 ", srca+1, n, bands));
	TRACE_DO (__aktive_vector_dump ("b1 ", srcb+1, n, bands));
	TRACE_DO (__aktive_vector_dump ("a2 ", srca+2, n, bands));
	TRACE_DO (__aktive_vector_dump ("b2 ", srcb+2, n, bands));
	TRACE_DO (__aktive_vector_dump ("a3 ", srca+3, n, bands));
	TRACE_DO (__aktive_vector_dump ("b3 ", srcb+3, n, bands));

	// Run 4 lanes of partial sums, one per band, no merging
	kahan acc0; aktive_kahan_init (acc0);
	kahan acc1; aktive_kahan_init (acc1);
	kahan acc2; aktive_kahan_init (acc2);
	kahan acc3; aktive_kahan_init (acc3);

	double *av = srca, *bv = srcb;

	aktive_uint count;
	for (count = n; count > 4; count --, srca += 4, srcb += 4) {
	    double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc0, z0);
	    double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc1, z1);
	    double a2 = av[2], b2 = bv[2], z2 = a2 * b2; aktive_kahan_add (acc2, z2);
	    double a3 = av[3], b3 = bv[3], z3 = a3 * b3; aktive_kahan_add (acc3, z3);
	}

	dst[0] = aktive_kahan_final (acc0);
	dst[1] = aktive_kahan_final (acc1);
	dst[2] = aktive_kahan_final (acc2);
	dst[3] = aktive_kahan_final (acc3);
    } ; break;
    default: {
	// TODO vector dumps of the bands

	// iterate over bands, groups of 4, 2, 1
	aktive_uint band;
	for (band = bands; band > 4; band -= 4, dst += 4, srca += 4, srcb += 4) {
	    // 4 independent lanes
	    kahan acc0; aktive_kahan_init (acc0);
	    kahan acc1; aktive_kahan_init (acc1);
	    kahan acc2; aktive_kahan_init (acc2);
	    kahan acc3; aktive_kahan_init (acc3);
	    // iterate pixels of the 4 bands
	    double *av = srca, *bv = srcb;
	    aktive_uint i; for (i = 0; i < n; i ++, av += bands, bv += bands) {
		double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc0, z0);
		double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc1, z1);
		double a2 = av[2], b2 = bv[2], z2 = a2 * b2; aktive_kahan_add (acc2, z2);
		double a3 = av[3], b3 = bv[3], z3 = a3 * b3; aktive_kahan_add (acc3, z3);
	    }
	    dst[0] = aktive_kahan_final (acc0);
	    dst[1] = aktive_kahan_final (acc1);
	    dst[2] = aktive_kahan_final (acc2);
	    dst[3] = aktive_kahan_final (acc3);
	}
	for (            ; band > 2; band -= 2, dst += 2, srca += 2, srcb +=2) {
	    // 2x2 lanes, 2 pixels, 2 bands each
	    kahan acc00; aktive_kahan_init (acc00);
	    kahan acc01; aktive_kahan_init (acc01);
	    kahan acc10; aktive_kahan_init (acc10);
	    kahan acc11; aktive_kahan_init (acc11);
	    //       |\- pixel
	    //       \-- band
	    double *av = srca, *bv = srcb;
	    aktive_uint count;
	    for (count = n; count > 4; count -= 4, av += 2*bands, bv += 2*bands) {
		double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc00, z0);
		double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc01, z1);
		double a2 = av[2], b2 = bv[2], z2 = a2 * b2; aktive_kahan_add (acc10, z2);
		double a3 = av[3], b3 = bv[3], z3 = a3 * b3; aktive_kahan_add (acc11, z3);
	    }
	    for (         ; count > 2; count -= 2, av += 2*bands, bv += 2*bands) {
		double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc00, z0);
		double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc01, z1);
	    }

	    aktive_kahan_add_kahan (acc00, acc01);
	    aktive_kahan_add_kahan (acc10, acc11);

	    dst[0] = aktive_kahan_final (acc00);
	    dst[1] = aktive_kahan_final (acc10);
	}
	for (            ; band > 1; band --, dst ++, srca ++, srcb ++) {
	    // last single band - 4 lanes, groups of 4, 2, 1 pixels
	    double *av = srca, *bv = srcb;
	    kahan acc0; aktive_kahan_init (acc0);
	    kahan acc1; aktive_kahan_init (acc1);
	    kahan acc2; aktive_kahan_init (acc2);
	    kahan acc3; aktive_kahan_init (acc3);
	    // ASSERT bands == 1
	    aktive_uint count;
	    for (count = n; count > 4; count -= 4, av += 4*bands, bv += 4*bands) {
		double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc0, z0);
		double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc1, z1);
		double a2 = av[2], b2 = bv[2], z2 = a2 * b2; aktive_kahan_add (acc2, z2);
		double a3 = av[3], b3 = bv[3], z3 = a3 * b3; aktive_kahan_add (acc3, z3);
	    }
	    for (         ; count > 2; count -= 2, av += 2*bands, bv += 2*bands) {
		double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc0, z0);
		double a1 = av[1], b1 = bv[1], z1 = a1 * b1; aktive_kahan_add (acc1, z1);
	    }
	    for (         ; count > 1; count --,   av += 1*bands, bv += 1*bands) {
		double a0 = av[0], b0 = bv[0], z0 = a0 * b0; aktive_kahan_add (acc0, z0);
	    }

	    aktive_kahan_add_kahan (acc2, acc3);
	    aktive_kahan_add_kahan (acc0, acc1);
	    aktive_kahan_add_kahan (acc0, acc2);

	    dst[0] = aktive_kahan_final (acc0);
	}

    } ; break;
    }
    TRACE_RETURN_VOID;
}

#if 0
SCRATCH

	// show inputs
	av = srca; fprintf(stderr, "a = {");
	for (i = 0; i < n; i ++, av += bands) {
	    fprintf(stderr, " %f", *av);
	}; fprintf(stderr, " }\n");
	bv = srcb; fprintf(stderr, "b = {");
	for (i = 0; i < n; i ++, bv += bands) {
	    fprintf(stderr, " %f", *bv);
	}; fprintf(stderr, " }\n");

#endif

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
