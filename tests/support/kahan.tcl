# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2025 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#
##
# Commands for use in tests. Do not create when in a non-testing environment
##

critcl::msg "\t[dsl::reader::cyan "Testing Support; Expose core kahan functionality"]"

critcl::include kahan.h

# expose compensated summation
critcl::cproc ::aktive::kahan {double args} double {
    aktive_uint k;
    kahan acc;
    aktive_kahan_init (acc);
    for (k=0; k < args.c; k++) { aktive_kahan_add (acc, args.v[k]); }
    return aktive_kahan_final (acc);
}

# expose a plain uncompensated summation for contrast
critcl::cproc ::aktive::nonkahan {double args} double {
    aktive_uint k;
    double acc = 0;
    for (k=0; k < args.c; k++) { acc += args.v[k]; }
    return acc;
}
