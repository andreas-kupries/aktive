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

|@1|aktive query depth 	@1 |
|---|---|
|<img src='example-00317.gif' alt='@1' style='border:4px solid gold'>|1|

|@1|aktive query depth 	@1 |
|---|---|
|<img src='example-00319.gif' alt='@1' style='border:4px solid gold'>|1|


---
### <a name='query_domain'></a> aktive query domain

Syntax: __aktive query domain__ src

Returns the input's domain, a 2D rectangle. I.e. location, width, and height.


## Examples

|@1|aktive query domain 	@1 |
|---|---|
|<img src='example-00321.gif' alt='@1' style='border:4px solid gold'>|0 0 32 32|

|@1|aktive query domain 	@1 |
|---|---|
|<img src='example-00323.gif' alt='@1' style='border:4px solid gold'>|0 0 32 32|


---
### <a name='query_geometry'></a> aktive query geometry

Syntax: __aktive query geometry__ src

Returns the input's full geometry, i.e. domain and depth.


## Examples

|@1|aktive query geometry 	@1 |
|---|---|
|<img src='example-00325.gif' alt='@1' style='border:4px solid gold'>|0 0 32 32 1|

|@1|aktive query geometry 	@1 |
|---|---|
|<img src='example-00327.gif' alt='@1' style='border:4px solid gold'>|0 0 32 32 1|


---
### <a name='query_height'></a> aktive query height

Syntax: __aktive query height__ src

Returns the input's height.


## Examples

|@1|aktive query height 	@1 |
|---|---|
|<img src='example-00329.gif' alt='@1' style='border:4px solid gold'>|32|

|@1|aktive query height 	@1 |
|---|---|
|<img src='example-00331.gif' alt='@1' style='border:4px solid gold'>|32|


---
### <a name='query_location'></a> aktive query location

Syntax: __aktive query location__ src

Returns the input's location, a 2D point.


## Examples

|@1|aktive query location 	@1 |
|---|---|
|<img src='example-00333.gif' alt='@1' style='border:4px solid gold'>|0 0|

|@1|aktive query location 	@1 |
|---|---|
|<img src='example-00335.gif' alt='@1' style='border:4px solid gold'>|0 0|


---
### <a name='query_pitch'></a> aktive query pitch

Syntax: __aktive query pitch__ src

Returns the input's pitch, the number of values in a row, i.e. width times depth.


## Examples

|@1|aktive query pitch 	@1 |
|---|---|
|<img src='example-00343.gif' alt='@1' style='border:4px solid gold'>|32|

|@1|aktive query pitch 	@1 |
|---|---|
|<img src='example-00345.gif' alt='@1' style='border:4px solid gold'>|32|


---
### <a name='query_pixels'></a> aktive query pixels

Syntax: __aktive query pixels__ src

Returns the input's number of pixels.


## Examples

|@1|aktive query pixels 	@1 |
|---|---|
|<img src='example-00347.gif' alt='@1' style='border:4px solid gold'>|1024|

|@1|aktive query pixels 	@1 |
|---|---|
|<img src='example-00349.gif' alt='@1' style='border:4px solid gold'>|1024|


---
### <a name='query_size'></a> aktive query size

Syntax: __aktive query size__ src

Returns the input's size, i.e. the number of pixels times depth.


## Examples

|@1|aktive query size 	@1 |
|---|---|
|<img src='example-00355.gif' alt='@1' style='border:4px solid gold'>|1024|

|@1|aktive query size 	@1 |
|---|---|
|<img src='example-00357.gif' alt='@1' style='border:4px solid gold'>|1024|


---
### <a name='query_width'></a> aktive query width

Syntax: __aktive query width__ src

Returns the input's width.


## Examples

|@1|aktive query width 	@1 |
|---|---|
|<img src='example-00367.gif' alt='@1' style='border:4px solid gold'>|32|

|@1|aktive query width 	@1 |
|---|---|
|<img src='example-00369.gif' alt='@1' style='border:4px solid gold'>|32|


---
### <a name='query_x'></a> aktive query x

Syntax: __aktive query x__ src

Returns the input's x location.


## Examples

|@1|aktive query x 	@1 |
|---|---|
|<img src='example-00371.gif' alt='@1' style='border:4px solid gold'>|0|

|@1|aktive query x 	@1 |
|---|---|
|<img src='example-00373.gif' alt='@1' style='border:4px solid gold'>|0|


---
### <a name='query_xmax'></a> aktive query xmax

Syntax: __aktive query xmax__ src

Returns the input's maximum x location.


## Examples

|@1|aktive query xmax 	@1 |
|---|---|
|<img src='example-00375.gif' alt='@1' style='border:4px solid gold'>|31|

|@1|aktive query xmax 	@1 |
|---|---|
|<img src='example-00377.gif' alt='@1' style='border:4px solid gold'>|31|


---
### <a name='query_y'></a> aktive query y

Syntax: __aktive query y__ src

Returns the input's y location.


## Examples

|@1|aktive query y 	@1 |
|---|---|
|<img src='example-00379.gif' alt='@1' style='border:4px solid gold'>|0|

|@1|aktive query y 	@1 |
|---|---|
|<img src='example-00381.gif' alt='@1' style='border:4px solid gold'>|0|


---
### <a name='query_ymax'></a> aktive query ymax

Syntax: __aktive query ymax__ src

Returns the input's maximum y location.


## Examples

|@1|aktive query ymax 	@1 |
|---|---|
|<img src='example-00383.gif' alt='@1' style='border:4px solid gold'>|31|

|@1|aktive query ymax 	@1 |
|---|---|
|<img src='example-00385.gif' alt='@1' style='border:4px solid gold'>|31|


