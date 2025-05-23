<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform sdf combiner

## <anchor='top'> Table Of Contents

  - [transform sdf](transform_sdf.md) ↗


### Operators

 - [aktive op sdf and](#op_sdf_and)
 - [aktive op sdf or](#op_sdf_or)
 - [aktive op sdf sub](#op_sdf_sub)
 - [aktive op sdf xor](#op_sdf_xor)
 - [aktive op sdf xor-core](#op_sdf_xor_core)

## Operators

---
### [↑](#top) <a name='op_sdf_and'></a> aktive op sdf and

Syntax: __aktive op sdf and__ srcs... [[→ definition](/file?ci=trunk&ln=143&name=etc/generator/virtual/sdf.tcl)]

Returns the intersection (`*`, `max`) of all input SDFs.

|Input|Description|
|:---|:---|
|args...|Source images|

#### <a name='op_sdf_and__examples'></a> Examples

<a name='op_sdf_and__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf and @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00582.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00583.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00584.gif' alt='aktive op sdf and @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00585.gif' alt='aktive op sdf and @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00586.gif' alt='aktive op sdf and @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


#### <a name='op_sdf_and__references'></a> References

  - <https://iquilezles.org/articles/distfunctions2d>

---
### [↑](#top) <a name='op_sdf_or'></a> aktive op sdf or

Syntax: __aktive op sdf or__ srcs... [[→ definition](/file?ci=trunk&ln=123&name=etc/generator/virtual/sdf.tcl)]

Returns the union (`+`, `min`) of all input SDFs.

|Input|Description|
|:---|:---|
|args...|Source images|

#### <a name='op_sdf_or__examples'></a> Examples

<a name='op_sdf_or__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf or @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00592.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00593.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00594.gif' alt='aktive op sdf or @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00595.gif' alt='aktive op sdf or @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00596.gif' alt='aktive op sdf or @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


#### <a name='op_sdf_or__references'></a> References

  - <https://iquilezles.org/articles/distfunctions2d>

---
### [↑](#top) <a name='op_sdf_sub'></a> aktive op sdf sub

Syntax: __aktive op sdf sub__ a b [[→ definition](/file?ci=trunk&ln=163&name=etc/generator/virtual/sdf.tcl)]

Returns the difference `A - B` of the two input SDFs. This is defined as `A * (not B)`.

|Input|Description|
|:---|:---|
|a|SDF A|
|b|SDF B|

#### <a name='op_sdf_sub__examples'></a> Examples

<a name='op_sdf_sub__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf sub @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00612.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00613.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00614.gif' alt='aktive op sdf sub @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00615.gif' alt='aktive op sdf sub @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00616.gif' alt='aktive op sdf sub @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


#### <a name='op_sdf_sub__references'></a> References

  - <https://iquilezles.org/articles/distfunctions2d>

---
### [↑](#top) <a name='op_sdf_xor'></a> aktive op sdf xor

Syntax: __aktive op sdf xor__ srcs... [[→ definition](/file?ci=trunk&ln=186&name=etc/generator/virtual/sdf.tcl)]

Returns the symmetric difference of all input SDFs.

A single input is passed through unchanged.

|Input|Description|
|:---|:---|
|args...|Source images|

#### <a name='op_sdf_xor__examples'></a> Examples

<a name='op_sdf_xor__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf xor @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00617.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00618.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00619.gif' alt='aktive op sdf xor @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00620.gif' alt='aktive op sdf xor @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00621.gif' alt='aktive op sdf xor @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


#### <a name='op_sdf_xor__references'></a> References

  - <https://iquilezles.org/articles/distfunctions2d>

---
### [↑](#top) <a name='op_sdf_xor_core'></a> aktive op sdf xor-core

Syntax: __aktive op sdf xor-core__ a b [[→ definition](/file?ci=trunk&ln=210&name=etc/generator/virtual/sdf.tcl)]

Returns the symmetric difference of the two input SDFs. This is defined as `(A + B) - (A * B)`.

|Input|Description|
|:---|:---|
|a|SDF A|
|b|SDF B|

#### <a name='op_sdf_xor_core__examples'></a> Examples

<a name='op_sdf_xor_core__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf xor-core @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00622.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00623.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00624.gif' alt='aktive op sdf xor-core @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00625.gif' alt='aktive op sdf xor-core @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00626.gif' alt='aktive op sdf xor-core @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


#### <a name='op_sdf_xor_core__references'></a> References

  - <https://iquilezles.org/articles/distfunctions2d>

