## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers - Unary math, with up to two parameters

# # ## ### ##### ######## ############# #####################
## Unary without parameters

## cfunction	C function to use in the operator
## mathfunc	Equivalent Tcl mathfunc to use when short-circuiting at construction
##		The value `<<` signals identity with `function`.
##              The value `-` signals that it does not exist. Prevents short-circuiting
## dexpr	Documentation expression. If undefined use operator name tail.
##              `I` refers to source image. If not present extend to function notation, i.e. `(I)`.
## class	General class of behaviour, with attached simplification rules

operator {                     cfunction             mathfunc     dexpr classes} {
    op::math1::abs             fabs                  abs          {}    idempotent
    op::math1::acos            acos                  <<           {}    {}
    op::math1::acosh           acosh                 <<           {}    {}
    op::math1::asin            asin                  <<           {}    fixpoint0
    op::math1::asinh           asinh                 <<           {}    {}
    op::math1::atan            atan                  <<           {}    fixpoint0
    op::math1::atanh           atanh                 <<           {}    {}
    op::math1::cbrt            cbrt                  <<           {}    fixpoint0
    op::math1::ceil            ceil                  <<           {}    idempotent
    op::math1::round           round                 <<           {}    idempotent
    op::math1::clamp           aktive_clamp          <<           {}    idempotent
    op::math1::cos             cos                   <<           {}    {}
    op::math1::cosh            cosh                  <<           {}    {}
    op::math1::exp             exp                   <<           {}    {}
    op::math1::exp10           aktive_exp10          exp10        {}    {}
    op::math1::exp2            exp2                  <<           {}    {}
    op::math1::floor           floor                 <<           {}    idempotent
    op::math1::gamma::compress aktive_gamma_compress -            {}    {}
    op::math1::gamma::expand   aktive_gamma_expand   -            {}    {}
    op::math1::invert          aktive_invert         <<           "1-I" inverting
    op::math1::log             log                   <<           {}    {}
    op::math1::log10           log10                 <<           {}    {}
    op::math1::log2            log2                  <<           {}    {}
    op::math1::neg             aktive_neg            <<           "-I"  {inverting  fixpoint0}
    op::math1::reciproc        aktive_reciprocal     <<           "1/I" {inverting  fixpoint1}
    op::math1::sign            aktive_sign           sign         {}    {idempotent fixpoint0}
    op::math1::sign*           aktive_signb          signb        {}    idempotent
    op::math1::sin             sin                   <<           {}    fixpoint0
    op::math1::sinh            sinh                  <<           {}    fixpoint0
    op::math1::square          aktive_square         <<           "I**2" {}
    op::math1::sqrt            sqrt                  <<           {}    fixpoint0
    op::math1::tan             tan                   <<           {}    fixpoint0
    op::math1::tanh            tanh                  <<           {}    fixpoint0
    op::math1::wrap            aktive_wrap           <<           {}    idempotent
    op::math1::not             aktive_not            <<           "!I"  {}
} {
    if {$dexpr eq {}} { set dexpr [namespace tail $__op] }
    if {![string match *I* $dexpr]} { append dexpr (I) }

    note Returns image with the unary function `${dexpr}` applied to all pixels of the input.

    note The resulting image has the same geometry as the input.

    if {$__op in {
	op::math1::not
    }} {
	section transform math unary logical
	note As a logical operation the input image is implicitly trivially \
	    thresholded at 0.5. Values <= 0.5 are seen as false, else as true.
    } else {
	section transform math unary
    }

    input

    # Simplifications: class and function rules, if any, then general const-folding, if supported.

    foreach class $classes { import? ../simpler/$class.rules }
    import? ../simpler/$cfunction.rules

    if {$mathfunc eq "<<"} { set mathfunc $cfunction}
    if {$mathfunc ne "-"}  { simplify for   constant $mathfunc }

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary0 (block, dst, @@cfunction@@,
			    aktive_region_fetch_area (srcs->v[0], request));
    }
}

##
# # ## ### ##### ######## ############# #####################
## Unary with one parameter

## function	C function to use in the operator
## mathfunc	Equivalent Tcl mathfunc to use when short-circuiting at construction
##		The value `<<` signals identity with `function`.
##              The value `-` signals that it does not exist. Prevents short-circuiting
## dexpr	Display expression. If not set operator tail name is used
## flip         Non-commutative function, alternate order
## pname        Name of the function/operator parameter
## pdescription Parameter description

