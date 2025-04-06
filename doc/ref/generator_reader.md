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

 - [aktive read from aktive file](#read_from_aktive_file)
 - [aktive read from aktive string](#read_from_aktive_string)
 - [aktive read from netpbm file](#read_from_netpbm_file)
 - [aktive read from netpbm string](#read_from_netpbm_string)

## Operators

---
### [↑](#top) <a name='read_from_aktive_file'></a> aktive read from aktive file

Syntax: __aktive read from aktive file__  (param value)... [[→ definition](/file?ci=trunk&ln=146&name=etc/generator/reader/aktive.tcl)]

Construct image from file content in the native AKTIVE format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|path|object||Path to file holding the AKTIVE image data to read|

#### <a name='read_from_aktive_file__examples'></a> Examples

<a name='read_from_aktive_file__examples__e1'></a><table>
<tr><th>aktive read from aktive file path tests/assets/results/format-colorbox.aktive
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00736.gif' alt='aktive read from aktive file path tests/assets/results/format-colorbox.aktive' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 3)</td></tr></table></td></tr>
</table>

<a name='read_from_aktive_file__examples__e2'></a><table>
<tr><th>aktive read from aktive file path tests/assets/results/format-graybox.aktive
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td valign='top'>times 8</td><td valign='top'><img src='example-00737.gif' alt='aktive read from aktive file path tests/assets/results/format-graybox.aktive' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='read_from_aktive_string'></a> aktive read from aktive string

Syntax: __aktive read from aktive string__  (param value)... [[→ definition](/file?ci=trunk&ln=8&name=etc/generator/reader/aktive.tcl)]

Construct image from a Tcl byte array value in the native AKTIVE format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|value|object||Tcl value holding the AKTIVE image data to read|

---
### [↑](#top) <a name='read_from_netpbm_file'></a> aktive read from netpbm file

Syntax: __aktive read from netpbm file__  (param value)... [[→ definition](/file?ci=trunk&ln=110&name=etc/generator/reader/netpbm.tcl)]

Construct image from file content in one of the NetPBM formats.

Currently supported are PPM and PGM formats, in the binary byte and short variants, as well as the text and extended text variants.

The PBM format is not supported.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|path|object||Path to file holding the NetPBM image data to read|

#### <a name='read_from_netpbm_file__examples'></a> Examples

<a name='read_from_netpbm_file__examples__e1'></a><table>
<tr><th>aktive read from netpbm file path tests/assets/sines.ppm
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00738.gif' alt='aktive read from netpbm file path tests/assets/sines.ppm' style='border:4px solid gold'>
    <br>geometry(0 0 256 256 3)</td></tr>
</table>

<a name='read_from_netpbm_file__examples__e2'></a><table>
<tr><th>aktive read from netpbm file path tests/assets/crop.pgm
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00739.gif' alt='aktive read from netpbm file path tests/assets/crop.pgm' style='border:4px solid gold'>
    <br>geometry(0 0 300 200 1)</td></tr>
</table>


---
### [↑](#top) <a name='read_from_netpbm_string'></a> aktive read from netpbm string

Syntax: __aktive read from netpbm string__  (param value)... [[→ definition](/file?ci=trunk&ln=8&name=etc/generator/reader/netpbm.tcl)]

Construct image from Tcl byte array value in one of the supported NetPBM formats.

Currently supported are PPM and PGM formats, in the binary byte and short variants, as well as the text and extended text variants.

The PBM format is not supported.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|value|object||Tcl value holding the NetPBM image data to read|

