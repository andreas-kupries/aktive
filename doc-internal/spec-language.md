# Language for high-level operator specification

This document describes AKTIVE's internal domain specific language used to describe the implemented
operations. The generator part of the Critcl setup uses this to generate the actual C code,
interleaving the boilerplate and user-specified elements as needed.

This document has to be read by everybody desiring to either extend the package with more
operations, or to modify an existing operation, or both.

## Overview

The main commands are `import`, `import?`, `type`, `vector`, `def`, and `operator`.
They declare

  - The types used in the API between C and Tcl
  - Which of these types require dynamic array structures
  - And the operators to implement

All other commands, described below, are used to specify the details of the operators to implement,
and are therefore restricted to the `spec` argument of the `operator` command.

Note that operators can be separated into 5 categories, based on their number of image arguments,
number of (non-image) parameters, and the kind of their result, if any.

## Main command details

### `nyi`

A prefix command to disable an entire block, like `operator`.

The name stands for `Not Implemented Yet`.

Syntax:

  - `nyi (words of the disabled command...)`

### `import`

The command reads the definitions from the referenced file for use in operator parameters and
results. Imported types and vector types are excluded from code generation.

Syntax

  - `import PATH`

### `import?`

The same syntax as for `import` this command is a conditional import. It does nothing when the
requested path does not exist, or is not file.

### `type`

The command declares a type for use by the generator, with references to associated C and Critcl
types, and a piece of C code to upconvert from C into the Tcl layer

Syntax:

  - `type ID CRITCL C CONVERTER`

Arguments:

|Name           |Description                                                            |
|---            |---                                                                    |
|`id`           |DSL name of the type. Used in `vector` and `operator` commands         |
|`critcl`       |Associated Critcl type name. `-` defaults to `id`                      |
|`c`            |Associated C type name. `-` defaults to `critcl`                       |
|`converter`    |C code fragment to convert a C value of the type into a Tcl_Obj        |
|               |The fragment has to return a `Tcl_Obj*` value.                         |
|               |The fragment expects to have access to a variable `value` holding      |
|               |a pointer to the C value to convert                                    |

### `vector`

The command takes a list of DSL type names and arranges for the generator to emit C code that
provides the types and functions for the management of dynamic arrays of values of this type.

Syntax:

  - `vector ID...`

Arguments:

|Name           |Description                                            |
|---            |---                                                    |
|`id`           |DSL name of the type to generate dynamic array code for|

### `operator`

The command takes a name and a detailed specification of the desired operators and arranges for the
generator to emit the C code implementing these operators on top of the AKTIVE runtime.

So-specified operators can take zero or more images, zero or more parameters, and will return either
a single new image, some non-image value, or nothing.

This divides the space of possible operators into 5 regions:

|Region         |Images |Parameters          |Result    |Examples               |
|---            |---    |---                 |---       |---                    |
|Generators     |0      |>= 1                |image     |Read from file         |
|Transformers   |1      |>= 0                |image     |Global thresholding    |
|Compositors    |>= 2   |>= 0                |image     |Montage, interleaving  |
|Sinks          |1      |>= 0                |none      |Write to file          |
|Accessors      |1      |0                   |non-image |Attributes, statistics |

Syntax:

  - `operator ID SPEC`
  - `operator OPS SPEC`
  - `operator VARS OPS SPEC`

Arguments:

|Name           |Description                                                                    |
|---            |---                                                                            |
|`id`           |Name of the operator, suitable as a Tcl command name                           |
|`ops`          |__Without vars__ `ops` is a plain list of operator ids sharing a fixed spec. __With `N` vars__ `ops` is a list of N+1 sections, one per operator id, sharing a templated spec. The first element of a section is always the operator name. It is followed by N values, one per variable. The `spec` script has access to these variables under the given names |
|`vars`         |List of variable names for templating the spec. See `ops` above for details    |
|`spec`         |Tcl script containing specification commands detailing the operator            |

Defaults:

  - Operators start out with no parameters
  - Operators start out with no input images
  - Operators start out as returning an image

#### Specification commands