operator {                    function      mathfunc flip dexpr      pname     pdescription} {
    op::math1::shift          aktive_shift  <<       0    "I+@"      offset    {Add scalar offset}
    op::math1::neg-shift      aktive_nshift <<        1   "@-I"      offset    {Subtract from scalar offset}
    op::math1::scale          aktive_scale  <<       0    "I*@"      factor    {Multiply by scalar factor}
    op::math1::reciproc-scale aktive_rscale <<        1   "@/I"      factor    {Divide from scalar factor}
    op::math1::mod            fmod          <<       0    "I % @"    modulus   {Remainder by scalar modulus}
    op::math1::modb           aktive_fmod   <<        1   "@ % I"    numerator {Remainder by scalar numerator}
    op::math1::pow            pow           <<       0    {}         exponent  {Power by scalar exponent}
    op::math1::expx           aktive_pow    <<        1   pow(@,I)   base      {Power by scalar base}
    op::math1::hypot          hypot         <<       0    {}         y         {Hypot to scalar y}
    op::math1::max            fmax          max      0    {}         min       {Limit to greater or equal a scalar min}
    op::math1::min            fmin          min      0    {}         max       {Limit to less    or equal a scalar max}
    op::math1::atan2          atan2         <<       0    atan2      x         {Atan by scalar x}
    op::math1::atan2b         aktive_atan   <<        1   atan2(@,I) y         {Atan by scalar y}
    op::math1::eq             aktive_eq     <<       0    "I == @"   threshold {Indicate pixels equal to the scalar threshold}
    op::math1::ge             aktive_ge     <<       0    "I >= @"   threshold {Indicate pixels greater or equal to the scalar threshold}
    op::math1::gt             aktive_gt     <<       0    "I > @"    threshold {Indicate pixels greater than the scalar threshold}
    op::math1::le             aktive_le     <<       0    "I <= @"   threshold {Indicate pixels less or equal to the scalar threshold}
    op::math1::lt             aktive_lt     <<       0    "I < @"    threshold {Indicate pixels less than the scalar threshold}
    op::math1::ne             aktive_ne     <<       0    "I != @"   threshold {Indicate pixels different from the scalar threshold}
    op::math1::solarize       aktive_sol    <<       0    solarize   threshold {Solarize pixels per the threshold}
} {
    section transform math unary

    # For non-commutative functions we have a separate operation reversing the argument order internally
    # See modb, atan2b, expx

    # Note: `atan2`, `atan2b` - No simplification rules - While it is possible the
    # relevant parameter and image values are extremes (+/- inf), and in some cases
    # distinguish +/-0. Tcl does not, at script level. Let it be.

    # `mod`, `modb` - No rules - The only special parameter is `1`, for `fmod (I,1) = frac (I)`,
    # except there is no `frac` in C. Regarding chaining - No trivial rule on how to
    # combine the moduli a and b ... The chain is __not commutative__ in a and b, thus the
    # combiner cannot be either.

    # Compute the varying elements of the description

    if {$dexpr eq {}} { set dexpr [namespace tail $__op] }
    if {![string match *@* $dexpr]} { append dexpr (I,@) }
    set dexpr [string map [list @ $pname] $dexpr]

    note Returns image with the parameterized unary function `${dexpr}` applied to all \
	pixels of the input.

    if {$flip} {
	note The image is the first argument of the command, even if not of the function
    } else {
	note The image is the first argument of the command
    }
    note The resulting image has the same geometry as the input.

    # Arguments

    input
    double $pname  {*}$pdescription

    # Simplification rules. Special rules first for specific impae/parameter combinations,
    # followed by general const folding.

    if {$mathfunc eq "<<"} { set mathfunc $function }

    import?  ../simpler/${mathfunc}.rules
    simplify for   constant $mathfunc $pname

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary1 (block, dst, @@function@@, param->@@pname@@, aktive_region_fetch_area (srcs->v[0], request));
    }
}

##
# # ## ### ##### ######## ############# #####################
## Unary with two parameters

operator {function lowkind highkind mode} {
    op::math1::inside-oo   aktive_inside_oo  open   open   inside
    op::math1::inside-oc   aktive_inside_oc  open   closed inside
    op::math1::inside-co   aktive_inside_co  closed open   inside
    op::math1::inside-cc   aktive_inside_cc  closed closed inside

    op::math1::outside-oo  aktive_outside_oo open   open   outside
    op::math1::outside-oc  aktive_outside_oc open   closed outside
    op::math1::outside-co  aktive_outside_co closed open   outside
    op::math1::outside-cc  aktive_outside_cc closed closed outside
} {
    section transform math unary

    note Returns image with the double sided thresholding against the \
	$lowkind/$highkind interval given by the two boundaries applied \
	to all pixels of the input.

    note Values $mode the interval are indicated as `1` in the result.
    note The resulting image has the same geometry as the input.

    input

    double low   Lower $lowkind boundary
    double high  Upper $highkind boundary

    simplify for   constant $function low high

    # TODO *side-* Chain reduction is possible -- new operator takes in the information
    # TODO from the input, and stacks on the input/child, ignoring the input.

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary2 (block, dst, @@function@@, param->low, param->high,
			    aktive_region_fetch_area (srcs->v[0], request));
    }
}

