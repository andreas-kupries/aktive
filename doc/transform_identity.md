# transform identity

||||||||
|---|---|---|---|---|---|---|
|[Home ↗](/)|[Main ↗](index.md)|[Sections](index.md#sectree)|[Permuted Sections](bypsections.md)|[Names](byname.md)|[Permuted Names](bypnames.md)|[Implementations](bylang.md)|

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

