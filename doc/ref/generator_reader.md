<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- generator reader

## <anchor='top'> Table Of Contents

  - [generator](generator.md) ↗


### Operators

 - [aktive read from aktive](#read_from_aktive)
 - [aktive read from netpbm](#read_from_netpbm)

## Operators

---
### [↑](#top) <a name='read_from_aktive'></a> aktive read from aktive

Syntax: __aktive read from aktive__  (param value)... [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/generator/reader/aktive.tcl)]

Construct image from file content in the native AKTIVE format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|path|object||Path to file holding the AKTIVE image data to read|

#### <a name='read_from_aktive__examples'></a> Examples

<table>
<tr><th>aktive read from aktive path tests/assets/results/format-colorbox.aktive
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00724.gif' alt='aktive read from aktive path tests/assets/results/format-colorbox.aktive' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 3)</td></tr></table></td></tr>
</table>

<table>
<tr><th>aktive read from aktive path tests/assets/results/format-graybox.aktive
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00725.gif' alt='aktive read from aktive path tests/assets/results/format-graybox.aktive' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='read_from_netpbm'></a> aktive read from netpbm

Syntax: __aktive read from netpbm__  (param value)... [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/generator/reader/netpbm.tcl)]

Construct image from file content in one of the NetPBM formats.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|path|object||Path to file holding the NetPBM image data to read|

#### <a name='read_from_netpbm__examples'></a> Examples

<table>
<tr><th>aktive read from netpbm path tests/assets/sines.ppm
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00726.gif' alt='aktive read from netpbm path tests/assets/sines.ppm' style='border:4px solid gold'>
    <br>geometry(0 0 256 256 3)</td></tr>
</table>

<table>
<tr><th>aktive read from netpbm path tests/assets/crop.pgm
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00727.gif' alt='aktive read from netpbm path tests/assets/crop.pgm' style='border:4px solid gold'>
    <br>geometry(0 0 300 200 1)</td></tr>
</table>


