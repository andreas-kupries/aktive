# Documentation -- Reference Pages -- accessor values

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [accessor](accessor.md) ↗


### Operators

 - [aktive query value around](#query_value_around)
 - [aktive query value at](#query_value_at)
 - [aktive query values](#query_values)

## Operators

---
### <a name='query_value_around'></a> aktive query value around

Syntax: __aktive query value around__ src ?(param value)...?

Returns the pixels values for the region around the specified 2d point, within the manhattan radius. The result is __not__ an image.

Beware that the coordinate domain is 0..width|height, regardless of image location.

This operator is __strict__ in its single input. The requested pixel region is materialized in memory.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|int||x-coordinate of the pixel to query|
|y|int||y-coordinate of the pixel to query|
|radius|uint|1|Region radius, defaults to 1, i.e. a 3x3 region.|

---
### <a name='query_value_at'></a> aktive query value at

Syntax: __aktive query value at__ src (param value)...

Returns the pixel value at the given 2d point. The result is a list for multi-band inputs. The result is __not__ an image.

Beware that the coordinate domain is 0..width|height, regardless of image location.

This operator is __strict__ in its single input. The requested pixel is materialized in memory.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|int||x-coordinate of the pixel to query|
|y|int||y-coordinate of the pixel to query|

---
### <a name='query_values'></a> aktive query values

Syntax: __aktive query values__ src

Returns a Tcl list of image pixel values. The values are provided in row-major order.

This operator is __strict__ in its single input. The image is materialized in memory.


