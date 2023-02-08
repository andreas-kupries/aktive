## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Location changes

# # ## ### ##### ######## ############# #####################

nyi operator op::translate::to {
    input keep-pass-ignore

    int x  New absolute x location of image in the plane
    int y  New absolute y location of image in the plane

    # %% TODO %% specify implementation
}

nyi operator op::translate::by {
    input keep-pass-ignore

    int dx  Shift for x location of image in the plane
    int dy  Shift for y location of image in the plane

    # %% TODO %% specify implementation
}

##
# # ## ### ##### ######## ############# #####################
::return
