# Documentation -- Reference Pages -- transform identity

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op pass](#op_pass)

## Operators

---
### <a name='op_pass'></a> aktive op pass

Syntax: __aktive op pass__ src

Returns unchanged input.

This is useful for round-trip testing, to stop application of simplification rules which would otherwise eliminate or modify the chain of operations under test.


