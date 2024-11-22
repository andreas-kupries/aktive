<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform geometry

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op geometry bands fold](#op_geometry_bands_fold)
 - [aktive op geometry bands unfold](#op_geometry_bands_unfold)

## Operators

---
### <a name='op_geometry_bands_fold'></a> aktive op geometry bands fold

Syntax: __aktive op geometry bands fold__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=12&name=etc/transformer/structure/band-geometry.tcl)]

Returns image with the input's columns folded into bands, reducing width. The result is a (input depth * k)-band image and input width divided by k.

The parameter k has to be a proper divisor of the input width. I.e. the input width divided by k leaves no remainder.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Folding factor. Range 2... Factor 1 is a nop-op.|

---
### <a name='op_geometry_bands_unfold'></a> aktive op geometry bands unfold

Syntax: __aktive op geometry bands unfold__ src [[→ definition](../../../../file?ci=trunk&ln=102&name=etc/transformer/structure/band-geometry.tcl)]

Returns image with the input's bands unfolded and making it wider. The result is a single-band image wider by input depth times.