|Command                        |Description                                            |
|---                            |---                                                    |
|`note ...`                     |Internal notes for maintainers                         |
|||
|`def NAME CODE`		|Declare named code blocks for inclusion into others via `@@NAME@@`|
|`blit name SCANS FUNC`		|Declare named code block to hold the specified blitter	|
|||
|`return ID RETURN_CODE ...`    |Declare non-image return type with a C code fragment providing the value to return. See `type` declarations |
|`void ACTION_CODE ...`         |Declare operator as void, returning nothing. The C code fragment contains the actions to perform|
|||
|`<type>  NAME ...`             |Declare required named parameter with help text        |
|`<type>? NAME VALUE ...`       |As above, optional, with default value                 |
|`<type>... NAME ...`           |As above, variadic, has to be last, see notes below    |
|||
|`input`			|Declare required input image				|
|`input...`                  	|As above, variadic, has to be last, see notes below    |
|||
|`pixels ?-fields RFIELDS? ?-setup RSETUP? ?-cleanup RCLEANUP? FETCH ...`|C code fragments to manage custom region state, and pixel fetch|
|`state ?-fields FIELDS? ?-setup SETUP? ?-cleanup CLEANUP? ...`|C code fragments to manage custom operator state|
|`support CCODE ...`		|Provide C code fragments containing supporting definitions|

##### Variadics

Only one parameter and/or input image can be declared variadic.

More than one variadic element is not allowed.

Whichever element, parameter or inpu image is variadic, has to be declared last.

After the declaration of a variadic element no further elements can be declared.

As the generated Tcl glue commands place parameters before input images a variadic parameter implies
that the specified operator cannot take any image arguments.

##### Code fragments

Which of the commands `state`, and `pixels` are required or forbidden depends on the operator
result.

Operators returning `void` or a non-image must not specify the aforementioned commands. Their
actions are specified as part of the `void` and `return` commands which declare them as such.

Operators returning an image have to specify both `state` and `pixels` commands.

The image `state -setup` is required and has to initialize the image geometry.

It may initialize the image's operator state. If `-fields` were provided the state structure will be
pre-allocated. Without `-fields` the setup code is wholly responsible. The `-cleanup` code is needed
if and only if the state structure has heap-allocated members. Note that the runtime assumes that
the state information is heap allocated, and it will release it on image destruction, if not
NULL. You __cannot__ store non-pointer data directly into the state field. Except when a crash is
desired.

The region state setup, cleanup, and fields provided through the `pixel` command are wholly
optional. When specified the behaviour of the system is the same as for the image state.

All the commands providing C code fragments take an arbitrary, but even number of additional
arguments, as a means of last-minute templating. The generator replaces all occurences of the key
in each KEY/VALUE pair with the corresponding value.

The basic templating is done by means of named code blocks created via `def`. Each such code block
`foo` can be inserted into any other code block defined after it by means of the placeholder
`@@foo@@`.

Note that for an operator specification using variables each variable is also available as a code
block of the same name.

When using both code blocks and last-minute templating the code blocks are inserted first, before
the keys from the last-minute templating.

###### `FIELDS`, `RFIELDS`

The most simple of C code fragments, it is expected to follow the C syntax for the fields of a C
structure, for immediate insertion into a `struct { ...}` declaration.

###### `RETURN_CODE`

This C code fragment is called by an operator to compute its non-image result value from the
parameters and input images, if any. It has to follow the C syntax for a C function body, for
insertion into such.

__Attention__: If the last statement in the fragment (i.e. the last line) does not contain a
`return` statement then the generator adds a `return` in front of the content of that line, under
the assumption that this line contains the statement or expression computing the value to deliver.

In other words, instead of having to write `return int { return foo(); }`, with its visual
duplication of the `return` it is possible to write `return int { foo(); }` and the needed `return`
statement is added by the generator.

The fragment has access to the following variables:

|Name        |Type                      |Content                                        |
|---         |---                       |---                                            |
|ip          |Tcl_Interp*               |Interpreter receiving the result               |
|src         |aktive_image              |Input image. Optional                          |
|src<N>      |aktive_image              |Input images, if multiple, in fixed number     |
|            |                          |`N` counts from 0 up                           |
|srcs        |aktive_image_vector       |Input images, if multiple, variable number     |
|param       |(param-struct)*           |Operator parameter structure. Optional         |

