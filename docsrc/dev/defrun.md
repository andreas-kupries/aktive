!include ../parts/topnav-dev-b.inc

# Image pipelines: Definition and Runtime structures

Note that the `image_vector` and `region_vector` types should have a link from their `v` field to
`image` and `region`. This was left out as having them causes the computed layout to be much worse.

[<img alt='Definition/Runtime Structures' src='figures/defrun-structures.svg' style='width:50%;'>](figures/defrun-structures.svg)
