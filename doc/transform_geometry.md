# transform geometry

||||||||
|---|---|---|---|---|---|---|
|[Home ↗](../README.md)|[Main ↗](index.md)|[Sections](index.md#sectree)|[Permuted Sections](bypsections.md)|[Names](byname.md)|[Permuted Names](bypnames.md)|[Implementations](bylang.md)|

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op geometry bands fold](#op_geometry_bands_fold)
 - [aktive op geometry bands unfold](#op_geometry_bands_unfold)

## Operators

---
### <a name='op_geometry_bands_fold'></a> aktive op geometry bands fold

Syntax: __aktive op geometry bands fold__ src (param value)...

Returns image with the input's columns folded into bands, reducing width. The result is a (input depth * k)-band image and input width divided by k.

The parameter k has to be a proper divisor of the input width. I.e. the input width divided by k leaves no remainder.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Folding factor. Range 2... Factor 1 is a nop-op.|

---
### <a name='op_geometry_bands_unfold'></a> aktive op geometry bands unfold

Syntax: __aktive op geometry bands unfold__ src

Returns image with the input's bands unfolded and making it wider. The result is a single-band image wider by input depth times.


