## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Generic warping by means of an origin map and a pixel interpolator.

operator {
    op::warp::bicubic
    op::warp::bilinear
    op::warp::lanczos
    op::warp::near-neighbour
} {
    op -> _ _ interpolation

    section transform structure warp

    def description [dict get {
	bicubic         bicubic
	bilinear        bilinear
	lanczos        {order-3 lanczos}
	near-neighbour {nearest neighbour}
    } $interpolation]

    def spec [dict get {
	bicubic         bicubic
	bilinear        bilinear
	lanczos         lanczos
	near-neighbour  nneighbour
    } $interpolation]

    note Returns an image generated by the application of the \
	origin map (`src0`) to the image (`src1`), \
	with $description interpolation.

    note The result has the domain of the origin map, \
	and the depth of the image.

    note See "<!xref: aktive transform affine>" and its relatives \
	for a set of operations creating origin maps acceptable here.

    input	;# origin map
    input	;# image to warp

    # blit over first input (origins) only.
    # fetch from the second is input dependent, not a scan.
    # bands are not scanned. this is done by the interpolator.
    blit warp {
	{AH {y AY 1 up} {y 0 1 up}}
	{AW {x AX 1 up} {x 0 1 up}}
    } {raw interpolated-fetch {
	aktive_region_fetch_interpolated (srcs->v[1],
					  spec,
					  idomain->depth,
					  srcvalue,
					  dstvalue);
    }}

    state -setup {
	// The domain and location are unchanged, taken from the origin map.
	// The depth becomes the depth of the image.
	aktive_geometry* og = aktive_image_get_geometry (srcs->v[0]);
	aktive_geometry* ig = aktive_image_get_geometry (srcs->v[1]);

	aktive_geometry_copy (domain, og);
	domain->depth = ig->depth;
    }
    pixels {
	aktive_interpolator* spec = aktive_interpolator_@@spec@@ ();

	aktive_rectangle_def_as (subrequest, request);
	TRACE_RECTANGLE_M("fetch", &subrequest);

	// fetch from the map
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// fetch from the input is done through the interpolator,
	// for the declared origin points.

	@@warp@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