###### `ACTION_CODE`

See previous section about the `RETURN_CODE`.

The only difference is that here no `return` command is auto-inserted.

###### `SETUP`

This C code fragment is called by an operator returning an image to allocate and initialize a custom
state structure from parameters, and input images, if any. It has to follow the C syntax for a C
function body, for insertion into such.

It has to return a pointer to the new state.

The `FIELDS` fragment provides the structure fields. If not specified the result is taken as
`void*`.

__Attention__: If the last statement in the fragment (i.e. the last line) does not contain a
`return` statement then the generator adds a `return` in front of the content of that line, under
the assumption that this line contains the statement or expression computing the state value to
deliver.

The fragment has access to the following variables:

|Name        |Type                      |Content                                        |
|---         |---                       |---                                            |
|param       |(param-struct)*           |Operator parameter structure. May be `0`       |
|srcs        |aktive_image_vector*      |Input images. May be empty                     |
|domain	     |aktive_geometry*		|Operator geometry to initialize    		|
|state       |(image-state-struct)*     |Operator image state to optionally initialize	|
|meta        |Tcl_Obj**                 |Operator meta data to optionally initialize	|

###### `CLEANUP`

This C code fragment is called by an operator returning an image to cleanup any heap-allocated
fields of the custom state structure. It has to follow the C syntax for a C function body, for
insertion into such.

The `FIELDS` fragment provides the structure fields. If not specified the state is taken as
`void*` and the fragment has to cast as needed.

The fragment has access to the following variables:

|Name        |Type                      |Content                |
|---         |---                       |---                    |
|state       |(image-state-struct)*     |Operator image state   |

###### `RSETUP`

See `SETUP`. This is for the construction of operator-specific region (i.e. processing)
state. Whereas `SETUP` is for static image state.

The fragment has access to the following variables:

|Name        |Type                      |Content                                        |
|---         |---                       |---                                            |
|param       |(param-struct)*           |Operator parameter structure. May be `0`       |
|srcs        |aktive_image_vector*      |Input images. May be empty                     |
|imagestate  |(image-state-struct)*     |Operator image state. May be `0`               |
|state       |(region-state-struct)*	|Region state to fill. 	      			|

The `state` is pre-allocated when the type is known, i.e. when `RFIELDS` were provided.

###### `RCLEANUP`

This C code fragment is called by an operator returning an image to cleanup any heap-allocated
fields of the custom region state structure. It has to follow the C syntax for a C function body,
for insertion into such.

The `RFIELDS` fragment provides the structure fields. If not specified the state is taken as `void*`
and the fragment has to cast as needed.

The fragment has access to the following variables:

|Name        |Type                      |Content                |
|---         |---                       |---                    |
|state       |(region-state-struct)*    |Operator region state  |


###### `FETCH`

This C code fragment is called by an operator returning an image to compute the pixels for the
requested area of the image from parameters, input regions, and operator-specific region state, if
any. It has to follow the C syntax for a C function body, for insertion into such.

The fragment has access to the following variables:

|Name        |Type                      |Content                                        |
|---         |---                       |---                                            |
|param       |(param-struct)*           |Operator parameter structure, if any           |
|srcs        |aktive_region_vector*     |Input regions. If any.                         |
|state       |(region-state-struct)*    |Operator region state. If any.                 |
|istate      |(image-state-struct)*     |Operator state. If any.                        |
|request     |aktive_rectangle*         |Area to compute the pixels for                 |
|dst         |aktive_rectangle*         |Destination areay for the pixels in block      |
|block       |aktive_block*             |Pixel storage                                  |

The `request` is the image area to get pixels for. This is possibly passed to inputs.
The `dst` is the storage area the pixels are to be written (blitted) to.

###### `CCODE`

Supporting C code fragments are emitted before the definitions of the containing operator.
They have no access to variables, and just the public types.

##### Blitter

See the [blitter notes](blitter-nodes.md) for the details of scan and function specification.
