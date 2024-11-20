<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- generator reader

## Table Of Contents

  - [generator](generator.md) ↗


### Operators

 - [aktive read from aktive](#read_from_aktive)
 - [aktive read from netpbm](#read_from_netpbm)

## Operators

---
### <a name='read_from_aktive'></a> aktive read from aktive

Syntax: __aktive read from aktive__  (param value)...

Construct image from file content in the native AKTIVE format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|path|object||Path to file holding the AKTIVE image data to read|

#### <a name='read_from_aktive__examples'></a> Examples

<table><tr><th>aktive read from aktive path tests/assets/results/format-colorbox.aktive</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00465.gif' alt='aktive read from aktive path tests/assets/results/format-colorbox.aktive' style='border:4px solid gold'></td></tr></table></td></tr></table>

<table><tr><th>aktive read from aktive path tests/assets/results/format-graybox.aktive</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00466.gif' alt='aktive read from aktive path tests/assets/results/format-graybox.aktive' style='border:4px solid gold'></td></tr></table></td></tr></table>


---
### <a name='read_from_netpbm'></a> aktive read from netpbm

Syntax: __aktive read from netpbm__  (param value)...

Construct image from file content in one of the NetPBM formats.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|path|object||Path to file holding the NetPBM image data to read|

#### <a name='read_from_netpbm__examples'></a> Examples

<table><tr><th>aktive read from netpbm path tests/assets/sines.ppm</th></tr>
<tr><td valign='top'><img src='example-00467.gif' alt='aktive read from netpbm path tests/assets/sines.ppm' style='border:4px solid gold'></td></tr></table>

<table><tr><th>aktive read from netpbm path tests/assets/crop.pgm</th></tr>
<tr><td valign='top'><img src='example-00468.gif' alt='aktive read from netpbm path tests/assets/crop.pgm' style='border:4px solid gold'></td></tr></table>


