# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Templates for 4-unrolled implementations

set u2_unary0_vdecl {extern void aktive_vector2_unary_@name@ (double* d, double* s, aktive_uint n);}
set u2_unary0_vdef {
    void aktive_vector2_unary_@name@ (double* d, double* s, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);
	TRACE_RUN (double* dhead = d);

	// 2-unroll
 	for (; n > 1; n -= 2, d += 2, s += 2) {
	    double v0 = s[0];
	    double v1 = s[1];
#define v v0
	    @opcode@
#undef  v
#define v v1
	    @opcode@
#undef  v
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s);
	    d[0] = v0;
	    d[1] = v1;
	}
	// remainder
 	for (; n > 0; n--, d++, s++) {
	    double v = *s;
	    @opcode@
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s);
	    *d = v;
	}

	TRACE_RETURN_VOID;
    }
}

set u2_unary1_vdecl {extern void aktive_vector2_unary_@name@ (double* d, double* s, aktive_uint n, double a);}
set u2_unary1_vdef  {
    void aktive_vector2_unary_@name@ (double* d, double* s, aktive_uint n, double a) {

	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);
	TRACE_RUN (double* dhead = d);

	// 2-unroll
	for (; n > 1; n -= 2, d += 2, s += 2) {
	    double v0 = s[0];
	    double v1 = s[1];
#define v v0
	    @opcode@
#undef  v
#define v v1
	    @opcode@
#undef  v
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s, a);
	    d[0] = v0;
	    d[1] = v1;
	}
	// remainder
	for (; n > 0; n--, d++, s++) {
	    double v = *s;
	    @opcode@
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s, a);
	    *d = v;
	}

	TRACE_RETURN_VOID;
    }
}

set u2_unary2_vdecl {extern void aktive_vector2_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b);}
set u2_unary2_vdef  {
    void aktive_vector2_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);
	TRACE_RUN (double* dhead = d);

	// 2-unroll
	for (; n > 1; n -= 2, d += 2, s += 2) {
	    double v0 = s[0];
	    double v1 = s[1];
#define v v0
	    @opcode@
#undef  v
#define v v1
	    @opcode@
#undef  v
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s, a, b);
	    d[0] = v0;
	    d[1] = v1;
	}
	// remainder
	for (; n > 0; n--, d++, s++) {
	    double v = *s;
	    @opcode@
	    TRACE("d\[%u] = %f = @name@ (%f)", v, d-dhead, *s, a, b);
	    *d = v;
	}

	TRACE_RETURN_VOID;
    }
}

set u2_binary_vdecl {extern void aktive_vector2_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n);}
set u2_binary_vdef  {
    void aktive_vector2_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);
	TRACE_RUN (double* dhead = d);

	// 2-unroll
	for (; n > 1; n -= 2, d += 2, sa += 2, sb += 2) {
	    double v0, v1;
	    double a0 = sa[0]; double a1 = sa[1];
	    double b0 = sb[0]; double b1 = sb[1];
#define v v0
#define a a0
#define b b0
	    @opcode@
#undef  v
#undef  a
#undef  b
#define v v1
#define a a1
#define b b1
	    @opcode@
#undef  v
#undef  a
#undef  b
	    TRACE("d\[%u] %f = @name@ (%f, %f)", v, d-dhead, a, b);
	    d[0] = v0;
	    d[1] = v1;
	}
	// remainder
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

return
