# Documentation -- Reference Pages -- transform

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

||||||||
|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [Main](index.md) ↗


## Subsections


 - [transform color](transform_color.md) ↘
 - [transform convolution](transform_convolution.md) ↘
 - [transform drawing](transform_drawing.md) ↘
 - [transform effect](transform_effect.md) ↘
 - [transform geometry](transform_geometry.md) ↘
 - [transform identity](transform_identity.md) ↘
 - [transform kuwahara](transform_kuwahara.md) ↘
 - [transform location](transform_location.md) ↘
 - [transform math](transform_math.md) ↘
 - [transform metadata](transform_metadata.md) ↘
 - [transform morphology](transform_morphology.md) ↘
 - [transform sdf](transform_sdf.md) ↘
 - [transform statistics](transform_statistics.md) ↘
 - [transform structure](transform_structure.md) ↘
 - [transform wiener](transform_wiener.md) ↘

### Operators

 - [aktive op bands recombine](#op_bands_recombine)
 - [aktive op view](#op_view)

## Operators

---
### <a name='op_bands_recombine'></a> aktive op bands recombine

Syntax: __aktive op bands recombine__ src0 src1

Returns image with the input's band information recombined through a matrix-vector multiplication.

The band values of the input pixels are the vectors which are multiplied with the matrix specified as the first image argument. The input to be processed is the second image argument.

The matrix has to be single-band and its height has to match the depth of the input. The width of the matrix becomes the depth of the result.

The location of the matrix image is ignored.


---
### <a name='op_view'></a> aktive op view

Syntax: __aktive op view__ src (param value)...

Returns image arbitrarily offset and shaped compared to the input domain. In other words, an arbitrary view (port) into the input.

Beware, the requested area may fall __anywhere__ with respect to the input's domain. Same, inside (subset), outside, partially overlapping, etc.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|port|rect||The specific area to view in the plane|

