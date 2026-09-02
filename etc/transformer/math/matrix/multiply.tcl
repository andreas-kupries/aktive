## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - More math (pixel wise)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core

operator op::math::matrix::multiply {
    section transform math matrix

    example [string map [list A [string map {\n { }} {
	1 2 3
	4 5 6
	7 8 9
	0 1 2
    }] B [string map {\n { }} {
	9 8 7 6
	5 4 3 2
	1 0 9 8
    }]] {
	aktive image from matrix width 3 height 4 values AA | -matrix -int
	aktive image from matrix width 4 height 3 values BB | -matrix -int
	@1 @2                                               | -matrix -int
    }]
    #        |  9  8   7   6
    #	     |  5  4   3   2
    #	     |  1  0   9   8
    # ------ | -------------
    #  1 2 3 | 22 16  40  34
    #  4 5 6 | 67 42  97  82
    #  7 8 9 |112 88 154 130
    #  0 1 2 |  7  4  21  18

    note Treats the images A and B as matrices and performs a \
	matrix multiplication.

    note An error is thrown if the necessary condition \
	`width(A) == `height(B)` does not hold. Likewise \
	if the two matrices do not have the same depth.

    note The result geometry (WxHxD) is \
	`width (B)` x `height (A)` x `depth (A)`.

    note The result image has the same location in the plane as input A. \
	The location of input B does not matter.

    note The bands of the two inputs are multiplied separately.

    input a	Left  matrix of the multiplication
    input b	Right matrix of the multiplication

    state -fields {
	aktive_uint join; // Size of join dimension
	int         dx;   // x translation between the origins of A and B
	int         by;   // y origin of B
    } -setup {
	aktive_geometry* a = aktive_image_get_geometry (srcs->v[0]);
	aktive_geometry* b = aktive_image_get_geometry (srcs->v[1]);

	TRACE_GEOMETRY_M("A", a);
	TRACE_GEOMETRY_M("B", b);

	if ((a->width  != b->height) || \
	    (a->depth  != b->depth)) { aktive_fail ("input dimension mismatch"); }

	aktive_geometry_copy (domain, a);
	domain->width  = b->width;
	domain->height = a->height;
	state->join    = b->height;
	state->dx      = b->x - a->x;
	state->by      = b->y;
	TRACE_GEOMETRY_M("Z", domain);
    }

    pixels -state {
	aktive_uint join; // Size of join dimension
	int         dx;   // x translation between the origins of A and B
	int         by;   // y origin of B
    } -setup {
	state->join = istate->join;
	state->dx   = istate->dx;
	state->by   = istate->by;
    } {
	// Fetch the relevant region of A. Iterate over B, fetch single columns.
	// Compute the dot product of B's column with the rows of A's region.

	// pull important dimensions
	aktive_uint columns = request->width;
	aktive_uint rows    = request->height;
	aktive_uint bands   = idomain->depth;
	aktive_uint join    = state->join;

	// derive the requests for A and B from the incoming
	// full rows of A
	aktive_rectangle_def_as (rowrequest, request);
	rowrequest.width = join;

	// full columns of B
	aktive_rectangle_def (colscan,
			      request->x + state->dx, state->by, 1, join);

	TRACE_RECTANGLE_M("region A", &rowrequest);
	TRACE_RECTANGLE_M("region B", &colscan);
	TRACE_RECTANGLE_M("region Z", request);

	// Fetch A's region, one or more rows
	aktive_block* a = aktive_region_fetch_area (0, &rowrequest);
	TRACE_DO (__aktive_block_dump ("block A", a));

	aktive_uint apitch = a->domain.width     * a->domain.depth;
	aktive_uint dpitch = block->domain.width * block->domain.depth;

	// iterate B's column's, left to right
	aktive_uint col; // B column counter
	double*     z;   // Z column start
	#define ITER_C for (col = 0, z = block->pixel; col  < columns; col ++, colscan.x ++)
	ITER_C {
	    TRACE ("scan B column %d", col);
	    TRACE_RECTANGLE_M("scan B column", &colscan);

	    // retch B's region, single column
	    aktive_rectangle_def_as (colrequest, &colscan);
	    aktive_block* b = aktive_region_fetch_area (1, &colrequest);
	    TRACE_DO (__aktive_block_dump ("block B", b));

	    // iterate A's rows down for the dot products with the column
	    double *cb = b->pixel; // B column start
	    double *d  = z;        // Z column iterator
	    aktive_uint row;       // A row counter
	    double* ra;            // A row iterator
	    #define ITER_R for (row = 0, ra = a->pixel; row < rows; row ++, ra += apitch)
	    ITER_R {
		TRACE ("scan A row %d", row);
		aktive_dotproduct (d, ra, cb, join, bands);
		d += dpitch;
	    }
	    z += bands;
	}

	TRACE_DO (__aktive_block_dump ("block Z", block));

	#undef ITER_R
	#undef ITER_C
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
