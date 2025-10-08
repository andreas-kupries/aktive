## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- DSL helpers for chain reductions and meta data

# Color transform chain reductions
proc cc-reduce {from to} {
    simplify \
	for src/type op::color::${to}::to::${from} \
	returns src/child

    cc-meta $from $to
}

# Meta data support. See also `aktive::op::color::CC` (`op/color.tcl`) for Tcl-level equivalent
proc cc-meta {from to} {
    def check-input-colorspace {
	if (!aktive_colorspace (srcs->v[0], "%%%")) aktive_fail ("rejecting input not in colorspace %%%");
    } %%% $from

    def set-result-colorspace {
	aktive_meta_inherit    (meta, srcs->v[0]);
	aktive_meta_set_string (meta, "colorspace", "%%%");
    } %%% $to
}

##
# # ## ### ##### ######## ############# #####################
::return
