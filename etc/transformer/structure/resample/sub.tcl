## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Sub sampling along one of the coordinate axes.
#
# BEWARE: The user is responsible for running a convolution beforehand to avoid/reduce
#         aliasing artifacts. See `op::sample::decimate`.
#
##
## The sampling factor S is also the scale factor, i.e.
##
##   result width = floor (input width / S)
##
## and S-1 pixels are removed from the input for every kept pixel.
#
## TODO OPTIMIZATION do not query input for full rectangle - ask just for desired points
##                   -- because most of the input data is thrown away --
##
##                   NOTE - placement of sampling into runtime functions
##                   i.e. ...fetch_sampled ... complicates inputs, making them aware of
##                   sampling, i.e. load is on them.
##
##                   OTOH, while fetching a single point can be done through the existing
##                   interface (i.e. an 1x1 rectangle), this still goes through loops. A
##                   specialised point fetcher can leave such out, and thus be faster
##                   because of less cycles spent, less branch-prediction work, etc. At
##                   that point sampled fetching might not be that difficult to add as
##                   well.

operator op::sample::sub::xy {
    section transform structure

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 by 4
    }

    note Returns image with the input sampled down along both x and y axes \
	according to the sampling factor S (>= 1). The result keeps every S'th \
	pixel of the input. S-1 pixels after every kept pixel are removed.

    input

    uint? 2 by Sampling factor, range 2...

    # TODO label the last operation with the actual operation performed by the sequence.
    # TODO use this information in a simplification rule to properly reduce repeated
    # TODO application.
    ##
    # NOTE do the labeling in a way which allows for co-existence with higher combinations
    #      using this combo doing their own labeling too.

    body {
	set src [x $src by $by]
	set src [y $src by $by]
    }
}

operator {coordinate dimension} {
    op::sample::sub::x  x width
    op::sample::sub::y  y height
    op::sample::sub::z  z depth
} {
    section transform structure

    if {$coordinate in {x y}} {
	example {
	    aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	    @1 by 4
	}
    }

    note Returns image with the input sampled down along the ${coordinate}-axis \
	according to the sampling factor S (>= 1). The result keeps every S'th \
	pixel of the input. S-1 pixels after every kept pixel are removed.

    # Factor 0 - Undefined. Rejected.
    #        1 - Keep every pixel -> Identity, no operation
    #        2 - Keep half the pixels
    #        3 - Keep a third of the pixels

    input

    uint? 2 by Sampling factor, range 2...

    # Factor 1 sampling is no sampling at all
    simplify for \
	if {$by == 1} \
	returns src

    # Chains: sampling factors multiply
    simplify for  \
	src/type @self \
	src/value by __by \
	calc __by {$__by * $by} \
	src/pop \
	returns op sample sub $coordinate : by __by

    # Chains: sampling of a zero-stuffed with the same factor is identity
    # The reverse is __not__ true (unrecoverable information loss in the sampling)
    simplify for \
	src/type op::sample::fill::$coordinate \
	src/value by __by \
	if {$__by == $by} \
	src/pop \
	returns src

    simplify for \
	src/type op::sample::replicate::${coordinate} \
	src/value by __by \
	if {$__by == $by} \
	src/pop \
	returns src

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    # ... stretch specific source axis
    switch -exact -- $coordinate {
	y { lset blitspec 0 2 2 n }
	x { lset blitspec 1 2 2 n }
	z { lset blitspec 2 2 2 n }
    }
    # ... generate code
    blit subsampler $blitspec copy

    def expansion-rewrite-core {
	// Rewrite request along the @@coordinate@@-axis to get enough data from the source
	subrequest.@@coordinate@@ *= n;
	subrequest.@@dimension@@ *= n;
    }

    def expansion [dict get {
	x { @@expansion-rewrite-core@@ }
	y { @@expansion-rewrite-core@@ }
	z { // Nothing to rewrite for z, depth }
    } $coordinate]

    state -setup {
	// could be moved into the cons wrapper created for simplification
	if (param->by == 0) aktive_fail ("Rejecting undefined sampling by factor 0");

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	// Modify dimension according to parameter
	domain->@@dimension@@ = (domain->@@dimension@@ / param->by) +
		(0 != (domain->@@dimension@@ % param->by));
    }

    # NOTE: At higher sampling factors it becomes more sensible to fetch individual points
    # from the source, as an ever higher percentage of the generated data will be thrown
    # away here. And if the input is expensive efficiency will be a botch.
    #
    # An example is decimation, a low pass filter followed by sampling.

    pixels {
	aktive_uint n = param->by;
	aktive_rectangle_def_as (subrequest, request);
	@@expansion@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// The source @@coordinate@@ axis is scanned N times faster than the destination
	@@subsampler@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
