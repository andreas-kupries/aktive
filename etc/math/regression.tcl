## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Least squares regressions of various orders
## -- Fitting completely non-image functionality into the framework

## TODO: accept 2-band image as the set of x- and y-coordinates.
##       band 0 -- x-coordinates
##       band 1 -- y-coordinates

operator math::least-squares-regression::points {
    section math

    esupport {
	set points {{0 3} {1 4} {2 5} {3 6} {4 4} {5 2} {6 0} {7 5} {8 10} {9 15}}
    }
    example { order 1 points $points | -text }
    example { order 2 points $points | -text }
    example { order 3 points $points | -text }

    # TODO - plot points, with approximation laid over it

    note Perform a least squares regression of the given order \
	on the specified 2d-points

    note Returns the coefficients of the best-fitting polynomial \
	of the given order, or less.

    note The cofficients are listed from lowest to highest order. \
	In other words, the first coefficient is the constant, \
	followed by the values for `x`, `x^2`, etc. The coefficients \
	will not contain trailing zeroes.

    str order		Regression order. Does accept positive \
	integers > 0, and a few keywords for specific orders. \
	These are `linear`, `quadratic`, and `cubic`.

    double() points		Series of 2d-points

    body {
	# split points into series, then feed into the core method
	set xvalues [lmap p $points { lindex $p 0 }]
	set yvalues [lmap p $points { lindex $p 1 }]

	series order $order xs $xvalues ys $yvalues
    }
}

operator math::least-squares-regression::series {
    section math

    esupport {
	set xs {0 1 2 3 4 5 6 7  8  9}
	set ys {3 4 5 6 4 2 0 5 10 15}
    }
    example { order 1 xs $xs ys $ys | -text }
    example { order 2 xs $xs ys $ys | -text }
    example { order 3 xs $xs ys $ys | -text }

    # TODO - plot series, with approximation laid over it

    note Perform a least squares regression of the given order \
	on the specified x- and y-series. The two series have \
	to have the same length.

    note Returns the coefficients of the best-fitting polynomial \
	of the given order, or less.

    note The cofficients are listed from lowest to highest order. \
	In other words, the first coefficient is the constant, \
	followed by the values for `x`, `x^2`, etc. The coefficients \
	will not contain trailing zeroes.

    str order		Regression order. Does accept positive \
	integers > 0, and a few keywords for specific orders. \
	These are `linear`, `quadratic`, and `cubic`.

    double() xs		Series of x-coordinates
    double() ys		Series of y-coordinates

    body {
	set omap { linear 1 quadratic 2 cubic 3 }
	if {[dict exists $omap $order]} { set order [dict get $omap $order] }
	if {![string is int -strict $order] || ($order <= 0)} {
	    aktive error \
		"bad regression order `$order`, expected int > 0, or one of linear, quadratic, or cubic"
	}
	set xn [llength $xs]
	set yn [llength $ys]
	if {$xn != $yn} {
	    aktive error "expected series of identical length, xn($xn) != yn($yn)"
	}
	# move arguments inot the image domain
	set yv [aktive image from matrix width 1 height $yn values {*}$ys]
	incr order
	set xm [aktive image from matrix width $order height $xn \
		    values {*}[concat {*}[lmap x $xs {
			set row 1 ; set xx 1
			for {set n 1} {$n < $order} {incr n} {
			    set xx [expr {$xx * $x}] ; lappend row $xx }
			set row
		    }]]]
	# compute least squares regression
	# 	xt           = transpose(x)
	# 	coefficients = inverse(xt * x) * (xt * y)
	set xt    [aktive op transpose $xm]
	set xtx   [aktive op math matrix multiply $xt $xm]
	set xtxi  [aktive op math matrix invert $xtx]
	set xty   [aktive op math matrix multiply $xt $yv]
	set coeff [aktive op math matrix multiply $xtxi $xty]
	# move result out of image domain
	set coeff [aktive query values $coeff]
	# strip trailing zeros, possibly reducing order
	while {[lindex $coeff end] == 0} { set coeff [lreplace $coeff end end] }
	# if everything was stripped normalize to the 0 polynomial
	if {![llength $coeff]} { lappend coeff 0 }
	return $coeff
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
