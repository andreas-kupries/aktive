<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- accessor geometry

## Table Of Contents

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
### <a name='query_depth'></a> aktive query depth

Syntax: __aktive query depth__ src [[→ definition](../../../../file?ci=trunk&ln=139&name=etc/accessor/attributes.tcl)]

Returns the input's depth.


#### <a name='query_depth__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query depth @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00446.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query depth @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00448.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1</td></tr>
</table>


---
### <a name='query_domain'></a> aktive query domain

Syntax: __aktive query domain__ src [[→ definition](../../../../file?ci=trunk&ln=69&name=etc/accessor/attributes.tcl)]

Returns the input's domain, a 2D rectangle. I.e. location, width, and height.


#### <a name='query_domain__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query domain @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00450.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0 32 32</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query domain @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00452.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0 32 32</td></tr>
</table>


---
### <a name='query_geometry'></a> aktive query geometry

Syntax: __aktive query geometry__ src [[→ definition](../../../../file?ci=trunk&ln=90&name=etc/accessor/attributes.tcl)]

Returns the input's full geometry, i.e. domain and depth.


#### <a name='query_geometry__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query geometry @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00454.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0 32 32 1</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query geometry @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00456.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0 32 32 1</td></tr>
</table>


---
### <a name='query_height'></a> aktive query height

Syntax: __aktive query height__ src [[→ definition](../../../../file?ci=trunk&ln=139&name=etc/accessor/attributes.tcl)]

Returns the input's height.


#### <a name='query_height__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query height @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00458.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query height @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00460.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>


---
### <a name='query_location'></a> aktive query location

Syntax: __aktive query location__ src [[→ definition](../../../../file?ci=trunk&ln=48&name=etc/accessor/attributes.tcl)]

Returns the input's location, a 2D point.


#### <a name='query_location__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query location @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00462.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query location @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00464.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0 0</td></tr>
</table>


---
### <a name='query_pitch'></a> aktive query pitch

Syntax: __aktive query pitch__ src [[→ definition](../../../../file?ci=trunk&ln=139&name=etc/accessor/attributes.tcl)]

Returns the input's pitch, the number of values in a row, i.e. width times depth.


#### <a name='query_pitch__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query pitch @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00472.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query pitch @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00474.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>


---
### <a name='query_pixels'></a> aktive query pixels

Syntax: __aktive query pixels__ src [[→ definition](../../../../file?ci=trunk&ln=139&name=etc/accessor/attributes.tcl)]

Returns the input's number of pixels.


#### <a name='query_pixels__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query pixels @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00476.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1024</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query pixels @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00478.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1024</td></tr>
</table>


---
### <a name='query_size'></a> aktive query size

Syntax: __aktive query size__ src [[→ definition](../../../../file?ci=trunk&ln=139&name=etc/accessor/attributes.tcl)]

Returns the input's size, i.e. the number of pixels times depth.


#### <a name='query_size__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query size @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00484.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1024</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query size @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00486.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;1024</td></tr>
</table>


---
### <a name='query_width'></a> aktive query width

Syntax: __aktive query width__ src [[→ definition](../../../../file?ci=trunk&ln=139&name=etc/accessor/attributes.tcl)]

Returns the input's width.


#### <a name='query_width__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query width @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00496.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query width @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00498.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;32</td></tr>
</table>


---
### <a name='query_x'></a> aktive query x

Syntax: __aktive query x__ src [[→ definition](../../../../file?ci=trunk&ln=111&name=etc/accessor/attributes.tcl)]

Returns the input's x location.


#### <a name='query_x__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query x @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00500.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query x @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00502.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0</td></tr>
</table>


---
### <a name='query_xmax'></a> aktive query xmax

Syntax: __aktive query xmax__ src [[→ definition](../../../../file?ci=trunk&ln=111&name=etc/accessor/attributes.tcl)]

Returns the input's maximum x location.


#### <a name='query_xmax__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query xmax @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00504.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;31</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query xmax @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00506.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;31</td></tr>
</table>


---
### <a name='query_y'></a> aktive query y

Syntax: __aktive query y__ src [[→ definition](../../../../file?ci=trunk&ln=111&name=etc/accessor/attributes.tcl)]

Returns the input's y location.


#### <a name='query_y__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query y @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00508.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query y @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00510.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;0</td></tr>
</table>


---
### <a name='query_ymax'></a> aktive query ymax

Syntax: __aktive query ymax__ src [[→ definition](../../../../file?ci=trunk&ln=111&name=etc/accessor/attributes.tcl)]

Returns the input's maximum y location.


#### <a name='query_ymax__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query ymax @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00512.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;31</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query ymax @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00514.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'>&nbsp;31</td></tr>
</table>


