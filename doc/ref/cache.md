# Documentation -- Reference Pages -- cache

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [Main](index.md) ↗


### Operators

 - [aktive op cache](#op_cache)

## Operators

---
### <a name='op_cache'></a> aktive op cache

Syntax: __aktive op cache__ src

Returns the unchanged input.

However, this operator materializes and caches the input in memory, for fast random access. Yet it is __not strict__, as the materialization is deferred until the first access.

This is useful to put in front of a computationally expensive pipeline, to avoid recomputing parts as upstream demands them. The trade-off here is, of course, memory for time.


