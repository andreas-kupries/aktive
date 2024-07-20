<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- accessor

## Table Of Contents

  - [Roots](bysection.md) ↗


## Subsections


 - [accessor geometry](accessor_geometry.md) ↘
 - [accessor metadata](accessor_metadata.md) ↘
 - [accessor values](accessor_values.md) ↘

### Operators

 - [aktive format as d2](#format_as_d2)
 - [aktive format as markdown](#format_as_markdown)
 - [aktive format as tclscript](#format_as_tclscript)
 - [aktive op connected-components](#op_connected_components)
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
### <a name='op_connected_components'></a> aktive op connected-components

Syntax: __aktive op connected-components__ src

Returns a Tcl dictionary describing all the connected components found in the (binary) input.

The components are identified by integer numbers.

The data of each component is a dictionary providing the elements of the component's bounding box, its area (in pixels), and an unordered list of the row ranges the component consists of.


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

Returns list of the image's inputs.

For an image without inputs the result is the empty list.


---
### <a name='query_params'></a> aktive query params

Syntax: __aktive query params__ src

Returns dictionary of the image's parameters.

For an image without parameters the result is the empty dictionary.


## Examples

### aktive query params @1

|||
|---|---|
|@1|aktive query params @1|
|<img src='example-00161.png' alt='aktive query params @1' style='border:4px solid gold'>|`width 32 height 32`

### aktive query params @1

|||
|---|---|
|@1|aktive query params @1|
|<img src='example-00163.png' alt='aktive query params @1' style='border:4px solid gold'>|`width 32 height 32 depth 1 first 0.0 last 1.0`

---
### <a name='query_setup'></a> aktive query setup

Syntax: __aktive query setup__ src

Returns dictionary of the image's setup.

This includes type, geometry, and parameters, if any. No inputs though, even if the image has any.


## Examples

### aktive query setup @1

|||
|---|---|
|@1|aktive query setup @1|
|<img src='example-00173.png' alt='aktive query setup @1' style='border:4px solid gold'>|`type image::zone domain {x 0 y 0 width 32 height 32 depth 1} config {width 32 height 32}`

### aktive query setup @1

|||
|---|---|
|@1|aktive query setup @1|
|<img src='example-00175.png' alt='aktive query setup @1' style='border:4px solid gold'>|`type image::gradient domain {x 0 y 0 width 32 height 32 depth 1} config {width 32 height 32 depth 1 first 0.0 last 1.0}`

---
### <a name='query_type'></a> aktive query type

Syntax: __aktive query type__ src

Returns the image's type.


## Examples

### aktive query type @1

|||
|---|---|
|@1|aktive query type @1|
|<img src='example-00181.png' alt='aktive query type @1' style='border:4px solid gold'>|`image::zone`

### aktive query type @1

|||
|---|---|
|@1|aktive query type @1|
|<img src='example-00183.png' alt='aktive query type @1' style='border:4px solid gold'>|`image::gradient`

