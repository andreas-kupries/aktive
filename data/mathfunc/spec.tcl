# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

# # ## ### ##### ######## #############
## Unary math functions, without parameters
##
## code environment
## - `v` = input value to transform, also output

set unary0 {
    acos {
	direct { v = acos (v); }
    }
    acosh {
	direct { v = acosh (v); }
    }
    asin {
	direct { v = asin (v); }
    }
    asinh {
	direct { v = asinh (v); }
    }
    atan {
	direct { v = atan (v); }
    }
    atanh {
	direct { v = atanh (v); }
    }
    cbrt {
	direct { v = cbrt (v); }
    }
    ceil {
	direct { v = ceil (v); }
    }
    clamp {
	direct { v = fmax (0, fmin (1, v)); }
    }
    cos {
	direct { v = cos (v); }
    }
    cosh {
	direct { v = cosh (v); }
    }
    exp {
	direct { v = exp (v); }
    }
    exp10 {
	direct { v = pow (10, v); }
    }
    exp2 {
	direct { v = exp2 (v); }
    }
    fabs {
	direct { v = fabs (v); }
    }
    floor {
	direct { v = floor (v); }
    }
    gamma_compress {
	direct {
	    #define GAMMA  (2.4)
	    #define OFFSET (0.055)
	    #define SCALE  (1.055)
	    #define IGAIN  (12.92)
	    #define ILIMIT (0.0031308)
	    v = (v <= ILIMIT) ? v * IGAIN : SCALE * pow (v, 1.0/GAMMA) - OFFSET;
	    #undef GAMMA
	    #undef OFFSET
	    #undef SCALE
	    #undef IGAIN
	    #undef ILIMIT
	}
    }
    gamma_expand {
	direct {
	    #define GAMMA  (2.4)
	    #define OFFSET (0.055)
	    #define SCALE  (1.055)
	    #define IGAIN  (12.92)
	    #define GLIMIT (0.04045)
	    v = (v <= GLIMIT) ? v / IGAIN : pow ((v + OFFSET) / SCALE, GAMMA);
	    #undef GAMMA
	    #undef OFFSET
	    #undef SCALE
	    #undef IGAIN
	    #undef GLIMIT
	}
    }
    invert {
	direct { v = 1 - v; }
    }
    log {
	direct { v = log (v); }
    }
    log10 {
	direct { v = log10 (v); }
    }
    log2 {
	direct { v = log2 (v); }
    }
    neg {
	direct { v = - v; }
    }
    not {
	direct { v = (v <= 0.5) ? 1 : 0; }
    }
    reciprocal {
	direct { v = 1.0 / v; }
    }
    round {
	direct { v = round (v); }
    }
    sign {
	direct { v = (v < 0) ? -1 : (v > 0) ? 1 : 0; }
    }
    signb {
	direct { v = (v < 0) ? -1 : 1; }
    }
    sin {
	direct { v = sin (v); }
    }
    sinh {
	direct { v = sinh (v); }
    }
    sqrt {
	direct { v = sqrt (v); }
    }
    square {
	direct { v = v * v; }
    }
    tan {
	direct { v = tan (v); }
    }
    tanh {
	direct { v = tanh (v); }
    }
    wrap {
	direct { v = (v > 1) ? fmod(v, 1) : (v < 0) ? (1 + fmod(v - 1, 1)) : v; }
    }
}

# # ## ### ##### ######## #############
## Unary math functions, single parameter
##
## code environment
## - `v` = input value to transform, also output
## - `a` = parameter

set unary1 {
    atan2  { direct { v = atan2 (v, a);     } }
    eq     { direct { v = (v == a) ? 1 : 0; } }
    fmax   { direct { v = fmax (v, a);      } }
    fmin   { direct { v = fmin (v, a);      } }
    fmod   { direct { v = fmod(v, a);       } }
    ge     { direct { v = (v >= a) ? 1 : 0; } }
    gt     { direct { v = (v > a) ? 1 : 0;  } }
    hypot  { direct { v = hypot (v, a);     } }
    le     { direct { v = (v <= a) ? 1 : 0; } }
    lt     { direct { v = (v <  a) ? 1 : 0; } }
    ne     { direct { v = (v != a) ? 1 : 0;   } }
    nshift { direct { v = a - v;              } }
    pow    { direct { v = pow (v, a);         } }
    ratan2 { direct { v = atan2 (a, v);       } }
    rfmod  { direct { v = fmod (a, v);        } }
    expx   { direct { v = pow (a, v);         } }
    rscale { direct { v = a / v;              } }
    scale  { direct { v = v * a;              } }
    shift  { direct { v = v + a;              } }
    sol    { direct { v = (v <= a) ? v : 1-v; } }
}

