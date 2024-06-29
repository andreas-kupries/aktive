# Documentation -- Reference Pages -- transform kuwahara

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

||||||||
|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op kuwahara](#op_kuwahara)
 - [aktive op kuwahara-core](#op_kuwahara_core)

## Operators

---
### <a name='op_kuwahara'></a> aktive op kuwahara

Syntax: __aktive op kuwahara__ src ?(param value)...?

Returns input with a Kuwahara filter applied to it.

The location of the input is ignored.

The image is allowed to be multi-band.

For known colorspaces the core filter is applied to the luminance channel of the input.

The image may be converted into and out of a colorspace with such a channel if it does not have one on its own.

For images without known colorspace the last band is used as the luminance channel.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|uint|2|Filter radius. Actual window size is `2*k-1`. The default value is 2. This is also the minimum allowed value.|

---
### <a name='op_kuwahara_core'></a> aktive op kuwahara-core

Syntax: __aktive op kuwahara-core__ src ?(param value)...?

Returns input with a Kuwahara filter applied to it.

The location of the input is ignored.

The input is expected to be single-band.

The result image is shrunken by `k` relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for kuwahara is `mirror`. It is chosen to have minimal to no impact on results at the original input's borders.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|uint|2|Filter radius. Actual window size is `2*k-1`. The default value is 2. This is also the minimum allowed value.|

