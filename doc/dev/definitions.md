<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||
|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|[Developer Index ↗](index.md)|


# Image pipelines: Definition structures

[image.h line 21-26](/file?ci=trunk&ln=21-26&name=runtime/image.h)

Note on the image:

  - The `image_vector` type should be linked to `image`, via their field `v` field.
    This link was left out because having it causes the computed layout to be much worse.

More notes:

  - The `image` structure is the only public type in the definition block. All others are internal.

  - And even `image` is only exposed as an [__opaque__ type](../../runtime/base.h) keeping its
    fields hidden.

  - All manipulation outside of the runtime itself is done via
    [accessor functions](../../runtime/image.h).

  - On the internal side, the information about the content, i.e. the actual operator, and the meta
    data are intentionally separated from the main structure, each with their own reference
    counting.

    This allows image-creating operators to share the same meta data as they are added to a
    pipeline, and, vice versa, for operators modifying only the meta data to keep the same
    content. There is no need for these operators to implement some kind of pixel pass through, no
    superfluous copying of data.

  - The `image_info` data is what is generally seen by the image-level function vectors,
    i.e. `setup()` and `final()`.

![Definition Structures](figures/definition-structures.svg)
