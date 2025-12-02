# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Templates for highway implementations.

set u4_unary0_hdecl {void aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n);}
set u4_unary0_hdef  {
    HWY_ATTR void
    aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);

	const int32_t N  = Lanes(f64);
	const int32_t N2 = N + N;
	const int32_t N3 = N2 + N;
	const int32_t N4 = N2 + N2;
	@decls@
	// not enough for a full block - perform a masked partial op
	if (n < N) {
	    auto mask = FirstN(f64, n);
	    auto v    = MaskedLoad(mask, f64, s);
	    // / / // /// ///// //////// /////////////
	    @opcode@
	    // / / // /// ///// //////// /////////////
	    BlendedStore (v, mask, f64, d);
	    return;
	}
	aktive_uint k;
	if (n >= N4) {
	    // 4-unrolled lane-sized blocks
	    for (k = 0; k < n - N4; k += N4) {
		auto v0 = LoadU (f64, s + k);
		auto v1 = LoadU (f64, s + k + N);
		auto v2 = LoadU (f64, s + k + N2);
		auto v3 = LoadU (f64, s + k + N3);
		// / / // /// ///// //////// /////////////
	#define v v0
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v1
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v2
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v3
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
		StoreU (v0, f64, d + k);
		StoreU (v1, f64, d + k + N);
		StoreU (v2, f64, d + k + N2);
		StoreU (v3, f64, d + k + N3);
	    }
	}
	if (n >= N2) {
	    // 2-unrolled lane-sized blocks
	    for (k = 0; k < n - N2; k += N2) {
		auto v0 = LoadU (f64, s + k);
		auto v1 = LoadU (f64, s + k + N);
		// / / // /// ///// //////// /////////////
	#define v v0
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v1
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
		StoreU (v0, f64, d + k);
		StoreU (v1, f64, d + k + N);
	    }
	}
	// lane-sized blocks
	aktive_uint border = n - N;
	for (k = 0; k < n; k += N) {
	    aktive_uint at = HWY_MIN (k, border);
	    auto v = LoadU (f64, s + at);
	    // / / // /// ///// //////// /////////////
	    @opcode@
	    // / / // /// ///// //////// /////////////
	    StoreU (v, f64, d + at);
	}

	TRACE_RETURN_VOID;
    }
}
set u4_unary0_hexport {
    HWY_EXPORT(aktive_highway4_unary_@name@);

    void
    aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway4_unary_@name@)(d, s, n);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set u4_unary1_hdecl {void aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n, double a);}
set u4_unary1_hdef  {
    HWY_ATTR void
    aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n, double as) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);

	const int32_t N  = Lanes(f64);
	const int32_t N2 = N + N;
	const int32_t N3 = N2 + N;
	const int32_t N4 = N2 + N2;
	const auto    a  = Set(f64, as);
	@decls@
	// not enough for a full block - perform a masked partial op
	if (n < N) {
	    auto mask = FirstN(f64, n);
	    auto v    = MaskedLoad(mask, f64, s);
	    // / / // /// ///// //////// /////////////
	    @opcode@
	    // / / // /// ///// //////// /////////////
	    BlendedStore (v, mask, f64, d);
	    return;
	}
	aktive_uint k;
	if (n >= N4) {
	    // 4-unrolled lane-sized blocks
	    for (k = 0; k < n - N4; k += N4) {
		auto v0 = LoadU (f64, s + k);
		auto v1 = LoadU (f64, s + k + N);
		auto v2 = LoadU (f64, s + k + N2);
		auto v3 = LoadU (f64, s + k + N3);
		// / / // /// ///// //////// /////////////
	#define v v0
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v1
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v2
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v3
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
		StoreU (v0, f64, d + k);
		StoreU (v1, f64, d + k + N);
		StoreU (v2, f64, d + k + N2);
		StoreU (v3, f64, d + k + N3);
	    }
	}
	if (n >= N2) {
	    // 2-unrolled lane-sized blocks
	    for (k = 0; k < n - N2; k += N2) {
		auto v0 = LoadU (f64, s + k);
		auto v1 = LoadU (f64, s + k + N);
		// / / // /// ///// //////// /////////////
	#define v v0
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v1
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
		StoreU (v0, f64, d + k);
		StoreU (v1, f64, d + k + N);
	    }
	}
	// lane-sized blocks
	aktive_uint border = n - N;
	for (k = 0; k < n; k += N) {
	    aktive_uint at = HWY_MIN (k, border);
	    auto v = LoadU (f64, s + at);
	    // / / // /// ///// //////// /////////////
	    @opcode@
	    // / / // /// ///// //////// /////////////
	    StoreU (v, f64, d + at);
	}

	TRACE_RETURN_VOID;
    }
}
set u4_unary1_hexport {
    HWY_EXPORT(aktive_highway4_unary_@name@);

    void
    aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n, double a) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway4_unary_@name@)(d, s, n, a);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set u4_unary2_hdecl {void aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b);}
