## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Composer -- Joinining two or more images in some form

# # ## ### ##### ######## ############# #####################
## Merge images along one of the coordinate axes

nyi operator {
    op::montage::x
    op::montage::y
    op::montage::z
} {
    input... keep-pass

    # %% TODO %% specify implementation
}

##
# # ## ### ##### ######## ############# #####################
::return