# # ## ### ##### ######## #############
## Unary math functions, two parameters
##
## code environment
## - `v` = input value to transform, also output
## - `a` = parameter 1
## - `b` = parameter 2

set unary2 {
    inside_cc  { direct { v = (a <= v) && (v <= b) ? 1 : 0; } }
    inside_co  { direct { v = (a <= v) && (v <  b) ? 1 : 0; } }
    inside_oc  { direct { v = (a <  v) && (v <= b) ? 1 : 0; } }
    inside_oo  { direct { v = (a <  v) && (v <  b) ? 1 : 0; } }
    outside_cc { direct { v = (a <= v) && (v <= b) ? 0 : 1; } }
    outside_co { direct { v = (a <= v) && (v <  b) ? 0 : 1; } }
    outside_oc { direct { v = (a <  v) && (v <= b) ? 0 : 1; } }
    outside_oo { direct { v = (a <  v) && (v <  b) ? 0 : 1; } }
}

# # ## ### ##### ######## #############
## Binary math functions
##
## code environment
## - `a` = input value 1
## - `b` = input value 2
## - `v`  = output

set binary {
    and   { direct { v = ( a >  0.5) && (b >  0.5) ? 1 : 0; } }
    or    { direct { v = ( a >  0.5) || (b >  0.5) ? 1 : 0; } }
    xor   { direct { v = ((a > 0.5) && (b <= 0.5)) || ((a <= 0.5) && (b >  0.5)) ? 1 : 0; } }
    add   { direct { v = a + b; } }
    mul   { direct { v = a * b; } }
    fmax  { direct { v = fmax (a, b); } }
    fmin  { direct { v = fmin (a, b); } }

    nand  { direct { v = ( a >  0.5) && (b >  0.5) ? 0 : 1; } }
    nor   { direct { v = ( a >  0.5) || (b >  0.5) ? 0 : 1; } }
    atan2 { direct { v = atan2 (a, b); } }
    div   { direct { v = a / b; } }
    eq    { direct { v = (a == b) ? 1 : 0; } }
    ge    { direct { v = (a >= b) ? 1 : 0; } }
    gt    { direct { v = (a >  b) ? 1 : 0; } }
    hypot { direct { v = hypot (a, b); } }
    le    { direct { v = (a <= b) ? 1 : 0; } }
    lt    { direct { v = (a <  b) ? 1 : 0; } }
    fmod  { direct { v = fmod (a, b); } }
    ne    { direct { v = (a != b) ? 1 : 0; } }
    pow   { direct { v = pow (a, b); } }
    sub   { direct { v = a - b; } }

}

# # ## ### ##### ######## #############
## Templates for the vector and highway functions. This is where the function code
## fragments declared above are used in.

# # ## ### ##### ######## #############
## vector direct

set unary0_vdecl {extern void aktive_vector_unary_@name@ (double* d, double* s, aktive_uint n);}
set unary0_vdef {
    void aktive_vector_unary_@name@ (double* d, double* s, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);
	TRACE_RUN (double* dhead = d);

	for (; n > 0; n--, d++, s++) {
	    double v = *s;
	    @opcode@
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s);
	    *d = v;
	}

	TRACE_RETURN_VOID;
    }
}

set unary1_vdecl {extern void aktive_vector_unary_@name@ (double* d, double* s, aktive_uint n, double a);}
set unary1_vdef  {
    void aktive_vector_unary_@name@ (double* d, double* s, aktive_uint n, double a) {

	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);
	TRACE_RUN (double* dhead = d);
	for (; n > 0; n--, d++, s++) {
	    double v = *s;
	    @opcode@
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s, a);
	    *d = v;
	}

	TRACE_RETURN_VOID;
    }
}

set unary2_vdecl {extern void aktive_vector_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b);}
set unary2_vdef  {
    void aktive_vector_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);
	TRACE_RUN (double* dhead = d);

	for (; n > 0; n--, d++, s++) {
	    double v = *s;
	    @opcode@
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s, a, b);
	    *d = v;
	}

	TRACE_RETURN_VOID;
    }
}

