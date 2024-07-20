<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- miscellaneous

## Table Of Contents

  - [Roots](bysection.md) ↗


## Subsections


 - [miscellaneous geometry](miscellaneous_geometry.md) ↘

### Operators

 - [aktive error](#error)
 - [aktive processors](#processors)
 - [aktive version](#version)

## Operators

---
### <a name='error'></a> aktive error

Syntax: __aktive error__ m args...

Throw error with message and error code.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|m|str||Human readable error message|
|args|str...||Trappable error code suffix|

---
### <a name='processors'></a> aktive processors

Syntax: __aktive processors__ 

Return number of processor cores available for concurrent operation.


---
### <a name='version'></a> aktive version

Syntax: __aktive version__ 

Return package version number.


