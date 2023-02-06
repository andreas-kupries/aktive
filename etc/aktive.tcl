## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
##
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

import runtime.tcl

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

import point.tcl
import rectangle.tcl
import getter.tcl
import generator.tcl
import transformer.tcl
#import composer.tcl
import sink.tcl

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

## # # ## ### ##### ######## ############# #####################
# Generators ... The returned image is constructed from the parameters.

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

nyi operator {thing depth} {
    format::pgm::read pgm 1
    format::ppm::read ppm 3
} {
    take-channel src  Channel to read $thing image data from

    # state: maxval ? variant-dependent actual reader function ?
    # cons : reader image header (dimensions, variant) - choose reader ?

    state -fields {
	aktive_uint w;
	aktive_uint h;
    } -setup {
	// %% TODO %% // state :: PPM/PGM header
	aktive_geometry_set (domain, 0,0, state->w, state->h, @depth@);
    } @depth@ $depth

    pixels { /**/ }

    # %% TODO %% specify implementation - read image data - locked
}

## # # ## ### ##### ######## ############# #####################
# Transformers ... The returned image is constructed from the input image, and
# possibly some parameters.

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
