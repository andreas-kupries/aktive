<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform sdf

## Table Of Contents

  - [transform](transform.md) ↗


## Subsections


 - [transform sdf combiner](transform_sdf_combiner.md) ↘

### Operators

 - [aktive op sdf 2image fit](#op_sdf_2image_fit)
 - [aktive op sdf 2image pixelated](#op_sdf_2image_pixelated)
 - [aktive op sdf 2image smooth](#op_sdf_2image_smooth)
 - [aktive op sdf not](#op_sdf_not)
 - [aktive op sdf outline](#op_sdf_outline)
 - [aktive op sdf ring](#op_sdf_ring)
 - [aktive op sdf round](#op_sdf_round)

## Operators

---
### <a name='op_sdf_2image_fit'></a> aktive op sdf 2image fit

Syntax: __aktive op sdf 2image fit__ src [[→ definition](../../../../file?ci=trunk&ln=241&name=etc/generator/virtual/sdf.tcl)]

Compresses the input SDF into the range 0..1 and returns the resulting grayscale image.


---
### <a name='op_sdf_2image_pixelated'></a> aktive op sdf 2image pixelated

Syntax: __aktive op sdf 2image pixelated__ src [[→ definition](../../../../file?ci=trunk&ln=266&name=etc/generator/virtual/sdf.tcl)]

Converts the SDF into a black/white image with pixelated element borders.


---
### <a name='op_sdf_2image_smooth'></a> aktive op sdf 2image smooth

Syntax: __aktive op sdf 2image smooth__ src [[→ definition](../../../../file?ci=trunk&ln=253&name=etc/generator/virtual/sdf.tcl)]

Converts the SDF into a grey-scale image with anti-aliased element borders.


---
### <a name='op_sdf_not'></a> aktive op sdf not

Syntax: __aktive op sdf not__ src [[→ definition](../../../../file?ci=trunk&ln=99&name=etc/generator/virtual/sdf.tcl)]

Returns the inverted input SDF, where inside and outside changed places.


---
### <a name='op_sdf_outline'></a> aktive op sdf outline

Syntax: __aktive op sdf outline__ src [[→ definition](../../../../file?ci=trunk&ln=199&name=etc/generator/virtual/sdf.tcl)]

Replaces the input SDF with an outlined form, and returns the result.

This is implemented by taking the absolute of the input.


---
### <a name='op_sdf_ring'></a> aktive op sdf ring

Syntax: __aktive op sdf ring__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=180&name=etc/generator/virtual/sdf.tcl)]

Combines outlining and rounding to replace the input SDF with an SDF tracing the border at some thickness and returns the result.

The result is annular, i.e. has a ring/onion-like structure.

Note that a thickness of zero devolves this operation to a plain outline.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|thickness|uint||Desired border thickness.|

---
### <a name='op_sdf_round'></a> aktive op sdf round

Syntax: __aktive op sdf round__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=213&name=etc/generator/virtual/sdf.tcl)]

Replaces the input SDF with a more rounded form per the radius, and returns the result.

This is implemented by shifting the input SDF down by the radius.

For a radius > 0 this expands the SDF, making the encoded element rounder. A radius < 0 conversely shrinks the SDF.

To get a rounded SDF at the original size use a pre-shrunken/expanded SDF as the input to compensate the changes made by this operator.

A radius of zero is ignored.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Expansion/Shrinkage radius for the SDF.|

