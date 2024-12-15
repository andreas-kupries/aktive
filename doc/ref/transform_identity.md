<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform identity

## <anchor='top'> Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op pass](#op_pass)

## Operators

---
### [↑](#top) <a name='op_pass'></a> aktive op pass

Syntax: __aktive op pass__ src [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/identity.tcl)]

Returns unchanged input.

This is useful for round-trip testing, to stop application of simplification rules which would otherwise eliminate or modify the chain of operations under test.

|Input|Description|
|:---|:---|
|src|Source image|

