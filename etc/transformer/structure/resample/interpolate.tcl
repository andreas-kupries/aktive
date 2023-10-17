## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Interpolation - Fill step followed by a lowpass filter.

operator op::sample::interpolate::xy {
    section transform structure

    note Returns image with the input interpolated along both x and y axes \
	according to the interpolation factor (>= 1).

    note This is accomplished by low-pass filtering applied to the result of \
	zero-stuffing the input.

    input

    uint? 2 by Interpolation factor, range 2...

    str?  mirror embed \
	Embedding to apply to prevent input from shrinking \
	before sampled down.

    body {
	set src [x $src by $by embed $embed]
	set src [y $src by $by embed $embed]
    }
}

# Z -- TODO :: convolution along the depth axis
operator {coordinate dimension} {
    op::sample::interpolate::x  x width
    op::sample::interpolate::y  y height
} {
    section transform structure

    note Returns image with the input interpolated along the ${coordinate}-axis \
	according to the interpolation factor (>= 1).

    note This is accomplished by low-pass filtering applied to the result of \
	zero-stuffing the input.

    uint? 2      by    Interpolation factor, range 2...
    str?  mirror embed \
	Embedding to apply to prevent input from shrinking \
	before sampled down.

    input

    # Factor 1 interpolation is no interpolation at all
    simplify for  if {$by == 1}  returns src

    def filter [dict get {
	x {
	    set src    [aktive op embed $embed $src left $radius right $radius]
	    set src    [aktive op convolve xy $kernel $src]
	}
	y {
	    set kernel [aktive op swap xy $kernel]
	    set src    [aktive op embed $embed $src top $radius bottom $radius]
	    set src    [aktive op convolve xy $kernel $src]
	}
    } $coordinate]

    body {
	if {$by < 2} { aktive error "Invalid interpolation factor, expected > 1" }
	set sigma $by
	set kernel [aktive image kernel gauss discrete sigma $sigma]
	set radius [expr {[aktive query width $kernel] >> 1}]
	# NOTE: The kernel values are scaled up by the sampling factor to compensate
	#       for the attenuation caused by the zero-valued infill.
	set kernel [aktive op math1 scale $kernel factor $by]
	set src    [aktive op sample fill @@coordinate@@ $src by $by]
	@@filter@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
