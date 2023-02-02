# -*- mode: tcl ; fill-column: 90 -*-
## # # ## ### ##### ######## ############# #####################

# Operators take zero or more images, zero or more parameters, and return either a single
# new image, some non-image value, or nothing. We have
#
# - Generators:   No inputs, one or more parameters, image result
# - Transformers: One input, zero or more parameters, image result
# - Compositors:  Two or more inputs, zero or more parameters, image result
# - Sinks:        One input, zero or more parameters, no result
# - Accessors:    One input, no parameters, non-image result

## # # ## ### ##### ######## ############# #####################

# Note: While pixel values are generally something in the range [0..1] this is only
# relevant when converting an image to and/or from some external image format.

## # # ## ### ##### ######## ############# #####################
# Types for parameters and results.
# Note: Dynamic vector structures match critcl variadics.
##

## I. Required by runtime
# __ id __________ critcl ___________ C type ___________________ Conversion ______________________________
type point         aktive_point       -                          {aktive_new_point_obj (value)}
type rect          aktive_rectangle   -                          {aktive_new_rectangle_obj (value)}
type image-type    aktive_image_type* {const aktive_image_type*} {Tcl_NewStringObj ((*value)->name, -1)}
type image         aktive_image       -                          {aktive_new_image_obj (*value)}
type region        aktive_region      -                          {0 /* INTERNAL -- No Tcl_Obj* equivalent */}
type uint          aktive_uint        -                          {aktive_new_uint_obj (*value)}
type double        -                  -                          {Tcl_NewDoubleObj (*value)}

vector region image point uint double

## II. Operator support
# __ id __________ critcl ___________ C type ____ Conversion ______________________________
type bool          boolean            int         {Tcl_NewIntObj (*value)}
type int           -                  -           {Tcl_NewIntObj (*value)}
type object0       -                  Tcl_Obj*    {*value}
type channel       -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
type take-channel  -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
type pgm_variant   aktive_pgm_variant -           {aktive_pgm_variant_pool (interp, *value)}
type ppm_variant   aktive_ppm_variant -           {aktive_ppm_variant_pool (interp, *value)}

## # # ## ### ##### ######## ############# #####################

## # # ## ### ##### ######## ############# #####################
# Rectangle operations

operator rectangle::zones {
    rect domain  Rectangle to modify
    rect request Rectangle to modify

    return object0 {
	aktive_uint c;
	aktive_rectangle v[5];

	aktive_rectangle_outzones (&param->domain, &param->request, &c, v);

	Tcl_Obj* r = Tcl_NewListObj (c, 0);

	for (aktive_uint i = 0; i < c; i++) {
	    Tcl_Obj* vo = aktive_new_rectangle_obj (&v[i]);
	    Tcl_ListObjReplace(ip, r, i, 1, 1, &vo);
	}
	return r;
    }
}

operator rectangle::make {
    int  x  Rectangle location, Column
    int  y  Rectangle location, Row
    uint w  Rectangle width
    uint h  Rectangle height

    return rect {
	aktive_rectangle r = {
	    .x     = param->x, .y      = param->y,
	    .width = param->w, .height = param->h
	};
	return r;
    }
}

operator rectangle::grow {
    rect r       Rectangle to modify
    int  left    Amount to grow the left border, positive to the left
    int  right   Amount to grow the right border, positive to the right
    int  top     Amount to grow the top border, positive upward
    int  bottom  Amount to grow the bottom border, positive downward

    return rect {
	aktive_rectangle r;
	r = param->r;
	aktive_rectangle_grow (&r,
			       param->left, param->right,
			       param->top,  param->bottom);
	return r;
    }
}

operator rectangle::move {
    rect r   Rectangle to modify
    int  dx  Amount to move left/right, positive to the right
    int  dy  Amount to move up/down, positive downward

    return rect {
	aktive_rectangle r;
	r = param->r;
	aktive_rectangle_move (&r, param->dx, param->dy);
	return r;
    }
}

