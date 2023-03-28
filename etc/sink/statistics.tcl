## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- Image statistics
##
## NOTE: In contrast to the row, column, and band statistics, which are transformers, the
##       image statistics are sinks. Because they return a scalar double value, instead of
##       an 1x1x1 image.

operator {dexpr attr} {
    op::image::max         maximum              {}
    op::image::mean        {arithmetic mean}    {}
    op::image::min         minimum              {}
    op::image::stddev      {standard deviation} {}
    op::image::sum         sum                  {}
    op::image::sumsquared  sum                  squared
    op::image::variance    variance             {}
} {
    section sink statistics

    def kind [lindex [split $__op :] 2]
    def fun  [lindex [split $__op :] 4]

    # As sinks cannot be stacked, simplification is not applicable.

    note Returns a single value, the $dexpr of the {*}$attr values \
	(across all rows, columns, and bands)

    input

    return double {
	TRACE ("image @@fun@@ reduction starting", 0);
	double result;

	TRACE ("create and execute batch", 0);
	result = aktive_image_@@fun@@ (src, 0 /* client data, ignored */);
	result;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
