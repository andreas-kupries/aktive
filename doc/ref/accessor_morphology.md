<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- accessor morphology

## <anchor='top'> Table Of Contents

  - [accessor](accessor.md) ↗


### Operators

 - [aktive op connected-components get](#op_connected_components_get)

## Operators

---
### [↑](#top) <a name='op_connected_components_get'></a> aktive op connected-components get

Syntax: __aktive op connected-components get__ src [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/accessor/cc.tcl)]

Returns a dictionary describing all the connected components of the single-band input.

The input is expected to be binary. If not, all `values > 0` are treated as the foreground searched for components.

The components are identified by integer numbers.

The data of each component is a dictionary providing the component's `area`, bounding `box`, `centroid` location, and `parts` list. __Note__ that the centroid is not the same as the center of the bounding box.

The `area` value is an unsigned integer number indicating the number of pixels covered by the component.

The bounding `box` value is a 4-element list holding the x- and y-coordinates of the upper-left and lower-right points of the bounding box, in this order. In other words the x- and y- min coordinates followed by the x- and y- max coordinates.

The `centroid` value is a 2-element list holding the x- and y-coordinates of the point, in this order.

The `parts` value is an __unordered__ list of the row ranges the component consists of. A single range value is a 3-element list holding the y-coordinate of the range, followed by the min and max x-coordinates the range covers.

See "[aktive op connected-components labeled](transform_morphology.md#op_connected_components_labeled)" for a transformer command built on top of this.

__Note__ that this operation can also be used to determine the perimeters of the connected components. Instead of using the image with the regions directly as the operation's input pre-process it with "[aktive op morph gradient internal](transform_morphology.md#op_morph_gradient_internal)" (radius 1) to highlight the region boundaries and feed that result in. The boundary components are the desired perimeters of the original regions. See the second example. __Beware__, there is currently a mismatch here. The morphological gradient is based on a 8-neighbourhood. Connected components on the other hand uses a 4-neighourhood.


#### <a name='op_connected_components_get__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op connected-components get @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00328.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 264 88 1)</td></tr></table></td>
    <td valign='top'><table><tr><td valign='top'>cc.pretty</td><td valign='top'>&nbsp;1&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;8<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{0 0 5 2}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{3.125 1.625}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{0 5 5}&nbsp;{1 5 5}&nbsp;{2 0 5}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>2&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;15<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{1 1 9 6}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{5.266666666666667 3.4}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{1 8 9}&nbsp;{2 8 9}&nbsp;{3 7 8}&nbsp;{4 1 7}&nbsp;{5 1 1}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{6 1 1}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>3&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;8<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{12 1 14 3}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{13.0 2.0}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{1 12 14}&nbsp;{2 12 12}&nbsp;{2 14 14}&nbsp;{3 12 14}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>4&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;18<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{16 1 20 6}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{18.0 3.5}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{1 16 20}&nbsp;{2 16 16}&nbsp;{2 20 20}&nbsp;{3 16 16}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{3 20 20}&nbsp;{4 16 16}&nbsp;{4 20 20}&nbsp;{5 16 16}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{5 20 20}&nbsp;{6 16 20}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>5&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;45<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{22 1 32 7}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{27.0 3.422222222222222}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{1 24 30}&nbsp;{2 23 31}&nbsp;{3 22 32}&nbsp;{4 22 24}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{4 30 32}&nbsp;{5 22 23}&nbsp;{5 31 32}&nbsp;{6 23 24}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{6 30 31}&nbsp;{7 24 25}&nbsp;{7 29 30}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>6&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;15<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{1 4 9 9}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{4.733333333333333 6.6}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{4 9 9}&nbsp;{5 9 9}&nbsp;{6 3 9}&nbsp;{7 2 3}&nbsp;{8 1 2}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{9 1 2}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>7&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;18<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{22 5 32 10}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{27.0 8.61111111111111}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{5 27 27}&nbsp;{6 27 27}&nbsp;{7 27 27}&nbsp;{8 27 27}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{9 22 32}&nbsp;{10 26 28}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>8&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;8<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{5 8 10 10}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{6.875 8.375}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{8 5 10}&nbsp;{9 5 5}&nbsp;{10 5 5}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>9&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;20<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{12 8 19 10}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{15.5 8.8}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{8 12 19}&nbsp;{9 12 19}&nbsp;{10 12 13}&nbsp;{10 18 19}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}</td></tr></table></td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op connected-components get @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00330.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 200 104 1)</td></tr></table></td>
    <td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00331.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 200 104 1)</td></tr></table></td>
    <td valign='top'><table><tr><td valign='top'>cc.pretty</td><td valign='top'>&nbsp;1&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;18<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{1 1 4 7}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{2.5 4.0}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{1 1 4}&nbsp;{2 1 1}&nbsp;{2 4 4}&nbsp;{3 1 1}&nbsp;{3 4 4}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{4 1 1}&nbsp;{4 4 4}&nbsp;{5 1 1}&nbsp;{5 4 4}&nbsp;{6 1 1}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{6 4 4}&nbsp;{7 1 4}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>2&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;14<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{9 1 22 1}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{15.5 1.0}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{1 9 22}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>3&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;28<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{7 3 15 9}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{11.0 6.0}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{3 7 15}&nbsp;{4 7 7}&nbsp;{4 15 15}&nbsp;{5 7 7}&nbsp;{5 15 15}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{6 7 7}&nbsp;{6 15 15}&nbsp;{7 7 7}&nbsp;{7 15 15}&nbsp;{8 7 7}<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{8 15 15}&nbsp;{9 7 15}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>4&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;12<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{9 5 13 7}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{11.0 6.0}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{5 9 13}&nbsp;{6 9 9}&nbsp;{6 13 13}&nbsp;{7 9 13}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}<br/>5&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;area&nbsp;24<br/>&nbsp;&nbsp;&nbsp;&nbsp;box&nbsp;{13 10 23 12}<br/>&nbsp;&nbsp;&nbsp;&nbsp;centroid&nbsp;{18.208333333333332 11.208333333333334}<br/>&nbsp;&nbsp;&nbsp;&nbsp;parts&nbsp;{<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{10 18 23}&nbsp;{11 13 18}&nbsp;{11 23 23}&nbsp;{12 13 23}<br/>&nbsp;&nbsp;&nbsp;&nbsp;}<br/>}</td></tr></table></td></tr>
</table>


