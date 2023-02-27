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
type object        -                  Tcl_Obj*    {*value}
type channel       -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
type take-channel  -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
#type pgm_variant   aktive_pgm_variant -           {aktive_pgm_variant_pool (interp, *value)}
#type ppm_variant   aktive_ppm_variant -           {aktive_ppm_variant_pool (interp, *value)}

vector int

# # ## ### ##### ######## ############# #####################

import other/point.tcl
import other/rectangle.tcl

import generator/reader/aktive.tcl
import generator/reader/netpbm.tcl

import generator/virtual/constant.tcl
import generator/virtual/eye.tcl
import generator/virtual/gradient.tcl
import generator/virtual/grey.tcl
import generator/virtual/indexed.tcl
import generator/virtual/random.tcl
import generator/virtual/sines.tcl
import generator/virtual/zone.tcl

import transformer/location.tcl
import transformer/viewport.tcl

import transformer/math/binary.tcl
import transformer/math/unary.tcl

import transformer/math/complex/binary.tcl
import transformer/math/complex/reduce.tcl
import transformer/math/complex/unary.tcl

import transformer/structure/combinations.tcl
import transformer/structure/flip.tcl
import transformer/structure/select.tcl
import transformer/structure/swap.tcl

import transformer/structure/resample/down.tcl
import transformer/structure/resample/up-replicated.tcl
import transformer/structure/resample/up.tcl

import composer/montage.tcl

import sink/astcl.tcl	;# Tcl representation
import sink/netpbm.tcl	;# NETPBM basics (PGM, PPM)
import sink/aktive.tcl	;# AKTIVE raw format

import accessor/attributes.tcl

# # ## ### ##### ######## ############# #####################
## Unsorted

tcl-operator error {m args} {
    return -code error -errorcode [linsert $args 0 AKTIVE ERROR] $m
}

nyi operator op::geometry::reshape {
    input

    uint width   New width of the returned image
    uint height  New height of the returned image
    uint depth   New depth of the returned image

    # %% TODO %% specify implementation
}

nyi operator {
    op::pixel::mul
} {
    # VIPS :: recomb - recombine

    # op::pixel::mul - vector matrix multiplication - vector is pixel, image depth long.
    #                  matrix is image, depth fixed 1, width equal to image depth, asserted
    #                  result image has depth equal to matrix height
    #
    # example: color conversions.

    input
    input

    # %% TODO %% specify implementation
}


# # ## ### ##### ######## ############# #####################
::return
