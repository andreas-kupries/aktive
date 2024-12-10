<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- generator virtual sdf

## <anchor='top'> Table Of Contents

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
### [↑](#top) <a name='image_sdf_box'></a> aktive image sdf box

Syntax: __aktive image sdf box__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a box.

Beware, the location and size of the box are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a box located completely outside of the image domain.

See also [aktive op draw box on](transform_drawing.md#op_draw_box_on) and [aktive image draw box](generator_virtual_drawing.md#image_draw_box).

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

#### <a name='image_sdf_box__examples'></a> Examples

<table>
<tr><th>aktive image sdf box center {64 64} width 128 height 128 ewidth 32 eheight 32
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00206.gif' alt='aktive image sdf box center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00207.gif' alt='aktive image sdf box center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00208.gif' alt='aktive image sdf box center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='image_sdf_box_rounded'></a> aktive image sdf box-rounded

Syntax: __aktive image sdf box-rounded__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a box.

Beware, the location and size of the box are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a box located completely outside of the image domain.

See also [aktive op draw box-rounded on](transform_drawing.md#op_draw_box_rounded_on) and [aktive image draw box-rounded](generator_virtual_drawing.md#image_draw_box_rounded).

The box is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, with rounded corners per the radii, and placed at the specified center.

The radii default to 0, i.e. no rounded corners.

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

#### <a name='image_sdf_box_rounded__examples'></a> Examples

<table>
<tr><th>aktive image sdf box-rounded center {64 64} width 128 height 128 ewidth 32 eheight 32
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00209.gif' alt='aktive image sdf box-rounded center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00210.gif' alt='aktive image sdf box-rounded center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00211.gif' alt='aktive image sdf box-rounded center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>

<table>
<tr><th>aktive image sdf box-rounded center {64 64} width 128 height 128 ewidth 32 eheight 32 upleftradius 32
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00212.gif' alt='aktive image sdf box-rounded center {64 64} width 128 height 128 ewidth 32 eheight 32 upleftradius 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00213.gif' alt='aktive image sdf box-rounded center {64 64} width 128 height 128 ewidth 32 eheight 32 upleftradius 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00214.gif' alt='aktive image sdf box-rounded center {64 64} width 128 height 128 ewidth 32 eheight 32 upleftradius 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='image_sdf_circle'></a> aktive image sdf circle

Syntax: __aktive image sdf circle__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a circle.

Beware, the location and size of the circle are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a circle located completely outside of the image domain.

See also [aktive op draw circle on](transform_drawing.md#op_draw_circle_on) and [aktive image draw circle](generator_virtual_drawing.md#image_draw_circle).

The circle has the `radius`, and is placed at the specified center.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|radius|uint|1|Circle radius|
|center|point||Element center|

#### <a name='image_sdf_circle__examples'></a> Examples

<table>
<tr><th>aktive image sdf circle center {64 64} width 128 height 128 radius 32
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00215.gif' alt='aktive image sdf circle center {64 64} width 128 height 128 radius 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00216.gif' alt='aktive image sdf circle center {64 64} width 128 height 128 radius 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00217.gif' alt='aktive image sdf circle center {64 64} width 128 height 128 radius 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='image_sdf_circles'></a> aktive image sdf circles

Syntax: __aktive image sdf circles__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a set of circles.

Beware, the location and size of the set of circles are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a set of circles located completely outside of the image domain.

See also [aktive op draw circles on](transform_drawing.md#op_draw_circles_on) and [aktive image draw circles](generator_virtual_drawing.md#image_draw_circles).

The circles all have the same `radius`, and are placed at the specified centers.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|radius|uint|1|Circle radius|
|centers|point...||Circle centers|

#### <a name='image_sdf_circles__examples'></a> Examples

<table>
<tr><th>aktive image sdf circles width 128 height 128 radius 8 centers {10 10} {30 80} {80 30}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00218.gif' alt='aktive image sdf circles width 128 height 128 radius 8 centers {10 10} {30 80} {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00219.gif' alt='aktive image sdf circles width 128 height 128 radius 8 centers {10 10} {30 80} {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00220.gif' alt='aktive image sdf circles width 128 height 128 radius 8 centers {10 10} {30 80} {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='image_sdf_line'></a> aktive image sdf line

Syntax: __aktive image sdf line__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a line.

Beware, the location and size of the line are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a line located completely outside of the image domain.

See also [aktive op draw line on](transform_drawing.md#op_draw_line_on) and [aktive image draw line](generator_virtual_drawing.md#image_draw_line).

The line connects the two specified locations.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|from|point||Starting location|
|to|point||End location|

#### <a name='image_sdf_line__examples'></a> Examples

<table>
<tr><th>aktive image sdf line width 128 height 128 from {10 10} to {30 80}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00221.gif' alt='aktive image sdf line width 128 height 128 from {10 10} to {30 80}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00222.gif' alt='aktive image sdf line width 128 height 128 from {10 10} to {30 80}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00223.gif' alt='aktive image sdf line width 128 height 128 from {10 10} to {30 80}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='image_sdf_parallelogram'></a> aktive image sdf parallelogram

Syntax: __aktive image sdf parallelogram__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a parallelogram.

Beware, the location and size of the parallelogram are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a parallelogram located completely outside of the image domain.

See also [aktive op draw parallelogram on](transform_drawing.md#op_draw_parallelogram_on) and [aktive image draw parallelogram](generator_virtual_drawing.md#image_draw_parallelogram).

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

#### <a name='image_sdf_parallelogram__examples'></a> Examples

<table>
<tr><th>aktive image sdf parallelogram center {64 64} width 128 height 128 ewidth 32 eheight 32 eskew 8
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00224.gif' alt='aktive image sdf parallelogram center {64 64} width 128 height 128 ewidth 32 eheight 32 eskew 8' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00225.gif' alt='aktive image sdf parallelogram center {64 64} width 128 height 128 ewidth 32 eheight 32 eskew 8' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00226.gif' alt='aktive image sdf parallelogram center {64 64} width 128 height 128 ewidth 32 eheight 32 eskew 8' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='image_sdf_polyline'></a> aktive image sdf polyline

Syntax: __aktive image sdf polyline__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a set of lines.

Beware, the location and size of the set of lines are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a set of lines located completely outside of the image domain.

See also [aktive op draw polyline on](transform_drawing.md#op_draw_polyline_on) and [aktive image draw polyline](generator_virtual_drawing.md#image_draw_polyline).

The lines form a polyline through the specified points.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Image width|
|height|uint||Image height|
|x|int|0|Image location, X coordinate|
|y|int|0|Image location, Y coordinate|
|points|point...||Points of the poly-line|

#### <a name='image_sdf_polyline__examples'></a> Examples

<table>
<tr><th>aktive image sdf polyline width 128 height 128 points {10 10} {30 80} {80 30}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00227.gif' alt='aktive image sdf polyline width 128 height 128 points {10 10} {30 80} {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00228.gif' alt='aktive image sdf polyline width 128 height 128 points {10 10} {30 80} {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00229.gif' alt='aktive image sdf polyline width 128 height 128 points {10 10} {30 80} {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='image_sdf_rhombus'></a> aktive image sdf rhombus

Syntax: __aktive image sdf rhombus__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a rhombus.

Beware, the location and size of the rhombus are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a rhombus located completely outside of the image domain.

See also [aktive op draw rhombus on](transform_drawing.md#op_draw_rhombus_on) and [aktive image draw rhombus](generator_virtual_drawing.md#image_draw_rhombus).

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

#### <a name='image_sdf_rhombus__examples'></a> Examples

<table>
<tr><th>aktive image sdf rhombus center {64 64} width 128 height 128 ewidth 32 eheight 32
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00230.gif' alt='aktive image sdf rhombus center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00231.gif' alt='aktive image sdf rhombus center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00232.gif' alt='aktive image sdf rhombus center {64 64} width 128 height 128 ewidth 32 eheight 32' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='image_sdf_triangle'></a> aktive image sdf triangle

Syntax: __aktive image sdf triangle__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=75&name=etc/generator/virtual/sdf.tcl)]

Returns an image with the given dimensions and location, containing the signed distance field of a triangle.

Beware, the location and size of the triangle are independent of image location and dimensions. The operator is perfectly fine computing the SDF of a triangle located completely outside of the image domain.

See also [aktive op draw triangle on](transform_drawing.md#op_draw_triangle_on) and [aktive image draw triangle](generator_virtual_drawing.md#image_draw_triangle).

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

#### <a name='image_sdf_triangle__examples'></a> Examples

<table>
<tr><th>aktive image sdf triangle width 128 height 128 a {10 10} b {30 80} c {80 30}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00233.gif' alt='aktive image sdf triangle width 128 height 128 a {10 10} b {30 80} c {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00234.gif' alt='aktive image sdf triangle width 128 height 128 a {10 10} b {30 80} c {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00235.gif' alt='aktive image sdf triangle width 128 height 128 a {10 10} b {30 80} c {80 30}' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


