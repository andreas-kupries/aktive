## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Pixels proclaim their origin location

operator warp::matrix {
    section generator virtual warp

    example {
	aktive transform translate x 5 y 3 | -matrix -label translate x 5 y 3
	@1 width 5 height 5                | -matrix
    }
    example {
	aktive transform shear x 5 | -matrix -label shear x 5
	@1 width 5 height 5        | -matrix
    }

    note Returns the warp map for the general transformation specified \
	by the 3x3x1 input matrix.

    note __Attention__. As a warp map declares origin positions for output \
	pixels the matrix has to specify a __backward transformation__.

    # TODO :: look into extended MD support - bullet list would be nice here.
    note The operations "<!xref: aktive transform affine>," \
	"<!xref: aktive transform identity>," \
	"<!xref: aktive transform projective>," \
	"<!xref: aktive transform quad quad>," \
	"<!xref: aktive transform quad unit>," \
	"<!xref: aktive transform reflect line>," \
	"<!xref: aktive transform reflect x>," \
	"<!xref: aktive transform reflect y>," \
	"<!xref: aktive transform rotate>," \
	"<!xref: aktive transform scale>," \
	"<!xref: aktive transform shear>," \
	and "<!xref: aktive transform translate>" \
	all create matrices suitable as input to this operation.

    note The operations \
	"<!xref: aktive transform compose>" and \
	"<!xref: aktive transform invert>" \
	enable the composition of arbitrary transformations \
	from simpler pieces, and the conversion between forward \
	and backward transformations.

    note The result is designed to be usable with the \
	"<!xref: aktive op warp>" operation.

    note At the technical level the result is a 2-band image \
	where each pixel declares its origin position.

    strict 1st The projective matrix is materialized and cached.

    input	;# projective transform matrix

    uint   width  Width  of the returned image
    uint   height Height of the returned image
    int? 0 x      X location of the returned image in the 2D plane
    int? 0 y      Y location of the returned image in the 2D plane

    state -fields {
	aktive_region pr;	  // region holding the projective matrix
	double*       projective; // quick access to the matrix data
    } -cleanup {
	aktive_region_destroy (state->pr);
	// projective goes away with the region.
    } -setup {
	aktive_image     pm = srcs->v[0];
	aktive_geometry* pg = aktive_image_get_geometry (pm);

	if (pg->width  != 3) aktive_fail ("not a projective matrix, expected width == 3");
	if (pg->height != 3) aktive_fail ("not a projective matrix, expected height == 3");

	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 2);

	// materialize the matrix
	aktive_rectangle_def_as(prect,aktive_geometry_as_rectangle (pg));
	prect.width         = pg->width;
	prect.height        = pg->height;
	state->pr           = aktive_region_new (pm, 0);
	aktive_block* block = aktive_region_fetch_area (state->pr, &prect);
	state->projective   = block->pixel;
    }

    blit indexed {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {point {
	(z == 0) ? (U) : (V)
    }}

    pixels {
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
        #define SY (request->y)

	// Matrix (3x3) is a b c | x
	//                 d e f | y
	//                 g h i | 1

	double a = istate->projective [0];
	double b = istate->projective [1];
	double c = istate->projective [2];
	double d = istate->projective [3];
	double e = istate->projective [4];
	double f = istate->projective [5];
	double g = istate->projective [6];
	double h = istate->projective [7];
	double i = istate->projective [8];

	#define U ((srcx * a + srcy * b + 1 * c) / (W))
	#define V ((srcx * d + srcy * e + 1 * f) / (W))
	#define W  (   1 * g +    1 * h + 1 * i)

	@@indexed@@

	#undef U
	#undef V
	#undef W
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
