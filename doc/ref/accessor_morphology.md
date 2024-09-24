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

Returns a dictionary describing all the connected components of the single-band input.

The input is expected to be binary. If not, all `values > 0` are treated as the foreground searched for components.

The components are identified by integer numbers.

The data of each component is a dictionary providing the elements of the component's bounding box, its area (in pixels), and an unordered list of the row ranges the component consists of.

See "<!xref: aktive op connected-components labeled>" for a transformer command built on top of this.


## Examples

|@1|aktive op connected-components get 	@1                                                        |
|---|---|
|<table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00173.gif' alt='@1' style='border:4px solid gold'></td></tr></table>|<table><tr><td valign='top'>cc.norm</td><td valign='top'><!include: example-00174.txt></td></tr></table>|


