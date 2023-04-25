## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - convolution kernels
#
## - gauss (3/5/7/9; x, y, xy; discrete)
## - emboss
## - kirsch  (x, y, md, sd)
## - laplace (5, 9, X)
## - prewitt (x, y, md, sd)
## - roberts (x, y)
## - scharr  (x, y)
## - sobel   (x, y, md, sd)
#
## References
#
## - http://www.holoborodko.com/pavel/image-processing/edge-detection/
## - https://wiki.tcl-lang.org/page/TkPhotoLab
## - https://en.wikipedia.org/wiki/Prewitt_operator
## - https://en.wikipedia.org/wiki/Roberts_cross
## - https://en.wikipedia.org/wiki/Sobel_operator
## - https://en.wikipedia.org/wiki/Scharr_operator
#
## - https://en.wikipedia.org/wiki/Scale_space_implementation#The_discrete_Gaussian_kernel

# # ## ### ##### ######## ############# #####################
## md = main diagonal
## sd = secondary diagonal

operator {w h description factor kernel} {
    image::kernel::gauss3::x   3 1 {@ian blur effect}       1/4.   { 1 2 1 }
    image::kernel::gauss3::y   1 3 {@ian blur effect}       1/4.   { 1 2 1 }
    image::kernel::gauss3::xy  3 3 {@ian blur effect}       1/16.  { 1 2 1  2 4 2  1 2 1 }
    image::kernel::gauss5::x   5 1 {@ian blur effect}       1/16.  { 1 4 6 4 1 }
    image::kernel::gauss5::y   1 5 {@ian blur effect}       1/16.  { 1 4 6 4 1 }
    image::kernel::gauss7::x   7 1 {@ian blur effect}       1/64.  { 1 6 15 20 15 6 1 }
    image::kernel::gauss7::y   1 7 {@ian blur effect}       1/64.  { 1 6 15 20 15 6 1 }
    image::kernel::gauss9::x   9 1 {@ian blur effect}       1/128. { 1 8 28 56 70 56 28 8 1 }
    image::kernel::gauss9::y   1 9 {@ian blur effect}       1/128. { 1 8 28 56 70 56 28 8 1 }

    image::kernel::kirsch::md  3 3 {@ edge detection}       {}    { -3   5  5   -3 0  5  -3 -3 -3 }
    image::kernel::kirsch::sd  3 3 {@ edge detection}       {}    {  5   5 -3    5 0 -3  -3 -3 -3 }
    image::kernel::kirsch::x   3 3 {@ edge detection}       {}    {  5  -3 -3    5 0 -3   5 -3 -3 }
    image::kernel::kirsch::y   3 3 {@ edge detection}       {}    {  5   5  5   -3 0 -3  -3 -3 -3 }

    image::kernel::prewitt::md 3 3 {@ edge detection}       {}    {  0   1  1   -1 0  1  -1 -1  0 }
    image::kernel::prewitt::sd 3 3 {@ edge detection}       {}    { -1  -1  0   -1 0  1   0  1  1 }
    image::kernel::prewitt::x  3 3 {@ edge detection}       {}    { -1   0  1   -1 0  1  -1  0  1 }
    image::kernel::prewitt::y  3 3 {@ edge detection}       {}    { -1  -1 -1    0 0  0   1  1  1 }

    image::kernel::roberts::x  3 3 {@ cross edge detection} {}    {  0  -1  0    1 0  0   0  0  0 }
    image::kernel::roberts::y  3 3 {@ cross edge detection} {}    { -1   0  0    0 1  0   0  0  0 }

    image::kernel::scharr::x   3 3 {@ edge detection}       {}    { -3   0  3  -10 0 10  -3  0  3 }
    image::kernel::scharr::y   3 3 {@ edge detection}       {}    { -3 -10 -3    0 0  0   3 10  3 }

    image::kernel::sobel::md   3 3 {@ edge detection}       {}    {  0  -1 -1    2 0 -2   1  1  0 }
    image::kernel::sobel::sd   3 3 {@ edge detection}       {}    {  1   1  0    2 0 -2   0 -1 -1 }
    image::kernel::sobel::x    3 3 {@ edge detection}       {}    {  1   0 -1    2 0 -2   1  0 -1 }
    image::kernel::sobel::y    3 3 {@ edge detection}       {}    {  1   2  1    0 0  0  -1 -2 -1 }

    image::kernel::emboss      3 3 {emboss effect}          {}    {  2   0  0    0 -1  0  0  0 -1 }

    image::kernel::laplace::4  3 3 {sharpening effect}      {}    {  0  -1  0   -1  4 -1  0 -1  0 }
    image::kernel::laplace::5  3 3 {sharpening effect}      {}    {  0  -1  0   -1  5 -1  0 -1  0 }
    image::kernel::laplace::8  3 3 {sharpening effect}      {}    { -1  -1 -1   -1  8 -1 -1 -1 -1 }
    image::kernel::laplace::9  3 3 {sharpening effect}      {}    { -1  -1 -1   -1  9 -1 -1 -1 -1 }
    image::kernel::laplace::X  3 3 {sharpening effect}      {}    {  1  -2  1   -2  4 -2  1 -2  1 }
    image::kernel::laplace::X1 3 3 {sharpening effect}      {}    {  1  -2  1   -2  5 -2  1 -2  1 }
} {
    set ref         [lindex [split $__op :] 4]
    set description [string map [list @ $ref] $description]

    if {$factor ne {}} {
	set factor [expr $factor]
	def scale "factor $factor"
    } else {
	def scale {}
    }

    section generator virtual

    note Returns convolution kernel for $description

    body {
        aktive image from matrix width @@w@@ height @@h@@ @@scale@@ values @@kernel@@
    }
}