operator rectangle::union {
    rect... r   Rectangles to union

    return rect {
	if (param->r.c == 0) {
	    aktive_rectangle zero = { 0, 0, 0, 0};
	    return zero;
	}

	aktive_rectangle r;
	r = param->r.v [0];
	if (param->r.c > 1) {
	    for (aktive_uint i = 1; i < param->r.c; i++) { aktive_rectangle_union (&r, &r, &param->r.v [i]); }
	}
	return r;
    }
}

operator rectangle::intersect {
    rect... r   Rectangles to intersect

    return rect {
	if (param->r.c == 0) {
	    aktive_rectangle zero = { 0, 0, 0, 0};
	    return zero;
	}

	aktive_rectangle r;
	r = param->r.v [0];
	if (param->r.c > 1) {
	    for (aktive_uint i = 1; i < param->r.c; i++) { aktive_rectangle_intersect (&r, &r, &param->r.v [i]); }
	}
	return r;
    }
}

operator rectangle::equal {
    rect a   First rectangle to compare
    rect b   Second rectangle to compare

    return int { aktive_rectangle_is_equal (&param->a, &param->b) ; }
}

operator rectangle::subset {
    rect a   First rectangle to compare
    rect b   Second rectangle to compare

    return int { aktive_rectangle_is_subset (&param->a, &param->b) ; }
}

operator rectangle::empty {
    rect r   Rectangle to check

    return int { aktive_rectangle_is_empty (&param->r) ; }
}

## # # ## ### ##### ######## ############# #####################
# Accessors - Querying various attributes

operator query::type {
    input ignore
    return image-type { aktive_image_get_type (src); }
}

operator attribute {
    query::x    x
    query::xmax xmax
    query::y    y
    query::ymax ymax
} {
    input ignore
    return int "aktive_image_get_$attribute (src);"
}

operator attribute {
    query::width  width
    query::height height
    query::depth  depth
    query::pixels pixels
    query::pitch  pitch
    query::size   size
} {
    input ignore
    return uint "aktive_image_get_$attribute (src);"
}

operator query::inputs {
    input ignore
    return object0 {
	aktive_uint c = aktive_image_get_nsrcs (src);
	Tcl_Obj**   v = NALLOC (Tcl_Obj*, c);

	for (aktive_uint i = 0; i < c; i++) {
	  v [i] = aktive_new_image_obj  (aktive_image_get_src (src, i));
	}
	Tcl_Obj* r = Tcl_NewListObj (c, v);
	ckfree ((char*) v);
	return r;
    }
}

operator query::params {
    input ignore
    return object0 {
	aktive_uint c = aktive_image_get_nparams (src);
	Tcl_Obj* r    = Tcl_NewDictObj();

	for (aktive_uint i = 0; i < c; i++) {
	  const char* n = aktive_image_get_param_name (src, i);
	  Tcl_Obj*    v = aktive_image_get_param_value (src, i, ip);
	  Tcl_DictObjPut (ip, r, Tcl_NewStringObj (n,-1), v);
	}
	return r;
    }
}

## # # ## ### ##### ######## ############# #####################
# Sinks ... Writing an image to somewhere else

nyi operator thing {
    format::pgm::write pgm
    format::ppm::write ppm
} {
    note Sink. Serializes image to $thing format, into channel

    input ignore
    void

    channel                                dst     Channel the $thing image data is written to
    ${thing}_variant? aktive_${thing}_text variant The $thing format variant to generate

    # %% TODO %% specify implementation
}

operator format::tcl {
    note Sink. Serializes image to readable Tcl structures (dict with flat pixel list)

    input ignore

    return object0 { aktive_op_astcl (ip, src); }
}

## # # ## ### ##### ######## ############# #####################
# Generators ... The returned image is constructed from the parameters.

