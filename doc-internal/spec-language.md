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

### `nyi`

A prefix command for easy disabling of an entire block, like `operator`.

The name stands for `Not Implemented Yet`.

Syntax:

  - `nyi (words of the disabled command...)`

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
|||
|`return ID RETURN_CODE ...`    |Declare non-image return type with a C code fragment providing the value to return. See `type` declarations |
|`void ACTION_CODE ...`         |Declare operator as void, returning nothing. The C code fragment contains the actions to perform|
|||
|`<type>  NAME ...`             |Declare required named parameter with help text        |
|`<type>? NAME VALUE ...`       |As above, optional, with default value                 |
|`<type>... NAME ...`           |As above, variadic, has to be last, see notes below    |
|||
|`input RC`                     |Declare required input image with ref-counting mode    |
|`input... RC`                  |As above, variadic, has to be last, see notes below    |
|||
|`geometry GEO_CODE ...`		|C code fragment to compute initial location+geometry	|
|`pixels ?-state RFIELDS? ?-cons RCONS? ?-release RRELEASE? FETCH ...`|C code fragments to manage custom region state, and pixel fetch|
|`state ?-state FIELDS? ?-cons CONS? ?-release RELEASE? ...`|C code fragments to manage custom operator state|

##### Variadics

Only one parameter and/or input image can be declared variadic.

More than one varidic element is not allowed.

Whichever element, parameter or inpu image is variadic, has to be declared last.

After the declaration of a variadic element no further elements can be declared.

As the generated Tcl glue commands place parameters before input images a variadic parameter implies
that the specified operator cannot take any image arguments.

##### Code fragments

Which of the commands `geometry`, `state`, and `pixels` are required or forbidden depends on the
operator result.

Operators returning void or a non-image must not specify the aforementioned commands. Their actions
are specified as part of the `void` and `return` commands which declare them as such.

Operators returning an image have to specify the `geometry` and `pixels` commands. The `state`
command is optional, as well as the region state options of the `pixels` command.

All the commands providing C code fragments take an arbitrary, but even number of additional
arguments, as a means of driving code templating. The generator replaces all occurences of the key
in each KEY/VALUE pair with the corresponding value.

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

|Name	     |Type			|Content					|
|---	     |---			|---						|
|ip	     |Tcl_Interp*		|Interpreter receiving the result		|
|src	     |aktive_image		|Input image. Optional 	   			|
|src<N>	     |aktive_image      	|Input images, if multiple, in fixed number	|
|	     |				|`N` counts from 0 up	       	     		|
|srcs	     |aktive_image_vector	|Input images, if multiple, variable number	|
|param	     |(param-struct)*		|Operator parameter structure. Optional		|

###### `ACTION_CODE`

See previous section about the `RETURN_CODE`.

The only difference is that here no `return` command is auto-inserted.

###### `GEO_CODE`

This C code fragment is called by an operator returning an image to compute the geometry and
location of that image purely from parameters, input images, and operator-specific state, if any. It
has to follow the C syntax for a C function body, for insertion into such.

The fragment has access to the following variables:

|Name	     |Type			|Content					|
|---	     |---			|---						|
|param	     |(param-struct)*		|Operator parameter structure. May be `0`	|
|srcs	     |aktive_image_vector	|Input images. May be empty    	      		|
|state	     |(image-state-struct)*	|Operator image state. May be `0`		|
|loc	     |aktive_point*		|Place to write the computed location to	|
|geom	     |aktive_geometry*		|Place to write the computed geometry to	|

###### `CONS`

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

|Name	     |Type			|Content					|
|---	     |---			|---						|
|param	     |(param-struct)*		|Operator parameter structure. May be `0`	|
|srcs	     |aktive_image_vector	|Input images. May be empty    	      		|

###### `RELEASE`

This C code fragment is called by an operator returning an image to release any heap-allocated
fields of the custom state structure. It has to follow the C syntax for a C function body, for
insertion into such.

The `FIELDS` fragment provides the structure fields. If not specified the state is taken as
`void*` and the fragment has to cast as needed.

The fragment has access to the following variables:

|Name	     |Type			|Content		|
|---	     |---			|---			|
|state       |(image-state-struct)*	|Operator image state	|

###### `RCONS`

See `CONS`. This is for the construction of operator-specific region (i.e. processing)
state. Whereas `CONS` is for static image state.

The fragment has access to the same variables as `CONS`, plus an additional variable:

|Name	     |Type			|Content					|
|---	     |---			|---						|
|imagestate  |(image-state-struct)*	|Operator image state. May be `0`		|

###### `RRELEASE`

This C code fragment is called by an operator returning an image to release any heap-allocated
fields of the custom region state structure. It has to follow the C syntax for a C function body,
for insertion into such.

The `RFIELDS` fragment provides the structure fields. If not specified the state is taken as `void*`
and the fragment has to cast as needed.

The fragment has access to the following variables:

|Name	     |Type			|Content		|
|---	     |---			|---			|
|state       |(region-state-struct)*	|Operator region state	|


###### `FETCH`

This C code fragment is called by an operator returning an image to compute the pixels for the
requested area of the image from parameters, input regions, and operator-specific region state, if
any. It has to follow the C syntax for a C function body, for insertion into such.

The fragment has access to the following variables:

|Name	     |Type			|Content						|
|---	     |---			|---							|
|param	     |(param-struct)*		|Operator parameter structure. May be `0`		|
|srcs	     |aktive_region_vector	|Input regions. May be empty   	      			|
|state	     |(region-state-struct)*	|Operator region state. May be `0`			|
|request     |aktive_rectangle*		|Area to compute the pixels for				|
|block	     |aktive_block*		|IO argument with overall area, pixel memory, etc.	|
