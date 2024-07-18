# Documentation -- Reference Pages -- transform wiener

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op wiener](#op_wiener)

## Operators

---
### <a name='op_wiener'></a> aktive op wiener

Syntax: __aktive op wiener__ src ?(param value)...?

Returns input with a Wiener reconstruction filter applied to it.

The location of the input is ignored.

The filter is applied to each band of the input separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|2|Filter radius. Actual window size is `2*k-1`. The default value is 2. This is also the minimum allowed value.|
|embed|str|mirror|Embedding to use for the internal local mean/variance information. The default, mirror, is chosen to not affect the result as much as possible.|

