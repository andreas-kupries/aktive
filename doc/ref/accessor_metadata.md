<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- accessor metadata

## <anchor='top'> Table Of Contents

  - [accessor](accessor.md) ↗


### Operators

 - [aktive meta exists](#meta_exists)
 - [aktive meta for](#meta_for)
 - [aktive meta get](#meta_get)
 - [aktive meta info](#meta_info)
 - [aktive meta keys](#meta_keys)
 - [aktive meta size](#meta_size)
 - [aktive meta values](#meta_values)
 - [aktive query meta](#query_meta)

## Operators

---
### [↑](#top) <a name='meta_exists'></a> aktive meta exists

Syntax: __aktive meta exists__ src args... [[→ definition](../../../../file?ci=trunk&ln=30&name=etc/transformer/meta.tcl)]

Wraps the dict method "exists" for image meta data management.

Returns result of "dict exists" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### [↑](#top) <a name='meta_for'></a> aktive meta for

Syntax: __aktive meta for__ src args... [[→ definition](../../../../file?ci=trunk&ln=30&name=etc/transformer/meta.tcl)]

Wraps the dict method "for" for image meta data management.

Returns result of "dict for" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### [↑](#top) <a name='meta_get'></a> aktive meta get

Syntax: __aktive meta get__ src args... [[→ definition](../../../../file?ci=trunk&ln=30&name=etc/transformer/meta.tcl)]

Wraps the dict method "get" for image meta data management.

Returns result of "dict get" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### [↑](#top) <a name='meta_info'></a> aktive meta info

Syntax: __aktive meta info__ src args... [[→ definition](../../../../file?ci=trunk&ln=30&name=etc/transformer/meta.tcl)]

Wraps the dict method "info" for image meta data management.

Returns result of "dict info" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### [↑](#top) <a name='meta_keys'></a> aktive meta keys

Syntax: __aktive meta keys__ src args... [[→ definition](../../../../file?ci=trunk&ln=30&name=etc/transformer/meta.tcl)]

Wraps the dict method "keys" for image meta data management.

Returns result of "dict keys" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### [↑](#top) <a name='meta_size'></a> aktive meta size

Syntax: __aktive meta size__ src args... [[→ definition](../../../../file?ci=trunk&ln=30&name=etc/transformer/meta.tcl)]

Wraps the dict method "size" for image meta data management.

Returns result of "dict size" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### [↑](#top) <a name='meta_values'></a> aktive meta values

Syntax: __aktive meta values__ src args... [[→ definition](../../../../file?ci=trunk&ln=30&name=etc/transformer/meta.tcl)]

Wraps the dict method "values" for image meta data management.

Returns result of "dict values" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### [↑](#top) <a name='query_meta'></a> aktive query meta

Syntax: __aktive query meta__ src [[→ definition](../../../../file?ci=trunk&ln=243&name=etc/accessor/attributes.tcl)]

Returns a dictionary containing the input's meta data.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='query_meta__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive query meta @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00664.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 256 256 3)</td>
    <td valign='top'>&nbsp;netpbm {maxval 255} path tests/assets/sines.ppm colorspace sRGB</td></tr>
</table>


