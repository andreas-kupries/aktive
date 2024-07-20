<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- accessor morphology

## Table Of Contents

  - [accessor](accessor.md) ↗


### Operators

 - [aktive op connected-components get](#op_connected_components_get)

## Operators

---
### <a name='op_connected_components_get'></a> aktive op connected-components get

Syntax: __aktive op connected-components get__ src

Returns a Tcl dictionary describing all the connected components found in the (binary) input.

The components are identified by integer numbers.

The data of each component is a dictionary providing the elements of the component's bounding box, its area (in pixels), and an unordered list of the row ranges the component consists of.


## Examples

### aktive op connected-components get @1 (cc.norm)

|||
|---|---|
|@1|aktive op connected-components get @1|
|<img src='example-00119.gif' alt='aktive op connected-components get @1 (cc.norm)' style='border:4px solid gold'>|`1 {area 8 parts {{0 5 5} {1 5 5} {2 0 5}} xmax 5 xmin 0 ymax 2 ymin 0} 2 {area 15 parts {{1 8 9} {2 8 9} {3 7 8} {4 1 7} {5 1 1} {6 1 1}} xmax 9 xmin 1 ymax 6 ymin 1} 3 {area 8 parts {{1 12 14} {2 12 12} {2 14 14} {3 12 14}} xmax 14 xmin 12 ymax 3 ymin 1} 4 {area 18 parts {{1 16 20} {2 16 16} {2 20 20} {3 16 16} {3 20 20} {4 16 16} {4 20 20} {5 16 16} {5 20 20} {6 16 20}} xmax 20 xmin 16 ymax 6 ymin 1} 5 {area 45 parts {{1 24 30} {2 23 31} {3 22 32} {4 22 24} {4 30 32} {5 22 23} {5 31 32} {6 23 24} {6 30 31} {7 24 25} {7 29 30}} xmax 32 xmin 22 ymax 7 ymin 1} 6 {area 15 parts {{4 9 9} {5 9 9} {6 3 9} {7 2 3} {8 1 2} {9 1 2}} xmax 9 xmin 1 ymax 9 ymin 4} 7 {area 18 parts {{5 27 27} {6 27 27} {7 27 27} {8 27 27} {9 22 32} {10 26 28}} xmax 32 xmin 22 ymax 10 ymin 5} 8 {area 8 parts {{8 5 10} {9 5 5} {10 5 5}} xmax 10 xmin 5 ymax 10 ymin 8} 9 {area 20 parts {{8 12 19} {9 12 19} {10 12 13} {10 18 19}} xmax 19 xmin 12 ymax 10 ymin 8}`|