set binary_vdecl {extern void aktive_vector_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n);}
set binary_vdef  {
    void aktive_vector_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);
	TRACE_RUN (double* dhead = d);

	for (; n > 0; n--, d++, sa++, sb++) {
	    double a = *sa;
	    double b = *sb;
	    double v;
	    @opcode@
	    TRACE("d\[%u] %f = @name@ (%f, %f)", v, d-dhead, a, b);
	    *d = v;
	}

	TRACE_RETURN_VOID;
    }
}

# # ## ### ##### ######## #############
## vector highway

set unary0_hdecl {extern void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n);}
set unary0_hdef  {
    void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);

	const int32_t N = Lanes(f64);

	// not enough for a full block - perform a masked partial op
	if (n < N) {
	    auto mask = FirstN(f64, n);
	    auto v    = MaskedLoad(mask, f64, s);
	    @opcode@
	    BlendedStore (v, mask, f64, d);
	    return;
	}
	// lane-sized blocks
	aktive_uint k, border = n - N;
	for (k = 0; k < n; k += N) {
	    aktive_uint at = HWY_MIN (k, border);
	    auto v = LoadU (f64, s + at);
	    @opcode@
	    StoreU (v, f64, d + at);
	}

	TRACE_RETURN_VOID;
    }
}
set unary0_hexport {
    HWY_EXPORT(aktive_highway_unary_@name@);
    extern void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway_unary_@name@)(d, s, n);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set unary1_hdecl {extern void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a);}
set unary1_hdef  {
    void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);

	const int32_t N  = Lanes(f64);
	const auto    av = Set(f64, a);

	// not enough for a full block - perform a masked partial op
	if (n < N) {
	    auto mask = FirstN(f64, n);
	    auto v    = MaskedLoad(mask, f64, s);
	    @opcode@
	    BlendedStore (v, mask, f64, d);
	    return;
	}
	// lane-sized blocks
	aktive_uint k, border = n - N;
	for (k = 0; k < n; k += N) {
	    aktive_uint at = HWY_MIN (k, border);
	    auto v = LoadU (f64, s + at);
	    @opcode@
	    StoreU (v, f64, d + at);
	}

	TRACE_RETURN_VOID;
    }
}
set unary1_hexport {
    HWY_EXPORT(aktive_highway_unary_@name@);
    extern void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway_unary_@name@)(d, s, n, a);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set unary2_hdecl {extern void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b);}
set unary2_hdef  {
    void aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);

	const int32_t N  = Lanes(f64);
	const auto    av = Set(f64, a);
	const auto    bv = Set(f64, b);

	// not enough for a full block - perform a masked partial op
	if (n < N) {
	    auto mask = FirstN(f64, n);
	    auto v    = MaskedLoad(mask, f64, s);
	    @opcode@
	    BlendedStore (v, mask, f64, d);
	    return;
	}
	// lane-sized blocks
	aktive_uint k, border = n - N;
	for (k = 0; k < n; k += N) {
	    aktive_uint at = HWY_MIN (k, border);
	    auto v = LoadU (f64, s + at);
	    @opcode@
	    StoreU (v, f64, d + at);
	}

	TRACE_RETURN_VOID;
    }
}
set unary2_hexport {
    HWY_EXPORT(aktive_highway_unary_@name@);
    extern void
    aktive_highway_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);
	/* clang-format off */
	HWY_DYNAMIC_DISPATCH(aktive_highway_unary_@name@)(d, s, n, a, b);
	/* clang-format on */
	TRACE_RETURN_VOID;
    }
}

set binary_hdecl {extern void aktive_highway_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n);}
set binary_hdef  {
    void aktive_highway_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);

	const int32_t N = Lanes(f64);

	// not enough for a full block - perform a masked partial op
	if (n < N) {
	    auto mask = FirstN(f64, n);
	    auto a    = MaskedLoad(mask, f64, sa);
	    auto b    = MaskedLoad(mask, f64, sb);
	    @opcode@
	    BlendedStore (v, mask, f64, d);
	    return;
	}
	// lane-sized blocks
	aktive_uint k, border = n - N;
	for (k = 0; k < n; k += N) {
	    aktive_uint at = HWY_MIN (k, border);
	    auto a = LoadU (f64, sa + at);
	    auto b = LoadU (f64, sb + at);
	    @opcode@
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
