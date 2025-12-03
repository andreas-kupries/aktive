# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Code fragments for the vector functions

proc dedent {s} { string map [list "    " "" "\t" "    "] $s }

# Function declarations

set scalar(unary0,decl) {extern void @func@ (double* d, double* s, aktive_uint n);}
set scalar(unary1,decl) {extern void @func@ (double* d, double* s, aktive_uint n, double a);}
set scalar(unary2,decl) {extern void @func@ (double* d, double* s, aktive_uint n, double a, double b);}
set scalar(binary,decl) {extern void @func@ (double* d, double* sa, double* sb, aktive_uint n);}

# Function implementation, base scaffold

set scalar(unary0,impl) [dedent {
    void @func@ (double* d, double* s, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);
	@body@
	TRACE_RETURN_VOID;
    }
}]

set scalar(unary1,impl) [dedent {
    void @func@ (double* d, double* s, aktive_uint n, double a) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, a);
	@body@
	TRACE_RETURN_VOID;
    }
}]

set scalar(unary2,impl) [dedent {
    void @func@ (double* d, double* s, aktive_uint n, double a, double b) {
	TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, a, b);
	@body@
	TRACE_RETURN_VOID;
    }
}]

set scalar(binary,impl) [dedent {
    void @func@ (double* d, double* sa, double* sb, aktive_uint n) {
	TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);
	@body@
	TRACE_RETURN_VOID;
    }
}]

# Loops bodies, 1/2/4 unrolled, unary and binary

set scalar(unary,1) {
    // base loop, not unrolled
    for (; n > 0; n--, d++, s++) {
	double v = *s;
	@opcode1@
	*d = v;
    }
}

set scalar(unary,2) {
    // unrolled 2 times
    for (; n > 1; n -= 2, d += 2, s += 2) {
	double v0 = s[0];
	double v1 = s[1];
	@opcode2@
	d[0] = v0;
	d[1] = v1;
    }
}

set scalar(unary,4) {
    // unrolled 4 times
    for (; n > 3; n -= 4, d += 4, s += 4) {
	double v0 = s[0];
	double v1 = s[1];
	double v2 = s[2];
	double v3 = s[3];
	@opcode4@
	d[0] = v0;
	d[1] = v1;
	d[2] = v2;
	d[3] = v3;
    }
}

set scalar(binary,1) {
    // base loop, not unrolled
    for (; n > 0; n--, d++, sa++, sb++) {
	double a = *sa, b = *sb, v;
	@opcode1@
	*d = v;
    }
}

set scalar(binary,2) {
    // unrolled 2 times
    for (; n > 1; n -= 2, d += 2, sa += 2, sb += 2) {
	double a0 = sa[0], b0 = sb[0], v0;
	double a1 = sa[1], b1 = sb[1], v1;
	@opcode2@
	d[0] = v0;
	d[1] = v1;
    }
}

set scalar(binary,4) {
    // unrolled 4 times
    for (; n > 3; n -= 4, d += 4, sa += 4, sb += 4) {
	double a0 = sa[0], b0 = sb[0], v0;
	double a1 = sa[1], b1 = sb[1], v1;
	double a2 = sa[2], b2 = sb[2], v2;
	double a3 = sa[3], b3 = sb[3], v3;
	@opcode4@
	d[0] = v0;
	d[1] = v1;
	d[2] = v2;
	d[3] = v3;
    }
}

# # ## ### ##### ######## #############

return
