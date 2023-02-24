# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2022,2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#

# # ## ### ##### ######## ############# #####################
## Requisites

package require critcl 3.1 ;# 3.1   : critcl::source
#                          ;# 3.0.8 : critcl::at::*
package require critcl::enum

# # ## ### ##### ######## ############# #####################
## Bail early if the environment is not suitable.

if {![critcl::compiling]} {
    error "Unable to build aktive, no proper compiler found."
}

# # ## ### ##### ######## ############# #####################
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

# # ## ### ##### ######## ############# #####################
## Implementation.

critcl::tcl 8.6

::critcl::debug symbols memory
#::critcl::config trace on
#::critcl::config lines off

package require critcl::cutil

critcl::config keepsrc

critcl::cutil::assertions on
critcl::cutil::tracer     on
critcl::cutil::alloc

critcl::ccode {
    TRACE_OFF;
}

# # ## ### ##### ######## ############# #####################
## Meta level
## - Generate operator code from high-level spec.
#
##   NOTE: The generated code is written to files instead of directly injected
##   into critcl state.
#
##   This makes debugging the generator easier, as its results can be directly
##   inspected

critcl::source support/dsl.tcl

dsl generate runtime etc/runtime.tcl rtgen/
dsl generate aktive  etc/aktive.tcl  generated/

critcl::source etc/runtime/blitter.tcl

# # ## ### ##### ######## ############# #####################
## Core Runtime

critcl::source   runtime/critcl-types.tcl
critcl::cheaders runtime
critcl::cheaders runtime/*.h
critcl::csources runtime/*.c

##
# # ## ### ##### ######## ############# #####################
# Base operator set - Generated

critcl::include  runtime/rt.h
critcl::cheaders op/*.h

# Types    ##### ######## ############# #####################

critcl::source  op/types.tcl                    ;# Operator support
critcl::include generated/vector-types.h        ;# Variadic support
critcl::include generated/param-types.h         ;# Parameter blocks

# Function declarations # ############# #####################

critcl::include generated/vector-funcs.h        ;# Variadic support
critcl::include generated/param-funcs.h         ;# Parameter block variadic init/finish
critcl::include generated/type-funcs.h          ;# Type conversions
critcl::include generated/op-funcs.h            ;# Operators

# Variables #### ######## ############# #####################

critcl::include generated/param-descriptors.c   ;# Parameter block descriptors

# Function implementations ############ #####################

critcl::include op/op.c                         ;# Operator support
critcl::include op/netpbm.c                     ;# Operator support
critcl::source  op/math.tcl                     ;# Extended math function support
critcl::include generated/vector-funcs.c        ;# Variadic support
critcl::include generated/param-funcs.c         ;# Parameter block variadic init/finish
critcl::include generated/type-funcs.c          ;# Type conversions
critcl::include generated/op-funcs.c            ;# Operators

# # ## ### ##### ######## ############# #####################
## Assemble Tcl level interface

critcl::source   generated/glue.tcl             ;# Tcl-level operator construction
critcl::tsources generated/overlay.tcl		;# Peep-hole optimizer overlays
critcl::tsources generated/ensemble.tcl         ;# Command hierarchy for preceding
#                                               ;# Pure Tcl commands
critcl::tsources generated/ops.tcl              ;# - Operators built in Tcl
critcl::tsources version.tcl			;# - Version info command
critcl::tsources simplifier.tcl			;# - Simplifier runtime used by overlay.tcl

# # ## ### ##### ######## ############# #####################
## Build binaries now, without deferal.

if {![critcl::load]} {
    error "Building and loading aktive failed."
}

# # ## ### ##### ######## ############# #####################
## Versioning information and exposure

critcl::cconst  aktive::version char* {"0.0"}
package provide aktive 0.0

# # ## ### ##### ######## ############# #####################
return

# - -- --- ----- -------- -------------
# vim: set sts=4 sw=4 tw=80 et ft=tcl:
#
# Local Variables:
# mode: tcl
# fill-column: 78
# End:
#
