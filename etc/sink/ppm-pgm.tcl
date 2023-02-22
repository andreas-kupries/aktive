## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- PPM, PGM format

nyi operator thing {
    format::pgm::write pgm
    format::ppm::write ppm
} {
    note Sink. Serializes image to $thing format, into channel

    input
    void

    channel                                dst     Channel the $thing image data is written to
    ${thing}_variant? aktive_${thing}_text variant The $thing format variant to generate

    # %% TODO %% specify implementation
}

##
# # ## ### ##### ######## ############# #####################
::return
