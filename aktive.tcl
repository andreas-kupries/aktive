# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2022-2024 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
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

critcl::userconfig define benchmarks {} bool 0

# # ## ### ##### ######## ############# #####################
## Implementation.

set benchmarking [critcl::userconfig query benchmarks]

## critcl::tcl 8.6 ##

#::critcl::debug symbols
#::critcl::debug symbols memory
#::critcl::config trace on
#::critcl::config lines off

package require critcl::cutil 0.5 ;# TRACE_THREAD_EXIT

# critcl::config keepsrc 1

critcl::cutil::assertions on
critcl::cutil::tracer     off
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

critcl::msg "[dsl::reader::blue Benchmarking]: [dsl::reader::magenta [dict get {
  0 No
  1 YES
} $benchmarking]]"

# scan for markers the documentation can then reference.
dsl xref scan \
    /into doc/ref/xmark.tcl \
    /from etc runtime

# translate the operator specifications
dsl generate runtime etc/runtime.tcl rtgen
dsl generate aktive  etc/aktive.tcl  generated doc/ref

# scan structure definitions for developer documentation and extract them
dsl structs scan \
    /into doc/dev/figures/generated \
    /from runtime op rtgen generated

# render the main figures, these include the generated definitions as needed
dsl structs render doc/dev/figures

# # ## ### ##### ######## ############# #####################
## color database

source data/css-named-colors.tcl	;# emits (x) `generated/color.tcl`

# # ## ### ##### ######## ############# #####################
## definitions for math vector functions

source data/math-gen.tcl	;# emits (xx) `generated/vector_direct.[ch]`

# # ## ### ##### ######## ############# #####################

critcl::source etc/runtime/blitter.tcl
critcl::source etc/sink/statistics-c.tcl

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
critcl::csources op/*.c
critcl::csources generated/vector_direct.c	;# Vector support: Scalar loops

# Types ## ##### ######## ############# #####################

critcl::source  op/types.tcl                    ;# Operator support
critcl::include generated/vector-types.h        ;# Variadic support
critcl::include generated/param-types.h         ;# Parameter blocks

# Function declarations # ############# #####################

critcl::include generated/vector-funcs.h        ;# Variadic support
critcl::include generated/param-funcs.h         ;# Parameter block variadic init/finish
critcl::include generated/type-funcs.h          ;# Type conversions
critcl::include generated/op-funcs.h            ;# Operators
critcl::include generated/vector_direct.h       ;# Vector support

# Variables #### ######## ############# #####################

critcl::include generated/param-descriptors.c   ;# Parameter block descriptors

# Function implementations ############ #####################

critcl::include op/aktive.h
critcl::include op/amath.h
critcl::include op/astcl.h
critcl::include op/cconn.h
critcl::include op/color.h
critcl::include op/convolve.h
critcl::include op/cprofile.h
critcl::include op/csum.h
critcl::include op/lut.h
critcl::include op/memory.h
critcl::include op/netpbm.h
critcl::include op/null.h
critcl::include op/otsu.h
critcl::include op/profile.h
critcl::include op/reduce.h
critcl::include op/sdf.h
critcl::include op/whitepoint.h

critcl::source  op/math.tcl                     ;# Extended math function support
critcl::include generated/vector-funcs.c        ;# Variadic support
critcl::include generated/param-funcs.c         ;# Parameter block variadic init/finish
critcl::include generated/type-funcs.c          ;# Type conversions
critcl::include generated/op-funcs.c            ;# Operators

# # ## ### ##### ######## ############# #####################
## Meta data operations - Not operators, positional parameters

critcl::source   op/meta.tcl	;# meta data core set
critcl::tsources meta.tcl	;# meta data dict wrapper

# # ## ### ##### ######## ############# #####################
## Benchmarking support code & commands.
## Used if only if the package is built for benchmarking.

if {$benchmarking} { critcl::source bench.tcl }

# # ## ### ##### ######## ############# #####################
## Versioning information and exposure, processor count set/get

critcl::cconst aktive::version char* {"0.0"}

critcl::cproc aktive::processors {
    int {n 0}
} aktive_uint {
    if (has_n) aktive_set_processors (n);
    return aktive_processors ();
}

# # ## ### ##### ######## ############# #####################
## Assemble Tcl level interface

critcl::source   generated/glue.tcl             ;# Tcl-level operator construction
#
critcl::tsources generated/overlay.tcl		;# Peep-hole optimizer overlays
critcl::tsources generated/ensemble.tcl         ;# Command hierarchy for preceding
critcl::tsources generated/color.tcl            ;# Color database commands - (x) `data/css-named-colors.tcl`
#                                               ;# Pure Tcl commands
critcl::tsources generated/ops.tcl              ;# - Operators built in Tcl
critcl::tsources simplifier.tcl			;# - Simplifier runtime used by overlay.tcl
critcl::tsources parameters.tcl			;# - Parameter runtime used by overlay.tcl
critcl::tsources error.tcl			;# - Error helper
critcl::tsources op/2string.tcl			;# Support for "write to string|file".
critcl::tsources op/aggregate.tcl		;# Support for aggregation by binary reduction
critcl::tsources op/asother.tcl			;# DAG conversion support (walker, emitters)
critcl::tsources op/embed.tcl			;# `embed` argument validation
critcl::tsources op/color.tcl			;# color conversion support (sRGB <-> scRGB)
critcl::tsources op/transform.tcl		;# transform matrix support

critcl::csources op/math.c

# # ## ### ##### ######## ############# #####################

package provide aktive 0.0

# # ## ### ##### ######## ############# #####################
## Build binaries now, without deferal.

if {![critcl::load]} {
    error "Building and loading aktive failed."
}

# Write the scripts stashed by the DSL writer into a file for
# post-installation execution
# - documentation examples
dsl::writer::stash-to examples.tcl

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
