<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||
|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|[Developer Index ↗](index.md)|


# Image pipelines: Definition and Runtime structures

Note that the `image_vector` and `region_vector` types should have a link from their `v` field to
`image` and `region`. This was left out as having them causes the computed layout to be much worse.

![Definition Structures](figures/defrun-structures.svg)