operator image::constant {
    note The entire image is set to the value

    uint   width   Width of the returned image
    uint   height  Height of the returned image
    uint   depth   Depth of the returned image
    double value   Pixel value

    geometry {
	// location is kept at default (0,0)
	aktive_geometry_set (geo, param->width, param->height, param->depth);
    }
    pixels {
	// param   -- value
	// srcs    -- n/a
	// state   -- n/a
	// request -- ignore
	// physreq -- area in block to fill
	// block   -- pixel storage

	aktive_blit_fill (block, physreq, param->value);
    } ;# no state
}

operator image::const::planes {
    note The entire set of pixels is set to the same series of band values
    note Depth is len(value)

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    double... value   Pixel band values

    geometry {
	// location is default (0,0)
	// depth is number of band values
	aktive_geometry_set (geo, param->width, param->height, param->value.c);
    }
    pixels {
	// param   -- value
	// srcs    -- n/a
	// state   -- n/a
	// request -- ignore
	// physreq -- area in block to fill
	// block   -- pixel storage
	//
	// assert: param.value.c == block.geo.depth
	// assert: block.used % block.depth == 0

	aktive_blit_fill_bands (block, physreq, &param->value);
    } ;# no state
}

nyi operator image::const::matrix {
    note Explictly specified image through pixel values
    note Less than width by height values is extended with zeroes.
    note Excess values are ignored.
    note Depth is fixed at 1.

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    double... value   Pixel values

    # %% TODO %% specify implementation
}

nyi operator image::noise::salt {
    note Salt and pepper noise.
    note Pixels are set where the random value passes the threshold
    note The value of set pixels is fixed at 1.0

    uint      width      Width of the returned image
    uint      height     Height of the returned image
    uint      depth      Depth of the returned image
    double    threshold  Noise threshold within low..high
    double? 0 low        Lowest  possible random value
    double? 1 high       Highest possible random value

    # %% TODO %% specify implementation
}

nyi operator image::noise::uniform {
    note Pixels are set to a random value drawn from a uniform distribution

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    uint      depth   Depth of the returned image
    double? 0 low     Lowest  possible noise value
    double? 1 high    Highest possible noise value

    # %% TODO %% specify implementation
}

nyi operator image::noise::gauss {
    note Pixels are set to a random value drawn from a gaussian distribution

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    uint      depth   Depth of the returned image
    double? 0 mean    Noise center value
    double? 1 sigma   Noise spread (sqrt of desired variance)

    # %% TODO %% specify implementation
}

nyi operator image::noise::seed {
    note Set the seed of the random number generator used by the noise-based image generators

    int seed  Seed to set
    void {
	// %% TODO %% specify implementation
    }
}

nyi operator image::gradient {
    uint   width   Width of the returned image
    uint   height  Height of the returned image
    uint   depth   Depth of the returned image
    double first   First value
    double last    Last value

    # %% TODO %% specify implementation
}

nyi operator image::sparse::points {
    point... points  Coordinates of the pixels to set in the image

    note Generally, the bounding box specifies the geometry, especially also the image origin.q
    note Width is implied by the bounding box of the points
    note Height is implied by the bounding box of the points
    note Depth is fixed at 1
    note Pixel value is fixed at 1.0

    # %% TODO %% specify implementation
}

nyi operator image::sparse::deltas {
    uint    width   Width of the returned image
    uint    height  Height of the returned image
    uint... delta   Linear distances between points to set

    note Depth is fixed at 1
    note Pixel value is fixed at 1.0

    # %% TODO %% specify implementation
}

nyi operator {thing depth} {
    format::pgm::read pgm 1
    format::ppm::read ppm 3
} {
    take-channel src  Channel to read $thing image data from

    # state: maxval ? variant-dependent actual reader function ?
    # cons : reader image header (dimensions, variant) - choose reader ?

    state -state {
	aktive_uint width;  /* Image width read from image header */
	aktive_uint height; /* Image height read from image header */
    } -cons { return 0; } ;# %% TODO %%

    geometry {
	// location is kept at default (0,0)
	aktive_geometry_set (geo, state->width, state->height, @depth@);
    } @depth@ $depth
    pixels { 0 }

    # %% TODO %% specify implementation - read image data - locked
}

