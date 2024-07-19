<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- generator virtual drawing

## Table Of Contents

  - [generator virtual](generator_virtual.md) ↗


### Operators

 - [aktive image draw box](#image_draw_box)
 - [aktive image draw box-rounded](#image_draw_box_rounded)
 - [aktive image draw circle](#image_draw_circle)
 - [aktive image draw circles](#image_draw_circles)
 - [aktive image draw line](#image_draw_line)
 - [aktive image draw parallelogram](#image_draw_parallelogram)
 - [aktive image draw polyline](#image_draw_polyline)
 - [aktive image draw rhombus](#image_draw_rhombus)
 - [aktive image draw triangle](#image_draw_triangle)

## Operators

---
### <a name='image_draw_box'></a> aktive image draw box

Syntax: __aktive image draw box__  ?(param value)...?

Returns an image with the given dimensions and location, with a box drawn into it.

Beware, the location and size of the box are independent of the image dimensions. The operator is perfectly fine computing the SDF of a box located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The box is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, and placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|outlined|uint|0|Outline thickness. Draw filled if zero (Default).|
|ewidth|uint|1|Element width|
|eheight|uint|1|Element height|
|center|point||Element center|

---
### <a name='image_draw_box_rounded'></a> aktive image draw box-rounded

Syntax: __aktive image draw box-rounded__  ?(param value)...?

Returns an image with the given dimensions and location, with a box drawn into it.

Beware, the location and size of the box are independent of the image dimensions. The operator is perfectly fine computing the SDF of a box located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The box is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, with rounded corners per the radii, and placed at the specified center.

The radii defauilt to 0, i.e. no rounded corners.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|outlined|uint|0|Outline thickness. Draw filled if zero (Default).|
|upleftradius|uint|0|Radius of element at upper left corner|
|uprightradius|uint|0|Radius of element at upper right corner|
|downleftradius|uint|0|Radius of element at lower left corner|
|downrightradius|uint|0|Radius of element at lower right corner|
|ewidth|uint|1|Element width|
|eheight|uint|1|Element height|
|center|point||Element center|

---
### <a name='image_draw_circle'></a> aktive image draw circle

Syntax: __aktive image draw circle__  ?(param value)...?

Returns an image with the given dimensions and location, with a circle drawn into it.

Beware, the location and size of the circle are independent of the image dimensions. The operator is perfectly fine computing the SDF of a circle located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The circle has the `radius`, and is placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|outlined|uint|0|Outline thickness. Draw filled if zero (Default).|
|radius|uint|1|Circle radius|
|center|point||Element center|

---
### <a name='image_draw_circles'></a> aktive image draw circles

Syntax: __aktive image draw circles__  ?(param value)...?

Returns an image with the given dimensions and location, with a set of circles drawn into it.

Beware, the location and size of the set of circles are independent of the image dimensions. The operator is perfectly fine computing the SDF of a set of circles located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The circles all have the same `radius`, and are placed at the specified centers.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|outlined|uint|0|Outline thickness. Draw filled if zero (Default).|
|radius|uint|1|Circle radius|
|centers|point...||Circle centers|

---
### <a name='image_draw_line'></a> aktive image draw line

Syntax: __aktive image draw line__  ?(param value)...?

Returns an image with the given dimensions and location, with a line drawn into it.

Beware, the location and size of the line are independent of the image dimensions. The operator is perfectly fine computing the SDF of a line located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The line connects the two specified locations.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|strokewidth|uint|0|Stroke width. Lines are `2*strokewidth+1` wide.|
|from|point||Starting location|
|to|point||End location|

---
### <a name='image_draw_parallelogram'></a> aktive image draw parallelogram

Syntax: __aktive image draw parallelogram__  ?(param value)...?

Returns an image with the given dimensions and location, with a parallelogram drawn into it.

Beware, the location and size of the parallelogram are independent of the image dimensions. The operator is perfectly fine computing the SDF of a parallelogram located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The parallelogram is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, skewed by `eskew`, and placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|outlined|uint|0|Outline thickness. Draw filled if zero (Default).|
|eskew|uint|1|Element skew|
|ewidth|uint|1|Element width|
|eheight|uint|1|Element height|
|center|point||Element center|

---
### <a name='image_draw_polyline'></a> aktive image draw polyline

Syntax: __aktive image draw polyline__  ?(param value)...?

Returns an image with the given dimensions and location, with a set of lines drawn into it.

Beware, the location and size of the set of lines are independent of the image dimensions. The operator is perfectly fine computing the SDF of a set of lines located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The lines form a polyline through the specified points.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|strokewidth|uint|0|Stroke width. Lines are `2*strokewidth+1` wide.|
|points|point...||Points of the poly-line|

---
### <a name='image_draw_rhombus'></a> aktive image draw rhombus

Syntax: __aktive image draw rhombus__  ?(param value)...?

Returns an image with the given dimensions and location, with a rhombus drawn into it.

Beware, the location and size of the rhombus are independent of the image dimensions. The operator is perfectly fine computing the SDF of a rhombus located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The rhombus is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, and placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|outlined|uint|0|Outline thickness. Draw filled if zero (Default).|
|ewidth|uint|1|Element width|
|eheight|uint|1|Element height|
|center|point||Element center|

---
### <a name='image_draw_triangle'></a> aktive image draw triangle

Syntax: __aktive image draw triangle__  ?(param value)...?

Returns an image with the given dimensions and location, with a triangle drawn into it.

Beware, the location and size of the triangle are independent of the image dimensions. The operator is perfectly fine computing the SDF of a triangle located completely outside of the image domain.

The returned image is always single-band. It is grey-scale when anti-aliasing is active, and black/white if not.

The triangle connects the points A, B, and C, in this order.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|antialiased|bool|1|Draw with antialiasing for smoother contours (Default)|
|outlined|uint|0|Outline thickness. Draw filled if zero (Default).|
|a|point||Triangle point A|
|b|point||Triangle point B|
|c|point||Triangle point C|

