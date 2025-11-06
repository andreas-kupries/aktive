<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|Entry|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|


# File formats: AKTIVELE

  - [Operators](../ref/sink_writer.md#format_as_aktive_2chan)

AKTIVE's native file format is a binary format consisting of a descriptive
header followed by an array holding the floating point values of all pixels of
the image.

All multi-byte non-string values are stored in __little endian byte order__,
i.e. least significant byte first.

It uses the magic `AKTIVELE`.

|Offset		|Bytes	|Type		|Id	|Content			|
|---:		|---:	|---:		|---:	|---:				|
|0		|8	|`uchar[8]`	|magic	|fixed: "`AKTIVELE`"		|
|8		|2	|`uchar[2]`	|version|fixed: "`OO`"			|
|10		|4	|`int32le`	|x	|x location			|
|14		|4	|`int32le`	|y	|y location			|
|18		|4	|`uint32le`	|width	|number of columns		|
|22		|4	|`uint32le`	|height |number of rows			|
|26		|4	|`uint32le`	|depth	|number of bands		|
|30		|4	|`uint32le`	|metac	|number of metadata bytes	|
|		|	|		|	|				|
|34		|`metac`|`uchar[metac]` |meta	|meta data (1)			|
|		|	|		|	|				|
|34+`metac`	|8	|`uchar[8]`	|magic2 |fixed: "`AKTIVE_D`"		|
|		|	|		|	|				|
|62+`metac`	|8*`n`	|`float64le[n]`	|pixel	| `n == width*height*depth`	|

  1. The meta data is stored in the format of a Tcl dictionary value.

This format can be decoded with a pure Tcl script, the core has everything needed
to handle the binary data.

See [tools/deaktive.tcl](/file?ci=trunk&name=tools/deaktive.tcl)
for a helper script doing exactly this.

# File formats: AKTIVE

The older file format, still available using the `aktive-be` commands stores all
multi-byte information in __big endian byte order__, and uses the magic `AKTIVE`.

Beyond that there are no differences.

|Offset		|Bytes	|Type		|Id	|Content			|
|---:		|---:	|---:		|---:	|---:				|
|0		|6	|`uchar[6]`	|magic	|fixed: "`AKTIVE`"		|
|6		|2	|`uchar[2]`	|version|fixed: "`OO`"			|
|8		|4	|`int32be`	|x	|x location			|
|12		|4	|`int32be`	|y	|y location			|
|16		|4	|`uint32be`	|width	|number of columns		|
|20		|4	|`uint32be`	|height |number of rows			|
|24		|4	|`uint32be`	|depth	|number of bands		|
|28		|4	|`uint32be`	|metac	|number of metadata bytes	|
|		|	|		|	|				|
|32		|`metac`|`uchar[metac]` |meta	|meta data (1)			|
|		|	|		|	|				|
|32+`metac`	|8	|`uchar[8]`	|magic2 |fixed: "`AKTIVE_D`"		|
|		|	|		|	|				|
|60+`metac`	|8*`n`	|`float64be[n]`	|pixel	| `n == width*height*depth`	|

This format can be decoded with a pure Tcl script, the core has everything needed
to handle the binary data.

See [tools/deaktive.tcl](/file?ci=trunk&name=tools/deaktive.tcl)
for a helper script doing exactly this.

