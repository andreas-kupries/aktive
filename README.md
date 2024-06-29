
`AKTIVE`, Andreas Kupries's Tcl Image Vector Extension is yet another attempt
at creating an image processing package for Tcl, which started out with the
`CRIMP` (CRItcl IMage Processor).

This here started as an experiment in massive code generation, both Tcl and C,
converting operator specifications written in a custom DSL into a functional
Tcl extension.

This experiment looks to be a success and worthy of continuing.

At the moment the sources are split, after code generation, into

  - 2% DSL implementation/converter (Tcl),
  - 8% runtime (C),
  - 13% operator specifications (Tcl DSL), and
  - 77% generated code (C).

implementing a few hundred operators in 6 major sections.

For the full details please read the [operator reference](/doc/trunk/doc/index.md).

The internals are somewhat inspired by VIPS.

In the sense that AKTIVE's runtime enables the same thing that VIPS does, the
multi-threaded, concurrent handling of multiple input regions without having
to load the entirety of the inputs into memory.

The detailed structures are very different from VIPS however, for several reasons:

  - This is a Tcl extension, linked to and using Tcl API functions and structures.

  - No support for multiple integer types, etc. for pixel values. The only type
    used internally is __double__.