set u4_unary2_hdef  {
    HWY_ATTR void
    aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n, double as, double bs) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);

	const int32_t N  = Lanes(f64);
	const int32_t N2 = N + N;
	const int32_t N3 = N2 + N;
	const int32_t N4 = N2 + N2;
	const auto    a  = Set(f64, as);
	const auto    b  = Set(f64, bs);
	@decls@
	// not enough for a full block - perform a masked partial op
	if (n < N) {
	    auto mask = FirstN(f64, n);
	    auto v    = MaskedLoad(mask, f64, s);
	    // / / // /// ///// //////// /////////////
	    @opcode@
	    // / / // /// ///// //////// /////////////
	    BlendedStore (v, mask, f64, d);
	    return;
	}
	aktive_uint k;
	if (n >= N4) {
	    // 4-unrolled lane-sized blocks
	    for (k = 0; k < n - N4; k += N4) {
		auto v0 = LoadU (f64, s + k);
		auto v1 = LoadU (f64, s + k + N);
		auto v2 = LoadU (f64, s + k + N2);
		auto v3 = LoadU (f64, s + k + N3);
		// / / // /// ///// //////// /////////////
	#define v v0
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v1
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v2
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v3
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
		StoreU (v0, f64, d + k);
		StoreU (v1, f64, d + k + N);
		StoreU (v2, f64, d + k + N2);
		StoreU (v3, f64, d + k + N3);
	    }
	}
	if (n >= N2) {
	    // 2-unrolled lane-sized blocks
	    for (k = 0; k < n - N2; k += N2) {
		auto v0 = LoadU (f64, s + k);
		auto v1 = LoadU (f64, s + k + N);
		// / / // /// ///// //////// /////////////
	#define v v0
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
	#define v v1
		@opcode@
	#undef  v
		// / / // /// ///// //////// /////////////
		StoreU (v0, f64, d + k);
		StoreU (v1, f64, d + k + N);
	    }
	}
	// lane-sized blocks
	aktive_uint border = n - N;
	for (k = 0; k < n; k += N) {
	    aktive_uint at = HWY_MIN (k, border);
	    auto v = LoadU (f64, s + at);
	    // / / // /// ///// //////// /////////////
	    @opcode@
	    // / / // /// ///// //////// /////////////
	    StoreU (v, f64, d + at);
	}

	TRACE_RETURN_VOID;
    }
}
set u4_unary2_hexport {
    HWY_EXPORT(aktive_highway4_unary_@name@);

    void
    aktive_highway4_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway4_unary_@name@)(d, s, n, a, b);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set u4_binary_hdecl {void aktive_highway4_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n);}
set u4_binary_hdef  {
    HWY_ATTR void
    aktive_highway4_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);

	const int32_t N  = Lanes(f64);
	const int32_t N2 = N + N;
	const int32_t N3 = N2 + N;
	const int32_t N4 = N2 + N2;
	@decls@
	// not enough for a full block - perform a masked partial op
	if (n < N) {
	    auto mask = FirstN(f64, n);
	    auto a    = MaskedLoad(mask, f64, sa);
	    auto b    = MaskedLoad(mask, f64, sb);
	    // / / // /// ///// //////// /////////////
	    auto @opcode@
	    // / / // /// ///// //////// /////////////
	    BlendedStore (v, mask, f64, d);
	    return;
	}
	aktive_uint k;
	if (n >= N4) {
	    // 4-unrolled lane-sized blocks
	    for (k = 0; k < n - N4; k += N4) {
		auto a0 = LoadU (f64, sa + k);
		auto b0 = LoadU (f64, sb + k);
		auto a1 = LoadU (f64, sa + k + N);
		auto b1 = LoadU (f64, sb + k + N);
		auto a2 = LoadU (f64, sa + k + N2);
		auto b2 = LoadU (f64, sb + k + N2);
		auto a3 = LoadU (f64, sa + k + N3);
		auto b3 = LoadU (f64, sb + k + N3);
		// / / // /// ///// //////// /////////////
		#define v v0
		#define a a0
		#define b b0
		auto @opcode@
		#undef  v
		#undef  a
		#undef  b
		// / / // /// ///// //////// /////////////
		#define v v1
		#define a a1
		#define b b1
		auto @opcode@
		#undef  v
		#undef  a
		#undef  b
		// / / // /// ///// //////// /////////////
		#define v v2
		#define a a2
		#define b b2
		auto @opcode@
		#undef  v
		#undef  a
		#undef  b
		// / / // /// ///// //////// /////////////
		#define v v3
		#define a a3
		#define b b3
		auto @opcode@
		#undef  v
		#undef  a
		#undef  b
		// / / // /// ///// //////// /////////////
		StoreU (v0, f64, d + k);
		StoreU (v1, f64, d + k + N);
		StoreU (v2, f64, d + k + N2);
		StoreU (v3, f64, d + k + N3);
	    }
	}
	if (n >= N2) {
	    // 2-unrolled lane-sized blocks
	    for (k = 0; k < n - N2; k += N2) {
		auto a0 = LoadU (f64, sa + k);
		auto b0 = LoadU (f64, sb + k);
		auto a1 = LoadU (f64, sa + k + N);
		auto b1 = LoadU (f64, sb + k + N);
		// / / // /// ///// //////// /////////////
		#define v v0
		#define a a0
		#define b b0
		auto @opcode@
		#undef  v
		#undef  a
		#undef  b
		// / / // /// ///// //////// /////////////
		#define v v1
		#define a a1
		#define b b1
		auto @opcode@
		#undef  v
		#undef  a
		#undef  b
		// / / // /// ///// //////// /////////////
		StoreU (v0, f64, d + k);
		StoreU (v1, f64, d + k + N);
	    }
	}
	// lane-sized blocks
	aktive_uint border = n - N;
	for (k = 0; k < n; k += N) {
	    aktive_uint at = HWY_MIN (k, border);
	    auto a = LoadU (f64, sa + at);
	    auto b = LoadU (f64, sb + at);
	    // / / // /// ///// //////// /////////////
	    auto @opcode@
	    // / / // /// ///// //////// /////////////
	    StoreU (v, f64, d + at);
	}

	TRACE_RETURN_VOID;
    }
}
set u4_binary_hexport {
    HWY_EXPORT(aktive_highway4_binary_@name@);

    extern void
    aktive_highway4_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway4_binary_@name@)(d, sa, sb, n);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

# # ## ### ##### ######## #############

return