operator op::math1::linear {
    section transform math unary

    note Returns image with the linear transform `(I*scale)+gain` applied to it.

    double scale Input scaling factor
    double gain  Post-scaling offset

    input

    body {
	aktive op math1 shift [aktive op math1 scale $src factor $scale] offset $gain
    }
}

operator op::math1::fit::stretch {
    section transform math unary

    note Returns image fitted into the given range. Default range is 0..1.
    note Each band of the image is fitted separately.

    note The (image statistics) method `<by>` is used to determine the \
	range of the image band values to fit into the destination range. \
	The method is expected to return a list of two values, \
	the min and the max to fit, in this order.

    note __Beware__, this means that construction incurs a computation \
	cost on the input.

    note This cost somewhat offset by providing these `min` and `max` values \
	to the caller. It is done by storing the values in the sub-dictionary \
	`stretch` of the meta data dictionary. `stretch` also contains the \
	calculated `scale` and `gain` parameters of the linear mapping. This \
	enables the mapping of fitted values back to the original domain.

    double? 0 min	Destination minimum value to fit the image into
    double? 1 max	Destination maximum value to fit the image into
    str       by	Method computing the input min and max values to fit into the destination.
    bool?   1 clamp	Force clamping into result range.

    input

    body {
	set byparams [lassign $by by]
	aktive op montage z {*}[lmap band [aktive op split z $src] {
	    lassign [{*}$by $band {*}$byparams] srclow srchigh

	    #     max = fit (srchigh) = scale*srchigh + gain
	    #     min = fit (srclow)  = scale*srclow  + gain
	    # <=> max-min             = scale*(srchigh-srclow)
	    # <=> scale               = (max-min) / (srchigh - srclow)
	    # =>  gain                = min - scale * srclow
	    # =>  gain                = max - scale * srchigh

	    # special case:
	    # - srclow == srchigh -> cannot fit to both min and max.
	    # - choose min
	    # - scale = 1, gain = min - srclow

	    if {$srchigh == $srclow} {
		set scale 1
		set gain [expr {$min - $srclow}]
	    } else {
		set scale [expr {double($max-$min)/double($srchigh-$srclow)}]
		set gain  [expr {$min - ($scale * $srclow)}]
	    }

	    set src [aktive op math1 linear $band scale $scale gain $gain]

	    if {$clamp} {
		# The max and min operations ensure that the result is indeed limited to the
		# desired range.  Because the source low/high boundaries can specify a mapping
		# where the actual min/max values are mapped to something outside the desired
		# result range.
		#
		# The caller can disable this if it is sure that the mapping will be good.
		set src [aktive op math1 max $src min $min]
		set src [aktive op math1 min $src max $max]
	    }

	    # export the stretch configuration. this supports mapping of fitted values
	    # back into the original domain
	    set src [aktive meta set $src stretch min   $srclow]
	    set src [aktive meta set $src stretch max   $srchigh]
	    set src [aktive meta set $src stretch scale $scale]
	    set src [aktive meta set $src stretch gain  $gain]

	    set src
	}]
    }
}

operator op::math1::fit::min-max {
    section transform math unary

    note Returns image fitted into the given range. Default range is 0..1.

    note Each band of the image is fitted separately.

    note The actual min and max values of the image bands are used to \
	compute the necessary fit. They may be modified by the upper and \
	lower percentiles.

    note BEWARE, this means that construction incurs a computation \
	cost on the input.

    double? 0 min	Minimum value to fit the image to
    double? 1 max	Maximum value to fit the image to

    double? 1 upper	Upper percentile to apply to input max. Default is 100%
    double? 0 lower	Lower percentile to apply to input min. Default is 0%

    input

    body {
	stretch $src min $min max $max by \
	    [list {aktive op image min-max} upper $upper lower $lower]
    }
}

operator op::math1::fit::mean-stddev {
    section transform math unary

    note Returns image fitted into the given range. Default range is 0..1.

    note Each band of the image is fitted separately.

    note The actual mean and standard deviation of the image bands are \
	used to compute the necessary fit.

    note BEWARE, this means that construction incurs a computation \
	cost on the input.

    double? 0 min	Minimum value to fit the image to.
    double? 1 max	Maximum value to fit the image to.
    double? 1.2 sigma   Interval around the input mean to fit into the min/max range.

    input

    body {
	stretch $src min $min max $max \
	    by [list {aktive op image mean-stddev} sigma $sigma]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
