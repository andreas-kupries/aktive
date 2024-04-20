## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- Image statistics
##
## NOTE: In contrast to the row, column, and band statistics, which are transformers, the
##       image statistics are sinks. Because they return a scalar double value, instead of
##       an 1x1x1 image.
##
## TODO: Look into computing all the statistical values in a single run.

operator {dexpr attr} {
    op::image::max         maximum              {}
    op::image::mean        {arithmetic mean}    {}
    op::image::min         minimum              {}
    op::image::stddev      {standard deviation} {}
    op::image::sum         sum                  {}
    op::image::sumsquared  sum                  squared
    op::image::variance    variance             {}
} {
    op -> _ _ fun
    section sink statistics

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

operator op::image::min-max {
    section sink statistics
    input

    note Returns a 2-element list containing the min and max of the image, in this order.
    note The results can be modified by setting lower and upper percentiles.

    double? 1 upper	Upper percentile to apply to max. Default is 100%
    double? 0 lower	Lower percentile to apply to min. Default is 0%

    # Note: Look into computing these in C, together.

    body {
	# base min/max information
	set min   [min $src]
	set max   [max $src]

	set delta [expr {$max - $min}] ;# span of values

	# shift min/max via the percentiles
	set min [expr {$min + $lower*$delta}]
	set max [expr {$min + $upper*$delta}]

	return [list $min $max]
    }
}

operator op::image::mean-stddev {
    section sink statistics
    input

    note Returns a 2-element list containing lower and upper bounds for the \
	image values, based on the image's mean and a multiple of its \
	standard deviation.

    double? 1.2 sigma   Interval around the mean to return.

    # Note: Look into computing these in C, together.

    body {
	set m   [aktive op image mean   $src]
	set s   [aktive op image stddev $src]
	set min [expr {$m - $s * $sigma}]
	set max [expr {$m + $s * $sigma}]
	return [list $min $max]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
