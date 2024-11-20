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

Syntax: __aktive query depth__ src

Returns the input's depth.


## Examples

<table><tr><th>@1</th><th>aktive query depth @1</th></tr>
<tr><td valign='top'><img src='example-00378.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>1</td></tr></table>

<table><tr><th>@1</th><th>aktive query depth @1</th></tr>
<tr><td valign='top'><img src='example-00380.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>1</td></tr></table>


---
### <a name='query_domain'></a> aktive query domain

Syntax: __aktive query domain__ src

Returns the input's domain, a 2D rectangle. I.e. location, width, and height.


## Examples

<table><tr><th>@1</th><th>aktive query domain @1</th></tr>
<tr><td valign='top'><img src='example-00382.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0 0 32 32</td></tr></table>

<table><tr><th>@1</th><th>aktive query domain @1</th></tr>
<tr><td valign='top'><img src='example-00384.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0 0 32 32</td></tr></table>


---
### <a name='query_geometry'></a> aktive query geometry

Syntax: __aktive query geometry__ src

Returns the input's full geometry, i.e. domain and depth.


## Examples

<table><tr><th>@1</th><th>aktive query geometry @1</th></tr>
<tr><td valign='top'><img src='example-00386.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0 0 32 32 1</td></tr></table>

<table><tr><th>@1</th><th>aktive query geometry @1</th></tr>
<tr><td valign='top'><img src='example-00388.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0 0 32 32 1</td></tr></table>


---
### <a name='query_height'></a> aktive query height

Syntax: __aktive query height__ src

Returns the input's height.


## Examples

<table><tr><th>@1</th><th>aktive query height @1</th></tr>
<tr><td valign='top'><img src='example-00390.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>32</td></tr></table>

<table><tr><th>@1</th><th>aktive query height @1</th></tr>
<tr><td valign='top'><img src='example-00392.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>32</td></tr></table>


---
### <a name='query_location'></a> aktive query location

Syntax: __aktive query location__ src

Returns the input's location, a 2D point.


## Examples

<table><tr><th>@1</th><th>aktive query location @1</th></tr>
<tr><td valign='top'><img src='example-00394.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0 0</td></tr></table>

<table><tr><th>@1</th><th>aktive query location @1</th></tr>
<tr><td valign='top'><img src='example-00396.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0 0</td></tr></table>


---
### <a name='query_pitch'></a> aktive query pitch

Syntax: __aktive query pitch__ src

Returns the input's pitch, the number of values in a row, i.e. width times depth.


## Examples

<table><tr><th>@1</th><th>aktive query pitch @1</th></tr>
<tr><td valign='top'><img src='example-00404.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>32</td></tr></table>

<table><tr><th>@1</th><th>aktive query pitch @1</th></tr>
<tr><td valign='top'><img src='example-00406.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>32</td></tr></table>


---
### <a name='query_pixels'></a> aktive query pixels

Syntax: __aktive query pixels__ src

Returns the input's number of pixels.


## Examples

<table><tr><th>@1</th><th>aktive query pixels @1</th></tr>
<tr><td valign='top'><img src='example-00408.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>1024</td></tr></table>

<table><tr><th>@1</th><th>aktive query pixels @1</th></tr>
<tr><td valign='top'><img src='example-00410.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>1024</td></tr></table>


---
### <a name='query_size'></a> aktive query size

Syntax: __aktive query size__ src

Returns the input's size, i.e. the number of pixels times depth.


## Examples

<table><tr><th>@1</th><th>aktive query size @1</th></tr>
<tr><td valign='top'><img src='example-00416.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>1024</td></tr></table>

<table><tr><th>@1</th><th>aktive query size @1</th></tr>
<tr><td valign='top'><img src='example-00418.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>1024</td></tr></table>


---
### <a name='query_width'></a> aktive query width

Syntax: __aktive query width__ src

Returns the input's width.


## Examples

<table><tr><th>@1</th><th>aktive query width @1</th></tr>
<tr><td valign='top'><img src='example-00428.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>32</td></tr></table>

<table><tr><th>@1</th><th>aktive query width @1</th></tr>
<tr><td valign='top'><img src='example-00430.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>32</td></tr></table>


---
### <a name='query_x'></a> aktive query x

Syntax: __aktive query x__ src

Returns the input's x location.


## Examples

<table><tr><th>@1</th><th>aktive query x @1</th></tr>
<tr><td valign='top'><img src='example-00432.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0</td></tr></table>

<table><tr><th>@1</th><th>aktive query x @1</th></tr>
<tr><td valign='top'><img src='example-00434.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0</td></tr></table>


---
### <a name='query_xmax'></a> aktive query xmax

Syntax: __aktive query xmax__ src

Returns the input's maximum x location.


## Examples

<table><tr><th>@1</th><th>aktive query xmax @1</th></tr>
<tr><td valign='top'><img src='example-00436.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>31</td></tr></table>

<table><tr><th>@1</th><th>aktive query xmax @1</th></tr>
<tr><td valign='top'><img src='example-00438.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>31</td></tr></table>


---
### <a name='query_y'></a> aktive query y

Syntax: __aktive query y__ src

Returns the input's y location.


## Examples

<table><tr><th>@1</th><th>aktive query y @1</th></tr>
<tr><td valign='top'><img src='example-00440.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0</td></tr></table>

<table><tr><th>@1</th><th>aktive query y @1</th></tr>
<tr><td valign='top'><img src='example-00442.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>0</td></tr></table>


---
### <a name='query_ymax'></a> aktive query ymax

Syntax: __aktive query ymax__ src

Returns the input's maximum y location.


## Examples

<table><tr><th>@1</th><th>aktive query ymax @1</th></tr>
<tr><td valign='top'><img src='example-00444.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>31</td></tr></table>

<table><tr><th>@1</th><th>aktive query ymax @1</th></tr>
<tr><td valign='top'><img src='example-00446.gif' alt='@1' style='border:4px solid gold'></td><td valign='top'>31</td></tr></table>


