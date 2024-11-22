<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- composer

## Table Of Contents

  - [Roots](bysection.md) ↗


### Operators

 - [aktive op montage x](#op_montage_x)
 - [aktive op montage x-core](#op_montage_x_core)
 - [aktive op montage x-rep](#op_montage_x_rep)
 - [aktive op montage y](#op_montage_y)
 - [aktive op montage y-core](#op_montage_y_core)
 - [aktive op montage y-rep](#op_montage_y_rep)
 - [aktive op montage z](#op_montage_z)
 - [aktive op montage z-core](#op_montage_z_core)
 - [aktive op montage z-rep](#op_montage_z_rep)

## Operators

---
### <a name='op_montage_x'></a> aktive op montage x

Syntax: __aktive op montage x__ srcs... [[→ definition](../../../../file?ci=trunk&ln=40&name=etc/composer/montage.tcl)]

Returns image with all inputs joined left to right along the x-axis.


#### <a name='op_montage_x__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage x @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00262.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00263.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00264.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00265.gif' alt='aktive op montage x @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 224 128 1)</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage x @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00266.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00267.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00268.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00269.gif' alt='aktive op montage x @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 192 64 1)</td></tr>
</table>


---
### <a name='op_montage_x_core'></a> aktive op montage x-core

Syntax: __aktive op montage x-core__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=72&name=etc/composer/montage.tcl)]

Returns image with the 2 inputs joined left to right along the x-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The width of the result is the sum of the widths of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.


---
### <a name='op_montage_x_rep'></a> aktive op montage x-rep

Syntax: __aktive op montage x-rep__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=12&name=etc/composer/montage.tcl)]

Returns image with input joined left to right with itself N times along the x-axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

#### <a name='op_montage_x_rep__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op montage x-rep @1 by 3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00270.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00271.gif' alt='aktive op montage x-rep @1 by 3' style='border:4px solid gold'>
    <br>geometry(0 0 96 32 1)</td></tr>
</table>


---
### <a name='op_montage_y'></a> aktive op montage y

Syntax: __aktive op montage y__ srcs... [[→ definition](../../../../file?ci=trunk&ln=40&name=etc/composer/montage.tcl)]

Returns image with all inputs joined top to bottom along the y-axis.


#### <a name='op_montage_y__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage y @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00272.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00273.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00274.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00275.gif' alt='aktive op montage y @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 128 224 1)</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage y @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00276.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00277.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00278.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00279.gif' alt='aktive op montage y @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 64 192 1)</td></tr>
</table>


---
### <a name='op_montage_y_core'></a> aktive op montage y-core

Syntax: __aktive op montage y-core__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=72&name=etc/composer/montage.tcl)]

Returns image with the 2 inputs joined top to bottom along the y-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The height of the result is the sum of the heights of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.


---
### <a name='op_montage_y_rep'></a> aktive op montage y-rep

Syntax: __aktive op montage y-rep__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=12&name=etc/composer/montage.tcl)]

Returns image with input joined top to bottom with itself N times along the y-axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

#### <a name='op_montage_y_rep__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op montage y-rep @1 by 3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00280.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00281.gif' alt='aktive op montage y-rep @1 by 3' style='border:4px solid gold'>
    <br>geometry(0 0 32 96 1)</td></tr>
</table>


---
### <a name='op_montage_z'></a> aktive op montage z

Syntax: __aktive op montage z__ srcs... [[→ definition](../../../../file?ci=trunk&ln=40&name=etc/composer/montage.tcl)]

Returns image with all inputs joined front to back along the z-axis.


#### <a name='op_montage_z__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage z @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00282.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00283.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00284.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00285.gif' alt='aktive op montage z @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 3)</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage z @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00286.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00287.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00288.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00289.gif' alt='aktive op montage z @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 3)</td></tr>
</table>


---
### <a name='op_montage_z_core'></a> aktive op montage z-core

Syntax: __aktive op montage z-core__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=72&name=etc/composer/montage.tcl)]

Returns image with the 2 inputs joined front to back along the z-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The depth of the result is the sum of the depths of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.


---
### <a name='op_montage_z_rep'></a> aktive op montage z-rep

Syntax: __aktive op montage z-rep__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=12&name=etc/composer/montage.tcl)]

Returns image with input joined front to back with itself N times along the z-axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

#### <a name='op_montage_z_rep__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op montage z-rep @1 by 3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00290.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00291.gif' alt='aktive op montage z-rep @1 by 3' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 3)</td></tr>
</table>


