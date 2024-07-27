!include ../parts/topnav-dev-b.inc

# Image pipelines: Runtime structures

Note that the `region_vector` type should have a link from their `v` field to `region`.
This was left out as having it causes the computed layout to be much worse.

![Definition Structures](figures/runtime-structures.svg)