## # # ## ### ##### ######## ############# #####################
# Transformers ... The returned image is constructed from the input image, and
# possibly some parameters.

nyi operator {
    op::cmath::conjugate
    op::cmath::cos
    op::cmath::div
    op::cmath::exp
    op::cmath::log
    op::cmath::log10
    op::cmath::magnitude
    op::cmath::mul
    op::cmath::sin
    op::cmath::sqmagnitude
    op::cmath::sqrt
    op::cmath::tan
    op::cmath::tocartesian
    op::cmath::topolar

    op::integrate
} {
    input keep

    # %% TODO %% specify implementation
}

nyi operator {
    op::montage::x
    op::montage::y
    op::montage::z
} {
    input... keep-pass

    # %% TODO %% specify implementation
}

nyi operator {
    op::flip::x
    op::flip::y
    op::flip::z
} {
    input keep-pass

    # %% TODO %% specify implementation
}

nyi operator {
    op::swap::xy
    op::swap::xz
    op::swap::yz
} {
    input keep-pass-ignore

    # %% TODO %% specify implementation
}

operator op::view {
    note Look at some area of an image.
    note The requested area may fall anywhere regarding the input image's domain.
    note Same, insude (subset), outside, partially overlapping, etc.

    input keep
    rect view  The specific area to view in the plane

    geometry {
	// taking depth from input
	aktive_point_set    (loc, param->view.x, param->view.y);
	aktive_geometry_set (geo,
			     param->view.width,
			     param->view.height,
			     aktive_image_get_depth (srcs->v [0]));
    }
    pixels {
	// param   -- view
	// srcs    -- #1 [0]
	// state   -- n/a
	// request -- passed down to input
	// physreq -- area in block to fill
	// block   -- pixel storage
	//
	// pass-through operation ...
	// - Requested area passes unchanged to input ...
	// - Returned pixels pass unchanged to caller ...
	//
	// TODO :: proper pixel blit because area here may be a subset of full area,
	//      :: whereas the returned pixels are the fully requested set
	//
	// CONSIDER :: A reworked fetch API enabling zero copy full pass-through
	//          :: (full area, requested area, pixel memory)
	//          :: Maybe move aktive_block out of region ? Caller-owned ?
	//          :: ops not passing through => block is standard region state ?!

	// assert: result.used == block.used
	// assert: result.geo  == block.geo

	aktive_blit_copy0 (block, physreq,
			   aktive_region_fetch_area (srcs->v [0], request));
    }
}

nyi operator {
    op::math::inside-oo
    op::math::inside-oc
    op::math::inside-co
    op::math::inside-cc
    op::math::outside-oo
    op::math::outside-oc
    op::math::outside-co
    op::math::outside-cc
} {
    input keep-pass-ignore

    double low   Low boundary
    double high  High boundary

    # %% TODO %% specify implementation
}

nyi operator op::geometry::move-to {
    input keep-pass-ignore

    int x  New absolute x location of image in the plane
    int y  New absolute y location of image in the plane

    # %% TODO %% specify implementation
}

nyi operator op::geometry::move-by {
    input keep-pass-ignore

    int dx  Shift for x location of image in the plane
    int dy  Shift for y location of image in the plane

    # %% TODO %% specify implementation
}

nyi operator op::geometry::reshape {
    input keep-pass-ignore

    uint width   New width of the returned image
    uint height  New height of the returned image
    uint depth   New depth of the returned image

    # %% TODO %% specify implementation
}

## # # ## ### ##### ######## ############# #####################
# Compositors ... The returned image is contructed from the input

