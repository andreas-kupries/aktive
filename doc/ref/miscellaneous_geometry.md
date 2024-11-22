<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- miscellaneous geometry

## Table Of Contents

  - [miscellaneous](miscellaneous.md) ↗


### Operators

 - [aktive point add](#point_add)
 - [aktive point box](#point_box)
 - [aktive point make](#point_make)
 - [aktive point move](#point_move)
 - [aktive rectangle empty](#rectangle_empty)
 - [aktive rectangle equal](#rectangle_equal)
 - [aktive rectangle grow](#rectangle_grow)
 - [aktive rectangle intersect](#rectangle_intersect)
 - [aktive rectangle make](#rectangle_make)
 - [aktive rectangle move](#rectangle_move)
 - [aktive rectangle subset](#rectangle_subset)
 - [aktive rectangle union](#rectangle_union)
 - [aktive rectangle zones](#rectangle_zones)

## Operators

---
### <a name='point_add'></a> aktive point add

Syntax: __aktive point add__ point delta [[→ definition](../../../../file?ci=trunk&ln=22&name=etc/other/point.tcl)]

Translate a 2D point by a specific amount given as 2D vector

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|point|point||Point to modify|
|delta|point||Point to add|

#### <a name='point_add__examples'></a> Examples

<table>
<tr><th>aktive point add {11 23} {-1 7}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>10 30</td></tr>
</table>


---
### <a name='point_box'></a> aktive point box

Syntax: __aktive point box__ points... [[→ definition](../../../../file?ci=trunk&ln=59&name=etc/other/point.tcl)]

Compute minimum axis-aligned 2D rectangle enclosing the set of 2D points

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|points|point...||Points to find the bounding box for|

#### <a name='point_box__examples'></a> Examples

<table>
<tr><th>aktive point box {11 23} {45 5} {5 45}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>5 5 41 41</td></tr>
</table>


---
### <a name='point_make'></a> aktive point make

Syntax: __aktive point make__ x y [[→ definition](../../../../file?ci=trunk&ln=6&name=etc/other/point.tcl)]

Construct a 2D point from x- and y-coordinates

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|int||Point location, Column|
|y|int||Point location, Row|

#### <a name='point_make__examples'></a> Examples

<table>
<tr><th>aktive point make 11 23
    <br>&nbsp;</th></tr>
<tr><td valign='top'>11 23</td></tr>
</table>


---
### <a name='point_move'></a> aktive point move

Syntax: __aktive point move__ point dx dy [[→ definition](../../../../file?ci=trunk&ln=40&name=etc/other/point.tcl)]

Translate a 2D point by a specific amount given as separate x- and y-deltas

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|point|point||Point to modify|
|dx|int||Amount to move left/right, positive to the right|
|dy|int||Amount to move up/down, positive downward|

#### <a name='point_move__examples'></a> Examples

<table>
<tr><th>aktive point move {11 23} -1 7
    <br>&nbsp;</th></tr>
<tr><td valign='top'>10 30</td></tr>
</table>


---
### <a name='rectangle_empty'></a> aktive rectangle empty

Syntax: __aktive rectangle empty__ rect [[→ definition](../../../../file?ci=trunk&ln=99&name=etc/other/rectangle.tcl)]

Test a 2D rectangle for emptiness

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|rect|rect||Rectangle to check|

#### <a name='rectangle_empty__examples'></a> Examples

<table>
<tr><th>aktive rectangle empty {11 23 30 20}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>0</td></tr>
</table>

<table>
<tr><th>aktive rectangle empty {11 23 0 0}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>1</td></tr>
</table>


---
### <a name='rectangle_equal'></a> aktive rectangle equal

Syntax: __aktive rectangle equal__ a b [[→ definition](../../../../file?ci=trunk&ln=70&name=etc/other/rectangle.tcl)]

Test two 2D rectangles for equality (location and dimensions)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|rect||First rectangle to compare|
|b|rect||Second rectangle to compare|

#### <a name='rectangle_equal__examples'></a> Examples

<table>
<tr><th>aktive rectangle equal {11 23 30 20} {11 23 30 20}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>1</td></tr>
</table>

<table>
<tr><th>aktive rectangle equal {11 23 30 20} {11 23 10 20}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>0</td></tr>
</table>


---
### <a name='rectangle_grow'></a> aktive rectangle grow

Syntax: __aktive rectangle grow__ rect left right top bottom [[→ definition](../../../../file?ci=trunk&ln=26&name=etc/other/rectangle.tcl)]

Modify 2D rectangle by moving its 4 borders by a specific amount

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|rect|rect||Rectangle to modify|
|left|int||Amount to grow the left border, positive to the left|
|right|int||Amount to grow the right border, positive to the right|
|top|int||Amount to grow the top border, positive upward|
|bottom|int||Amount to grow the bottom border, positive downward|

#### <a name='rectangle_grow__examples'></a> Examples

<table>
<tr><th>aktive rectangle grow {11 23 30 20} 1 7 5 10
    <br>&nbsp;</th></tr>
<tr><td valign='top'>10 18 38 35</td></tr>
</table>


---
### <a name='rectangle_intersect'></a> aktive rectangle intersect

Syntax: __aktive rectangle intersect__ rects... [[→ definition](../../../../file?ci=trunk&ln=139&name=etc/other/rectangle.tcl)]

Compute the maximum axis-aligned 2D rectangle shared by all input rectangles

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|rects|rect...||Rectangles to intersect|

---
### <a name='rectangle_make'></a> aktive rectangle make

Syntax: __aktive rectangle make__ x y w h [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/other/rectangle.tcl)]

Construct a 2D rectangle from x- and y-coordinates and width/height dimensions

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|int||Rectangle location, Column|
|y|int||Rectangle location, Row|
|w|uint||Rectangle width|
|h|uint||Rectangle height|

#### <a name='rectangle_make__examples'></a> Examples

<table>
<tr><th>aktive rectangle make 11 23 30 20
    <br>&nbsp;</th></tr>
<tr><td valign='top'>11 23 30 20</td></tr>
</table>


---
### <a name='rectangle_move'></a> aktive rectangle move

Syntax: __aktive rectangle move__ rect dx dy [[→ definition](../../../../file?ci=trunk&ln=49&name=etc/other/rectangle.tcl)]

Translate a 2D rectangle by a specific amount given as separate x- and y-deltas

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|rect|rect||Rectangle to modify|
|dx|int||Amount to move left/right, positive to the right|
|dy|int||Amount to move up/down, positive downward|

#### <a name='rectangle_move__examples'></a> Examples

<table>
<tr><th>aktive rectangle move {11 23 30 20} -5 7
    <br>&nbsp;</th></tr>
<tr><td valign='top'>6 30 30 20</td></tr>
</table>


---
### <a name='rectangle_subset'></a> aktive rectangle subset

Syntax: __aktive rectangle subset__ a b [[→ definition](../../../../file?ci=trunk&ln=84&name=etc/other/rectangle.tcl)]

Test if the first 2D rectangle is a subset of the second.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|a|rect||First rectangle to compare|
|b|rect||Second rectangle to compare|

#### <a name='rectangle_subset__examples'></a> Examples

<table>
<tr><th>aktive rectangle subset {11 23 30 20} {11 23 30 20}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>1</td></tr>
</table>

<table>
<tr><th>aktive rectangle subset {11 23 30 20} {12 22 10 15}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>0</td></tr>
</table>

<table>
<tr><th>aktive rectangle subset {11 23 30 20} {10 20 40 25}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>1</td></tr>
</table>


---
### <a name='rectangle_union'></a> aktive rectangle union

Syntax: __aktive rectangle union__ rects... [[→ definition](../../../../file?ci=trunk&ln=114&name=etc/other/rectangle.tcl)]

Compute the minimum axis-aligned 2D rectangle encompassing all input rectangles

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|rects|rect...||Rectangles to union|

---
### <a name='rectangle_zones'></a> aktive rectangle zones

Syntax: __aktive rectangle zones__ domain request [[→ definition](../../../../file?ci=trunk&ln=166&name=etc/other/rectangle.tcl)]

Compute a set of 2D rectangles describing the relation of the request to the domain.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|domain|rect||Area covered by image pixels|
|request|rect||Area to get the pixels for|

