## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Decimation - Lowpass filter followed by a sub sampling step.

operator op::sample::decimate::xy {
    section transform structure

    example \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]} \
	{@1 by 4}

    note Returns image with the input decimated along both x and \
	y axes according to the decimation factor (>= 1).

    input

    uint? 2 by Decimation factor, range 2...

    str?  mirror embed \
	Embedding to apply to prevent input from shrinking \
	before sampled down.

    body {
	set src [x $src by $by embed $embed]
	set src [y $src by $by embed $embed]
    }
}

operator {coordinate dimension} {
    op::sample::decimate::x  x width
    op::sample::decimate::y  y height
} {
    section transform structure

    example \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]} \
	{@1 by 4}

    note Returns image with the input decimated along the ${coordinate}-axis \
	according to the decimation factor (>= 1).

    note This is accomplished by sub sampling the result of a lowpass \
	filter applied to the input.

    uint? 2      by    Decimation factor, range 2...
    str?  mirror embed \
	Embedding to apply to prevent input from shrinking \
	before sampled down.

    input

    # Factor 1 decimation is no decimation at all
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

    # Reference:
    # - https://dsp.stackexchange.com/questions/75899/appropriate-gaussian-filter-parameters-when-resizing-image
    # sigma = 1/(2s) where s = scale factor = new/old = 1/(decimation factor)
    #      => (decimation factor)/2

    body {
	if {$by < 2} { aktive error "Invalid decimation factor, expected > 1" }
	set sigma  [expr {$by/2.}]
	set kernel [aktive image kernel gauss discrete sigma $sigma]
	set radius [expr {[aktive query width $kernel] >> 1}]
	@@filter@@
	set src    [aktive op sample sub @@coordinate@@ $src by $by]
	set src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
