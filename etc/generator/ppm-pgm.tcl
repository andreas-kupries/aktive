## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Reading from somewhere

# # ## ### ##### ######## ############# #####################
## PPM, PGM format

nyi operator {thing depth} {
    format::pgm::read pgm 1
    format::ppm::read ppm 3
} {
    take-channel src  Channel to read $thing image data from

    # state: maxval ? variant-dependent actual reader function ?
    # cons : reader image header (dimensions, variant) - choose reader ?

    state -fields {
	aktive_uint w;
	aktive_uint h;
    } -setup {
	// %% TODO %% // state :: PPM/PGM header
	aktive_geometry_set (domain, 0,0, state->w, state->h, @depth@);
    } @depth@ $depth

    pixels { /**/ }

    # %% TODO %% specify implementation - read image data - locked
}

##
# # ## ### ##### ######## ############# #####################
::return
