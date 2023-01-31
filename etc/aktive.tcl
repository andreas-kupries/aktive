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
##

# __ id __________ critcl ___________ C type ____ Conversion ______________________________
type bool          boolean            int         {Tcl_NewIntObj (*value)}
type channel       -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
type double        -                  -           {Tcl_NewDoubleObj (*value)}
type image         aktive_image       -           {aktive_new_image_obj (*value)}
type image-type    aktive_image_type* -           {Tcl_NewStringObj ((*value)->name, -1)}
type int           -                  -           {Tcl_NewIntObj (*value)}
type object0       -                  Tcl_Obj*    {*value}
type pgm_variant   aktive_pgm_variant -           {aktive_pgm_variant_pool (interp, *value)}
type point         aktive_point       -           {aktive_new_point_obj (value)}
type ppm_variant   aktive_ppm_variant -           {aktive_ppm_variant_pool (interp, *value)}
type take-channel  -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
type uint          aktive_uint        -           {aktive_new_uint_obj (*value)}

# Types requiring dynamic vector structures - Match critcl variadics.
vector double image point uint

## # # ## ### ##### ######## ############# #####################
# Accessors - Querying various attributes

operator query::type {
    input ignore
    result image-type
}

operator {
    query::x
    query::xmax
    query::y
    query::ymax
} {
    input ignore
    result int
}

operator {
    query::width 
    query::height
    query::depth 
    query::pixels
    query::pitch
} {
    input ignore
    result uint
}

operator {
    query::params
    query::inputs
} {
    input ignore
    result object0
}

## # # ## ### ##### ######## ############# #####################
# Sinks ... Writing an image to somewhere else

operator thing {
    format::pgm::write pgm
    format::ppm::write ppm
} {
    note Sink. Serializes image to $thing format, into channel
    
    void
    input ignore

    channel                                dst     Channel the $thing image data is written to
    ${thing}_variant? aktive_${thing}_text variant The $thing format variant to generate

    # %% TODO %% specify implementation
}

## # # ## ### ##### ######## ############# #####################
# Generators ... The returned image is constructed from the parameters.

operator image::constant {
    note The entire image is set to the value
    
    uint   width   Width of the returned image
    uint   height  Height of the returned image
    uint   depth   Depth of the returned image
    double value   Pixel value

    # %% TODO %% specify implementation
}

operator image::const::planes {
    note The entire set of pixels is set to the values
    note Depth is len(value)
    
    uint      width   Width of the returned image	
    uint      height  Height of the returned image
    double... value   Pixel values

    # %% TODO %% specify implementation
}

operator image::const::matrix {
    note Explictly specified image through pixel values
    note Less than width by height values is extended with zeroes.
    note Excess values are ignored.
    note Depth is fixed at 1.
    
    uint      width   Width of the returned image	
    uint      height  Height of the returned image
    double... value   Pixel values

    # %% TODO %% specify implementation
}

operator image::noise::salt {
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

operator image::noise::uniform {
    note Pixels are set to a random value drawn from a uniform distribution
    
    uint      width   Width of the returned image
    uint      height  Height of the returned image
    uint      depth   Depth of the returned image
    double? 0 low     Lowest  possible noise value
    double? 1 high    Highest possible noise value

    # %% TODO %% specify implementation
}

operator image::noise::gauss {
    note Pixels are set to a random value drawn from a gaussian distribution
    
    uint      width   Width of the returned image
    uint      height  Height of the returned image
    uint      depth   Depth of the returned image
    double? 0 mean    Noise center value                     
    double? 1 sigma   Noise spread (sqrt of desired variance)

    # %% TODO %% specify implementation
}

operator image::noise::seed {
    note Set the seed of the random number generator used by the noise-based image generators
    
    void
    int seed  Seed to set

    # %% TODO %% specify implementation
}

operator image::gradient {
    uint   width   Width of the returned image
    uint   height  Height of the returned image
    uint   depth   Depth of the returned image
    double first   First value
    double last    Last value

    # %% TODO %% specify implementation
}

operator image::sparse::points {
    point... points  Coordinates of the pixels to set in the image
    
    note Generally, the bounding box specifies the geometry, especially also the image origin.q
    note Width is implied by the bounding box of the points
    note Height is implied by the bounding box of the points
    note Depth is fixed at 1
    note Pixel value is fixed at 1.0

    # %% TODO %% specify implementation
}

operator image::sparse::deltas {
    uint    width   Width of the returned image
    uint    height  Height of the returned image
    uint... delta   Linear distances between points to set

    note Depth is fixed at 1
    note Pixel value is fixed at 1.0

    # %% TODO %% specify implementation
}

operator thing {
    format::pgm::read pgm
    format::ppm::read ppm
} {
    take-channel src  Channel to read $thing image data from

    # %% TODO %% specify implementation
}

## # # ## ### ##### ######## ############# #####################
# Transformers ... The returned image is constructed from the input image, and
# possibly some parameters.

operator {
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

operator {
    op::montage::x
    op::montage::y
    op::montage::z
} {
    input keep-pass ...

    # %% TODO %% specify implementation
}

operator {
    op::flip::x
    op::flip::y
    op::flip::z
} {
    input keep-pass

    # %% TODO %% specify implementation
}

operator {
    op::swap::xy
    op::swap::xz
    op::swap::yz
} {
    input keep-pass-ignore

    # %% TODO %% specify implementation
}


operator {
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

operator op::geometry::move-to {
    input keep-pass-ignore

    int x  New absolute x location of image in the plane
    int y  New absolute y location of image in the plane

    # %% TODO %% specify implementation
}

operator op::geometry::move-by {
    input keep-pass-ignore

    int dx  Shift for x location of image in the plane
    int dy  Shift for y location of image in the plane

    # %% TODO %% specify implementation
}

operator op::geometry::reshape {
    input keep-pass-ignore

    uint width   New width of the returned image
    uint height  New height of the returned image
    uint depth   New depth of the returned image

    # %% TODO %% specify implementation
}

## # # ## ### ##### ######## ############# #####################
# Compositors ... The returned image is contructed from the input

operator {
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

operator {
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

operator {
    op::math::add
    op::math::max
    op::math::min
    op::math::mul
} {
    input keep-pass-ignore
    input keep-pass-ignore

    # %% TODO %% specify implementation
}

operator {name op} {
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

operator {
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

operator thing {
    op::select::x column
    op::select::y row
    op::select::z plane
} {
    input keep-pass

    uint         first  First $thing of input to be in result
    uint? _first last   Last  $thing of input to be in result

    # %% TODO %% specify implementation
}

operator {
    op::downsample::x
    op::downsample::y
    op::downsample::z
} {
    input keep-pass

    uint n  Sampling factor, range 2...

    # %% TODO %% specify implementation
}

operator {
    op::upsample::x
    op::upsample::y
    op::upsample::z
} {
    input keep-pass

    uint      n     Sampling factor, range 2...
    double? 0 fill  Pixel fill value

    # %% TODO %% specify implementation
}

operator {
    op::upsample::xrep
    op::upsample::yrep
    op::upsample::zrep
} {
    input keep-pass

    uint n  Sampling factor, range 2...

    # %% TODO %% specify implementation
}

## # # ## ### ##### ######## ############# #####################
return
