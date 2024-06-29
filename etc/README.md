# Operator specifications

This directory contains the operator specifications written in AKTIVE's custom DSL.

  - [Operator reference](/doc/trunk/doc/ref/index.md)

## Files

  - The file `runtime.tcl` declares a basic set of types using operators.

  - The file `aktive.tcl` provides the operators of the `aktive` package. It uses the basic runtime
    types, declares a few more, and then aggregates the operator specs from the various directories.

  - The file `aktive_tk.tcl` provides the operators of the `aktive::tk` package.

## Directories

| Path          | Operators |
|---            |---      |
| `accessor`	| Take images and return non-image data, like base attributes, or statistics |
| `composer`	| Take multiple images and merge them into a single new image |
| `generator`	| Taking parameters at most and returning an image generated from them |
| `other`	| Non-image actions. Point and rectangle functions only at the moment |
| `runtime`	| Common blitter specifications |
| `sink`	| Take a single image and return nothing, the side effect is important (saving to file, f.e.) |
| `transformer`	| Transforming one or more images into a new image, structurally, or value-wise |
