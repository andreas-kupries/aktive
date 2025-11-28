# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Templates for 1-unrolled implementations

set u1_unary0_vdecl {extern void aktive_vector1_unary_@name@ (double* d, double* s, aktive_uint n);}
set u1_unary0_vdef {
    void aktive_vector1_unary_@name@ (double* d, double* s, aktive_uint n) {
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

set u1_unary1_vdecl {extern void aktive_vector1_unary_@name@ (double* d, double* s, aktive_uint n, double a);}
set u1_unary1_vdef  {
    void aktive_vector1_unary_@name@ (double* d, double* s, aktive_uint n, double a) {

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

set u1_unary2_vdecl {extern void aktive_vector1_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b);}
set u1_unary2_vdef  {
    void aktive_vector1_unary_@name@ (double* d, double* s, aktive_uint n, double a, double b) {
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

set u1_binary_vdecl {extern void aktive_vector1_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n);}
set u1_binary_vdef  {
    void aktive_vector1_binary_@name@ (double* d, double* sa, double* sb, aktive_uint n) {
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

return
