# generator virtual sdf

||||||||
|---|---|---|---|---|---|---|
|[Home ↗](/)|[Main ↗](index.md)|[Sections](index.md#sectree)|[Permuted Sections](bypsections.md)|[Names](byname.md)|[Permuted Names](bypnames.md)|[Implementations](bylang.md)|

## Table Of Contents

  - [generator virtual](generator_virtual.md) ↗


### Operators

 - [aktive image sdf box](#image_sdf_box)
 - [aktive image sdf box-rounded](#image_sdf_box_rounded)
 - [aktive image sdf circle](#image_sdf_circle)
 - [aktive image sdf circles](#image_sdf_circles)
 - [aktive image sdf line](#image_sdf_line)
 - [aktive image sdf parallelogram](#image_sdf_parallelogram)
 - [aktive image sdf polyline](#image_sdf_polyline)
 - [aktive image sdf rhombus](#image_sdf_rhombus)
 - [aktive image sdf triangle](#image_sdf_triangle)

## Operators

---
### <a name='image_sdf_box'></a> aktive image sdf box

Syntax: __aktive image sdf box__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a box.

Beware, the location and size of the box are independent of the image dimensions. The operator is perfectly fine computing the SDF of a box located completely outside of the image domain.

The box is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, and placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|ewidth|uint|1|Element width|
|eheight|uint|1|Element height|
|center|point||Element center|

---
### <a name='image_sdf_box_rounded'></a> aktive image sdf box-rounded

Syntax: __aktive image sdf box-rounded__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a box.

Beware, the location and size of the box are independent of the image dimensions. The operator is perfectly fine computing the SDF of a box located completely outside of the image domain.

The box is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, with rounded corners per the radii, and placed at the specified center.

The radii defauilt to 0, i.e. no rounded corners.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|upleftradius|uint|0|Radius of element at upper left corner|
|uprightradius|uint|0|Radius of element at upper right corner|
|downleftradius|uint|0|Radius of element at lower left corner|
|downrightradius|uint|0|Radius of element at lower right corner|
|ewidth|uint|1|Element width|
|eheight|uint|1|Element height|
|center|point||Element center|

---
### <a name='image_sdf_circle'></a> aktive image sdf circle

Syntax: __aktive image sdf circle__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a circle.

Beware, the location and size of the circle are independent of the image dimensions. The operator is perfectly fine computing the SDF of a circle located completely outside of the image domain.

The circle has the `radius`, and is placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|radius|uint|1|Circle radius|
|center|point||Element center|

---
### <a name='image_sdf_circles'></a> aktive image sdf circles

Syntax: __aktive image sdf circles__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a set of circles.

Beware, the location and size of the set of circles are independent of the image dimensions. The operator is perfectly fine computing the SDF of a set of circles located completely outside of the image domain.

The circles all have the same `radius`, and are placed at the specified centers.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|radius|uint|1|Circle radius|
|centers|point...||Circle centers|

---
### <a name='image_sdf_line'></a> aktive image sdf line

Syntax: __aktive image sdf line__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a line.

Beware, the location and size of the line are independent of the image dimensions. The operator is perfectly fine computing the SDF of a line located completely outside of the image domain.

The line connects the two specified locations.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|from|point||Starting location|
|to|point||End location|

---
### <a name='image_sdf_parallelogram'></a> aktive image sdf parallelogram

Syntax: __aktive image sdf parallelogram__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a parallelogram.

Beware, the location and size of the parallelogram are independent of the image dimensions. The operator is perfectly fine computing the SDF of a parallelogram located completely outside of the image domain.

The parallelogram is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, skewed by `eskew`, and placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|eskew|uint|1|Element skew|
|ewidth|uint|1|Element width|
|eheight|uint|1|Element height|
|center|point||Element center|

---
### <a name='image_sdf_polyline'></a> aktive image sdf polyline

Syntax: __aktive image sdf polyline__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a set of lines.

Beware, the location and size of the set of lines are independent of the image dimensions. The operator is perfectly fine computing the SDF of a set of lines located completely outside of the image domain.

The lines form a polyline through the specified points.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|points|point...||Points of the poly-line|

---
### <a name='image_sdf_rhombus'></a> aktive image sdf rhombus

Syntax: __aktive image sdf rhombus__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a rhombus.

Beware, the location and size of the rhombus are independent of the image dimensions. The operator is perfectly fine computing the SDF of a rhombus located completely outside of the image domain.

The rhombus is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, and placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|ewidth|uint|1|Element width|
|eheight|uint|1|Element height|
|center|point||Element center|

---
### <a name='image_sdf_triangle'></a> aktive image sdf triangle

Syntax: __aktive image sdf triangle__  ?(param value)...?

Returns an image with the given dimensions and location, containing the signed distance field of a triangle.

Beware, the location and size of the triangle are independent of the image dimensions. The operator is perfectly fine computing the SDF of a triangle located completely outside of the image domain.

The triangle connects the points A, B, and C, in this order.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|a|point||Triangle point A|
|b|point||Triangle point B|
|c|point||Triangle point C|

