<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform color

## <anchor='top'> Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op color correct greyworld global](#op_color_correct_greyworld_global)
 - [aktive op color correct greyworld local](#op_color_correct_greyworld_local)
 - [aktive op color HSL to Grey](#op_color_HSL_to_Grey)
 - [aktive op color HSL to HSV](#op_color_HSL_to_HSV)
 - [aktive op color HSL to Lab](#op_color_HSL_to_Lab)
 - [aktive op color HSL to LCh](#op_color_HSL_to_LCh)
 - [aktive op color HSL to scRGB](#op_color_HSL_to_scRGB)
 - [aktive op color HSL to sRGB](#op_color_HSL_to_sRGB)
 - [aktive op color HSL to XYZ](#op_color_HSL_to_XYZ)
 - [aktive op color HSL to Yxy](#op_color_HSL_to_Yxy)
 - [aktive op color HSV to Grey](#op_color_HSV_to_Grey)
 - [aktive op color HSV to HSL](#op_color_HSV_to_HSL)
 - [aktive op color HSV to Lab](#op_color_HSV_to_Lab)
 - [aktive op color HSV to LCh](#op_color_HSV_to_LCh)
 - [aktive op color HSV to scRGB](#op_color_HSV_to_scRGB)
 - [aktive op color HSV to sRGB](#op_color_HSV_to_sRGB)
 - [aktive op color HSV to XYZ](#op_color_HSV_to_XYZ)
 - [aktive op color HSV to Yxy](#op_color_HSV_to_Yxy)
 - [aktive op color Lab to Grey](#op_color_Lab_to_Grey)
 - [aktive op color Lab to HSL](#op_color_Lab_to_HSL)
 - [aktive op color Lab to HSV](#op_color_Lab_to_HSV)
 - [aktive op color Lab to LCh](#op_color_Lab_to_LCh)
 - [aktive op color Lab to scRGB](#op_color_Lab_to_scRGB)
 - [aktive op color Lab to sRGB](#op_color_Lab_to_sRGB)
 - [aktive op color Lab to XYZ](#op_color_Lab_to_XYZ)
 - [aktive op color Lab to Yxy](#op_color_Lab_to_Yxy)
 - [aktive op color LCh to Grey](#op_color_LCh_to_Grey)
 - [aktive op color LCh to HSL](#op_color_LCh_to_HSL)
 - [aktive op color LCh to HSV](#op_color_LCh_to_HSV)
 - [aktive op color LCh to Lab](#op_color_LCh_to_Lab)
 - [aktive op color LCh to scRGB](#op_color_LCh_to_scRGB)
 - [aktive op color LCh to sRGB](#op_color_LCh_to_sRGB)
 - [aktive op color LCh to XYZ](#op_color_LCh_to_XYZ)
 - [aktive op color LCh to Yxy](#op_color_LCh_to_Yxy)
 - [aktive op color scRGB to Grey](#op_color_scRGB_to_Grey)
 - [aktive op color scRGB to HSL](#op_color_scRGB_to_HSL)
 - [aktive op color scRGB to HSV](#op_color_scRGB_to_HSV)
 - [aktive op color scRGB to Lab](#op_color_scRGB_to_Lab)
 - [aktive op color scRGB to LCh](#op_color_scRGB_to_LCh)
 - [aktive op color scRGB to sRGB](#op_color_scRGB_to_sRGB)
 - [aktive op color scRGB to XYZ](#op_color_scRGB_to_XYZ)
 - [aktive op color scRGB to Yxy](#op_color_scRGB_to_Yxy)
 - [aktive op color set](#op_color_set)
 - [aktive op color sRGB to gray](#op_color_sRGB_to_gray)
 - [aktive op color sRGB to Grey](#op_color_sRGB_to_Grey)
 - [aktive op color sRGB to HSL](#op_color_sRGB_to_HSL)
 - [aktive op color sRGB to HSV](#op_color_sRGB_to_HSV)
 - [aktive op color sRGB to Lab](#op_color_sRGB_to_Lab)
 - [aktive op color sRGB to LCh](#op_color_sRGB_to_LCh)
 - [aktive op color sRGB to scRGB](#op_color_sRGB_to_scRGB)
 - [aktive op color sRGB to XYZ](#op_color_sRGB_to_XYZ)
 - [aktive op color sRGB to Yxy](#op_color_sRGB_to_Yxy)
 - [aktive op color XYZ to Grey](#op_color_XYZ_to_Grey)
 - [aktive op color XYZ to HSL](#op_color_XYZ_to_HSL)
 - [aktive op color XYZ to HSV](#op_color_XYZ_to_HSV)
 - [aktive op color XYZ to Lab](#op_color_XYZ_to_Lab)
 - [aktive op color XYZ to LCh](#op_color_XYZ_to_LCh)
 - [aktive op color XYZ to scRGB](#op_color_XYZ_to_scRGB)
 - [aktive op color XYZ to sRGB](#op_color_XYZ_to_sRGB)
 - [aktive op color XYZ to Yxy](#op_color_XYZ_to_Yxy)
 - [aktive op color Yxy to Grey](#op_color_Yxy_to_Grey)
 - [aktive op color Yxy to HSL](#op_color_Yxy_to_HSL)
 - [aktive op color Yxy to HSV](#op_color_Yxy_to_HSV)
 - [aktive op color Yxy to Lab](#op_color_Yxy_to_Lab)
 - [aktive op color Yxy to LCh](#op_color_Yxy_to_LCh)
 - [aktive op color Yxy to scRGB](#op_color_Yxy_to_scRGB)
 - [aktive op color Yxy to sRGB](#op_color_Yxy_to_sRGB)
 - [aktive op color Yxy to XYZ](#op_color_Yxy_to_XYZ)

## Operators

---
### [↑](#top) <a name='op_color_correct_greyworld_global'></a> aktive op color correct greyworld global

Syntax: __aktive op color correct greyworld global__ src ?(param value)...? [[→ definition](/file?ci=trunk&ln=9&name=etc/transformer/color/recast.tcl)]

Corrects a color cast in the input using a global grey world assumption and returns the result.

Accepts inputs in the `sRGB` and `scRGB` color spaces, and returns a result in the same space.

The actual correction is always done in the `scRGB` space, i.e. with linear colors.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|mean|double|{}|Use as a fixed global mean, if specified. Else use the actual global mean for the input.|

#### <a name='op_color_correct_greyworld_global__examples'></a> Examples

<a name='op_color_correct_greyworld_global__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op color correct greyworld global @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00328.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 294 92 3)</td>
    <td valign='top'><img src='example-00329.gif' alt='aktive op color correct greyworld global @1' style='border:4px solid gold'>
    <br>geometry(0 0 294 92 3)</td></tr>
</table>

<a name='op_color_correct_greyworld_global__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op color correct greyworld global @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00330.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00331.gif' alt='aktive op color correct greyworld global @1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td></tr>
</table>


---
### [↑](#top) <a name='op_color_correct_greyworld_local'></a> aktive op color correct greyworld local

Syntax: __aktive op color correct greyworld local__ src ?(param value)...? [[→ definition](/file?ci=trunk&ln=75&name=etc/transformer/color/recast.tcl)]

Corrects a color cast in the input using a local grey world assumption and returns the result.

Accepts inputs in the `sRGB` and `scRGB` color spaces, and returns a result in the same space.

The actual correction is always done in the `scRGB` space, i.e. with linear colors.

The size of the window/tile used to compute local conditions is set by radius. The default is 10.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|10|Tile size as radius from center. Full width and height of the tile are `2*radius+1`. Default value is 10.|
|mean|double|{}|Use as a fixed xglobal mean, if specified. Else use the actual xglobal mean for the input.|

---
### [↑](#top) <a name='op_color_HSL_to_Grey'></a> aktive op color HSL to Grey

Syntax: __aktive op color HSL to Grey__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Grey colorspace, from input in HSL colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSL_to_HSV'></a> aktive op color HSL to HSV

Syntax: __aktive op color HSL to HSV__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in HSV colorspace, from input in HSL colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSL_to_Lab'></a> aktive op color HSL to Lab

Syntax: __aktive op color HSL to Lab__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Lab colorspace, from input in HSL colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSL_to_LCh'></a> aktive op color HSL to LCh

Syntax: __aktive op color HSL to LCh__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in LCh colorspace, from input in HSL colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSL_to_scRGB'></a> aktive op color HSL to scRGB

Syntax: __aktive op color HSL to scRGB__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in scRGB colorspace, from input in HSL colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSL_to_sRGB'></a> aktive op color HSL to sRGB

Syntax: __aktive op color HSL to sRGB__ src [[→ definition](/file?ci=trunk&ln=95&name=etc/transformer/color/hsl-srgb.tcl)]

Returns image in sRGB colorspace, from input in HSL colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSL_to_XYZ'></a> aktive op color HSL to XYZ

Syntax: __aktive op color HSL to XYZ__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in XYZ colorspace, from input in HSL colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSL_to_Yxy'></a> aktive op color HSL to Yxy

Syntax: __aktive op color HSL to Yxy__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Yxy colorspace, from input in HSL colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSV_to_Grey'></a> aktive op color HSV to Grey

Syntax: __aktive op color HSV to Grey__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Grey colorspace, from input in HSV colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSV_to_HSL'></a> aktive op color HSV to HSL

Syntax: __aktive op color HSV to HSL__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSL colorspace, from input in HSV colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSV_to_Lab'></a> aktive op color HSV to Lab

Syntax: __aktive op color HSV to Lab__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Lab colorspace, from input in HSV colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSV_to_LCh'></a> aktive op color HSV to LCh

Syntax: __aktive op color HSV to LCh__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in LCh colorspace, from input in HSV colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSV_to_scRGB'></a> aktive op color HSV to scRGB

Syntax: __aktive op color HSV to scRGB__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in scRGB colorspace, from input in HSV colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSV_to_sRGB'></a> aktive op color HSV to sRGB

Syntax: __aktive op color HSV to sRGB__ src [[→ definition](/file?ci=trunk&ln=92&name=etc/transformer/color/hsv-srgb.tcl)]

Returns image in sRGB colorspace, from input in HSV colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSV_to_XYZ'></a> aktive op color HSV to XYZ

Syntax: __aktive op color HSV to XYZ__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in XYZ colorspace, from input in HSV colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_HSV_to_Yxy'></a> aktive op color HSV to Yxy

Syntax: __aktive op color HSV to Yxy__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Yxy colorspace, from input in HSV colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Lab_to_Grey'></a> aktive op color Lab to Grey

Syntax: __aktive op color Lab to Grey__ src [[→ definition](/file?ci=trunk&ln=133&name=etc/transformer/color/xyz-lab.tcl)]

Returns image converted to greyscale, from input in Lab colorspace.

The gray data is just the Y channel of a conversion to XYZ colorspace. A separate operator is used to completely avoid the calculation of the unwanted XZ data.

This conversion is based on the (1,1,1) reference white.

For a different whitepoint scale the greyscale by the associated illuminant value after performing the conversion.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Lab_to_HSL'></a> aktive op color Lab to HSL

Syntax: __aktive op color Lab to HSL__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSL colorspace, from input in Lab colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Lab_to_HSV'></a> aktive op color Lab to HSV

Syntax: __aktive op color Lab to HSV__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSV colorspace, from input in Lab colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Lab_to_LCh'></a> aktive op color Lab to LCh

Syntax: __aktive op color Lab to LCh__ src [[→ definition](/file?ci=trunk&ln=9&name=etc/transformer/color/lab-lch.tcl)]

Returns image in LCh colorspace, from input in Lab colorspace.

The H coordinate is provided in degrees.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Lab_to_scRGB'></a> aktive op color Lab to scRGB

Syntax: __aktive op color Lab to scRGB__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in scRGB colorspace, from input in Lab colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Lab_to_sRGB'></a> aktive op color Lab to sRGB

Syntax: __aktive op color Lab to sRGB__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in sRGB colorspace, from input in Lab colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Lab_to_XYZ'></a> aktive op color Lab to XYZ

Syntax: __aktive op color Lab to XYZ__ src [[→ definition](/file?ci=trunk&ln=9&name=etc/transformer/color/xyz-lab.tcl)]

Returns image in XYZ colorspace, from input in Lab colorspace.

This conversion is based on the (1,1,1) reference white.

For a different whitepoint scale the XYZ bands by the associated illuminant values after performing the conversion.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Lab_to_Yxy'></a> aktive op color Lab to Yxy

Syntax: __aktive op color Lab to Yxy__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in Yxy colorspace, from input in Lab colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_LCh_to_Grey'></a> aktive op color LCh to Grey

Syntax: __aktive op color LCh to Grey__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Grey colorspace, from input in LCh colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_LCh_to_HSL'></a> aktive op color LCh to HSL

Syntax: __aktive op color LCh to HSL__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSL colorspace, from input in LCh colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_LCh_to_HSV'></a> aktive op color LCh to HSV

Syntax: __aktive op color LCh to HSV__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSV colorspace, from input in LCh colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_LCh_to_Lab'></a> aktive op color LCh to Lab

Syntax: __aktive op color LCh to Lab__ src [[→ definition](/file?ci=trunk&ln=64&name=etc/transformer/color/lab-lch.tcl)]

Returns image in Lab colorspace, from input in LCH colorspace.

The H coordinate is expected to be in degrees.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_LCh_to_scRGB'></a> aktive op color LCh to scRGB

Syntax: __aktive op color LCh to scRGB__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in scRGB colorspace, from input in LCh colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_LCh_to_sRGB'></a> aktive op color LCh to sRGB

Syntax: __aktive op color LCh to sRGB__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in sRGB colorspace, from input in LCh colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_LCh_to_XYZ'></a> aktive op color LCh to XYZ

Syntax: __aktive op color LCh to XYZ__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in XYZ colorspace, from input in LCh colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_LCh_to_Yxy'></a> aktive op color LCh to Yxy

Syntax: __aktive op color LCh to Yxy__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in Yxy colorspace, from input in LCh colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_scRGB_to_Grey'></a> aktive op color scRGB to Grey

Syntax: __aktive op color scRGB to Grey__ src [[→ definition](/file?ci=trunk&ln=150&name=etc/transformer/color/scrgb-xyz.tcl)]

Returns input converted to grey scale, from input in scRGB colorspace.

The gray data is just the Y channel of a conversion to XYZ colorspace. A separate operator is used to completely avoid the calculation of the unwanted XZ data.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_scRGB_to_HSL'></a> aktive op color scRGB to HSL

Syntax: __aktive op color scRGB to HSL__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSL colorspace, from input in scRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_scRGB_to_HSV'></a> aktive op color scRGB to HSV

Syntax: __aktive op color scRGB to HSV__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSV colorspace, from input in scRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_scRGB_to_Lab'></a> aktive op color scRGB to Lab

Syntax: __aktive op color scRGB to Lab__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Lab colorspace, from input in scRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_scRGB_to_LCh'></a> aktive op color scRGB to LCh

Syntax: __aktive op color scRGB to LCh__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in LCh colorspace, from input in scRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_scRGB_to_sRGB'></a> aktive op color scRGB to sRGB

Syntax: __aktive op color scRGB to sRGB__ src [[→ definition](/file?ci=trunk&ln=7&name=etc/transformer/color/srgb-scrgb.tcl)]

Returns image in sRGB colorspace, from input in scRGB colorspace. Linear light becomes (gamma) compressed light.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_scRGB_to_XYZ'></a> aktive op color scRGB to XYZ

Syntax: __aktive op color scRGB to XYZ__ src [[→ definition](/file?ci=trunk&ln=9&name=etc/transformer/color/scrgb-xyz.tcl)]

Returns image in XYZ colorspace, from input in scRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_scRGB_to_Yxy'></a> aktive op color scRGB to Yxy

Syntax: __aktive op color scRGB to Yxy__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Yxy colorspace, from input in scRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_set'></a> aktive op color set

Syntax: __aktive op color set__ src colorspace [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/color/non-core.tcl)]

Forcibly sets the colorspace attribute of the input image to the specified value

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|colorspace|str||New colorspace to assume|

---
### [↑](#top) <a name='op_color_sRGB_to_gray'></a> aktive op color sRGB to gray

Syntax: __aktive op color sRGB to gray__ src [[→ definition](/file?ci=trunk&ln=9&name=etc/transformer/color/srgb-gray.tcl)]

Returns image in grayscale, from input in sRGB colorspace.

This conversion uses the NTSC conversion formula.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='op_color_sRGB_to_gray__examples'></a> Examples

<a name='op_color_sRGB_to_gray__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op color sRGB to gray @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00332.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00333.gif' alt='aktive op color sRGB to gray @1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 1)</td></tr>
</table>


---
### [↑](#top) <a name='op_color_sRGB_to_Grey'></a> aktive op color sRGB to Grey

Syntax: __aktive op color sRGB to Grey__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Grey colorspace, from input in sRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_sRGB_to_HSL'></a> aktive op color sRGB to HSL

Syntax: __aktive op color sRGB to HSL__ src [[→ definition](/file?ci=trunk&ln=13&name=etc/transformer/color/hsl-srgb.tcl)]

Returns image in HSL colorspace, from input in sRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='op_color_sRGB_to_HSL__examples'></a> Examples

<a name='op_color_sRGB_to_HSL__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op color sRGB to HSL @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00334.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00335.gif' alt='aktive op color sRGB to HSL @1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td></tr>
</table>


---
### [↑](#top) <a name='op_color_sRGB_to_HSV'></a> aktive op color sRGB to HSV

Syntax: __aktive op color sRGB to HSV__ src [[→ definition](/file?ci=trunk&ln=13&name=etc/transformer/color/hsv-srgb.tcl)]

Returns image in HSV colorspace, from input in sRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='op_color_sRGB_to_HSV__examples'></a> Examples

<a name='op_color_sRGB_to_HSV__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op color sRGB to HSV @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00336.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00337.gif' alt='aktive op color sRGB to HSV @1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td></tr>
</table>


---
### [↑](#top) <a name='op_color_sRGB_to_Lab'></a> aktive op color sRGB to Lab

Syntax: __aktive op color sRGB to Lab__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Lab colorspace, from input in sRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_sRGB_to_LCh'></a> aktive op color sRGB to LCh

Syntax: __aktive op color sRGB to LCh__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in LCh colorspace, from input in sRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_sRGB_to_scRGB'></a> aktive op color sRGB to scRGB

Syntax: __aktive op color sRGB to scRGB__ src [[→ definition](/file?ci=trunk&ln=22&name=etc/transformer/color/srgb-scrgb.tcl)]

Returns image in scRGB colorspace, from input in sRGB colorspace. (gamma) compressed light becomes linear light.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='op_color_sRGB_to_scRGB__examples'></a> Examples

<a name='op_color_sRGB_to_scRGB__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op color sRGB to scRGB @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00338.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00339.gif' alt='aktive op color sRGB to scRGB @1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td></tr>
</table>


---
### [↑](#top) <a name='op_color_sRGB_to_XYZ'></a> aktive op color sRGB to XYZ

Syntax: __aktive op color sRGB to XYZ__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in XYZ colorspace, from input in sRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_sRGB_to_Yxy'></a> aktive op color sRGB to Yxy

Syntax: __aktive op color sRGB to Yxy__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Yxy colorspace, from input in sRGB colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_XYZ_to_Grey'></a> aktive op color XYZ to Grey

Syntax: __aktive op color XYZ to Grey__ src [[→ definition](/file?ci=trunk&ln=136&name=etc/transformer/color/scrgb-xyz.tcl)]

Returns input converted to grey scale, from input in XYZ colorspace.

The gray data is just the Y channel of the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_XYZ_to_HSL'></a> aktive op color XYZ to HSL

Syntax: __aktive op color XYZ to HSL__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSL colorspace, from input in XYZ colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_XYZ_to_HSV'></a> aktive op color XYZ to HSV

Syntax: __aktive op color XYZ to HSV__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSV colorspace, from input in XYZ colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_XYZ_to_Lab'></a> aktive op color XYZ to Lab

Syntax: __aktive op color XYZ to Lab__ src [[→ definition](/file?ci=trunk&ln=71&name=etc/transformer/color/xyz-lab.tcl)]

Returns image in Lab colorspace, from input in XYZ colorspace.

This conversion is based on the (1,1,1) reference white.

For a different whitepoint divide the XYZ bands by the associated illuminant values before performing the conversion.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_XYZ_to_LCh'></a> aktive op color XYZ to LCh

Syntax: __aktive op color XYZ to LCh__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in LCh colorspace, from input in XYZ colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_XYZ_to_scRGB'></a> aktive op color XYZ to scRGB

Syntax: __aktive op color XYZ to scRGB__ src [[→ definition](/file?ci=trunk&ln=70&name=etc/transformer/color/scrgb-xyz.tcl)]

Returns image in scRGB colorspace, from input in XYZ colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_XYZ_to_sRGB'></a> aktive op color XYZ to sRGB

Syntax: __aktive op color XYZ to sRGB__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in sRGB colorspace, from input in XYZ colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_XYZ_to_Yxy'></a> aktive op color XYZ to Yxy

Syntax: __aktive op color XYZ to Yxy__ src [[→ definition](/file?ci=trunk&ln=65&name=etc/transformer/color/xyz-yxy.tcl)]

Returns image in Yxy colorspace, from input in XYZ colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Yxy_to_Grey'></a> aktive op color Yxy to Grey

Syntax: __aktive op color Yxy to Grey__ src [[→ definition](/file?ci=trunk&ln=126&name=etc/transformer/color/xyz-yxy.tcl)]

Returns image converted to grey scale, from input in Yxy colorspace.

The gray data is just the Y channel of a conversion to XYZ colorspace. A separate operator is used to completely avoid the calculation of the unwanted XZ data.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Yxy_to_HSL'></a> aktive op color Yxy to HSL

Syntax: __aktive op color Yxy to HSL__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSL colorspace, from input in Yxy colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Yxy_to_HSV'></a> aktive op color Yxy to HSV

Syntax: __aktive op color Yxy to HSV__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in HSV colorspace, from input in Yxy colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Yxy_to_Lab'></a> aktive op color Yxy to Lab

Syntax: __aktive op color Yxy to Lab__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in Lab colorspace, from input in Yxy colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Yxy_to_LCh'></a> aktive op color Yxy to LCh

Syntax: __aktive op color Yxy to LCh__ src [[→ definition](/file?ci=trunk&ln=72&name=etc/transformer/color/non-core.tcl)]

Returns image in LCh colorspace, from input in Yxy colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Yxy_to_scRGB'></a> aktive op color Yxy to scRGB

Syntax: __aktive op color Yxy to scRGB__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in scRGB colorspace, from input in Yxy colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Yxy_to_sRGB'></a> aktive op color Yxy to sRGB

Syntax: __aktive op color Yxy to sRGB__ src [[→ definition](/file?ci=trunk&ln=96&name=etc/transformer/color/non-core.tcl)]

Returns image in sRGB colorspace, from input in Yxy colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_color_Yxy_to_XYZ'></a> aktive op color Yxy to XYZ

Syntax: __aktive op color Yxy to XYZ__ src [[→ definition](/file?ci=trunk&ln=11&name=etc/transformer/color/xyz-yxy.tcl)]

Returns image in XYZ colorspace, from input in Yxy colorspace.

|Input|Description|
|:---|:---|
|src|Source image|

