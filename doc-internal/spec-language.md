# Language for high-level operator specification

This document describes AKTIVE's internal domain specific language used to describe the implemented
operations. The generator part of the Critcl setup uses this to generate the actual C code,
interleaving the boilerplate and user-specified elements as needed.

This document has to be read by everybody desiring to either extend the package with more
operations, or to modify an existing operation, or both.

## Overview

The main commands are `type`, `vector`, and `operator`.
They declare

  - The types used in the API between C and Tcl
  - Which of these types require dynamic array structures
  - And the operators to implement

All other commands, described below, are used to specify the details of the operators to implement,
and are therefore restricted to the `spec` argument of the `operator` command.

Note that operators can be separated into 5 categories, based on their number of image arguments,
number of (non-image) parameters, and the kind of their result, if any.

## Main command details

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

The command takes a name and a detailed specification of the desired operator and arranges for the
generator to emit the C code implementing this operator on top of the AKTIVE runtime.

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
|                               |                                                       |
|`return ID C_CODE`             |Declare non-image return type with a C code fragment providing the value to return. See `type` declarations |
|`void`                         |Declare operator as void, returning nothing            |
|                               |                                                       |
|`<type>  NAME ...`             |Declare required named parameter with help text        |
|`<type>? NAME VALUE ...`       |As above, optional, with default value                 |
|`<type>... NAME ...`           |As above, variadic, has to be last, see notes below    |
|                               |                                                       |
|`input RC`                     |Declare required input image with ref-counting mode    |
|`input RC ?`                   |As above, optional                                     |
|`input RC ...`                 |As above, variadic, has to be last, see notes below    |

##### Notes on non-image returns

The C code fragment specified with `return` has access to the relevant `aktive_image` through the
`src` variable. It further has access to the relevant `Tcl_Interp*` through the `interp` variable.

If the last statement in the C code fragment (i.e. the last line) does not contain a `return` then
the generator adds a `return` in front of that line, under the assumption that this line contains
the statement or expression computing the value to deliver.

In other words, instead of having to write `return int { return foo(); }`, with its visual
duplication of the `return` it is possible to write `return int { foo(); }` and the needed `return`
is added by the generator.

##### Notes on variadics

Only one parameter and/or input image can be declared variadic.

More than one varidic element is not allowed.

Whichever element, parameter or inpu image is variadic, has to be declared last.

After the declaration of a variadic element no further elements can be declared.

As the generated Tcl glue commands place parameters before input images a variadic parameter implies
that the specified operator cannot take any image arguments.
