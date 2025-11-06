<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- accessor geometry

## <anchor='top'> Table Of Contents

  - [accessor](accessor.md) ↗


### Operators

 - [aktive query depth](#query_depth)
 - [aktive query domain](#query_domain)
 - [aktive query geometry](#query_geometry)
 - [aktive query height](#query_height)
 - [aktive query location](#query_location)
 - [aktive query pitch](#query_pitch)
 - [aktive query pixels](#query_pixels)
 - [aktive query size](#query_size)
 - [aktive query width](#query_width)
 - [aktive query x](#query_x)
 - [aktive query xmax](#query_xmax)
 - [aktive query y](#query_y)
 - [aktive query ymax](#query_ymax)

## Operators

---
### [↑](#top) <a name='query_depth'></a> aktive query depth

Syntax: __aktive query depth__ src [[→ definition](/file?ci=trunk&ln=141&name=etc/accessor/attributes.tcl)]

Returns the input's depth.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_depth__examples'></a> Examples

<a name='query_depth__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query depth @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00681.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1</td></tr>
</table>

<a name='query_depth__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query depth @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00683.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1</td></tr>
</table>


---
### [↑](#top) <a name='query_domain'></a> aktive query domain

Syntax: __aktive query domain__ src [[→ definition](/file?ci=trunk&ln=69&name=etc/accessor/attributes.tcl)]

Returns the input's domain, a 2D rectangle. I.e. location, width, and height.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_domain__examples'></a> Examples

<a name='query_domain__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query domain @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00685.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0 32 32</td></tr>
</table>

<a name='query_domain__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query domain @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00687.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0 32 32</td></tr>
</table>


---
### [↑](#top) <a name='query_geometry'></a> aktive query geometry

Syntax: __aktive query geometry__ src [[→ definition](/file?ci=trunk&ln=90&name=etc/accessor/attributes.tcl)]

Returns the input's full geometry, i.e. domain and depth.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_geometry__examples'></a> Examples

<a name='query_geometry__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query geometry @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00689.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0 32 32 1</td></tr>
</table>

<a name='query_geometry__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query geometry @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00691.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0 32 32 1</td></tr>
</table>


---
### [↑](#top) <a name='query_height'></a> aktive query height

Syntax: __aktive query height__ src [[→ definition](/file?ci=trunk&ln=141&name=etc/accessor/attributes.tcl)]

Returns the input's height.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_height__examples'></a> Examples

<a name='query_height__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query height @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00693.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>

<a name='query_height__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query height @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00695.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>


---
### [↑](#top) <a name='query_location'></a> aktive query location

Syntax: __aktive query location__ src [[→ definition](/file?ci=trunk&ln=48&name=etc/accessor/attributes.tcl)]

Returns the input's location, a 2D point.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_location__examples'></a> Examples

<a name='query_location__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query location @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00697.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0</td></tr>
</table>

<a name='query_location__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query location @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00699.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0</td></tr>
</table>


---
### [↑](#top) <a name='query_pitch'></a> aktive query pitch

Syntax: __aktive query pitch__ src [[→ definition](/file?ci=trunk&ln=141&name=etc/accessor/attributes.tcl)]

Returns the input's pitch, the number of values in a row, i.e. width times depth.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_pitch__examples'></a> Examples

<a name='query_pitch__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query pitch @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00707.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>

<a name='query_pitch__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query pitch @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00709.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>


---
### [↑](#top) <a name='query_pixels'></a> aktive query pixels

Syntax: __aktive query pixels__ src [[→ definition](/file?ci=trunk&ln=141&name=etc/accessor/attributes.tcl)]

Returns the input's number of pixels.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_pixels__examples'></a> Examples

<a name='query_pixels__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query pixels @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00711.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1024</td></tr>
</table>

<a name='query_pixels__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query pixels @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00713.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1024</td></tr>
</table>


---
### [↑](#top) <a name='query_size'></a> aktive query size

Syntax: __aktive query size__ src [[→ definition](/file?ci=trunk&ln=141&name=etc/accessor/attributes.tcl)]

Returns the input's size, i.e. the number of pixels times depth.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_size__examples'></a> Examples

<a name='query_size__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query size @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00719.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1024</td></tr>
</table>

<a name='query_size__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query size @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00721.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1024</td></tr>
</table>


---
### [↑](#top) <a name='query_width'></a> aktive query width

Syntax: __aktive query width__ src [[→ definition](/file?ci=trunk&ln=141&name=etc/accessor/attributes.tcl)]

Returns the input's width.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_width__examples'></a> Examples

<a name='query_width__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query width @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00731.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>

<a name='query_width__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query width @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00733.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>


---
### [↑](#top) <a name='query_x'></a> aktive query x

Syntax: __aktive query x__ src [[→ definition](/file?ci=trunk&ln=113&name=etc/accessor/attributes.tcl)]

Returns the input's x location.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_x__examples'></a> Examples

<a name='query_x__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query x @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00735.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0</td></tr>
</table>

<a name='query_x__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query x @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00737.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0</td></tr>
</table>


---
### [↑](#top) <a name='query_xmax'></a> aktive query xmax

Syntax: __aktive query xmax__ src [[→ definition](/file?ci=trunk&ln=113&name=etc/accessor/attributes.tcl)]

Returns the input's maximum x location.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_xmax__examples'></a> Examples

<a name='query_xmax__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query xmax @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00739.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;31</td></tr>
</table>

<a name='query_xmax__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query xmax @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00741.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;31</td></tr>
</table>


---
### [↑](#top) <a name='query_y'></a> aktive query y

Syntax: __aktive query y__ src [[→ definition](/file?ci=trunk&ln=113&name=etc/accessor/attributes.tcl)]

Returns the input's y location.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_y__examples'></a> Examples

<a name='query_y__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query y @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00743.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0</td></tr>
</table>

<a name='query_y__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query y @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00745.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0</td></tr>
</table>


---
### [↑](#top) <a name='query_ymax'></a> aktive query ymax

Syntax: __aktive query ymax__ src [[→ definition](/file?ci=trunk&ln=113&name=etc/accessor/attributes.tcl)]

Returns the input's maximum y location.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_ymax__examples'></a> Examples

<a name='query_ymax__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query ymax @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00747.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;31</td></tr>
</table>

<a name='query_ymax__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query ymax @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00749.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;31</td></tr>
</table>


