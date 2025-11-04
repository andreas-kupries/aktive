/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Vector Operations. Highway implementation (SIMD)
 */

#undef  HWY_TARGET_INCLUDE
#define HWY_TARGET_INCLUDE "generated/vector_highway.c"
#include <hwy/foreach_target.h>
#include <hwy/highway.h>

#include <generated/vector_highway.h>
#include <math.h>
#include <complex.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

HWY_BEFORE_NAMESPACE();
namespace HWY_NAMESPACE {
    using namespace hwy::HWY_NAMESPACE;
    using     F64 = ScalableTag<float64_t>;
    constexpr F64 f64;

    void aktive_highway_unary_const (double* dst, aktive_uint num, double value)
    {
	TRACE_FUNC("((dst) %p, (num) %u, (value) %f)", dst, num, value);
	TRACE_RUN (double* dhead = dst);

	const int32_t N   = Lanes(f64);
	const auto    val = Set(f64, value);

	// not enough for a full block - perform a masked partial op
	if (num < N) {
	    BlendedStore (val, FirstN(f64, num), f64, dst);
	    TRACE_RETURN_VOID;
	}
	// lane-sized blocks, possible partial at the end, shifted backwards to be full
	aktive_uint k, border = num - N;
	for (k = 0; k < num; k += N) {
	    StoreU(val, f64, dst + HWY_MIN (k, border));
	}

	TRACE_RETURN_VOID;
    }

    /*
     * - - -- --- ----- -------- -------------
     * highway function definitions
     */

@hdefs@

} /*namespace HWY_NAMESPACE*/
HWY_AFTER_NAMESPACE();

/*
 * - - -- --- ----- -------- -------------
 */

#if HWY_ONCE
HWY_EXPORT(aktive_highway_unary_const);

extern void
aktive_highway_unary_const (double* d, aktive_uint n, double v) {
    TRACE_FUNC("((dst) %p[%u], (v) %f)", d, n, v);
    /* clang-format off */
    HWY_DYNAMIC_DISPATCH(aktive_highway_unary_const)(d, n, v);
    /* clang-format on */
    TRACE_RETURN_VOID;
}

@hexports@
#endif /*HWY_ONCE*/

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
