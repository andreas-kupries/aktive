<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- generator virtual warp

## <anchor='top'> Table Of Contents

  - [generator virtual](generator_virtual.md) ↗


### Operators

 - [aktive transform affine](#transform_affine)
 - [aktive transform compose](#transform_compose)
 - [aktive transform compose-core](#transform_compose_core)
 - [aktive transform domain](#transform_domain)
 - [aktive transform identity](#transform_identity)
 - [aktive transform invert](#transform_invert)
 - [aktive transform point](#transform_point)
 - [aktive transform projective](#transform_projective)
 - [aktive transform quad 2quad](#transform_quad_2quad)
 - [aktive transform quad unit2](#transform_quad_unit2)
 - [aktive transform reflect line](#transform_reflect_line)
 - [aktive transform reflect x](#transform_reflect_x)
 - [aktive transform reflect y](#transform_reflect_y)
 - [aktive transform rotate](#transform_rotate)
 - [aktive transform scale](#transform_scale)
 - [aktive transform shear](#transform_shear)
 - [aktive transform translate](#transform_translate)
 - [aktive warp matrix](#warp_matrix)
 - [aktive warp noise gauss](#warp_noise_gauss)
 - [aktive warp noise uniform](#warp_noise_uniform)
 - [aktive warp swirl](#warp_swirl)

## Operators

---
### [↑](#top) <a name='transform_affine'></a> aktive transform affine

Syntax: __aktive transform affine__  (param value)... [[→ definition](../../../../file?ci=trunk&ln=686&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image holding the affine transformation specifed by the 6 parameters a to f.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|double||Parameter a of the affine transform|
|b|double||Parameter b of the affine transform|
|c|double||Parameter c of the affine transform|
|d|double||Parameter d of the affine transform|
|e|double||Parameter e of the affine transform|
|f|double||Parameter f of the affine transform|

#### <a name='transform_affine__examples'></a> Examples

<table>
<tr><th>aktive transform affine a 1 b 2 c 3 d 4 e 5 f 6
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td></tr><tr><td>4</td><td>5</td><td>6</td></tr><tr><td>0</td><td>0</td><td>1</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_compose'></a> aktive transform compose

Syntax: __aktive transform compose__ srcs... [[→ definition](../../../../file?ci=trunk&ln=155&name=etc/generator/virtual/warp.tcl)]

Takes any number of 3x3 projective transformation matrices and returns their composition.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

This operator is __strict__ in all inputs. All projective matrices are materialized and immediately used to compute the composition.

|Input|Description|
|:---|:---|
|args...|Source images|

#### <a name='transform_compose__examples'></a> Examples

<table>
<tr><th>@1
    <br>(translate x -5 y -6)</th>
    <th>@2
    <br>(rotate by 45)</th>
    <th>@3
    <br>(translate x 5 y 6)</th>
    <th>aktive transform compose @1 @2 @3
    <br>(rotate 45 around (5,6))</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>-6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>-5.7071</td></tr><tr><td>0.7071</td><td>0.7071</td><td>1.7782</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_compose_core'></a> aktive transform compose-core

Syntax: __aktive transform compose-core__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=183&name=etc/generator/virtual/warp.tcl)]

Takes two 3x3 projective transformation matrices and returns their composition.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

This operator is __strict__ in both inputs. The two projective matrices are materialized and immediately used to compute the composition A*B.

|Input|Description|
|:---|:---|
|src0||
|src1||

#### <a name='transform_compose_core__examples'></a> Examples

<table>
<tr><th>@1
    <br>(rotate)</th>
    <th>@2
    <br>(translate)</th>
    <th>aktive transform compose-core @1 @2
    <br>(rotate after translate)</th></tr>
<tr><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>-0.7071</td></tr><tr><td>0.7071</td><td>0.7071</td><td>7.7782</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(rotate)</th>
    <th>@2
    <br>(translate)</th>
    <th>aktive transform compose-core @1 @2
    <br>(translate after rotate)</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>5.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_domain'></a> aktive transform domain

Syntax: __aktive transform domain__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=42&name=etc/generator/virtual/warp.tcl)]

Returns the domain generated by applying the transformation (`src0`) to the domain of the image (`src1`). The domain is returned in the same form at as generated by [aktive query domain](accessor_geometry.md#query_domain), i.e. a 4-element Tcl list in the format __{x y w h}__.

Fractions are rounded to integers such that the actual domain is kept enclosed.

This operator is __strict__ in the 1st input. The projective matrix is materialized for the calculation of the domain.

|Input|Description|
|:---|:---|
|src0||
|src1||

#### <a name='transform_domain__examples'></a> Examples

<table>
<tr><th>@1
    <br>(assets/butterfly.ppm)</th>
    <th>@2
    <br>(rotate by 30)</th>
    <th>aktive transform domain @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00739.gif' alt='@1 (assets/butterfly.ppm)' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><table><tr><td>0.8660</td><td>-0.5000</td><td>0.0000</td></tr><tr><td>0.5000</td><td>0.8660</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'>&nbsp;-124 0 454 407</td></tr>
</table>


---
### [↑](#top) <a name='transform_identity'></a> aktive transform identity

Syntax: __aktive transform identity__  [[→ definition](../../../../file?ci=trunk&ln=220&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image containing the identity transform.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

#### <a name='transform_identity__examples'></a> Examples

<table>
<tr><th>aktive transform identity 
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_invert'></a> aktive transform invert

Syntax: __aktive transform invert__ src [[→ definition](../../../../file?ci=trunk&ln=124&name=etc/generator/virtual/warp.tcl)]

Takes a single 3x3 projective transformation matrix and returns the matrix of the inverted transformation. This is used to turn forward into backward transformations, and vice versa.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

This operator is __strict__ in the 1st input. The projective matrix is materialized and immediately used to compute the inversion.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='transform_invert__examples'></a> Examples

<table>
<tr><th>@1
    <br>(translate x -5 y -6)</th>
    <th>aktive transform invert @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>-6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>-0.0000</td><td>5.0000</td></tr><tr><td>-0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(translate x -5 y -6)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>-6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>-0.0000</td><td>5.0000</td></tr><tr><td>-0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_point'></a> aktive transform point

Syntax: __aktive transform point__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=10&name=etc/generator/virtual/warp.tcl)]

Returns the point generated by the application of the transformation to the input point.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|at|point||Point to transform.|

#### <a name='transform_point__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(at 0 0)</th>
    <th>@3
    <br>(at 0 1)</th>
    <th>@4
    <br>(at 1 1)</th>
    <th>aktive transform point @1 at {1 0}
    <br>(at 1 0)</th></tr>
<tr><td valign='top'><table><tr><td>5.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>-1.0000</td><td>5.0000</td><td>2.0000</td></tr><tr><td>-0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'>&nbsp;1.0 2.0</td>
    <td valign='top'>&nbsp;2.0 7.0</td>
    <td valign='top'>&nbsp;7.0 6.0</td>
    <td valign='top'>&nbsp;6.0 1.0</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(at 1 2 => 0 3)</th>
    <th>@3
    <br>(at 6 1 => 7 1)</th>
    <th>@4
    <br>(at 7 6 => 8 7)</th>
    <th>aktive transform point @1 at {2 7}
    <br>(at 2 7 => 1 7)</th></tr>
<tr><td valign='top'><table><tr><td>0.9377</td><td>0.0220</td><td>-0.9817</td></tr><tr><td>-0.2821</td><td>0.9231</td><td>1.4359</td></tr><tr><td>-0.0623</td><td>0.0220</td><td>1.0183</td></tr></table></td>
    <td valign='top'>&nbsp;0.0 3.0000000000000004</td>
    <td valign='top'>&nbsp;7.000000000000001 1.0000000000000004</td>
    <td valign='top'>&nbsp;8.000000000000002 7.000000000000002</td>
    <td valign='top'>&nbsp;1.0000000000000004 7.000000000000002</td></tr>
</table>


---
### [↑](#top) <a name='transform_projective'></a> aktive transform projective

Syntax: __aktive transform projective__  (param value)... [[→ definition](../../../../file?ci=trunk&ln=714&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image holding the projective transformation specifed by the 8 parameters a to h.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|double||Parameter a of the projective transform|
|b|double||Parameter b of the projective transform|
|c|double||Parameter c of the projective transform|
|d|double||Parameter d of the projective transform|
|e|double||Parameter e of the projective transform|
|f|double||Parameter f of the projective transform|
|g|double||Parameter g of the projective transform|
|h|double||Parameter h of the projective transform|

#### <a name='transform_projective__examples'></a> Examples

<table>
<tr><th>aktive transform projective a 1 b 2 c 3 d 4 e 5 f 6 g 7 h 8
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td></tr><tr><td>4</td><td>5</td><td>6</td></tr><tr><td>7</td><td>8</td><td>1</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_quad_2quad'></a> aktive transform quad 2quad

Syntax: __aktive transform quad 2quad__  (param value)... [[→ definition](../../../../file?ci=trunk&ln=501&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image transforming the specified quadrilateral A to the second quadrilateral B.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

The quadrilaterals are specified as 4 points A-B-C-D and E-F-G-H in counter clockwise order. The returned transform maps A to E and then the other points in counter clockwise order.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|point||Point A of the quadrilateral A|
|b|point||Point B of the quadrilateral A|
|c|point||Point C of the quadrilateral A|
|d|point||Point D of the quadrilateral A|
|e|point||Point A of the quadrilateral B|
|f|point||Point B of the quadrilateral B|
|g|point||Point C of the quadrilateral B|
|h|point||Point D of the quadrilateral B|

#### <a name='transform_quad_2quad__examples'></a> Examples

<table>
<tr><th>aktive transform quad 2quad a {1 2} b {6 1} c {7 6} d {2 7}   e {0 3} f {7 1} g {8 7} h {1 7}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>0.9377</td><td>0.0220</td><td>-0.9817</td></tr><tr><td>-0.2821</td><td>0.9231</td><td>1.4359</td></tr><tr><td>-0.0623</td><td>0.0220</td><td>1.0183</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>0.9377</td><td>0.0220</td><td>-0.9817</td></tr><tr><td>-0.2821</td><td>0.9231</td><td>1.4359</td></tr><tr><td>-0.0623</td><td>0.0220</td><td>1.0183</td></tr></table></td>
    <td valign='top'><table><tr><td>1.1273</td><td>-0.0545</td><td>1.1636</td></tr><tr><td>0.2455</td><td>1.1091</td><td>-1.3273</td></tr><tr><td>0.0636</td><td>-0.0273</td><td>1.0818</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-0.0000</td></tr><tr><td>-0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(at 1 2 => 0 3)</th>
    <th>@3
    <br>(at 6 1 => 7 1)</th>
    <th>@4
    <br>(at 7 6 => 8 7)</th>
    <th>aktive transform point @1 at {2 7}
    <br>(at 2 7 => 1 7)</th></tr>
<tr><td valign='top'><table><tr><td>0.9377</td><td>0.0220</td><td>-0.9817</td></tr><tr><td>-0.2821</td><td>0.9231</td><td>1.4359</td></tr><tr><td>-0.0623</td><td>0.0220</td><td>1.0183</td></tr></table></td>
    <td valign='top'>&nbsp;0.0 3.0000000000000004</td>
    <td valign='top'>&nbsp;7.000000000000001 1.0000000000000004</td>
    <td valign='top'>&nbsp;8.000000000000002 7.000000000000002</td>
    <td valign='top'>&nbsp;1.0000000000000004 7.000000000000002</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>(at 0 3 => 1 2)</th>
    <th>@4
    <br>(at 7 1 => 6 1)</th>
    <th>@5
    <br>(at 8 7 => 7 6)</th>
    <th>aktive transform point @2 at {1 7}
    <br>(at 1 7 => 2 7)</th></tr>
<tr><td valign='top'><table><tr><td>0.9377</td><td>0.0220</td><td>-0.9817</td></tr><tr><td>-0.2821</td><td>0.9231</td><td>1.4359</td></tr><tr><td>-0.0623</td><td>0.0220</td><td>1.0183</td></tr></table></td>
    <td valign='top'><table><tr><td>1.1273</td><td>-0.0545</td><td>1.1636</td></tr><tr><td>0.2455</td><td>1.1091</td><td>-1.3273</td></tr><tr><td>0.0636</td><td>-0.0273</td><td>1.0818</td></tr></table></td>
    <td valign='top'>&nbsp;1.0 1.9999999999999996</td>
    <td valign='top'>&nbsp;6.0 0.9999999999999994</td>
    <td valign='top'>&nbsp;6.999999999999999 5.999999999999999</td>
    <td valign='top'>&nbsp;1.9999999999999998 6.999999999999999</td></tr>
</table>

<table>
<tr><th>@1
    <br>(quadrilateral)</th>
    <th>@2
    <br>( 47  62 =>   0   0)</th>
    <th>@3
    <br>(100 125 =>   0 100)</th>
    <th>@4
    <br>(210  80 => 100 100)</th>
    <th>aktive transform point @1 at {190  10}
    <br>(190  10 => 100   0)</th></tr>
<tr><td valign='top'><table><tr><td>0.4944</td><td>-0.4159</td><td>2.5504</td></tr><tr><td>0.3440</td><td>0.9460</td><td>-74.8181</td></tr><tr><td>-0.0014</td><td>-0.0023</td><td>1.2110</td></tr></table></td>
    <td valign='top'>&nbsp;-3.1086244689504383e-15 0.0</td>
    <td valign='top'>&nbsp;-3.994220974639806e-15 100.00000000000001</td>
    <td valign='top'>&nbsp;99.99999999999999 100.00000000000001</td>
    <td valign='top'>&nbsp;99.99999999999999 0.0</td></tr>
</table>

<table>
<tr><th>@1
    <br>(quadrilateral)</th>
    <th>@2
    <br>(inverted)</th>
    <th>@3
    <br>(  0   0 =>  47  62)</th>
    <th>@4
    <br>(  0 100 => 100 125)</th>
    <th>@5
    <br>(100 100 => 210  80)</th>
    <th>aktive transform point @2 at {100   0}
    <br>(100   0 => 190  10)</th></tr>
<tr><td valign='top'><table><tr><td>0.4944</td><td>-0.4159</td><td>2.5504</td></tr><tr><td>0.3440</td><td>0.9460</td><td>-74.8181</td></tr><tr><td>-0.0014</td><td>-0.0023</td><td>1.2110</td></tr></table></td>
    <td valign='top'><table><tr><td>1.5880</td><td>0.8149</td><td>47.0000</td></tr><tr><td>-0.5117</td><td>0.9861</td><td>62.0000</td></tr><tr><td>0.0008</td><td>0.0028</td><td>1.0000</td></tr></table></td>
    <td valign='top'>&nbsp;47.00000000000001 61.99999999999999</td>
    <td valign='top'>&nbsp;100.0 125.0</td>
    <td valign='top'>&nbsp;210.00000000000003 80.0</td>
    <td valign='top'>&nbsp;190.0 10.0</td></tr>
</table>


---
### [↑](#top) <a name='transform_quad_unit2'></a> aktive transform quad unit2

Syntax: __aktive transform quad unit2__  (param value)... [[→ definition](../../../../file?ci=trunk&ln=390&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image transforming the unit square to the specified quadrilateral.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

The quadrilateral is specified as 4 points A-B-C-D in counter clockwise order. The returned transform maps the origin of the unit square to A and then the other points in counter clockwise order.

To map between two arbitrary quadrilaterals A and B a composition of two transforms is necessary and sufficient, i.e. mapping A to the unit square (as inversion of the map from unit square to A), followed by mapping the unit square to B. This is what [aktive transform quad 2quad](generator_virtual_warp.md#transform_quad_2quad) does.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|point||Point A of the quadrilateral|
|b|point||Point B of the quadrilateral|
|c|point||Point C of the quadrilateral|
|d|point||Point D of the quadrilateral|

#### <a name='transform_quad_unit2__examples'></a> Examples

<table>
<tr><th>aktive transform quad unit2 a {1 2} b {6 1} c {7 6} d {2 7}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>5.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>-1.0000</td><td>5.0000</td><td>2.0000</td></tr><tr><td>-0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(at 0 0)</th>
    <th>@3
    <br>(at 0 1)</th>
    <th>@4
    <br>(at 1 1)</th>
    <th>aktive transform point @1 at {1 0}
    <br>(at 1 0)</th></tr>
<tr><td valign='top'><table><tr><td>5.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>-1.0000</td><td>5.0000</td><td>2.0000</td></tr><tr><td>-0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'>&nbsp;1.0 2.0</td>
    <td valign='top'>&nbsp;2.0 7.0</td>
    <td valign='top'>&nbsp;7.0 6.0</td>
    <td valign='top'>&nbsp;6.0 1.0</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>5.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>-1.0000</td><td>5.0000</td><td>2.0000</td></tr><tr><td>-0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.1923</td><td>-0.0385</td><td>-0.1154</td></tr><tr><td>0.0385</td><td>0.1923</td><td>-0.4231</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_reflect_line'></a> aktive transform reflect line

Syntax: __aktive transform reflect line__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=626&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image specifying a reflection along either the line through point A and the origin, or the line through points A and B.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|point||Point A of the line to reflect over|
|b|point|{}|Point B of the line to reflect over. If not specified, the origin is used|

#### <a name='transform_reflect_line__examples'></a> Examples

<table>
<tr><th>aktive transform reflect line a {5 3}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>0.4706</td><td>0.8824</td><td>0.0000</td></tr><tr><td>0.8824</td><td>-0.4706</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(reflect line 0--A)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>0.4706</td><td>0.8824</td><td>0.0000</td></tr><tr><td>0.8824</td><td>-0.4706</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.4706</td><td>0.8824</td><td>-0.0000</td></tr><tr><td>0.8824</td><td>-0.4706</td><td>0.0000</td></tr><tr><td>-0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>aktive transform reflect line a {5 3} b {-2 -2}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>0.3243</td><td>0.9459</td><td>0.5405</td></tr><tr><td>0.9459</td><td>-0.3243</td><td>-0.7568</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(reflect line A--B)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>0.3243</td><td>0.9459</td><td>0.5405</td></tr><tr><td>0.9459</td><td>-0.3243</td><td>-0.7568</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.3243</td><td>0.9459</td><td>0.5405</td></tr><tr><td>0.9459</td><td>-0.3243</td><td>-0.7568</td></tr><tr><td>-0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>-0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_reflect_x'></a> aktive transform reflect x

Syntax: __aktive transform reflect x__  [[→ definition](../../../../file?ci=trunk&ln=576&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image specifying a reflection along the x-axis.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

When not used as part of a chain of transformations then this is better done using [aktive op flip x](transform_structure.md#op_flip_x)

#### <a name='transform_reflect_x__examples'></a> Examples

<table>
<tr><th>aktive transform reflect x 
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>-1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(reflect x)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>-1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>-1.0000</td><td>0.0000</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>-0.0000</td></tr><tr><td>-0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_reflect_y'></a> aktive transform reflect y

Syntax: __aktive transform reflect y__  [[→ definition](../../../../file?ci=trunk&ln=601&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image specifying a reflection along the y-axis.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

When not used as part of a chain of transformations then this is better done using [aktive op flip y](transform_structure.md#op_flip_y)

#### <a name='transform_reflect_y__examples'></a> Examples

<table>
<tr><th>aktive transform reflect y 
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>-1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(reflect y)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>-1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>-1.0000</td><td>0.0000</td></tr><tr><td>-0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_rotate'></a> aktive transform rotate

Syntax: __aktive transform rotate__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=349&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image specifying a rotation around the coordinate origin, by the given angle (in degrees).

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|double||In degrees, angle to rotate|
|around|point|{}|Rotation center. Default is the origin|

#### <a name='transform_rotate__examples'></a> Examples

<table>
<tr><th>aktive transform rotate by 45
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(rotate by 45)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.7071</td><td>0.7071</td><td>-0.0000</td></tr><tr><td>-0.7071</td><td>0.7071</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_scale'></a> aktive transform scale

Syntax: __aktive transform scale__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=240&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image specifying a scaling by x- and y factors.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|double|1|Scaling factor for x-axis|
|y|double|1|Scaling factor for y-axis|

#### <a name='transform_scale__examples'></a> Examples

<table>
<tr><th>aktive transform scale x 3 y 0.5
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>3.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.5000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(scale x 3 y 1/2)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>3.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.5000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>0.3333</td><td>-0.0000</td><td>0.0000</td></tr><tr><td>-0.0000</td><td>2.0000</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_shear'></a> aktive transform shear

Syntax: __aktive transform shear__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=296&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image specifying a shearing along the axes. When both X and Y angles are specified the result will shear X first, then shear Y.

__Beware__ that angles at +/- 90 degrees are poles of infinity.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|double|0|Angle for shearing away from the x-axis. __Beware__ that +/- 90 degrees are poles of infinity.|
|y|double|0|Angle for shearing away from the y-axis. __Beware__ that +/- 90 degrees are poles of infinity.|

#### <a name='transform_shear__examples'></a> Examples

<table>
<tr><th>aktive transform shear x 10
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.1763</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>aktive transform shear y 10
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.1763</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>aktive transform shear x 5 y 3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0875</td><td>0.0000</td></tr><tr><td>0.0524</td><td>1.0046</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(shear x 5 y 3)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0875</td><td>0.0000</td></tr><tr><td>0.0524</td><td>1.0046</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0046</td><td>-0.0875</td><td>0.0000</td></tr><tr><td>-0.0524</td><td>1.0000</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='transform_translate'></a> aktive transform translate

Syntax: __aktive transform translate__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=268&name=etc/generator/virtual/warp.tcl)]

Returns a single-band 3x3 image specifying a translation by x- and y offsets.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|double|0|Translation offset for x-axis|
|y|double|0|Translation offset for y-axis|

#### <a name='transform_translate__examples'></a> Examples

<table>
<tr><th>aktive transform translate x 3 y 1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>3.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(translate x 3 y 1)</th>
    <th>@2
    <br>(invert)</th>
    <th>aktive transform compose @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>3.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>-0.0000</td><td>-3.0000</td></tr><tr><td>-0.0000</td><td>1.0000</td><td>-1.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='warp_matrix'></a> aktive warp matrix

Syntax: __aktive warp matrix__ transform ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=5&name=etc/generator/virtual/warp/matrix.tcl)]

Returns the origin map for the projective transformation specified by the 3x3x1 matrix (`src`) applied to an image of the given geometry and location.

__Attention__. As a origin map declares origin positions for output pixels the matrix has to specify a __backward transformation__.

The operations [aktive transform affine](generator_virtual_warp.md#transform_affine), [aktive transform identity](generator_virtual_warp.md#transform_identity), [aktive transform projective](generator_virtual_warp.md#transform_projective), [aktive transform quad 2quad](generator_virtual_warp.md#transform_quad_2quad), [aktive transform quad unit2](generator_virtual_warp.md#transform_quad_unit2), [aktive transform reflect line](generator_virtual_warp.md#transform_reflect_line), [aktive transform reflect x](generator_virtual_warp.md#transform_reflect_x), [aktive transform reflect y](generator_virtual_warp.md#transform_reflect_y), [aktive transform rotate](generator_virtual_warp.md#transform_rotate), [aktive transform scale](generator_virtual_warp.md#transform_scale), [aktive transform shear](generator_virtual_warp.md#transform_shear), and [aktive transform translate](generator_virtual_warp.md#transform_translate) all create matrices suitable as input to this operation.

The operations [aktive transform compose](generator_virtual_warp.md#transform_compose) and [aktive transform invert](generator_virtual_warp.md#transform_invert) enable the composition of arbitrary transformations from simpler pieces, and the conversion between forward and backward transformations.

The result is designed to be usable with the [aktive op warp bicubic](transform_structure_warp.md#op_warp_bicubic) operation and its relatives.

At the technical level the result is a 2-band image where each pixel declares its origin position.

This operator is __strict__ in the 1st input. The projective matrix is materialized and cached.

|Input|Description|
|:---|:---|
|transform|Matrix of an affine transform.|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|x|int|0|X location of the returned image in the 2D plane|
|y|int|0|Y location of the returned image in the 2D plane|

#### <a name='warp_matrix__examples'></a> Examples

<table>
<tr><th>@1
    <br>(translate x 5 y 3)</th>
    <th>aktive warp matrix @1 width 5 height 5
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>3.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>(5.0000, 3.0000)</td><td>(6.0000, 3.0000)</td><td>(7.0000, 3.0000)</td><td>(8.0000, 3.0000)</td><td>(9.0000, 3.0000)</td></tr><tr><td>(5.0000, 4.0000)</td><td>(6.0000, 4.0000)</td><td>(7.0000, 4.0000)</td><td>(8.0000, 4.0000)</td><td>(9.0000, 4.0000)</td></tr><tr><td>(5.0000, 5.0000)</td><td>(6.0000, 5.0000)</td><td>(7.0000, 5.0000)</td><td>(8.0000, 5.0000)</td><td>(9.0000, 5.0000)</td></tr><tr><td>(5.0000, 6.0000)</td><td>(6.0000, 6.0000)</td><td>(7.0000, 6.0000)</td><td>(8.0000, 6.0000)</td><td>(9.0000, 6.0000)</td></tr><tr><td>(5.0000, 7.0000)</td><td>(6.0000, 7.0000)</td><td>(7.0000, 7.0000)</td><td>(8.0000, 7.0000)</td><td>(9.0000, 7.0000)</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>(shear x 5)</th>
    <th>aktive warp matrix @1 width 5 height 5
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0875</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td>(0.0000, 0.0000)</td><td>(1.0000, 0.0000)</td><td>(2.0000, 0.0000)</td><td>(3.0000, 0.0000)</td><td>(4.0000, 0.0000)</td></tr><tr><td>(0.0875, 1.0000)</td><td>(1.0875, 1.0000)</td><td>(2.0875, 1.0000)</td><td>(3.0875, 1.0000)</td><td>(4.0875, 1.0000)</td></tr><tr><td>(0.1750, 2.0000)</td><td>(1.1750, 2.0000)</td><td>(2.1750, 2.0000)</td><td>(3.1750, 2.0000)</td><td>(4.1750, 2.0000)</td></tr><tr><td>(0.2625, 3.0000)</td><td>(1.2625, 3.0000)</td><td>(2.2625, 3.0000)</td><td>(3.2625, 3.0000)</td><td>(4.2625, 3.0000)</td></tr><tr><td>(0.3500, 4.0000)</td><td>(1.3500, 4.0000)</td><td>(2.3500, 4.0000)</td><td>(3.3500, 4.0000)</td><td>(4.3500, 4.0000)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='warp_noise_gauss'></a> aktive warp noise gauss

Syntax: __aktive warp noise gauss__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=42&name=etc/generator/virtual/warp/noise.tcl)]

Returns a origin map derived from the identity map by application of gaussian noise as displacement values.

The result is designed to be usable with the [aktive op warp bicubic](transform_structure_warp.md#op_warp_bicubic) operation and its relatives.

At the technical level the result is a 2-band image where each pixel declares its origin position.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|x|int|0|X location of the returned image in the 2D plane|
|y|int|0|Y location of the returned image in the 2D plane|
|seed|uint|[expr {int(4294967296*rand())}]|Randomizer seed. Needed only to force fixed results.|
|mean|double|0|Mean of the desired gauss distribution.|
|sigma|double|1|Sigma of the desired gauss distribution.|

#### <a name='warp_noise_gauss__examples'></a> Examples

<table>
<tr><th>aktive warp noise gauss width 5 height 5 seed 703011174
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>(-2.0121, 1.5892)</td><td>(1.3499, 0.2499)</td><td>(2.7147, -0.1152)</td><td>(3.8782, -1.6135)</td><td>(5.1449, 0.2902)</td></tr><tr><td>(-0.6889, 2.2202)</td><td>(2.3416, -0.5845)</td><td>(1.2220, -0.3694)</td><td>(3.6195, 0.7493)</td><td>(4.7044, 0.2976)</td></tr><tr><td>(0.0954, 2.3508)</td><td>(-1.0648, 0.3407)</td><td>(1.7567, 1.7429)</td><td>(4.3928, 0.8721)</td><td>(3.1299, 2.1653)</td></tr><tr><td>(-0.1816, 2.7917)</td><td>(0.6991, 4.0203)</td><td>(3.5031, 2.0773)</td><td>(2.9707, 1.2286)</td><td>(2.6036, 4.7599)</td></tr><tr><td>(-1.3935, 4.7155)</td><td>(-0.9779, 3.3744)</td><td>(2.9045, 3.9337)</td><td>(5.0461, 5.1393)</td><td>(5.4505, 3.5626)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='warp_noise_uniform'></a> aktive warp noise uniform

Syntax: __aktive warp noise uniform__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=5&name=etc/generator/virtual/warp/noise.tcl)]

Returns a origin map derived from the identity map by application of uniform noise as displacement values

The result is designed to be usable with the [aktive op warp bicubic](transform_structure_warp.md#op_warp_bicubic) operation and its relatives.

At the technical level the result is a 2-band image where each pixel declares its origin position.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|x|int|0|X location of the returned image in the 2D plane|
|y|int|0|Y location of the returned image in the 2D plane|
|seed|uint|[expr {int(4294967296*rand())}]|Randomizer seed. Needed only to force fixed results.|
|min|double|0|Minimal noise value|
|max|double|1|Maximal noise value|

#### <a name='warp_noise_uniform__examples'></a> Examples

<table>
<tr><th>aktive warp noise uniform width 5 height 5 seed 703011174
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>(0.8863, 0.8719)</td><td>(1.7793, 0.2554)</td><td>(2.4107, 0.5807)</td><td>(3.9289, 0.7495)</td><td>(4.3616, 0.7607)</td></tr><tr><td>(0.3324, 1.3431)</td><td>(1.1898, 1.9291)</td><td>(2.6310, 1.1222)</td><td>(3.3401, 1.4667)</td><td>(4.3098, 1.1832)</td></tr><tr><td>(0.5581, 2.0059)</td><td>(1.9649, 2.9972)</td><td>(2.6588, 2.9941)</td><td>(3.4623, 2.0973)</td><td>(4.0229, 2.5306)</td></tr><tr><td>(0.5197, 3.8011)</td><td>(1.9559, 3.6307)</td><td>(2.3224, 3.6220)</td><td>(3.8149, 3.1401)</td><td>(4.2486, 3.3354)</td></tr><tr><td>(0.5329, 4.0316)</td><td>(1.1691, 4.5186)</td><td>(2.8783, 4.5382)</td><td>(3.5672, 4.7050)</td><td>(4.2872, 4.0349)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='warp_swirl'></a> aktive warp swirl

Syntax: __aktive warp swirl__  ?(param value)...? [[→ definition](../../../../file?ci=trunk&ln=5&name=etc/generator/virtual/warp/swirl.tcl)]

Returns the origin map for a swirl effect around the specified __center__, with fixed rotation __phi__, a base rotation __from__, and a __decay__ factor.

The rotation angle added to a pixel is given by "__phi__ + __from__ * exp(-__radius__ * __decay__)", where __radius__ is the distance of the pixel from the __center__. A large decay reduces the swirl at shorter radii. A decay of zero disables the decay.

All parameters except for the center are optional.

The result is designed to be usable with the [aktive op warp bicubic](transform_structure_warp.md#op_warp_bicubic) operation and its relatives.

At the technical level the result is a 2-band image where each pixel declares its origin position.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|x|int|0|X location of the returned image in the 2D plane|
|y|int|0|Y location of the returned image in the 2D plane|
|center|point||Center of the swirl|
|phi|double|0|In degrees, fixed rotation to apply.|
|from|double|45|In degrees, swirl rotation at distance 0 from center.|
|decay|double|0.1|Rotation decay with distance from center.|

#### <a name='warp_swirl__examples'></a> Examples

<table>
<tr><th>aktive warp swirl width 11 height 11 center {5 5} decay 1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>(0.0033, -0.0033)</td><td>(1.0065, -0.0052)</td><td>(2.0115, -0.0069)</td><td>(3.0180, -0.0072)</td><td>(4.0240, -0.0047)</td><td>(5.0265, 0.0001)</td><td>(6.0240, 0.0049)</td><td>(7.0180, 0.0072)</td><td>(8.0115, 0.0069)</td><td>(9.0065, 0.0052)</td><td>(10.0033, 0.0033)</td></tr><tr><td>(0.0052, 0.9935)</td><td>(1.0110, 0.9890)</td><td>(2.0212, 0.9842)</td><td>(3.0360, 0.9822)</td><td>(4.0510, 0.9876)</td><td>(5.0575, 1.0004)</td><td>(6.0508, 1.0130)</td><td>(7.0358, 1.0181)</td><td>(8.0211, 1.0159)</td><td>(9.0110, 1.0110)</td><td>(10.0052, 1.0065)</td></tr><tr><td>(0.0069, 1.9885)</td><td>(1.0159, 1.9789)</td><td>(2.0340, 1.9663)</td><td>(3.0645, 1.9580)</td><td>(4.1003, 1.9684)</td><td>(5.1173, 2.0023)</td><td>(6.0992, 2.0349)</td><td>(7.0636, 2.0434)</td><td>(8.0337, 2.0340)</td><td>(9.0158, 2.0212)</td><td>(10.0069, 2.0115)</td></tr><tr><td>(0.0072, 2.9820)</td><td>(1.0181, 2.9642)</td><td>(2.0434, 2.9364)</td><td>(3.0950, 2.9093)</td><td>(4.1712, 2.9232)</td><td>(5.2122, 3.0113)</td><td>(6.1642, 3.0909)</td><td>(7.0907, 3.0950)</td><td>(8.0420, 3.0645)</td><td>(9.0178, 3.0360)</td><td>(10.0072, 3.0180)</td></tr><tr><td>(0.0049, 3.9760)</td><td>(1.0130, 3.9492)</td><td>(2.0349, 3.9008)</td><td>(3.0909, 3.8358)</td><td>(4.2080, 3.8284)</td><td>(5.2849, 4.0415)</td><td>(6.1716, 4.2080)</td><td>(7.0768, 4.1712)</td><td>(8.0316, 4.1003)</td><td>(9.0124, 4.0510)</td><td>(10.0047, 4.0240)</td></tr><tr><td>(0.0001, 4.9735)</td><td>(1.0004, 4.9425)</td><td>(2.0023, 4.8827)</td><td>(3.0113, 4.7878)</td><td>(4.0415, 4.7151)</td><td>(5.0000, 5.0000)</td><td>(5.9585, 5.2849)</td><td>(6.9887, 5.2122)</td><td>(7.9977, 5.1173)</td><td>(8.9996, 5.0575)</td><td>(9.9999, 5.0265)</td></tr><tr><td>(-0.0047, 5.9760)</td><td>(0.9876, 5.9490)</td><td>(1.9684, 5.8997)</td><td>(2.9232, 5.8288)</td><td>(3.8284, 5.7920)</td><td>(4.7151, 5.9585)</td><td>(5.7920, 6.1716)</td><td>(6.9091, 6.1642)</td><td>(7.9651, 6.0992)</td><td>(8.9870, 6.0508)</td><td>(9.9951, 6.0240)</td></tr><tr><td>(-0.0072, 6.9820)</td><td>(0.9822, 6.9640)</td><td>(1.9580, 6.9355)</td><td>(2.9093, 6.9050)</td><td>(3.8358, 6.9091)</td><td>(4.7878, 6.9887)</td><td>(5.8288, 7.0768)</td><td>(6.9050, 7.0907)</td><td>(7.9566, 7.0636)</td><td>(8.9819, 7.0358)</td><td>(9.9928, 7.0180)</td></tr><tr><td>(-0.0069, 7.9885)</td><td>(0.9842, 7.9788)</td><td>(1.9663, 7.9660)</td><td>(2.9364, 7.9566)</td><td>(3.9008, 7.9651)</td><td>(4.8827, 7.9977)</td><td>(5.8997, 8.0316)</td><td>(6.9355, 8.0420)</td><td>(7.9660, 8.0337)</td><td>(8.9841, 8.0211)</td><td>(9.9931, 8.0115)</td></tr><tr><td>(-0.0052, 8.9935)</td><td>(0.9890, 8.9890)</td><td>(1.9789, 8.9841)</td><td>(2.9642, 8.9819)</td><td>(3.9492, 8.9870)</td><td>(4.9425, 8.9996)</td><td>(5.9490, 9.0124)</td><td>(6.9640, 9.0178)</td><td>(7.9788, 9.0158)</td><td>(8.9890, 9.0110)</td><td>(9.9948, 9.0065)</td></tr><tr><td>(-0.0033, 9.9967)</td><td>(0.9935, 9.9948)</td><td>(1.9885, 9.9931)</td><td>(2.9820, 9.9928)</td><td>(3.9760, 9.9951)</td><td>(4.9735, 9.9999)</td><td>(5.9760, 10.0047)</td><td>(6.9820, 10.0072)</td><td>(7.9885, 10.0069)</td><td>(8.9935, 10.0052)</td><td>(9.9967, 10.0033)</td></tr></table></td></tr>
</table>


