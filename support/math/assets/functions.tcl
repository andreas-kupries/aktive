# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Function templates for unary and binary math functions of varying arities
#
# Placeholders
#
#  - @func@	function name
#  - @body@	function body - generated from loop elements
#

def-func unary {} {
    void @func@ (double* d, double* s, aktive_uint n)
} {
    TRACE_FUNC("((dst) %p[%u], (src) %p[%u])", d, n, s, n);
    @body@
    TRACE_RETURN_VOID;
}

def-func unary {x} {
    void @func@ (double* d, double* s, aktive_uint n, double x)
} {
    TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f)", d, n, s, n, x);
    @body@
    TRACE_RETURN_VOID;
}

def-func unary {low high} {
    void @func@ (double* d, double* s, aktive_uint n, double low, double high)
} {
    TRACE_FUNC("((dst) %p[%u], (src) %p[%u], (a) %f, (b) %f)", d, n, s, n, low, high);
    @body@
    TRACE_RETURN_VOID;
}

def-func binary {} {
    void @func@ (double* d, double* sa, double* sb, aktive_uint n)
} {
    TRACE_FUNC("((dst) %p[%u], (srca) %p[%u], (srcb) %p[%u])", d, n, sa, n, sb, n);
    @body@
    TRACE_RETURN_VOID;
}

# # ## ### ##### ######## #############
return
