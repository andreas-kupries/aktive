# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2022,2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#

# # ## ### ##### ######## #############
## Requisites

package require critcl 3.1 ;# 3.1   : critcl::source
#                          ;# 3.0.8 : critcl::at::*
package require critcl::enum

# # ## ### ##### ######## #############
## Bail early if the environment is not suitable.

if {![critcl::compiling]} {
    error "Unable to build aktive, no proper compiler found."
}

# # ## ### ##### ######## #############
## Administrivia

critcl::license \
    {Andreas Kupries} \
    {BSD licensed}

critcl::summary \
    {Core data structures and functionality of project AKTIVE}

critcl::description {
    This package is the foundation for all other packages of project AKTIVE.

    At the C-level it provides the core data structures, functions, and macros for images,
    streams, and geometries, and their type definitions.

    These are reflected in the Tcl level API as well, via the fundamental accessors and
    basic image conversions from and to Tcl data structures (nested lists).
}

critcl::subject image {image type} {image accessors} {image construction}
critcl::subject {image transformation} {data structures} {image io}
critcl::subject {image reading} {image writing} {image composition}
critcl::subject {vector operations} {matrix operations}

# # ## ### ##### ######## #############
## Implementation.

critcl::tcl 8.6

::critcl::debug symbols memory
#::critcl::config trace on
#::critcl::config lines off

package require critcl::cutil
critcl::cutil::assertions on
critcl::cutil::tracer     on
critcl::cutil::alloc

critcl::ccode {
    TRACE_OFF;
}

# # ## ### ##### ######## #############
## Meta level
## - Generate operator code from high-level spec.
#
##   NOTE: The generated code is written to files instead of directly injected
##   into critcl state.
#
##   This makes debugging the generator easier, as its results can be directly
##   inspected

critcl::source support/dsl.tcl
dsl generate etc/aktive.tcl generated/

# # ## ### ##### ######## #############
## Ingest fixed and generated C code.

# %% TODO %%

# # ## ### ##### ######## #############
## Assemble Tcl level interface

# %% TODO %%

# # ## ### ##### ######## #############
## Ready the C pieces. Build binaries now, without deferal.

if {![critcl::load]} {
    error "Building and loading aktive failed."
}

# # ## ### ##### ######## #############
## Versioning information and exposure

critcl::cconst  aktive::version char* {"0.0"}
package provide aktive 0.0
return

# - -- --- ----- -------- -------------
# vim: set sts=4 sw=4 tw=80 et ft=tcl:
#
# Local Variables:
# mode: tcl
# fill-column: 78
# End:
#