# # ## ### ##### ######## ############# #####################

operator image::kernel::gauss::discrete {
    section generator virtual

    # Reference: http://en.wikipedia.org/wiki/Scale_space_implementation#The_discrete_Gaussian_kernel
    # G(x,sigma) = exp(-t)*I_x(t), where t = sigma^2
    # and I_x = Modified Bessel function of Order x

    double                                        sigma  Kernel spread, as standard deviation to cover.
    uint?   {[expr {max(1,int(ceil(3*$sigma)))}]} radius Kernel radius, defaults to max(1,ceil(3*sigma)).

    note Returns discrete gaussian convolution kernel, for the specified sigma and radius. \
	By default sigma is 1. \
	By default the radius is max(1,ceil(3*sigma)).

    note For more about the math see \
	http://en.wikipedia.org/wiki/Scale_space_implementation#The_discrete_Gaussian_kernel

    body {
	package require math::special
	if {$sigma <= 0} {
	    return -code error -errorCode {ARITH DOMAIN INVALID} {Invalid sigma, expected number > 0}
	}

	# Compute the upper half of the kernel (0...radius).
	set table {}
	set t [expr {$sigma ** 2}]

	for {set x 0} {$x <= $radius} {incr x} {
	    set v [expr {exp(-$t)*[math::special::I_n $x $t]}]
	    lappend table $v
	}

	# Compute lower half of the table as reflection of the upper half, and join the pieces.

	if {[llength $table] > 1} {
	    set table [linsert $table 0 {*}[lreverse [lrange $table 1 end]]]
	}

	# ATTENTION ______________________________________________________________
	##
	# Should we do the "correction" below ?
	# Or should we keep the difference to 1 as inevitable error due to truncating the infinite kernel ?
	##
	# ______________________________________________________________ ATTENTION

	# Compute scale factor normalizing the sum to 1.
	set scale [expr { 1. / [tcl::mathop::+ {*}$table] }]
	## puts XXXSCA|[tcl::mathop::+ {*}$table]|

	# Apply scale factor outside of `from matrix` -- easier to test, can expect a
	# fixed factor 1.
	set table [lmap x $table { expr {$x*$scale} }]

	# Compute anti-scale factor - verify that this is now 1
	## puts XXXSCB|[tcl::mathop::+ {*}$table]|

	# At last construct and return the kernel
	aktive image from matrix width [llength $table] height 1 values {*}$table
    }
}


# # ## ### ##### ######## ############# #####################

operator image::kernel::lanczos {
    section generator virtual

    # Reference: https://en.wikipedia.org/wiki/Lanczos_resampling#Lanczos_kernel

    uint?   3 order Order of the lanczos kernel. Acceptable minimum is 2.
    double? 1 step  X-delta between kernel elements.

    note Returns lanczos convolution kernel of the specified order. \
	The default order is 3. Step expands the kernel to the given \
	resolution (default 1).

    note For more about the math see \
	https://en.wikipedia.org/wiki/Lanczos_resampling#Lanczos_kernel

    body {
	if {$order < 2} {
	    return -code error -errorCode {ARITH DOMAIN INVALID} {Invalid order, has to be >= 2}
	}

	# Compute the upper half of the kernel (0...order)

	set steps [expr {ceil(double($order)/double($step))}]
	set table {}
	for {set n 0} {$n < $steps} {incr n} {
	    set v [expr {lanczos($order, $n*$step)}]
	    lappend table $v
	}

	# Compute lower half of the table as reflection of the upper half, and join the pieces.
	if {[llength $table] > 1} {
	    set table [linsert $table 0 {*}[lreverse [lrange $table 1 end]]]
	}

	# At last construct and return the kernel
	aktive image from matrix width [llength $table] height 1 values {*}$table
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
