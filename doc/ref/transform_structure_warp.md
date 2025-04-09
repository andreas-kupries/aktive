<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform structure warp

## <anchor='top'> Table Of Contents

  - [transform structure](transform_structure.md) ↗


### Operators

 - [aktive op transform by](#op_transform_by)
 - [aktive op warp bicubic](#op_warp_bicubic)
 - [aktive op warp bilinear](#op_warp_bilinear)
 - [aktive op warp lanczos](#op_warp_lanczos)
 - [aktive op warp near-neighbour](#op_warp_near_neighbour)

## Operators

---
### [↑](#top) <a name='op_transform_by'></a> aktive op transform by

Syntax: __aktive op transform by__ transform src ?(param value)...? [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/structure/transform.tcl)]

Applies the projective __forward__ `transform` to the source image, using some kind of pixel interpolation, and returns the result. The default interpolation is `bilinear`.

The necessary backward transformation is computed internally.

The result's domain is set to the domain of the forward transform applied to the input domain. Fractions are rounded to integers such that the actual bounding box is kept enclosed.

The result has depth of the image.

See [aktive transform affine](generator_virtual_warp.md#transform_affine) and its relatives for a set of operations creating transformations acceptable here.

The [aktive op view](transform.md#op_view) operator is a useful means of focusing on the desired part of a transformation result.

This operator is __strict__ in the 1st input. The projective matrix is materialized for the calculation of the backward transform.

|Input|Description|
|:---|:---|
|transform|Affine forward transformation.|
|src|The image to transform.|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|interpolate|str|bilinear|Interpolation method to use|

#### <a name='op_transform_by__examples'></a> Examples

<a name='op_transform_by__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(rotate by 30 around {10 50})</th>
    <th>aktive op transform by @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00633.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><table><tr><td>0.8660</td><td>-0.5000</td><td>26.3397</td></tr><tr><td>0.5000</td><td>0.8660</td><td>1.6987</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td valign='top'>bframe</td><td valign='top'><img src='example-00635.gif' alt='aktive op transform by @2 @1' style='border:4px solid gold'>
    <br>geometry(-98 1 454 407 3)</td></tr></table></td></tr>
</table>

<a name='op_transform_by__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(scale x 0.5 y 1.5)</th>
    <th>aktive op transform by @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00636.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><table><tr><td>0.5000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.5000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><img src='example-00638.gif' alt='aktive op transform by @2 @1' style='border:4px solid gold'>
    <br>geometry(0 0 191 375 3)</td></tr>
</table>

<a name='op_transform_by__examples__e3'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(shear x 20 y 10)</th>
    <th>aktive op transform by @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00639.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.3640</td><td>0.0000</td></tr><tr><td>0.1763</td><td>1.0642</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><img src='example-00641.gif' alt='aktive op transform by @2 @1' style='border:4px solid gold'>
    <br>geometry(0 0 471 333 3)</td></tr>
</table>

<a name='op_transform_by__examples__e4'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(reflect x)</th>
    <th>aktive op transform by @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00642.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><table><tr><td>-1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><img src='example-00644.gif' alt='aktive op transform by @2 @1' style='border:4px solid gold'>
    <br>geometry(-379 0 380 250 3)</td></tr>
</table>

<a name='op_transform_by__examples__e5'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(reflect y)</th>
    <th>aktive op transform by @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00645.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><table><tr><td>1.0000</td><td>0.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>-1.0000</td><td>0.0000</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><img src='example-00647.gif' alt='aktive op transform by @2 @1' style='border:4px solid gold'>
    <br>geometry(0 -249 380 250 3)</td></tr>
</table>

<a name='op_transform_by__examples__e6'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(reflect line {50 260} b {150 -10})</th>
    <th>aktive op transform by @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00648.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><table><tr><td>-0.7587</td><td>-0.6514</td><td>257.2979</td></tr><tr><td>-0.6514</td><td>0.7587</td><td>95.2955</td></tr><tr><td>0.0000</td><td>0.0000</td><td>1.0000</td></tr></table></td>
    <td valign='top'><table><tr><td valign='top'>bframe</td><td valign='top'><img src='example-00650.gif' alt='aktive op transform by @2 @1' style='border:4px solid gold'>
    <br>geometry(-192 -151 451 437 3)</td></tr></table></td></tr>
</table>

<a name='op_transform_by__examples__e7'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>(quadrilateral)</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op view @3 port {0 0 100 100}
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00651.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><table><tr><td>0.4944</td><td>-0.4159</td><td>2.5504</td></tr><tr><td>0.3440</td><td>0.9460</td><td>-74.8181</td></tr><tr><td>-0.0014</td><td>-0.0023</td><td>1.2110</td></tr></table></td>
    <td valign='top'><img src='example-00653.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(-161 -61 1036 3006 3)</td>
    <td valign='top'><img src='example-00654.gif' alt='aktive op view @3 port {0 0 100 100}' style='border:4px solid gold'>
    <br>geometry(0 0 100 100 3)</td></tr>
</table>


---
### [↑](#top) <a name='op_warp_bicubic'></a> aktive op warp bicubic

Syntax: __aktive op warp bicubic__ origins src [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/structure/warp.tcl)]

Returns an image generated by the application of the origin map to the image, with bicubic interpolation.

The result has the domain of the origin map, and the depth of the image.

See [aktive transform affine](generator_virtual_warp.md#transform_affine) and its relatives for a set of operations creating origin maps acceptable here.

|Input|Description|
|:---|:---|
|origins|Origin map to wrap the `src` by.|
|src|Image to warp by the `origin`.|

#### <a name='op_warp_bicubic__references'></a> References

  - <http://en.wikipedia.org/wiki/Bicubic_interpolation>

  - <http://www.paulinternet.nl/?page=bicubic>

---
### [↑](#top) <a name='op_warp_bilinear'></a> aktive op warp bilinear

Syntax: __aktive op warp bilinear__ origins src [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/structure/warp.tcl)]

Returns an image generated by the application of the origin map to the image, with bilinear interpolation.

The result has the domain of the origin map, and the depth of the image.

See [aktive transform affine](generator_virtual_warp.md#transform_affine) and its relatives for a set of operations creating origin maps acceptable here.

|Input|Description|
|:---|:---|
|origins|Origin map to wrap the `src` by.|
|src|Image to warp by the `origin`.|

#### <a name='op_warp_bilinear__references'></a> References

  - <https://en.wikipedia.org/wiki/Bilinear_interpolation>

---
### [↑](#top) <a name='op_warp_lanczos'></a> aktive op warp lanczos

Syntax: __aktive op warp lanczos__ origins src [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/structure/warp.tcl)]

Returns an image generated by the application of the origin map to the image, with order-3 lanczos interpolation.

The result has the domain of the origin map, and the depth of the image.

See [aktive transform affine](generator_virtual_warp.md#transform_affine) and its relatives for a set of operations creating origin maps acceptable here.

|Input|Description|
|:---|:---|
|origins|Origin map to wrap the `src` by.|
|src|Image to warp by the `origin`.|

#### <a name='op_warp_lanczos__references'></a> References

  - <https://mazzo.li/posts/lanczos.html>

  - <https://en.wikipedia.org/wiki/Lanczos_resampling>

  - <https://github.com/jeffboody/Lanczos>

---
### [↑](#top) <a name='op_warp_near_neighbour'></a> aktive op warp near-neighbour

Syntax: __aktive op warp near-neighbour__ origins src [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/structure/warp.tcl)]

Returns an image generated by the application of the origin map to the image, with nearest neighbour interpolation.

The result has the domain of the origin map, and the depth of the image.

See [aktive transform affine](generator_virtual_warp.md#transform_affine) and its relatives for a set of operations creating origin maps acceptable here.

|Input|Description|
|:---|:---|
|origins|Origin map to wrap the `src` by.|
|src|Image to warp by the `origin`.|

#### <a name='op_warp_near_neighbour__references'></a> References

  - <https://en.wikipedia.org/wiki/Nearest-neighbor_interpolation>

