# Documentation -- Reference Pages -- accessor

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [Main](index.md) ↗


## Subsections


 - [accessor geometry](accessor_geometry.md) ↘
 - [accessor metadata](accessor_metadata.md) ↘
 - [accessor values](accessor_values.md) ↘

### Operators

 - [aktive format as d2](#format_as_d2)
 - [aktive format as markdown](#format_as_markdown)
 - [aktive format as tclscript](#format_as_tclscript)
 - [aktive op query colorspace](#op_query_colorspace)
 - [aktive query id](#query_id)
 - [aktive query inputs](#query_inputs)
 - [aktive query params](#query_params)
 - [aktive query setup](#query_setup)
 - [aktive query type](#query_type)

## Operators

---
### <a name='format_as_d2'></a> aktive format as d2

Syntax: __aktive format as d2__ src

Converts the internal DAG representation of the image into a D2 graph format and returns the resulting string.

Despite the naming the operator is __not strict__. It does not access the input's pixels at all, only the meta information of the pipeline.


---
### <a name='format_as_markdown'></a> aktive format as markdown

Syntax: __aktive format as markdown__ src

Converts the internal DAG representation of the image into a Markdown table and returns the resulting string.

Despite the naming the operator is __not strict__. It does not access the input's pixels at all, only the meta information of the pipeline.


---
### <a name='format_as_tclscript'></a> aktive format as tclscript

Syntax: __aktive format as tclscript__ src

Converts the internal DAG representation of the image into a Tcl script and returns the resulting string.

Despite the naming the operator is __not strict__. It does not access the input's pixels at all, only the meta information of the pipeline.


---
### <a name='op_query_colorspace'></a> aktive op query colorspace

Syntax: __aktive op query colorspace__ src

Returns the name of color space the image is in.

If no colorspace is set then `sRGB` is assumed for 3-band images, and `grey` for single-band images.

For anything else an error is thrown instead of making assumptions.


---
### <a name='query_id'></a> aktive query id

Syntax: __aktive query id__ src

Returns an implementation-specific image identity.


---
### <a name='query_inputs'></a> aktive query inputs

Syntax: __aktive query inputs__ src

Returns list of the image inputs, if any.


---
### <a name='query_params'></a> aktive query params

Syntax: __aktive query params__ src

Returns dictionary of the image parameters, if any.


---
### <a name='query_setup'></a> aktive query setup

Syntax: __aktive query setup__ src

Returns dictionary of the image setup. IOW type, geometry, and parameters, if any. No inputs though, even if the image has any.


---
### <a name='query_type'></a> aktive query type

Syntax: __aktive query type__ src

Returns image type.


