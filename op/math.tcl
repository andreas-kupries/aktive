# -*- tcl -*-
# # ## ### ##### ######## #############
## C math support ... Policy decides later which of these are kept and placed into tcl::mathfunc

# # ## ### ##### ######## #############
## ceil, floor, round :: Ignored here. Known to exist at Tcl mathfunc, using the same C functions.

critcl::include math.h
critcl::include stdlib.h	;# rand

foreach {fun cfun} {
    acosh             -
    aktive_clamp      -
    aktive_invert     -
    aktive_neg        -
    aktive_not        -
    aktive_reciprocal -
    aktive_wrap       -
    asinh             -
    atanh             -
    cbrt              -
    exp10             aktive_exp10
    exp2              -
    gcompress         aktive_gamma_compress
    gexpand           aktive_gamma_expand
    log2              -
    sign              aktive_sign
    signb             aktive_signb
} {
    if {$cfun eq "-"} { set cfun $fun }
    critcl::cproc ::aktive::mathfunc::$fun {
	double x
    } double "return $cfun (x);"
}

foreach {fun cfun} {
    aktive_and        -
    aktive_atan       -
    aktive_eq         -
    aktive_fmod       -
    aktive_ge         -
    aktive_gt         -
    aktive_le         -
    aktive_lt         -
    aktive_nand       -
    aktive_ne         -
    aktive_nor        -
    aktive_nshift     -
    aktive_or         -
    aktive_pow        -
    aktive_rscale     -
    aktive_scale      -
    aktive_shift      -
    aktive_sol        -
    aktive_xor        -
} {
    if {$cfun eq "-"} { set cfun $fun }
    critcl::cproc ::aktive::mathfunc::$fun {
	double x double a
    } double "return $cfun (x, a);"
}

foreach {fun cfun} {
    aktive_inside_cc  -
    aktive_inside_co  -
    aktive_inside_oc  -
    aktive_inside_oo  -
    aktive_outside_cc -
    aktive_outside_co -
    aktive_outside_oc -
    aktive_outside_oo -
} {
    if {$cfun eq "-"} { set cfun $fun }
    critcl::cproc ::aktive::mathfunc::$fun {
	double x double a double b
    } double "return $cfun (x, a, b);"
}

critcl::cproc ::aktive::mathfunc::lanczos {
    int order double x
} double "return aktive_lanczos (order, x);"

# # ## ### ##### ######## #############
return
