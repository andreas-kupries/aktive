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
import generator/virtual/gradient.tcl
import generator/virtual/grey.tcl
import generator/virtual/indexed.tcl
import generator/virtual/sparse.tcl

import generator/virtual/noise/gauss.tcl
import generator/virtual/noise/salt.tcl
import generator/virtual/noise/uniform.tcl

import generator/virtual/pattern/eye.tcl
import generator/virtual/pattern/sines.tcl
import generator/virtual/pattern/zone.tcl

import transformer/geometry.tcl
import transformer/identity.tcl
import transformer/location.tcl
import transformer/viewport.tcl

# Helper for color transform chain reductions
proc cc-reduce {from to} {
    simplify \
	for src/type op::color::${to}::to::${from} \
	returns src/child
}

import transformer/color/hsl-srgb.tcl
import transformer/color/hsv-srgb.tcl
import transformer/color/lab-lch.tcl
import transformer/color/scrgb-xyz.tcl
import transformer/color/srgb-scrgb.tcl
import transformer/color/xyz-lab.tcl
import transformer/color/xyz-yxy.tcl
import transformer/color/non-core.tcl

rename cc-reduce {}

import transformer/math/binary.tcl
import transformer/math/unary.tcl

import transformer/math/complex/binary.tcl
import transformer/math/complex/reduce.tcl
import transformer/math/complex/unary.tcl

import transformer/statistics/by-bands.tcl
import transformer/statistics/by-tiles.tcl
import transformer/statistics/by-columns.tcl
import transformer/statistics/by-rows.tcl

import transformer/structure/crop.tcl
import transformer/structure/flip.tcl
import transformer/structure/rotate.tcl
import transformer/structure/select.tcl
import transformer/structure/split.tcl
import transformer/structure/swap.tcl
import transformer/structure/transpose.tcl
import transformer/structure/wrap.tcl

import transformer/structure/embed/bg.tcl
import transformer/structure/embed/black.tcl
import transformer/structure/embed/copy.tcl
import transformer/structure/embed/mirror.tcl
import transformer/structure/embed/tile.tcl
import transformer/structure/embed/white.tcl

import transformer/structure/resample/down.tcl
import transformer/structure/resample/up-replicated.tcl
import transformer/structure/resample/up.tcl

import composer/montage.tcl

import sink/aktive.tcl		;# AKTIVE raw format
import sink/astcl.tcl		;# Tcl representation
import sink/netpbm.tcl		;# NETPBM basics (PGM, PPM)
import sink/null.tcl		;# NULL writer
#
import sink/statistics.tcl	;# Compute various image statistics
#                                  See also `transformer/statistics/by-*`
#                                  for the variants calculating them
#                                  per row, column, or band

import accessor/attributes.tcl

# # ## ### ##### ######## ############# #####################
## Unsorted

tcl-operator error {
    section miscellaneous

    note Throw error with message and error code.

    arguments m args
    body { return -code error -errorcode [linsert $args 0 AKTIVE ERROR] $m }
}

nyi operator op::geometry::reshape {
    input

    uint width   New width of the returned image
    uint height  New height of the returned image
    uint depth   New depth of the returned image

    # %% TODO %% specify implementation
}

# # ## ### ##### ######## ############# #####################
::return
