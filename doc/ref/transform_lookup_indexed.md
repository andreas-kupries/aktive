<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform lookup indexed

## Table Of Contents

  - [transform lookup](transform_lookup.md) ↗


## Subsections


 - [transform lookup indexed compose](transform_lookup_indexed_compose.md) ↘
 - [transform lookup indexed make](transform_lookup_indexed_make.md) ↘

### Operators

 - [aktive op lut indexed](#op_lut_indexed)
 - [aktive op lut indexed-core](#op_lut_indexed_core)

## Operators

---
### <a name='op_lut_indexed'></a> aktive op lut indexed

Syntax: __aktive op lut indexed__ src0 src1 ?(param value)...?

Map the input image (second argument) through the LUT image provided as the first arguments and return the result.

This operator is __strict__ in the 1st input. The LUT to map through is materialized and cached.

The location of the LUT image is ignored.

The LUT image has to be single-row, with multiple columns and bands.



Each LUT band is applied to the corresponding image band.

Excess LUT bands are ignored.

If there are not enough LUT bands for the input the last LUT band is replicated.



Input pixels are expected to be in the range 0...1.

Values outside of that range are clamped to these.

The clamped values are quantized per the LUT width to integer indices into the LUT.

The LUT value becomes the result value for that pixel.



When extended mode is active the fractional part of the input pixel is used

to interpolate linearly between the values at the LUT index, and the next index.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|interpolate|bool|false|Flag to activate value interpolation mode.|

---
### <a name='op_lut_indexed_core'></a> aktive op lut indexed-core

Syntax: __aktive op lut indexed-core__ src0 src1 ?(param value)...?

Map the input image (second argument) through the LUT image provided as the first arguments and return the result.

The location of the LUT image is ignored.

The LUT is fully materialized at construction time.

The LUT image has to be single-row, with multiple columns and bands.



Each LUT band is applied to the corresponding image band.

Excess LUT bands are ignored.

If there are not enough LUT bands for the input an error is thrown



Input pixels are expected to be in the range 0...1.

Values outside of that range are clamped to these.

The clamped values are quantized per the LUT width to integer indices into the LUT.

The LUT value becomes the result value for that pixel.



When extended mode is active the fractional part of the input pixel is used

to interpolate linearly between the values at the LUT index, and the next index.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|interpolate|bool|false|Flag to activate value interpolation mode.|

