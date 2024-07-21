## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Transpose / transverse

operator op::transpose  {
    section transform structure

    example \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]} \
	@1

    note Returns image with the input mirrored along the primary diagonal.

    note This is an alias of `swap xy`.

    input

    body {
	swap xy $src
    }
}

operator op::transverse {
    section transform structure

    example \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]} \
	@1

    note Returns image with the input mirrored along the secondary diagonal.

    input

    body {
	flip x [flip y [swap xy $src]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
