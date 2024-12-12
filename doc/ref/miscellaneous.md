<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- miscellaneous

## <anchor='top'> Table Of Contents

  - [Roots](bysection.md) ↗


## Subsections


 - [miscellaneous geometry](miscellaneous_geometry.md) ↘

### Operators

 - [aktive error](#error)
 - [aktive processors](#processors)
 - [aktive version](#version)

## Operators

---
### [↑](#top) <a name='error'></a> aktive error

Syntax: __aktive error__ m args... [[→ definition](../../../../file?ci=trunk&ln=201&name=etc/aktive.tcl)]

Throw error with message and error code.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|m|str||Human readable error message|
|args|str...||Trappable error code suffix|

---
### [↑](#top) <a name='processors'></a> aktive processors

Syntax: __aktive processors__ n [[→ definition](../../../../file?ci=trunk&ln=218&name=etc/aktive.tcl)]

Set/Return number of processor cores available for concurrent operation.

Setting the default, `0`, causes the system to query the OS for the number of available processors and use the result. Anything else limits concurrency to the defined count. __Beware__ overcommit is possible, if more processors are declared for use than actually exist.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|n|int|0|Set number of processor available for concurrent operation.|

---
### [↑](#top) <a name='version'></a> aktive version

Syntax: __aktive version__  [[→ definition](../../../../file?ci=trunk&ln=211&name=etc/aktive.tcl)]

Return package version number.

