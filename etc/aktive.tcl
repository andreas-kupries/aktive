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
# __ id __________ critcl ___________ C type ____ Conversion _________________________________________ Init ___________ Finish _________
type bool          boolean            int         {Tcl_NewIntObj (*value)}
type int           -                  -           {Tcl_NewIntObj (*value)}
type wide          wideint            Tcl_WideInt {Tcl_NewWideIntObj (*value)}
type object0       -                  Tcl_Obj*    {*value}                                             Tcl_IncrRefCount Tcl_DecrRefCount
type object        -                  Tcl_Obj*    {*value}                                             Tcl_IncrRefCount Tcl_DecrRefCount
type channel       -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
type take-channel  -                  Tcl_Channel {Tcl_NewStringObj (Tcl_GetChannelName (*value), -1)}
#type pgm_variant   aktive_pgm_variant -           {aktive_pgm_variant_pool (interp, *value)}
#type ppm_variant   aktive_ppm_variant -           {aktive_ppm_variant_pool (interp, *value)}

vector int

# # ## ### ##### ######## ############# #####################

import other/point.tcl
import other/rectangle.tcl
import other/color.tcl

set supported {}
import generator/reader/aktive.tcl
import generator/reader/netpbm.tcl
import generator/reader/reader.tcl	;# always last - required for proper auto-detection supported formats
#                                       ;# collected by the preceding files.
unset supported

import generator/virtual/constant.tcl
import generator/virtual/gradient.tcl
import generator/virtual/grey.tcl
import generator/virtual/indexed.tcl
import generator/virtual/sparse.tcl

import generator/virtual/warp.tcl
import generator/virtual/warp/matrix.tcl
import generator/virtual/warp/noise.tcl
import generator/virtual/warp/polar-cart.tcl
import generator/virtual/warp/swirl.tcl
import generator/virtual/warp/wobble.tcl

import generator/virtual/sdf/support.tcl
import generator/virtual/sdf/definitions.tcl
import generator/virtual/sdf.tcl
import generator/virtual/draw.tcl

import generator/virtual/noise/gauss.tcl
import generator/virtual/noise/salt.tcl
import generator/virtual/noise/uniform.tcl

import generator/virtual/pattern/checkers.tcl
import generator/virtual/pattern/eye.tcl
import generator/virtual/pattern/kernels.tcl
import generator/virtual/pattern/palette.tcl
import generator/virtual/pattern/selements.tcl
import generator/virtual/pattern/sines.tcl
import generator/virtual/pattern/zone.tcl

import transformer/cache.tcl
import transformer/cc.tcl
import transformer/identity.tcl
import transformer/location.tcl
import transformer/meta.tcl
import transformer/viewport.tcl

import transformer/filter/convolve.tcl
import transformer/filter/effects.tcl
import transformer/filter/equalization.tcl
import transformer/filter/kuwahara.tcl
import transformer/filter/lookup.tcl
import transformer/filter/morphology.tcl
import transformer/filter/recombine.tcl
import transformer/filter/wiener.tcl

import transformer/color/dsl-helpers.tcl
#
import transformer/color/hsl-srgb.tcl
import transformer/color/hsv-srgb.tcl
import transformer/color/lab-lch.tcl
import transformer/color/scrgb-xyz.tcl
import transformer/color/srgb-gray.tcl
import transformer/color/srgb-scrgb.tcl
import transformer/color/xyz-lab.tcl
import transformer/color/xyz-yxy.tcl
#
import transformer/color/non-core.tcl
import transformer/color/recast.tcl
#
rename cc-reduce {}
rename cc-meta   {}

import transformer/math/binary.tcl
import transformer/math/unary.tcl
import transformer/math/other.tcl

import transformer/math/complex/binary.tcl
import transformer/math/complex/reduce.tcl
import transformer/math/complex/unary.tcl

import transformer/statistics/by-bands.tcl
import transformer/statistics/by-columns.tcl
import transformer/statistics/by-rows.tcl
import transformer/statistics/by-tiles.tcl
import transformer/statistics/cumulation.tcl
import transformer/statistics/histogram.tcl
import transformer/statistics/otsu.tcl
import transformer/statistics/rank-order.tcl

import transformer/structure/align.tcl
import transformer/structure/band-geometry.tcl
import transformer/structure/crop.tcl
import transformer/structure/flip.tcl
import transformer/structure/resize.tcl
import transformer/structure/rotate.tcl
import transformer/structure/scrolling.tcl
import transformer/structure/select.tcl
import transformer/structure/split.tcl
import transformer/structure/swap.tcl
import transformer/structure/take.tcl
import transformer/structure/transform.tcl
import transformer/structure/transpose.tcl
import transformer/structure/warp.tcl

import transformer/structure/embed/bg.tcl
import transformer/structure/embed/black.tcl
import transformer/structure/embed/copy.tcl
import transformer/structure/embed/mirror.tcl
import transformer/structure/embed/tile.tcl
import transformer/structure/embed/white.tcl

import transformer/structure/embed/band/black.tcl
import transformer/structure/embed/band/copy.tcl

import transformer/structure/resample/decimate.tcl
import transformer/structure/resample/fill.tcl
import transformer/structure/resample/interpolate.tcl
import transformer/structure/resample/replicated.tcl
import transformer/structure/resample/sub.tcl

import transformer/thresholds/mask.tcl
import transformer/thresholds/thresholds.tcl

import composer/montage.tcl

import sink/aktive.tcl		;# AKTIVE raw format
import sink/asother.tcl		;# Other representations, without materialization
import sink/astcl.tcl		;# Tcl representation, materialization
import sink/netpbm.tcl		;# NETPBM basics (PGM, PPM)
import sink/null.tcl		;# NULL writer (debug, perf measure)
#
import sink/statistics.tcl	;# Compute various image statistics
#                                  See also `transformer/statistics/by-*`
#                                  for the variants calculating them
#                                  per row, column, or band
import sink/compare.tcl		;# Compute various image difference
#                                  metrics for comparisons

import accessor/attributes.tcl
import accessor/cc.tcl
import accessor/colorspace.tcl
import accessor/thresholds.tcl

# # ## ### ##### ######## ############# #####################
## Descriptions of commands implemented outside of the DSL, yet integrated into the
## operator hierarchy and associated things (documentation).

operator error {
    section miscellaneous
    external!

    note Throw error with message and error code.

    str    m	Human readable error message
    str... args	Trappable error code suffix
}

operator version {
    section miscellaneous
    external!

    note Return package version number.
}

operator processors {
    section miscellaneous
    external!

    int? 0 n Set number of processor available for concurrent operation.

    note Set/Return number of processor cores available for concurrent operation.

    note Setting the default, `0`, causes the system to query the OS for the number \
	of available processors and use the result. Anything else limits concurrency \
	to the defined count. __Beware__ overcommit is possible, if more processors \
	are declared for use than actually exist.
}

# # ## ### ##### ######## ############# #####################
## Hook for experimental code, generally not present.

import? experimental.tcl

# # ## ### ##### ######## ############# #####################
::return
