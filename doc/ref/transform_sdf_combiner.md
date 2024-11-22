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

Syntax: __aktive op sdf and__ srcs... [[→ definition](../../../../file?ci=trunk&ln=123&name=etc/generator/virtual/sdf.tcl)]

Returns the intersection A and B and ... of the input SDFs


---
### <a name='op_sdf_or'></a> aktive op sdf or

Syntax: __aktive op sdf or__ srcs... [[→ definition](../../../../file?ci=trunk&ln=111&name=etc/generator/virtual/sdf.tcl)]

Returns the union A or B or ... of the input SDFs


---
### <a name='op_sdf_sub'></a> aktive op sdf sub

Syntax: __aktive op sdf sub__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=135&name=etc/generator/virtual/sdf.tcl)]

Returns the difference A - B of the two input SDFs


---
### <a name='op_sdf_xor'></a> aktive op sdf xor

Syntax: __aktive op sdf xor__ srcs... [[→ definition](../../../../file?ci=trunk&ln=149&name=etc/generator/virtual/sdf.tcl)]

Returns the symmetric difference of the input SDFs


---
### <a name='op_sdf_xor_core'></a> aktive op sdf xor-core

Syntax: __aktive op sdf xor-core__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=163&name=etc/generator/virtual/sdf.tcl)]

Returns the symmetric difference of the two input SDFs


