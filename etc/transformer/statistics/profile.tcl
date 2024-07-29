## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Profiles
#
## Compute the row/column-based left/top profile of the input image.  The profile returns
## an image whose pixel values contain the distance of the first pixel != 0 from left/top
## border of the row/column. This is best applied to b/w images with clean edges.
#
## While caching is technically not needed it does make both specification and
## implementation much simpler.

# # ## ### ##### ######## ############# #####################

operator {oaxis border okind} {
    op::row::profile    height left column
    op::column::profile width  top  row
} {
    op -> _ kind _

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 32 height 32 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 | -matrix -int
    }

    section transform statistics

    note Returns image with input ${kind}s transformed into a profile.
    note Where a profile contains, per $kind, the distance of the first pixel != 0
    note from the $border border of the input.

    note The result is a single-$okind image with $oaxis and depth of the input.

    cached $kind profile AKTIVE_PROFILE_FILL -rsize 1
}

##
# # ## ### ##### ######## ############# #####################
::return
