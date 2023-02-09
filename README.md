
AKTIVE, Andreas Kupries's Tcl Image Vector Extension is yet another attempt at creating an image
processing package for Tcl, starting with CRIMP (Critcl IMage Processor).

At the current stage in its life it is mainly a big experiment in code generation, both Tcl and C.

The internals are somewhat inspired by VIPS. While multi-threaded operation is planned for, nothing
is done yet on that front (except to properly segment passive and active image structures)
