<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- generator virtual warp

## Table Of Contents

  - [generator virtual](generator_virtual.md) ↗


### Operators

 - [aktive transform affine](#transform_affine)
 - [aktive transform compose](#transform_compose)
 - [aktive transform compose-core](#transform_compose_core)
 - [aktive transform identity](#transform_identity)
 - [aktive transform invert](#transform_invert)
 - [aktive transform projective](#transform_projective)
 - [aktive transform quad quad](#transform_quad_quad)
 - [aktive transform quad unit](#transform_quad_unit)
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
### <a name='transform_affine'></a> aktive transform affine

Syntax: __aktive transform affine__  (param value)...

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

## Examples

<table><tr><th>aktive transform affine a 1 b 2 c 3 d 4 e 5 f 6</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td></tr><tr><td>4</td><td>5</td><td>6</td></tr><tr><td>0</td><td>0</td><td>1</td></tr></table></td></tr></table>


---
### <a name='transform_compose'></a> aktive transform compose

Syntax: __aktive transform compose__ srcs...

Takes any number of 3x3 projective transformation matrices and returns their composition.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

This operator is __strict__ in all inputs. All projective matrices are materialized and immediately used to compute the composition.


## Examples

<table><tr><th>@1 (translate x -5 y -6)</th><th>@2 (rotate by 45)</th><th>@3 (translate x 5 y 6)</th><th>aktive transform compose @1 @2 @3 (rotate 45 around (5,6))</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>-6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>-5.7071</td></tr><tr><td>0.7071</td><td>0.7071</td><td>1.7782</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_compose_core'></a> aktive transform compose-core

Syntax: __aktive transform compose-core__ src0 src1

Takes two 3x3 projective transformation matrices and returns their composition.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

This operator is __strict__ in both inputs. The two projective matrices are materialized and immediately used to compute the composition A*B.


## Examples

<table><tr><th>@1 (rotate)</th><th>@2 (translate)</th><th>aktive transform compose-core @1 @2 (rotate after translate)</th></tr>
<tr><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>-0.7071</td></tr><tr><td>0.7071</td><td>0.7071</td><td>7.7782</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (rotate)</th><th>@2 (translate)</th><th>aktive transform compose-core @1 @2 (translate after rotate)</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>5.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_identity'></a> aktive transform identity

Syntax: __aktive transform identity__ 

Returns a single-band 3x3 image containing the identity transform.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)


## Examples

<table><tr><th>aktive transform identity </th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_invert'></a> aktive transform invert

Syntax: __aktive transform invert__ src

Takes a single 3x3 projective transformation matrix and returns the matrix of the inverted transformation. This is used to turn forward into backward transformations, and vice versa.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

This operator is __strict__ in the 1st input. The projective matrix is materialized and immediately used to compute the inversion.


## Examples

<table><tr><th>@1 (translate x -5 y -6)</th><th>aktive transform invert @1</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>-6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>-0.0000</td><td>5.0000</td></tr><tr><td>-0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (translate x -5 y -6)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>-6.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>-0.0000</td><td>5.0000</td></tr><tr><td>-0.0000</td><td>1.0000</td><td>6.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_projective'></a> aktive transform projective

Syntax: __aktive transform projective__  (param value)...

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

## Examples

<table><tr><th>aktive transform projective a 1 b 2 c 3 d 4 e 5 f 6 g 7 h 8</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td></tr><tr><td>4</td><td>5</td><td>6</td></tr><tr><td>7</td><td>8</td><td>1</td></tr></table></td></tr></table>


---
### <a name='transform_quad_quad'></a> aktive transform quad quad

Syntax: __aktive transform quad quad__  (param value)...

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

## Examples

<table><tr><th>aktive transform quad quad a {1 2} b {6 1} c {7 6} d {2 7}   e {0 3} f {7 1} g {8 7} h {1 7}</th></tr>
<tr><td valign='top'><table><tr><td>0.9377</td><td>0.0220</td><td>-0.9817</td></tr><tr><td>-0.2821</td><td>0.9231</td><td>1.4359</td></tr><tr><td>-0.0623</td><td>0.0220</td><td>1.0183</td></tr></table></td></tr></table>

<table><tr><th>@1</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>0.9377</td><td>0.0220</td><td>-0.9817</td></tr><tr><td>-0.2821</td><td>0.9231</td><td>1.4359</td></tr><tr><td>-0.0623</td><td>0.0220</td><td>1.0183</td></tr></table></td><td valign='top'><table><tr><td>1.1273</td><td>-0.0545</td><td>1.1636</td></tr><tr><td>0.2455</td><td>1.1091</td><td>-1.3273</td></tr><tr><td>0.0636</td><td>-0.0273</td><td>1.0818</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-0.0000</td></tr><tr><td>-0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_quad_unit'></a> aktive transform quad unit

Syntax: __aktive transform quad unit__  (param value)...

Returns a single-band 3x3 image transforming the unit square to the specified quadrilateral.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

The quadrilateral is specified as 4 points A-B-C-D in counter clockwise order. The returned transform maps the origin of the unit square to A and then the other points in counter clockwise order.

To map between two arbitrary quadrilaterals A and B a composition of two transforms is necessary and sufficient, i.e. mapping A to the unit square (as inversion of the map from unit square to A), followed by mapping the unit square to B. This is what [aktive transform quad quad](generator_virtual_warp.md#transform_quad_quad) does.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|point||Point A of the quadrilateral|
|b|point||Point B of the quadrilateral|
|c|point||Point C of the quadrilateral|
|d|point||Point D of the quadrilateral|

## Examples

<table><tr><th>aktive transform quad unit a {1 2} b {6 1} c {7 6} d {2 7}</th></tr>
<tr><td valign='top'><table><tr><td>5.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>-1.0000</td><td>5.0000</td><td>2.0000</td></tr><tr><td>-0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>5.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>-1.0000</td><td>5.0000</td><td>2.0000</td></tr><tr><td>-0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.1923</td><td>-0.0385</td><td>-0.1154</td></tr><tr><td>0.0385</td><td>0.1923</td><td>-0.4231</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_reflect_line'></a> aktive transform reflect line

Syntax: __aktive transform reflect line__  ?(param value)...?

Returns a single-band 3x3 image specifying a reflection along either the line through point A and the origin, or the line through points A and B.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|point||Point A of the line to reflect over|
|b|point|{}|Point B of the line to reflect over. If not specified, the origin is used|

## Examples

<table><tr><th>aktive transform reflect line a {5 3}</th></tr>
<tr><td valign='top'><table><tr><td>0.4706</td><td>0.8824</td><td>0.0000</td></tr><tr><td>0.8824</td><td>-0.4706</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (reflect line 0--A)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>0.4706</td><td>0.8824</td><td>0.0000</td></tr><tr><td>0.8824</td><td>-0.4706</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.4706</td><td>0.8824</td><td>-0.0000</td></tr><tr><td>0.8824</td><td>-0.4706</td><td>0.0000</td></tr><tr><td>-0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>aktive transform reflect line a {5 3} b {-2 -2}</th></tr>
<tr><td valign='top'><table><tr><td>0.3243</td><td>0.9459</td><td>0.5405</td></tr><tr><td>0.9459</td><td>-0.3243</td><td>-0.7568</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (reflect line A--B)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>0.3243</td><td>0.9459</td><td>0.5405</td></tr><tr><td>0.9459</td><td>-0.3243</td><td>-0.7568</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.3243</td><td>0.9459</td><td>0.5405</td></tr><tr><td>0.9459</td><td>-0.3243</td><td>-0.7568</td></tr><tr><td>-0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>-0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_reflect_x'></a> aktive transform reflect x

Syntax: __aktive transform reflect x__ 

Returns a single-band 3x3 image specifying a reflection along the x-axis.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

When not used as part of a chain of transformations then this is better done using [aktive op flip x](transform_structure.md#op_flip_x)


## Examples

<table><tr><th>aktive transform reflect x </th></tr>
<tr><td valign='top'><table><tr><td>-1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (reflect x)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>-1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>-1.0000</td><td>0.0000</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>-0.0000</td></tr><tr><td>-0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_reflect_y'></a> aktive transform reflect y

Syntax: __aktive transform reflect y__ 

Returns a single-band 3x3 image specifying a reflection along the y-axis.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

When not used as part of a chain of transformations then this is better done using [aktive op flip y](transform_structure.md#op_flip_y)


## Examples

<table><tr><th>aktive transform reflect y </th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>-1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (reflect y)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>-1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>-1.0000</td><td>0.0000</td></tr><tr><td>-0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_rotate'></a> aktive transform rotate

Syntax: __aktive transform rotate__  (param value)...

Returns a single-band 3x3 image specifying a rotation around the coordinate origin, by the given angle (in degrees).

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|double||In degrees, angle to rotate|

## Examples

<table><tr><th>aktive transform rotate by 45</th></tr>
<tr><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (rotate by 45)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>0.7071</td><td>-0.7071</td><td>0.0000</td></tr><tr><td>0.7071</td><td>0.7071</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.7071</td><td>0.7071</td><td>-0.0000</td></tr><tr><td>-0.7071</td><td>0.7071</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_scale'></a> aktive transform scale

Syntax: __aktive transform scale__  ?(param value)...?

Returns a single-band 3x3 image specifying a scaling by x- and y factors.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|double|1|Scaling factor for x-axis|
|y|double|1|Scaling factor for y-axis|

## Examples

<table><tr><th>aktive transform scale x 3 y 0.5</th></tr>
<tr><td valign='top'><table><tr><td>3.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.5000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (scale x 3 y 1/2)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>3.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.5000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>0.3333</td><td>-0.0000</td><td>0.0000</td></tr><tr><td>-0.0000</td><td>2.0000</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_shear'></a> aktive transform shear

Syntax: __aktive transform shear__  ?(param value)...?

Returns a single-band 3x3 image specifying a shearing along the axes.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|double|0|Shear by this many pixels along the x-axis|
|y|double|0|Shear by this many pixels along the y-axis|

## Examples

<table><tr><th>aktive transform shear x 10</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>10.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>aktive transform shear y 10</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>10.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>aktive transform shear x 5 y 3</th></tr>
<tr><td valign='top'><table><tr><td>16.0000</td><td>5.0000</td><td>0.0000</td></tr><tr><td>3.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (shear x 5 y 3)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>16.0000</td><td>5.0000</td><td>0.0000</td></tr><tr><td>3.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>-5.0000</td><td>0.0000</td></tr><tr><td>-3.0000</td><td>16.0000</td><td>-0.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='transform_translate'></a> aktive transform translate

Syntax: __aktive transform translate__  ?(param value)...?

Returns a single-band 3x3 image specifying a translation by x- and y offsets.

The result is suitable for use with [aktive warp matrix](generator_virtual_warp.md#warp_matrix)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|double|0|Translation offset for x-axis|
|y|double|0|Translation offset for y-axis|

## Examples

<table><tr><th>aktive transform translate x 3 y 1</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>3.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>

<table><tr><th>@1 (translate x 3 y 1)</th><th>@2 (invert)</th><th>aktive transform compose @1 @2</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>3.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>1.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>-0.0000</td><td>-3.0000</td></tr><tr><td>-0.0000</td><td>1.0000</td><td>-1.0000</td></tr><tr><td>0.0000</td><td>-0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td></tr></table>


---
### <a name='warp_matrix'></a> aktive warp matrix

Syntax: __aktive warp matrix__ src ?(param value)...?

Returns the warp map for the general transformation specified by the 3x3x1 input matrix.

__Attention__. As a warp map declares origin positions for output pixels the matrix has to specify a __backward transformation__.

The operations [aktive transform affine](generator_virtual_warp.md#transform_affine), [aktive transform identity](generator_virtual_warp.md#transform_identity), [aktive transform projective](generator_virtual_warp.md#transform_projective), [aktive transform quad quad](generator_virtual_warp.md#transform_quad_quad), [aktive transform quad unit](generator_virtual_warp.md#transform_quad_unit), [aktive transform reflect line](generator_virtual_warp.md#transform_reflect_line), [aktive transform reflect x](generator_virtual_warp.md#transform_reflect_x), [aktive transform reflect y](generator_virtual_warp.md#transform_reflect_y), [aktive transform rotate](generator_virtual_warp.md#transform_rotate), [aktive transform scale](generator_virtual_warp.md#transform_scale), [aktive transform shear](generator_virtual_warp.md#transform_shear), and [aktive transform translate](generator_virtual_warp.md#transform_translate) all create matrices suitable as input to this operation.

The operations [aktive transform compose](generator_virtual_warp.md#transform_compose) and [aktive transform invert](generator_virtual_warp.md#transform_invert) enable the composition of arbitrary transformations from simpler pieces, and the conversion between forward and backward transformations.

The result is designed to be usable with the <!xref: aktive op warp> operation.

At the technical level the result is a 2-band image where each pixel declares its origin position.

This operator is __strict__ in the 1st input. The projective matrix is materialized and cached.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|x|int|0|X location of the returned image in the 2D plane|
|y|int|0|Y location of the returned image in the 2D plane|

## Examples

<table><tr><th>@1 (translate x 5 y 3)</th><th>aktive warp matrix @1 width 5 height 5</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>5.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>3.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>(5.0000, 3.0000)</td><td>(6.0000, 3.0000)</td><td>(7.0000, 3.0000)</td><td>(8.0000, 3.0000)</td><td>(9.0000, 3.0000)</td></tr><tr><td>(5.0000, 4.0000)</td><td>(6.0000, 4.0000)</td><td>(7.0000, 4.0000)</td><td>(8.0000, 4.0000)</td><td>(9.0000, 4.0000)</td></tr><tr><td>(5.0000, 5.0000)</td><td>(6.0000, 5.0000)</td><td>(7.0000, 5.0000)</td><td>(8.0000, 5.0000)</td><td>(9.0000, 5.0000)</td></tr><tr><td>(5.0000, 6.0000)</td><td>(6.0000, 6.0000)</td><td>(7.0000, 6.0000)</td><td>(8.0000, 6.0000)</td><td>(9.0000, 6.0000)</td></tr><tr><td>(5.0000, 7.0000)</td><td>(6.0000, 7.0000)</td><td>(7.0000, 7.0000)</td><td>(8.0000, 7.0000)</td><td>(9.0000, 7.0000)</td></tr></table></td></tr></table>

<table><tr><th>@1 (shear x 5)</th><th>aktive warp matrix @1 width 5 height 5</th></tr>
<tr><td valign='top'><table><tr><td>1.0000</td><td>5.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td><td valign='top'><table><tr><td>(0.0000, 0.0000)</td><td>(1.0000, 0.0000)</td><td>(2.0000, 0.0000)</td><td>(3.0000, 0.0000)</td><td>(4.0000, 0.0000)</td></tr><tr><td>(5.0000, 1.0000)</td><td>(6.0000, 1.0000)</td><td>(7.0000, 1.0000)</td><td>(8.0000, 1.0000)</td><td>(9.0000, 1.0000)</td></tr><tr><td>(10.0000, 2.0000)</td><td>(11.0000, 2.0000)</td><td>(12.0000, 2.0000)</td><td>(13.0000, 2.0000)</td><td>(14.0000, 2.0000)</td></tr><tr><td>(15.0000, 3.0000)</td><td>(16.0000, 3.0000)</td><td>(17.0000, 3.0000)</td><td>(18.0000, 3.0000)</td><td>(19.0000, 3.0000)</td></tr><tr><td>(20.0000, 4.0000)</td><td>(21.0000, 4.0000)</td><td>(22.0000, 4.0000)</td><td>(23.0000, 4.0000)</td><td>(24.0000, 4.0000)</td></tr></table></td></tr></table>


---
### <a name='warp_noise_gauss'></a> aktive warp noise gauss

Syntax: __aktive warp noise gauss__  ?(param value)...?

Returns a warp map derived from the identity map by application of gaussian noise as displacement values.

The result is designed to be usable with the <!xref aktive op warp> operation.

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

## Examples

<table><tr><th>aktive warp noise gauss width 5 height 5 seed 703011174</th></tr>
<tr><td valign='top'><table><tr><td>(-2.0121, 1.5892)</td><td>(1.3499, 0.2499)</td><td>(2.7147, -0.1152)</td><td>(3.8782, -1.6135)</td><td>(5.1449, 0.2902)</td></tr><tr><td>(-0.6889, 2.2202)</td><td>(2.3416, -0.5845)</td><td>(1.2220, -0.3694)</td><td>(3.6195, 0.7493)</td><td>(4.7044, 0.2976)</td></tr><tr><td>(0.0954, 2.3508)</td><td>(-1.0648, 0.3407)</td><td>(1.7567, 1.7429)</td><td>(4.3928, 0.8721)</td><td>(3.1299, 2.1653)</td></tr><tr><td>(-0.1816, 2.7917)</td><td>(0.6991, 4.0203)</td><td>(3.5031, 2.0773)</td><td>(2.9707, 1.2286)</td><td>(2.6036, 4.7599)</td></tr><tr><td>(-1.3935, 4.7155)</td><td>(-0.9779, 3.3744)</td><td>(2.9045, 3.9337)</td><td>(5.0461, 5.1393)</td><td>(5.4505, 3.5626)</td></tr></table></td></tr></table>


---
### <a name='warp_noise_uniform'></a> aktive warp noise uniform

Syntax: __aktive warp noise uniform__  ?(param value)...?

Returns a warp map derived from the identity map by application of uniform noise as displacement values

The result is designed to be usable with the <!xref aktive op warp> operation.

At the technical level the result is a 2-band image where each pixel declares its origin position.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|x|int|0|X location of the returned image in the 2D plane|
|y|int|0|Y location of the returned image in the 2D plane|
|seed|uint|[expr {int(4294967296*rand())}]|Randomizer seed. Needed only to force fixed results.|

## Examples

<table><tr><th>aktive warp noise uniform width 5 height 5 seed 703011174</th></tr>
<tr><td valign='top'><table><tr><td>(0.8863, 0.8719)</td><td>(1.7793, 0.2554)</td><td>(2.4107, 0.5807)</td><td>(3.9289, 0.7495)</td><td>(4.3616, 0.7607)</td></tr><tr><td>(0.3324, 1.3431)</td><td>(1.1898, 1.9291)</td><td>(2.6310, 1.1222)</td><td>(3.3401, 1.4667)</td><td>(4.3098, 1.1832)</td></tr><tr><td>(0.5581, 2.0059)</td><td>(1.9649, 2.9972)</td><td>(2.6588, 2.9941)</td><td>(3.4623, 2.0973)</td><td>(4.0229, 2.5306)</td></tr><tr><td>(0.5197, 3.8011)</td><td>(1.9559, 3.6307)</td><td>(2.3224, 3.6220)</td><td>(3.8149, 3.1401)</td><td>(4.2486, 3.3354)</td></tr><tr><td>(0.5329, 4.0316)</td><td>(1.1691, 4.5186)</td><td>(2.8783, 4.5382)</td><td>(3.5672, 4.7050)</td><td>(4.2872, 4.0349)</td></tr></table></td></tr></table>


---
### <a name='warp_swirl'></a> aktive warp swirl

Syntax: __aktive warp swirl__  ?(param value)...?

Returns the warp map for a swirl effect around the specified __center__, with fixed rotation __phi__, a __base__ rotation, and a __decay__ factor.

The rotation angle to add to a pixel is given by "__phi__ + __base__*exp(-__radius__/(__decay__^2))", where __radius__ is the distance of the pixel from the __center__.

All parameter except for the center are optional.

The result is designed to be usable with the <!xref aktive op warp> operation.

At the technical level the result is a 2-band image where each pixel declares its origin position.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|x|int|0|X location of the returned image in the 2D plane|
|y|int|0|Y location of the returned image in the 2D plane|
|center|point||Center of the swirl|
|phi|double|0|In degrees, fixed rotation to apply.|
|base|double|45|In degrees, swirl rotation at distance 0 from center.|
|decay|double|4|Rotation decay with distance from center.|

## Examples

<table><tr><th>aktive warp swirl width 11 height 11 center {5 5} decay 16</th></tr>
<tr><td valign='top'><table><tr><td>(0.1081, 10.1058)</td><td>(-0.3437, 9.5235)</td><td>(-0.5474, 8.7447)</td><td>(-0.3850, 7.7331)</td><td>(0.2555, 6.4940)</td><td>(1.4112, 5.1074)</td><td>(2.9858, 3.7208)</td><td>(4.7807, 2.4816)</td><td>(6.5988, 1.4698)</td><td>(8.3178, 0.6907)</td><td>(9.8919, 0.1081)</td></tr><tr><td>(1.6822, 9.4850)</td><td>(1.0692, 9.0681)</td><td>(0.6530, 8.4625)</td><td>(0.5818, 7.5984)</td><td>(1.0408, 6.4407)</td><td>(2.1373, 5.0689)</td><td>(3.7501, 3.6970)</td><td>(5.5722, 2.5392)</td><td>(7.3373, 1.6750)</td><td>(8.9308, 1.0692)</td><td>(10.3437, 0.6521)</td></tr><tr><td>(3.4012, 8.6761)</td><td>(2.6627, 8.4324)</td><td>(2.0390, 8.0385)</td><td>(1.6813, 7.3920)</td><td>(1.8653, 6.3804)</td><td>(2.8594, 5.0388)</td><td>(4.5226, 3.6972)</td><td>(6.3361, 2.6855)</td><td>(7.9610, 2.0390)</td><td>(9.3470, 1.6449)</td><td>(10.5474, 1.4011)</td></tr><tr><td>(5.2193, 7.6430)</td><td>(4.4278, 7.5468)</td><td>(3.6639, 7.3705)</td><td>(3.0173, 7.0172)</td><td>(2.7886, 6.2822)</td><td>(3.5772, 5.0173)</td><td>(5.3011, 3.7524)</td><td>(6.9827, 3.0173)</td><td>(8.3187, 2.6640)</td><td>(9.4182, 2.4876)</td><td>(10.3850, 2.3914)</td></tr><tr><td>(7.0142, 6.3909)</td><td>(6.2499, 6.3762)</td><td>(5.4774, 6.3459)</td><td>(4.6989, 6.2692)</td><td>(4.0043, 6.0043)</td><td>(4.2907, 5.0043)</td><td>(5.9957, 4.0043)</td><td>(7.2114, 3.7394)</td><td>(8.1347, 3.6627)</td><td>(8.9592, 3.6324)</td><td>(9.7445, 3.6177)</td></tr><tr><td>(8.5888, 5.0000)</td><td>(7.8627, 5.0000)</td><td>(7.1406, 5.0000)</td><td>(6.4228, 5.0000)</td><td>(5.7093, 5.0000)</td><td>(5.0000, 5.0000)</td><td>(5.7093, 5.0000)</td><td>(6.4228, 5.0000)</td><td>(7.1406, 5.0000)</td><td>(7.8627, 5.0000)</td><td>(8.5888, 5.0000)</td></tr><tr><td>(9.7445, 3.6177)</td><td>(8.9592, 3.6324)</td><td>(8.1347, 3.6627)</td><td>(7.2114, 3.7394)</td><td>(5.9957, 4.0043)</td><td>(4.2907, 5.0043)</td><td>(4.0043, 6.0043)</td><td>(4.6989, 6.2692)</td><td>(5.4774, 6.3459)</td><td>(6.2499, 6.3762)</td><td>(7.0142, 6.3909)</td></tr><tr><td>(10.3850, 2.3914)</td><td>(9.4182, 2.4876)</td><td>(8.3187, 2.6640)</td><td>(6.9827, 3.0173)</td><td>(5.3011, 3.7524)</td><td>(3.5772, 5.0173)</td><td>(2.7886, 6.2822)</td><td>(3.0173, 7.0172)</td><td>(3.6639, 7.3705)</td><td>(4.4278, 7.5468)</td><td>(5.2193, 7.6430)</td></tr><tr><td>(10.5474, 1.4011)</td><td>(9.3470, 1.6449)</td><td>(7.9610, 2.0390)</td><td>(6.3361, 2.6855)</td><td>(4.5226, 3.6972)</td><td>(2.8594, 5.0388)</td><td>(1.8653, 6.3804)</td><td>(1.6813, 7.3920)</td><td>(2.0390, 8.0385)</td><td>(2.6627, 8.4324)</td><td>(3.4012, 8.6761)</td></tr><tr><td>(10.3437, 0.6521)</td><td>(8.9308, 1.0692)</td><td>(7.3373, 1.6750)</td><td>(5.5722, 2.5392)</td><td>(3.7501, 3.6970)</td><td>(2.1373, 5.0689)</td><td>(1.0408, 6.4407)</td><td>(0.5818, 7.5984)</td><td>(0.6530, 8.4625)</td><td>(1.0692, 9.0681)</td><td>(1.6822, 9.4850)</td></tr><tr><td>(9.8919, 0.1081)</td><td>(8.3178, 0.6907)</td><td>(6.5988, 1.4698)</td><td>(4.7807, 2.4816)</td><td>(2.9858, 3.7208)</td><td>(1.4112, 5.1074)</td><td>(0.2555, 6.4940)</td><td>(-0.3850, 7.7331)</td><td>(-0.5474, 8.7447)</td><td>(-0.3437, 9.5235)</td><td>(0.1081, 10.1058)</td></tr></table></td></tr></table>


