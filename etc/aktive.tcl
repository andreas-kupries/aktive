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
import generator/virtual/pattern/kernels.tcl
import generator/virtual/pattern/selements.tcl
import generator/virtual/pattern/sines.tcl
import generator/virtual/pattern/zone.tcl

import transformer/convolve.tcl
import transformer/effects.tcl
import transformer/geometry.tcl
import transformer/identity.tcl
import transformer/kuwahara.tcl
import transformer/location.tcl
import transformer/meta.tcl
import transformer/morphology.tcl
import transformer/recombine.tcl
import transformer/viewport.tcl

# Helper for color transform chain reductions
proc cc-reduce {from to} {
    simplify \
	for src/type op::color::${to}::to::${from} \
	returns src/child

    cc-meta $from $to
}

# See also aktive::op::color::CC (op/color.tcl) for Tcl-level equivalent
proc cc-meta {from to} {
    def check-input-colorspace {
	if (!aktive_colorspace (srcs->v[0], "%%%")) aktive_fail ("rejecting input not in colorspace %%%");
    } %%% $from

    def set-result-colorspace {
	aktive_meta_inherit    (meta, srcs->v[0]);
	aktive_meta_set_string (meta, "colorspace", "%%%");
    } %%% $to
}

import transformer/color/hsl-srgb.tcl
import transformer/color/hsv-srgb.tcl
import transformer/color/lab-lch.tcl
import transformer/color/scrgb-xyz.tcl
import transformer/color/srgb-scrgb.tcl
import transformer/color/xyz-lab.tcl
import transformer/color/xyz-yxy.tcl
import transformer/color/non-core.tcl
import transformer/color/recast.tcl

rename cc-reduce {}
rename cc-meta   {}

import transformer/math/binary.tcl
import transformer/math/unary.tcl

import transformer/math/complex/binary.tcl
import transformer/math/complex/reduce.tcl
import transformer/math/complex/unary.tcl

import transformer/statistics/by-bands.tcl
import transformer/statistics/by-columns.tcl
import transformer/statistics/by-rows.tcl
import transformer/statistics/by-tiles.tcl
import transformer/statistics/cumulation.tcl
import transformer/statistics/histogram.tcl
import transformer/statistics/rank-order.tcl

import transformer/structure/align.tcl
import transformer/structure/crop.tcl
import transformer/structure/flip.tcl
import transformer/structure/rotate.tcl
import transformer/structure/select.tcl
import transformer/structure/split.tcl
import transformer/structure/swap.tcl
import transformer/structure/scrolling.tcl
import transformer/structure/take.tcl
import transformer/structure/transpose.tcl

import transformer/structure/embed/bg.tcl
import transformer/structure/embed/black.tcl
import transformer/structure/embed/copy.tcl
import transformer/structure/embed/mirror.tcl
import transformer/structure/embed/tile.tcl
import transformer/structure/embed/white.tcl

import transformer/structure/resample/decimate.tcl
import transformer/structure/resample/fill.tcl
import transformer/structure/resample/interpolate.tcl
import transformer/structure/resample/replicated.tcl
import transformer/structure/resample/sub.tcl

import transformer/thresholds/mask.tcl
import transformer/thresholds/thresholds.tcl

import composer/montage.tcl

import sink/aktive.tcl		;# AKTIVE raw format
import sink/astcl.tcl		;# Tcl representation
import sink/netpbm.tcl		;# NETPBM basics (PGM, PPM)
import sink/null.tcl		;# NULL writer (debug, perf measure)
#
import sink/statistics.tcl	;# Compute various image statistics
#                                  See also `transformer/statistics/by-*`
#                                  for the variants calculating them
#                                  per row, column, or band

import accessor/attributes.tcl
import accessor/colorspace.tcl
import accessor/thresholds.tcl

# # ## ### ##### ######## ############# #####################
## Descriptions of commands implemented outside of the DSL

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

    note Return number of processor cores available for concurrent operation.
}

# # ## ### ##### ######## ############# #####################
::return
