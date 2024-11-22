<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform sdf combiner

## Table Of Contents

  - [transform sdf](transform_sdf.md) ↗


### Operators

 - [aktive op sdf and](#op_sdf_and)
 - [aktive op sdf or](#op_sdf_or)
 - [aktive op sdf sub](#op_sdf_sub)
 - [aktive op sdf xor](#op_sdf_xor)
 - [aktive op sdf xor-core](#op_sdf_xor_core)

## Operators

---
### <a name='op_sdf_and'></a> aktive op sdf and

Syntax: __aktive op sdf and__ srcs... [[→ definition](../../../../file?ci=trunk&ln=134&name=etc/generator/virtual/sdf.tcl)]

Returns the intersection A and B and ... of the input SDFs


#### <a name='op_sdf_and__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf and @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00429.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00430.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00431.gif' alt='aktive op sdf and @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00432.gif' alt='aktive op sdf and @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00433.gif' alt='aktive op sdf and @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### <a name='op_sdf_or'></a> aktive op sdf or

Syntax: __aktive op sdf or__ srcs... [[→ definition](../../../../file?ci=trunk&ln=116&name=etc/generator/virtual/sdf.tcl)]

Returns the union A or B or ... of the input SDFs


#### <a name='op_sdf_or__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf or @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00438.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00439.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00440.gif' alt='aktive op sdf or @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00441.gif' alt='aktive op sdf or @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00442.gif' alt='aktive op sdf or @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### <a name='op_sdf_sub'></a> aktive op sdf sub

Syntax: __aktive op sdf sub__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=152&name=etc/generator/virtual/sdf.tcl)]

Returns the difference A - B of the two input SDFs


#### <a name='op_sdf_sub__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf sub @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00455.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00456.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00457.gif' alt='aktive op sdf sub @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00458.gif' alt='aktive op sdf sub @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00459.gif' alt='aktive op sdf sub @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### <a name='op_sdf_xor'></a> aktive op sdf xor

Syntax: __aktive op sdf xor__ srcs... [[→ definition](../../../../file?ci=trunk&ln=172&name=etc/generator/virtual/sdf.tcl)]

Returns the symmetric difference of the input SDFs


#### <a name='op_sdf_xor__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf xor @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00460.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00461.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00462.gif' alt='aktive op sdf xor @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00463.gif' alt='aktive op sdf xor @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00464.gif' alt='aktive op sdf xor @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


---
### <a name='op_sdf_xor_core'></a> aktive op sdf xor-core

Syntax: __aktive op sdf xor-core__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=192&name=etc/generator/virtual/sdf.tcl)]

Returns the symmetric difference of the two input SDFs


#### <a name='op_sdf_xor_core__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op sdf xor-core @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00465.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00466.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td valign='top'>sdf-fit</td><td valign='top'><img src='example-00467.gif' alt='aktive op sdf xor-core @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-smooth</td><td valign='top'><img src='example-00468.gif' alt='aktive op sdf xor-core @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td><td valign='top'>sdf-pixelated</td><td valign='top'><img src='example-00469.gif' alt='aktive op sdf xor-core @1 @2' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td></tr></table></td></tr>
</table>