nyi operator {
    op::math::atan2
    op::math::div
    op::math::ge
    op::math::gt
    op::math::hypot
    op::math::le
    op::math::lt
    op::math::mod
    op::math::pow
    op::math::sub
} {
    input keep-pass-ignore
    input keep-pass-ignore

    # %% TODO %% specify implementation
}

nyi operator {
    op::pixel::mul
} {
    input keep
    input keep

    # %% TODO %% specify implementation
}

# op::pixel::mul - vector matrix multiplication - vector is pixel, image depth long.
#                  matrix is image, depth fixed 1, width equal to image depth, asserted
#                  result image has depth equal to matrix height
#
# example: color conversions.

nyi operator {
    op::math::add
    op::math::max
    op::math::min
    op::math::mul
} {
    input keep-pass-ignore
    input keep-pass-ignore

    # %% TODO %% specify implementation
}

nyi operator {name op} {
    op::math1::shift   offset    {Add      scalar offset}
    op::math1::unshift offset    {Subtract scalar offset}
    op::math1::scale   factor    {Multiply by scalar factor}
    op::math1::unscale factor    {Divide   by scalar factor}
    op::math1::moda    modulus   {Remainder by scalar modulus}
    op::math1::modb    numerator {Remainder by scalar numerator}
    op::math1::pow     exponent  {Power by scalar exponent}
    op::math1::expx    base      {Power by scalar base}
    op::math1::hypot   y         {Hypot to scalar y}
    op::math1::max     y         {Limit to greater or equal a scalar min}
    op::math1::min     y         {Limit to less    or equal a scalar max}
    op::math1::atan2a  x         {Atan by scalar x}
    op::math1::atan2b  y         {Atan by scalar y}
    op::math1::ge      threshold {Indicate pixels greater or equal the scalar threshold}
    op::math1::le      threshold {Indicate pixels less    or equal the scalar threshold}
    op::math1::gt      threshold {Indicate pixels greater than     the scalar threshold}
    op::math1::lt      threshold {Indicate pixels less    than     the scalar threshold}
    op::solarize       threshold {Solarize pixels per the threshold}
} {
    input keep-pass-ignore

    double $name  {*}$op

    # %% TODO %% specify implementation
}

nyi operator {
    op::math1::abs
    op::math1::clamp
    op::math1::wrap
    op::math1::invert
    op::math1::neg
    op::math1::sign
    op::math1::sign*
    op::math1::reciproc
    op::math1::sqrt
    op::math1::cbrt
    op::math1::exp
    op::math1::exp2
    op::math1::log
    op::math1::log10
    op::math1::log2
    op::math1::cos
    op::math1::sin
    op::math1::tan
    op::math1::cosh
    op::math1::sinh
    op::math1::tanh
    op::math1::acos
    op::math1::asin
    op::math1::atan
    op::math1::acosh
    op::math1::asinh
    op::math1::atanh
    op::math1::gamma-compress
    op::math1::gamma-expand
} {
    input keep-pass-ignore

    # %% TODO %% specify implementation
}

nyi operator thing {
    op::select::x column
    op::select::y row
    op::select::z plane
} {
    input keep-pass

    uint         first  First $thing of input to be in result
    uint? _first last   Last  $thing of input to be in result

    # %% TODO %% specify implementation
}

nyi operator {
    op::downsample::x
    op::downsample::y
    op::downsample::z
} {
    input keep-pass

    uint n  Sampling factor, range 2...

    # %% TODO %% specify implementation
}

nyi operator {
    op::upsample::x
    op::upsample::y
    op::upsample::z
} {
    input keep-pass

    uint      n     Sampling factor, range 2...
    double? 0 fill  Pixel fill value

    # %% TODO %% specify implementation
}

nyi operator {
    op::upsample::xrep
    op::upsample::yrep
    op::upsample::zrep
} {
    input keep-pass

    uint n  Sampling factor, range 2...

    # %% TODO %% specify implementation
}

## # # ## ### ##### ######## ############# #####################
::return
