
||||
|---|---|---|
|[Project ↗](../../README.md)|[Documentation](../index.md)|Developer Index|

<img src='../assets/aktive-logo-128.png' style='float:right;'>

# Documentation

AKTIVE's developer documentation explains the internals of the package, especially its operator
specification DSL and templating system.

  - [Code generated from the operator specifications](generated-code.md)
  - Image Pipelines:
      - [Definition structures](definitions.md)
      - [Runtime structures](runtime.md)
      - [Definition and Runtime structures together](defrun.md)
  - [Batch Processor](batch.md) - AKTIVE's foundation for horizontal threading.
  - [Connected Components](cc.md)

The internals are somewhat inspired by [VIPS](https://www.libvips.org/).

In the sense that AKTIVE's runtime enables the same thing that VIPS does, the
multi-threaded, concurrent handling of multiple input regions without having
to load the entirety of the inputs into memory.

The detailed structures are very different from VIPS however, for several reasons:

  - This is a Tcl extension, linked to and using Tcl API functions and structures.

  - There is no support for multiple integer types, etc. for pixel values. The only type used
    internally is __double__. All other types are cast to/from this on reading/writing.

