## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Compress along one of the coordinate axes.
#
# BEWARE: The compression is a simple decimation.
#         The user is responsible for running a convolution beforehand to avoid/reduce
#         aliasing artifacts.
#
## TODO OPTIMIZATION :: do not query input for full rectangle - ask just for desired points
##                   :: -- because most of the input data is thrown away --
##                   :: NOTE - placement of decimation into runtime functions
##                   :: i.e. ...fetch_decimated ... complicates inputs, making them
##                   :: aware of decimation, i.e. load is on them.
##
##                   :: OTOH, while fetching a single point can be done through the
##                   :: existing interface (i.e. an 1x1 rectangle), this still goes
##                   :: through loops. A specialised point fetcher can leave such out, and
##                   :: thus be faster -- in terms of cycles, less branch-prediction work,
##                   :: etc. At that point decimated fetching might not be that difficult
##                   :: to add as well

operator {coordinate dimension} {
    op::downsample::x  x width
    op::downsample::y  y height
    op::downsample::z  z depth
} {
    section transform structure

    note Returns image with the input decimated along the ${coordinate}-axis \
	according to the decimation factor (>= 1).

    input

    uint by  Decimation factor, range 2...

    # Factor 1 decimation is no decimation at all
    simplify for  if {$by == 1}  returns src

    # Chains: decimation factors multiply
    simplify for  src/type @self \
	src/value by __by \
	calc __by {$__by * $by} \
	src/pop \
	returns op downsample $coordinate : by __by

    # Chains: decimation of a stretch with the same factor is identity
    # The reverse is __not__ true (unrecoverable information loss in the decimation)
    simplify for  src/type op::upsample::$coordinate \
	src/value by __by \
	if {$__by == $by}	src/pop   returns src

    simplify for  src/type op::upsample::${coordinate}rep \
	src/value by __by \
	if {$__by == $by}	src/pop   returns src

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
	if (param->by == 0) aktive_fail ("Rejecting undefined decimation by 0");

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	// Modify dimension according to parameter
	domain->@@dimension@@ = (domain->@@dimension@@ / param->by) +
		(0 != (domain->@@dimension@@ % param->by));
    }
    # NOTE: At higher sampling factors it becomes more sensible to fetch individual points
    # from the source, as an ever higher percentage of the generated data will be thrown
    # away here. And if the input is expensive efficiency will be a botch.
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
