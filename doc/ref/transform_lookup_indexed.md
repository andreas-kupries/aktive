<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform lookup indexed

## <anchor='top'> Table Of Contents

  - [transform lookup](transform_lookup.md) ↗


### Operators

 - [aktive op lut compose](#op_lut_compose)
 - [aktive op lut from](#op_lut_from)
 - [aktive op lut indexed](#op_lut_indexed)
 - [aktive op lut indexed-core](#op_lut_indexed_core)

## Operators

---
### [↑](#top) <a name='op_lut_compose'></a> aktive op lut compose

Syntax: __aktive op lut compose__ a b [[→ definition](/file?ci=trunk&ln=62&name=etc/transformer/filter/lookup.tcl)]

Returns the composition `A*B` of the two indexed LUTs A and B. This composition is defined as `(A*B) (src) == A (B (src))`.

Internally this is computed as applying LUT A to input B, i.e. `A (B)`.

|Input|Description|
|:---|:---|
|a|LUT A to compose|
|b|LUT B to compose|

---
### [↑](#top) <a name='op_lut_from'></a> aktive op lut from

Syntax: __aktive op lut from__  (param value)... [[→ definition](/file?ci=trunk&ln=48&name=etc/transformer/filter/lookup.tcl)]

Create a single-band, single-row indexed LUT from values

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|values|double...||LUT values|

---
### [↑](#top) <a name='op_lut_indexed'></a> aktive op lut indexed

Syntax: __aktive op lut indexed__ lut src ?(param value)...? [[→ definition](/file?ci=trunk&ln=85&name=etc/transformer/filter/lookup.tcl)]

Returns the result of mapping the input through the LUT.

This operator is __strict__ in the 1st input. The LUT is materialized and cached.

The location of the LUT image is ignored.

The LUT has to be single-row, with multiple columns and bands.

Each LUT band is applied to the corresponding image band. The LUT's last band is replicated if the LUT has less bands than the image. Excess LUT bands are ignored.

Input pixels are expected to be in the range `0..1`. Values outside of that range are clamped to these (saturated math). The LUT width is used to quantize the clamped values into integer indices suitable for the LUT. The so-addressed LUT value becomes the value for that pixel of the result.

In interpolation mode (default: off) the fractional part of the input pixel is used to linearly interpolate between the values at the LUT index and the next index to determine the result.

The difference between this operator and [aktive op lut indexed-core](transform_lookup_indexed.md#op_lut_indexed_core) is the handling of a LUT with less bands than the input. Here the LUT is extended by replicating the last band. The core op throwns an error instead.

|Input|Description|
|:---|:---|
|lut|The LUT to apply. Materialized at construction time.|
|src|The image to apply the LUT to.|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|interpolate|bool|false|Flag to activate interpolation mode.|

---
### [↑](#top) <a name='op_lut_indexed_core'></a> aktive op lut indexed-core

Syntax: __aktive op lut indexed-core__ lut src ?(param value)...? [[→ definition](/file?ci=trunk&ln=132&name=etc/transformer/filter/lookup.tcl)]

Returns the result of mapping the input through the LUT.

This operator is __strict__ in the 1st input. The LUT is materialized and cached.

The location of the LUT image is ignored.

The LUT has to be single-row, with multiple columns and bands.

Each LUT band is applied to the corresponding image band. An error is thrown if the LUT has less bands than the image. Excess LUT bands are ignored.

Input pixels are expected to be in the range `0..1`. Values outside of that range are clamped to these (saturated math). The LUT width is used to quantize the clamped values into integer indices suitable for the LUT. The so-addressed LUT value becomes the value for that pixel of the result.

In interpolation mode (default: off) the fractional part of the input pixel is used to linearly interpolate between the values at the LUT index and the next index to determine the result.

The difference between this operator and [aktive op lut indexed](transform_lookup_indexed.md#op_lut_indexed) is the handling of a LUT with less bands than the input. Here an error is thrown. The wrapper extends the LUT by replicating the last band instead.

|Input|Description|
|:---|:---|
|lut|The LUT to apply. Materialized at construction time.|
|src|The image to apply the LUT to.|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|interpolate|bool|false|Flag to activate value interpolation mode.|

