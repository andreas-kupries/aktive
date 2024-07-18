
||||
|---|---|---|
|Project|[Documentation](doc/index.md)|[Developer Index](doc/dev/index.md)|

<a href='doc/logo.md'><img src='doc/assets/aktive-logo-128.png'
     style='border-right:20px solid white;
            border-bottom:280px solid white;
	    float:left;'></a>

# Welcome

Welcome to `AKTIVE`, Andreas Kupries's Tcl Image Vector Extension.

It is yet another attempt at creating an image processing package for Tcl, which started out with
the `CRIMP` (CRItcl IMage Processor).

While it only started as an experiment in massive code generation, it was successful and now
continued normally.

Operator specifications written in a custom Tcl-based DSL are converted into Tcl and C code working
on top of a small fixed runtime, making the combination a functional Tcl extension.

# State

The extension currently implements a few hundred operators in 7 major sections.
For the full details please read the [operator reference](/doc/trunk/doc/ref/index.md).

Last time it was checked the sources (after code generation) were split into

  - 2% DSL implementation/converter (Tcl),
  - 8% runtime (C),
  - 13% operator specifications (Tcl DSL), and
  - 77% generated code (C).
