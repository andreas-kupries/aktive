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

Syntax: __aktive op montage x__ srcs...

Returns image with all inputs joined left to right along the x-axis.


## Examples

<table><tr><th>@1</th><th>@2</th><th>@3</th><th>aktive op montage x @1 @2 @3</th></tr>
<tr><td valign='top'><img src='example-00228.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00229.gif' alt='@2' style='border:4px solid gold'></td><td valign='top'><img src='example-00230.gif' alt='@3' style='border:4px solid gold'></td><td valign='top'><img src='example-00231.gif' alt='aktive op montage x @1 @2 @3' style='border:4px solid gold'></td></tr></table>

<table><tr><th>@1</th><th>@2</th><th>@3</th><th>aktive op montage x @1 @2 @3</th></tr>
<tr><td valign='top'><img src='example-00232.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00233.gif' alt='@2' style='border:4px solid gold'></td><td valign='top'><img src='example-00234.gif' alt='@3' style='border:4px solid gold'></td><td valign='top'><img src='example-00235.gif' alt='aktive op montage x @1 @2 @3' style='border:4px solid gold'></td></tr></table>


---
### <a name='op_montage_x_core'></a> aktive op montage x-core

Syntax: __aktive op montage x-core__ src0 src1

Returns image with the 2 inputs joined left to right along the x-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The width of the result is the sum of the widths of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.


---
### <a name='op_montage_x_rep'></a> aktive op montage x-rep

Syntax: __aktive op montage x-rep__ src (param value)...

Returns image with input joined left to right with itself N times along the x-axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

## Examples

<table><tr><th>@1</th><th>aktive op montage x-rep @1 by 3</th></tr>
<tr><td valign='top'><img src='example-00236.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00237.gif' alt='aktive op montage x-rep @1 by 3' style='border:4px solid gold'></td></tr></table>


---
### <a name='op_montage_y'></a> aktive op montage y

Syntax: __aktive op montage y__ srcs...

Returns image with all inputs joined top to bottom along the y-axis.


## Examples

<table><tr><th>@1</th><th>@2</th><th>@3</th><th>aktive op montage y @1 @2 @3</th></tr>
<tr><td valign='top'><img src='example-00238.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00239.gif' alt='@2' style='border:4px solid gold'></td><td valign='top'><img src='example-00240.gif' alt='@3' style='border:4px solid gold'></td><td valign='top'><img src='example-00241.gif' alt='aktive op montage y @1 @2 @3' style='border:4px solid gold'></td></tr></table>

<table><tr><th>@1</th><th>@2</th><th>@3</th><th>aktive op montage y @1 @2 @3</th></tr>
<tr><td valign='top'><img src='example-00242.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00243.gif' alt='@2' style='border:4px solid gold'></td><td valign='top'><img src='example-00244.gif' alt='@3' style='border:4px solid gold'></td><td valign='top'><img src='example-00245.gif' alt='aktive op montage y @1 @2 @3' style='border:4px solid gold'></td></tr></table>


---
### <a name='op_montage_y_core'></a> aktive op montage y-core

Syntax: __aktive op montage y-core__ src0 src1

Returns image with the 2 inputs joined top to bottom along the y-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The height of the result is the sum of the heights of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.


---
### <a name='op_montage_y_rep'></a> aktive op montage y-rep

Syntax: __aktive op montage y-rep__ src (param value)...

Returns image with input joined top to bottom with itself N times along the y-axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

## Examples

<table><tr><th>@1</th><th>aktive op montage y-rep @1 by 3</th></tr>
<tr><td valign='top'><img src='example-00246.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00247.gif' alt='aktive op montage y-rep @1 by 3' style='border:4px solid gold'></td></tr></table>


---
### <a name='op_montage_z'></a> aktive op montage z

Syntax: __aktive op montage z__ srcs...

Returns image with all inputs joined front to back along the z-axis.


## Examples

<table><tr><th>@1</th><th>@2</th><th>@3</th><th>aktive op montage z @1 @2 @3</th></tr>
<tr><td valign='top'><img src='example-00248.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00249.gif' alt='@2' style='border:4px solid gold'></td><td valign='top'><img src='example-00250.gif' alt='@3' style='border:4px solid gold'></td><td valign='top'><img src='example-00251.gif' alt='aktive op montage z @1 @2 @3' style='border:4px solid gold'></td></tr></table>

<table><tr><th>@1</th><th>@2</th><th>@3</th><th>aktive op montage z @1 @2 @3</th></tr>
<tr><td valign='top'><img src='example-00252.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00253.gif' alt='@2' style='border:4px solid gold'></td><td valign='top'><img src='example-00254.gif' alt='@3' style='border:4px solid gold'></td><td valign='top'><img src='example-00255.gif' alt='aktive op montage z @1 @2 @3' style='border:4px solid gold'></td></tr></table>


---
### <a name='op_montage_z_core'></a> aktive op montage z-core

Syntax: __aktive op montage z-core__ src0 src1

Returns image with the 2 inputs joined front to back along the z-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The depth of the result is the sum of the depths of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.


---
### <a name='op_montage_z_rep'></a> aktive op montage z-rep

Syntax: __aktive op montage z-rep__ src (param value)...

Returns image with input joined front to back with itself N times along the z-axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

## Examples

<table><tr><th>@1</th><th>aktive op montage z-rep @1 by 3</th></tr>
<tr><td valign='top'><img src='example-00256.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'><img src='example-00257.gif' alt='aktive op montage z-rep @1 by 3' style='border:4px solid gold'></td></tr></table>


