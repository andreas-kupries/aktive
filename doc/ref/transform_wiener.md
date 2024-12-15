<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform wiener

## <anchor='top'> Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op wiener](#op_wiener)

## Operators

---
### [↑](#top) <a name='op_wiener'></a> aktive op wiener

Syntax: __aktive op wiener__ src ?(param value)...? [[→ definition](/file?ci=trunk&ln=7&name=etc/transformer/filter/wiener.tcl)]

Returns the input with a [Wiener reconstruction filter](https://en.wikipedia.org/wiki/Wiener_filter) applied to it.

The location of the input is ignored.

The filter is applied to each band of the input separately.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|2|Filter radius. Actual window size is `2*k-1`. The default value is 2. This is also the minimum allowed value.|
|embed|str|mirror|Embedding to use for the internal local mean/variance information. The default, mirror, is chosen to not affect the result as much as possible.|

#### <a name='op_wiener__references'></a> References

  - <https://en.wikipedia.org/wiki/Wiener_filter>

