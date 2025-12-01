# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Templates for highway implementations.

set unary0_hdecl {void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n);}
set unary0_hdef  {
    HWY_ATTR void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);

	const int32_t N = Lanes(f64);
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
	// lane-sized blocks
	aktive_uint k, border = n - N;
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
set unary0_hexport {
    HWY_EXPORT(aktive_highway_unary_@name@);

    void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway_unary_@name@)(d, s, n);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set unary1_hdecl {void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a);}
set unary1_hdef  {
    HWY_ATTR void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double as) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);

	const int32_t N = Lanes(f64);
	const auto    a = Set(f64, as);
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
	// lane-sized blocks
	aktive_uint k, border = n - N;
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
set unary1_hexport {
    HWY_EXPORT(aktive_highway_unary_@name@);

    void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway_unary_@name@)(d, s, n, a);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set unary2_hdecl {void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b);}
set unary2_hdef  {
    HWY_ATTR void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double as, double bs) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);

	const int32_t N = Lanes(f64);
	const auto    a = Set(f64, as);
	const auto    b = Set(f64, bs);
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
	// lane-sized blocks
	aktive_uint k, border = n - N;
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
set unary2_hexport {
    HWY_EXPORT(aktive_highway_unary_@name@);

    void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway_unary_@name@)(d, s, n, a, b);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set binary_hdecl {void aktive_highway_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n);}
set binary_hdef  {
    HWY_ATTR void
    aktive_highway_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);

	const int32_t N = Lanes(f64);
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
	// lane-sized blocks
	aktive_uint k, border = n - N;
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
set binary_hexport {
    HWY_EXPORT(aktive_highway_binary_@name@);

    extern void
    aktive_highway_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway_binary_@name@)(d, sa, sb, n);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

# # ## ### ##### ######## #############

return
