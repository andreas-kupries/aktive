## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Application of lookup tables
#
## Notes
#
# Two types of LUTs are supported.
#
# 1. Indexed LUT. Single-row, multiple columns, multiple bands.  Each band applies to the
#    corresponding band of the input.  Not enough LUT bands replicated the last LUT band
#    to match.
#
#    The LUT columns contain the Y-values to map the X-values to.  The X-values are whole
#    numbers and index into the LUT column.
#
#    Image pixels are quantized by the LUT width to determine the the column to pull the Y
#    from. Pixels are assumed in [0..1].  Indices < 0 or > width(LUT) are clamped to
#    these.
#
#    In an extended mode the fractional part of the quantized pixel is used to interpolate
#    linearly between the Y-values of the regular index and the next.
#
# 2. XY LUT. The LUT is single-band, has at least two rows.
#    First row (index 0) contains X values.
#    The other rows contains corresponding Y-values.
#    Each additional row is essentially a band for the image to map.
#
#    Pixel values are searched in the LUT to find the nearest X-values bracketing it.
#    The corresponding Y-values are linearly interpolated.
#
##   Piecewise linear map --  CRIMP
##   $HOME/Development/1.Development/AKTIVE/crimp-scratch/map/
#
# Note: Histograms are indexed LUTs.
#       The same is true for (scaled) cumulative sums derived from histograms.
#       <<global histogram equalization>> is a LUT mapping through the global histogram's
#       cumulative sum scaled to end in 1.0.
#
## TODO :: LUT composition - Z(x) = B(A(x)) - Z = B . A
##         This is LUT mapping! B is the LUT, A the input.
##         set Z [op lut indexed B A]

# Mapping through csum(hist) is "histogram equalization".
# Histogram matching is mapping through CSH and inverse CSH.

# # ## ### ##### ######## ############# #####################

operator {
    op::lut::from
} {
    section transform lookup indexed

    note Create a single-band, single-row indexed LUT from values

    double... values LUT values

    body {
	aktive image from row height 1 values {*}$values
    }
}

operator {
    op::lut::compose
} {
    section transform lookup indexed

    input a	LUT A to compose
    input b	LUT B to compose

    note Returns the composition `A*B` of the two indexed LUTs A and B. \
	This composition is defined as `(A*B) (src) == A (B (src))`.

    note Internally this is computed as applying LUT A to input B, i.e. `A (B)`.

    # This is a wrapper of convenience around `indexed` to self-document the different
    # meaning at call-sites.
    #
    # The composed LUT is created by indexing B through A.

    body {
	indexed $a $b
    }
}

operator {
    op::lut::indexed
} {
    section transform lookup indexed

    input lut	The LUT to apply. Materialized at construction time.
    input src	The image to apply the LUT to.

    note Returns the result of mapping the input through the LUT.

    strict 1st The LUT is materialized and cached.

    note The location of the LUT image is ignored.

    note The LUT has to be single-row, with multiple columns and bands.

    note Each LUT band is applied to the corresponding image band. \
	The LUT's last band is replicated if the LUT has less bands than the image. \
	Excess LUT bands are ignored.

    note Input pixels are expected to be in the range `0..1`. \
	Values outside of that range are clamped to these (saturated math). \
	The LUT width is used to quantize the clamped values into integer \
	indices suitable for the LUT. The so-addressed LUT value becomes \
	the value for that pixel of the result.

    note In interpolation mode (default: off) the fractional part of the input \
	pixel is used to linearly interpolate between the values at the LUT index \
	and the next index to determine the result.

    note The difference between this operator and "<!xref: aktive op lut indexed-core>" \
	is the handling of a LUT with less bands than the input. Here the LUT is \
	extended by replicating the last band. The core op throwns an error instead.

    bool? false interpolate	Flag to activate interpolation mode.

    body {
	set ld [aktive query depth $lut]
	set id [aktive query depth $src]
	if {$ld < $id} {
	    set lut [aktive op embed band copy $lut down [expr {$id - $ld}]]
	}

	indexed-core $lut $src interpolate $interpolate
    }
}

