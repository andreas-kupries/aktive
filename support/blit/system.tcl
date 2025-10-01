# -*- mode: tcl ; fill-column: 90 -*-
## blitter - error generation

# # ## ### ##### ######## #############

namespace eval ::dsl::blit::system {
    namespace export abort
}

# # ## ### ##### ######## #############

proc ::dsl::blit::system::abort {message} { return -code error $message }

# # ## ### ##### ######## #############
return
