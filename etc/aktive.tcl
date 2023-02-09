## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
##
# Operators take zero or more images, zero or more parameters, and return either a single
# new image, some non-image value, or nothing. We have
#
# - Generators:   No inputs, one or more parameters, image result
# - Transformers: One input, zero or more parameters, image result
# - Compositors:  Two or more inputs, zero or more parameters, image result
# - Sinks:        One input, zero or more parameters, no result (usually)
# - Accessors:    One input, no parameters, non-image result
#
# Note: While pixel values are generally something in the range [0..1] this is only
#       relevant when converting an image to and/or from some external image format.

# # ## ### ##### ######## ############# #####################
## Types for parameters and results.
#
## Note: Dynamic vector structures match critcl variadics.

import runtime.tcl

## II. Operator support
# __ id __________ critcl ___________ C type ____ Conversion ______________________________
type bool          boolean            int         {Tcl_NewIntObj (*value)}
type int           -                  -           {Tcl_NewIntObj (*value)}
type wide          wideint            Tcl_WideInt {Tcl_NewWideIntObj (*value)}
type object0       -                  Tcl_Obj*    {*value}
type channel       -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
type take-channel  -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
type pgm_variant   aktive_pgm_variant -           {aktive_pgm_variant_pool (interp, *value)}
type ppm_variant   aktive_ppm_variant -           {aktive_ppm_variant_pool (interp, *value)}

# # ## ### ##### ######## ############# #####################

import other/point.tcl
import other/rectangle.tcl

import generator/constant.tcl
import generator/ppm-pgm.tcl
import generator/random.tcl

import transformer/location.tcl
import transformer/math-binary.tcl
import transformer/math-complex.tcl
import transformer/math-unary.tcl
import transformer/structure.tcl
import transformer/viewport.tcl

import composer/montage.tcl

import sink/astcl.tcl
import sink/ppm-pgm.tcl

import accessor/attributes.tcl

# # ## ### ##### ######## ############# #####################
## Unsorted

nyi operator op::geometry::reshape {
    input keep-pass-ignore

    uint width   New width of the returned image
    uint height  New height of the returned image
    uint depth   New depth of the returned image

    # %% TODO %% specify implementation
}

nyi operator {
    op::pixel::mul
} {
    # op::pixel::mul - vector matrix multiplication - vector is pixel, image depth long.
    #                  matrix is image, depth fixed 1, width equal to image depth, asserted
    #                  result image has depth equal to matrix height
    #
    # example: color conversions.

    input keep
    input keep

    # %% TODO %% specify implementation
}


# # ## ### ##### ######## ############# #####################
::return