operator {
    op::lut::indexed-core
} {
    section transform lookup indexed

    input lut	The LUT to apply. Materialized at construction time.
    input src	The image to apply the LUT to.

    note Returns the result of mapping the input through the LUT.

    strict 1st The LUT is materialized and cached.

    note The location of the LUT image is ignored.

    note The LUT has to be single-row, with multiple columns and bands.

    note Each LUT band is applied to the corresponding image band. \
	An error is thrown if the LUT has less bands than the image. \
	Excess LUT bands are ignored.

    note Input pixels are expected to be in the range `0..1`. \
	Values outside of that range are clamped to these (saturated math). \
	The LUT width is used to quantize the clamped values into integer \
	indices suitable for the LUT. The so-addressed LUT value becomes \
	the value for that pixel of the result.

    note In interpolation mode (default: off) the fractional part of the input \
	pixel is used to linearly interpolate between the values at the LUT index \
	and the next index to determine the result.

    note The difference between this operator and "<!xref: aktive op lut indexed>" \
	is the handling of a LUT with less bands than the input. Here an error \
	is thrown. The wrapper extends the LUT by replicating the last band instead.

    bool? false interpolate	Flag to activate value interpolation mode.

    state -fields {
	aktive_region lut;	   // region to hold materialized LUT
	double*       lpixel;	   // quick access to lut data
	aktive_uint   lcap;        // quick access to lut capacity/use
	aktive_uint   lwidth;	   // quick access to lut width
	aktive_uint   ldepth;	   // quick access to lut depth
    } -cleanup {
	aktive_region_destroy (state->lut);
	// lpixel goes away with the region.
    } -setup {
	aktive_image     lut = srcs->v[0];
	aktive_geometry* lg  = aktive_image_get_geometry (lut);
	aktive_geometry* ig  = aktive_image_get_geometry (srcs->v[1]);
	aktive_geometry_copy (domain, ig);

	if (lg->height > 1        ) aktive_fail  ("Too many rows in LUT, expected 1");
	if (lg->depth  < ig->depth) aktive_failf ("Not enough bands in LUT, exprected %u", ig->depth);

	// materialize LUT

	state->lut    = aktive_region_new (lut, 0);
	state->lwidth = lg->width;
	state->ldepth = lg->depth;

	aktive_rectangle_def_as(lrect,aktive_geometry_as_rectangle (lg));
	lrect.width     = lg->width;
	lrect.height    = lg->height;

	aktive_block* l = aktive_region_fetch_area_head (state->lut, &lrect);
	state->lpixel   = l->pixel;
	state->lcap     = l->used;
    }

    pixels {
	// cache the important values locally
	aktive_uint lwidth   = istate->lwidth;		TRACE ("lwidth %u", lwidth );
	aktive_uint ldepth   = istate->ldepth;		TRACE ("ldepth %u", ldepth );
	aktive_uint lcap     = istate->lcap;		TRACE ("lcap   %u", lcap   );
	double*     lpixel   = istate->lpixel;

	// compute and fetch input region needed for calculating the request data

	aktive_rectangle_def_as (subrequest, request);
	TRACE_RECTANGLE_M("lookup", &subrequest);
	aktive_block* src = aktive_region_fetch_area (1, &subrequest);

	// do the calculation

	aktive_lut_config lut = {
	    .pixel = lpixel,
	    .width = lwidth,
	    .depth = ldepth,
	    .cap   = lcap
	};

	aktive_blit_unarygz (block, dst,
			     param->interpolate
			     ? AKTIVE_LUT_INDEX_LINEAR
			     : AKTIVE_LUT_INDEX,
			     &lut, src);

	TRACE_DO (__aktive_block_dump ("@@thing@@ lookup out", block));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
