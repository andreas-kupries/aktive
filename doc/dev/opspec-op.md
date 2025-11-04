<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||
|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|[Developer Index ↗](index.md)|

# <a name='top'></a> Operator Specifications DSL

|Syntax				|Notes							|
|:---				|:---							|
|`operator NAME SPEC`		|Create a single named operator				|
|`operator NAMELIST SPEC`	|Create multiple named operators			|
|`operator VARLIST OPLIST SPEC`	|As before, with additional configuration information	|

The command names and specifies one or more (related) image processing
operators, using a suite of subordinate commands within its `spec`.

|Argument	|Notes							|
|:---		|:---							|
|`NAME`		|Name of operator, suitable as Tcl command name		|
|`NAMELIST`	|List of operator names sharing the `spec`		|
|`VARLIST`	|List of variable names to template the `spec` with	|
|`OPLIST`	|List of operator names and variable values (1)		|
|`SPEC`		|Specification, a Tcl script   	     			|

  1. The `oplist` starts with an operator name followed by values for
     all the variables in the `varlist`, followed by more sections of
     the same structure.

The `spec` has access to all specified variables (if any) as both
variables and template blocks.

## <a name='cmds'></a> Specification commands

[Up ↑](#top)

The commands used within specifications fall into 4 categories.
These are

  - [Generally usable](#general)
  - [Usable in and declaring a C-level operator](#clang)
  - [Usable in and declaring a Tcl-level operator](#tcllang)
  - [Usable in and declaring an external operator](#external)

Note that the commands for a specific kind of operator cannot be mixed
with the commands for a different kind of operator. The first use of a
command requiring a specific kind locks the operator to that kind.

### <a name='general'></a> General

[Up ↑](#cmds)

The generally usable commands are mainly focused on support, inputs,
parameters, documentation, and examples.

|Command			|Description	|
|:---				|:---		|
|[def](opspec.md#def)		|Define a named local text block	|
|[import](opspec.md#import)	|Import definitions into the operator	|
|[import?](opspec.md#import)	|See above, ignore a missing file	|
|[op](#cmd-op)			|Access to parts of the operator name	|

|Command			|Description	|
|:---				|:---		|
|[\<type\>](#cmd-param)		|Declaration of a required parameter	|
|[\<type\>?](#cmd-param)	|Declaration of an optional parameter	|
|[\<type\>...](#cmd-param)	|Declaration of a variadic parameter	|
|||
|[input](#cmd-input)		|Declaration of image input    		|
|[input...](#cmd-input)		|Declaration of variadic image input	|

|Command			|Description	|
|:---				|:---		|
|[example](#cmd-example)	|Define an operator example		|
|[note](#cmd-note)		|Operator description / documentation	|
|[ref](#cmd-ref)		|Reference to relevant external page	|
|[section](#cmd-section)	|Documentation section for operator	|
|[strict](#cmd-strict)		|Strictness information	   		|

### <a name='clang'></a> C-level Operators

[Up ↑](#cmds)

The C-level operator commands further divide into

  - [Highlevel](#highlevel)
  - [Image result](#image)
  - [Non-image result](#nonimage)
  - [No result](#none)

#### <a name='highlevel'></a> Highlevel

[Up ↑](#clang)

|Command			|Description			|
|:---				|:---				|
|[cached](#cmd-cached)		|Declare a caching operator	|

The highlevel commands on the one hand extremely simplify the creation
of the operators of their kind, yet on the other hand are very
specialized and completely unusable outside of their domain.

Currently we have only a single such command, for the construction of
operators using a row- or column cache.

#### <a name='image'></a> Image result

[Up ↑](#clang)

|Command			|Description				|
|:---				|:---					|
|[blit](#cmd-blit)		|Blitter definition			|
|[pixels](#cmd-pixels)		|Operator implementation, runtime	|
|[simplify](#cmd-simplify)	|Declare simplification rule		|
|[state](#cmd-state)		|Operator implementation, definition	|

#### <a name='nonimage'></a> Non-image result

[Up ↑](#clang)

|Command			|Description		|
|:---				|:---			|
|[blit](#cmd-blit)		|Blitter definition	|
|[return](#cmd-return)		|Operator implementation|

#### <a name='none'></a> No result

[Up ↑](#clang)

|Command			|Description		|
|:---				|:---			|
|[blit](#cmd-blit)		|Blitter definition	|
|[void](#cmd-void)		|Operator implementation|

### <a name='tcllang'></a> Tcl-level Operators

[Up ↑](#cmds)

|Command			|Description		|
|:---				|:---			|
|[body](#cmd-body)		|Implementation script	|
|[pass](#cmd-pass)		|Parameter marker	|

### <a name='external'></a> External operator

[Up ↑](#cmds)

|Command			|Description	|
|:---				|:---		|
|[external!](#cmd-ext)		|Marker		|

External operators are not something outside of AKTIVE.

Here it refers to commands which are implemented outside of the
operator framework, i.e. as regular Tcl commands, be it in C or Tcl.

The specification only serves to pull them into the command hierarchy
set up by the generator, and as a means of providing both
documentation and examples.

## Command details

[Up ↑](#cmds)

### <a name='cmd-param'></a> Parameters

[Up ↑](#general)

|Syntax					|Notes		|
|:---					|---		|
|`<type> NAME [WORD...]`		|Required	|
|`<type>? DEFAULT NAME [WORD...]`	|Optional	|
|`<type...> NAME [WORD...]`		|Variadic	|

Each type defined via [type](opspec.md#cmd-type) provides these
commands to declare parameters of this type for operators.

Required parameters have to be set when constructing an instance of
the operator.  Optional parameter can be left unset, and take on their
default value.

The `default` can actually be any valid Tcl command. Any such command
has access to the values of all required parameters.

__BEWARE:__ When a variadic parameter is declared no further
parameters of any kind can be declared, nor image inputs.

It is not possible to declare a parameter if a variadic image input
was declared before. In other words, it is not possible to use any
kind of parameter together with variadic inputs.

When instantiating an operator with a variadic parameter this
parameter has to be specified last, as it takes all the arguments
after it for its value.

### <a name='cmd-input'></a> Image inputs

[Up ↑](#image)

|Syntax				|
|:---				|
|`input [NAME] [WORD...]`	|
|`input...`			|

The commands declare the presence of one or more image inputs for the
operator. The first form declares only a single image input, with
optional name and description. Multiple uses of this form accumulate.

The second form declares the presence of an arbitrary number of input
images, i.e. zero or more.

__BEWARE:__ After using the second form it is not possible declare
more image inputs, nor parameters. Conversely, declaration of any
parameter prevents the use of this form.

This is due the ordering of arguments expected by the generated
operator construction commands (inputs before parameters).

Regular image inputs without a user-specified name default to either
the name `src` (in case of a single input), or `srcN` with N an
integer counting up from `0` (in case of several inputs). When the
name `src` is assigned, a missing description is filled too, using a
default of `Source image`.

Variadic image inputs are given the name `args`, and a generic
description of `Source images`.

### <a name='cmd-example'></a> Examples

[Up ↑](#general)

|Syntax			|
|:---			|
|`example [SPEC]`	|

The command parses the spec and arranges for the execution of the
example and the capture of its results, for use in the generated
documentation.

Ignoring leading and trailing white space each line of the spec
defines a command to run as part of the example. A command may refer
to the results of a preceding command, using placeholders of the form
`@N`, with `N` counting from `1`. These results are used as they are,
their modifiers do not count for the command chain.

If the command in the __last line__, and only that line has no command
specified, just arguments (i.e. the word `aktive` is present), then
the operator under definition is used as the command.

Each line may contain display modifiers after the command, separated
from the command by a vertical bar, i.e. `|`. Modifiers come in the
form of options and formatting commands, the latter separated by
semicolons, i.e. `;`.

The accepted options are

|Option		|Meaning							|
|:---		|:---								|
|`-text`	|Command result is text						|
|`-matrix`	|Show result (image) as matrix (default 4 digits of precision)	|
|`-int`		|Modifier to `-matrix`, show as integers			|
|`-full`	|Modifier to `-matrix`, show with full double precision		|
|`-label TEXT`	|Override the default description of the command with `text`	|

If neither `-text` nor `-matrix` are specified then the result is
shown as image.

The set of currently supported commands, both to generate data and to
format result for display are available in
[support/esupport.tcl](/file?ci=trunk&name=support/esupport.tcl).

Some examples:

  - [affine](/file?ci=trunk&name=etc/transformer/structure/transform.tcl&ln=43-48)
  - [geometry](/file?ci=trunk&name=etc/accessor/attributes.tcl&ln=94-101)
  - [indexed](/file?ci=trunk&name=etc/generator/virtual/indexed.tcl&ln=9-10)
  - [labeled regions](/file?ci=trunk&name=etc/accessor/cc.tcl&ln=12-47)
  - [sdf](/file?ci=trunk&name=etc/generator/virtual/sdf.tcl&ln=105-108)
  - [wobble](/file?ci=trunk&name=etc/transformer/filter/effects.tcl&ln=81-84)

### <a name='cmd-note'></a> Documentation

[Up ↑](#general)

|Syntax			|
|:---			|
|`note [WORD...]`	|

The command records a piece of documentation for the operator.
The words are treated as the words of one or more sentences.

Multiple uses of the command accumulate.

The recorded text is placed into markdown files as is.  Use of
markdown syntax is allowed.

The custom `<!xref: ...>` instruction can be used to insert
cross-references into the text.

Currently two kinds of reference targets are supported.

  1. Full operators names of the forms

     - `aktive ...`,
     - `./aktive ...`, and
     - `../aktive ...`

     with the elements separated by space.

     As example, the operator `foo::bar` is referenced by

     - `<!xref: aktive foo bar>`,
     - `<!xref: ./aktive foo bar>`, or
     - `<!xref: ../aktive foo bar>`

     These references link to the operator documentation from
     different locations in the package documentation.  The
     specification is linked from the documentation.

     As example see [aktive query geometry](../ref/accessor_geometry.md#query_geometry).

     - Use `aktive ...` from within operator documentation.
     - Use `./aktive ...` from toplevel documentation.
     - Use `../aktive ...` from second level documentation (like here).

     All forms set a proper relative link.

  2. Source references of the form `src ...` where `...` is the label
     given to a source code location via the `!xref-mark` designator.
     See for example the [affine location marker](/file?ci=trunk&name=etc/transformer/structure/transform.tcl&ln=42).

     As example, the source code location labeled as `fox lair` is
     referenced by `<!xref: src fox lair>`.

References to unknown locations and operators are not touched.
As an example of that see the above examples.

### <a name='cmd-ref'></a> References

[Up ↑](#general)

|Syntax		|
|:---		|
|`ref LINK`	|

The command records a link to some external web site relevant to the
operator.

### <a name='cmd-op'></a> Operator name access

[Up ↑](#general)

|Syntax			|
|:---			|
|`op -> VARNAME...`	|

The command splits the operator name into pieces (at the `::`
separators) and assigns them to the named variables / text blocks
([def](opspec.md#cmd-def) is used internally).

This makes the information available for templating of the operator.

### <a name='cmd-section'></a> Documentation section

[Up ↑](#general)

|Syntax			|
|:---			|
|`section WORD...`	|

The command declares the documentation section the operator belongs to.

The sequence of words describes the section hierarchy from the roots
down.

Each use of the command replaces the data from all preceding uses in
the same operator.

### <a name='cmd-strict'></a> Strictness

[Up ↑](#general)

|Syntax				|
|:---				|
|`strict IDS [WORD...]`	|

The command declares in what inputs the operator is strict in.

If the operator is not strict this command can be left out.

The words after the list of argument ids are additional text added to
the documentation, after the note about the strictness.

|Argument	|Notes							|
|:---		|:---							|
|`IDS`		|List of the strict arguments, or special values	|

Examples for `IDS`:

|IDS		|Meaning						|
|:---		|:---							|
|`all`		|Strict in all arguments				|
|`its`		|Strict in the single first argument			|
|`single`	|Ditto	       	      	    				|
|`both`		|Strict in both of two arguments			|
|`1st`		|Strict in the first argument				|
|`2nd 3rd`	|Strict in second and third arguments			|
|`1st 4th`	|Strict in first and fourth 				|

### <a name='cmd-cached'></a> Caching operators

[Up ↑](#highlevel)

|Syntax					|
|:---					|
|`cached KIND LABEL FUNC [OPTION...]`	|

Arguments:

|Name	|Description							|
|:---	|---								|
|`KIND`	|What to cache, either `row` or `column`			|
|`LABEL`|Identifying label inserted into code, comments, and tracing	|
|`FUNC`	|Name of C function to call to fill the cache (1)		|

  1. The function has to have the signature of
     [aktive_iveccache_fill](/file?ci=trunk&name=runtime/iveccache.h&ln=74)
     or be cast-able to it.

     The `context` argument is assumed to be a
     [aktive_ivcache_context*](/file?ci=trunk&name=runtime/iveccache.h&ln=77-86),
     instead of the `void*` in the base signature.

     The argument type may be changed should no operators appear which
     do not fit into the currently emitted code.

Options:

|Name		|Description								|
|:---		|---									|
|`--`		|Stop option processing							|
|`-cdata CD`	|C expression delivering address of client data to use with `FUNC` (1)	|
|`-rsize RS`	|C expression delivering the operator's result size (2)			|
|`-fields F`	|C code fragment declaring additional runtime state fields		|
|`-setup S`	|C code fragment initializing the additional fields			|
|`-cleanup C`	|C code fragment scrubbing the additional fields			|

  1. The expression defines the value for the `.client` field of the
     internal `aktive_ivcache_context*` structure.

     For example, for row/column histograms this is a pointer to the
     `aktive_histogram` structure used by the `aktive_histogram_fill`
     function to collect interim results.

  1. This is for the result size along the uncached axis. As an
     example, for row histograms it is `param->bins` which becomes the
     width of the result.

Examples

 - [cumulation](/file?ci=trunk&name=etc/transformer/statistics/cumulation.tcl&ln=36)
 - [histogram](/file?ci=trunk&name=etc/transformer/statistics/histogram.tcl&ln=234-244)

### <a name='cmd-blit'></a> Blitting

[Up ↑](#image)

|Syntax				|
|:---				|
|`blit NAME BLIT FUNC...`	|

Arguments:

|Name		|Description							|
|:---		|---								|
|`NAME`		|Name of the [def](opspec.md#cmd-def)inition for the loop nest	|
|`BLIT`		|Specification of the loop nest itself 				|
|`FUNC...`	|Action to perform at each location the nest iterates over	|

The command specifies the loop nest for a blitter in shorthand, with an action
to perform, generates the C code implementing that loop nest and action, and
saves the result to the named definition. The last provides operators with
access to the blit code, via standard templating.

#### Actions

Thirteen actions are currently supported:

|Syntax				|Action at each location iterated over			|
|---				|---							|
|     	    			|Set destination to ...					|
|`copy`	    			| ... the value of the source				|
|`zero`				| ... zero, i.e. `(double) 0`				|
|`const v`			| ... the constant `v`	   				|
|`point C-expression`		| ... the result of evaluating the expression (1)	|
|`point/2d C-expression`	| ... the result of evaluating the expression (2)	|
|`pos C-expression`		| ... the result of evaluating the expression (3)	|
|`apply1 op arg...`		| ... the result of `op (source, arg, ...)`   		|
|`apply1z op arg ...`		| ... the result of `op (source, arg, ..., z)` (4)	|
|`apply2 op`			| ... the result of `op (source0, source1)`    		|
|`complex-apply-reduce cop`	| ... the double result of `cop (source)`		|
|`complex-apply-unary cop`	| ... the complex result of `cop (source)`		|
|`complex-apply-binary cop`	| ... the complex result of `cop (source0, source1)`	|
|`raw label C-code`		|Execute the `C-code` fragment (5)			|

  1. The expression has access to the current source cell's coordinates through
     `x`, `y`, and `z`, i.e. the 3D point currently looked at.

  1. The expression has access to the current source cell's coordinates through
     `x`, and `y`, i.e. the 2D point currently looked at.

  1. The expression has access to the linear source cell coordinate through `@`.

  1. `z` is the current source cell's band coordinate.

  1. The raw code has deeper access to the variables of the loop nest. All
     variables pertaining to the destination are prefixed with `dst`. All
     variables pertaining to a single source are prefixed with `src`. In case of
     more than one source the prefixes are `src0`, `src1`, etc.

       - `x`, `y`, `z` are the cell coordinates along the respective axes,
         i.e. for columns, rows, and bands.

       - `pos` is the linear position of the cell, derived from the previous
         using

       - `stride`, `pitch`, i.e. number of bands and number of cells per row
         (`width` times `stride`).

       - `value` is a pointer to the cell value, for either reading from or
         writing to.

#### Scan specification

In shorthand
```
blitter := list (scan...)
scan    := list (range block...)
block   := list (axis min delta direction)
```

A `blitter`, i.e. loop nest, is specified as a list of `scans`, in order from
outermost to innermost loop. Each `scan` specifies a `range`, i.e. how many
values to iterate over, and a number of `blocks` to iterate in parallel at that
level. Each `block` specifies the `axis` it is for (1), the `min`imal value of
the iteration, the `delta` (2) between values, and the `direction` of iteration (3).

  1. One of `x`, `y`, or `z`.

  1. While the `delta` most often will be some regular variable name the system
     also accepts the special form of `1/v`. When used the block is stepped
     fractionally, taking only 1 step per `v` steps of a non-fractional block at
     the same level.  The `v` can be the name of any variable from the calling
     context of the loop nest.

  1. One of `up`, or `down`.

Note that each `block` separately specifies an `axis`. This is required to be
able to specify loop nests which can exchange axes from source to
destination. The only common value to the blocks of a scan is the number of
values to process.

The first `block` in a `scan` always specifies the iteration over the
destination. Each block after it specifies one more source to iterate. It is
possible to have no sources at all.

Note that depending on the `direction` the `min`imal value can be assumed at the
end of the iteration (`down`), instead of the start (`up`).

### <a name='cmd-pixels'></a> Pixel fetching

[Up ↑](#image)

|Syntax						|
|:---						|
|`pixels [OPTION...] FETCH [(KEY VAL)...]`	|

__TODO FILL__ C code fragment context

Arguments:

|Name		|Description					|
|:---		|---						|
|`FETCH`	|C code fragment to serve a pixel request	|

Options:

|Name			|Description							|
|:---			|---								|
|`-fields FIELDS`	|C code fragment declaring the operator's runtime state fields	|
|`-setup SETUP`		|C code fragment initializing the runtime state fields		|
|`-cleanup CLEANUP`	|C code fragment scrubbing the runtime state fields		|

The optional additional `KEY`/`VAL` arguments are used to template all
fragments, i.e. `fetch` and the option values, beyond what is already
done based on the existing global and local text blocks.

#### Fields

The `FIELDS` fragment is inserted into a C structure definition and
has to follow its syntax. It declares fields to hold image state
necessary for and during the execution of image pipelines.

#### Setup

The `SETUP` fragment is called during startup of image pipelines and
has to initialize the pipline state structure from the image
structure.  It can be assured of the presence of the following C
definitions in its context:

|Name		|Content				|
|:---		|:---					|
|`istate`	|Image state fields, if any		|
|`param`	|Image parameters, if any		|
|`srcs`		|Image inputs as region vector, if any	|
|`state`	|Pixel state structure to initialize	|

All definitions are pointers.

#### Cleanup

The `CLEANUP` fragment is called during teardown of image pipelines
and is responsible for releasing any heap-allocated pixel state.  It
can be assured of the presence of the following C definitions in its
context:

|Name		|Content			|
|:---		|:---				|
|`state`	|Pixel state structure to clear	|

All definitions are pointers.

#### Fetch

The `FETCH` fragment implements the calculation of image pixels based
on the requested area. It can be assured of the presence of the
following C definitions in its context:

|Name		|Content				|
|:---		|:---					|
|`block`	|Block to store the fetched pixels into	|
|`dst`		|Rectangle, area of the block to write	|
|`idomain`	|Image domain, a geometry		|
|`istate`	|Image state fields, if any		|
|`param`	|Image parameters, if any		|
|`request`	|Rectangle, area of the image to fetch	|

All definitions are pointers.

### <a name='cmd-simplify'></a> Simplification rules

[Up ↑](#image)

|Syntax			|
|:---			|
|`simplify WORD....`	|

__TODO FILL__ sub language

### <a name='cmd-state'></a> State definitions

[Up ↑](#image)

|Syntax					|
|:---					|
|`state [OPTION...] [(KEY VAL)...]`	|

Options:

|Name			|Description								|
|:---			|---									|
|`-fields FIELDS`	|C code fragment declaring the operator's definition state fields	|
|`-setup SETUP`		|C code fragment initializing the definition state fields		|
|`-cleanup CLEANUP`	|C code fragment scrubbing the definition state fields			|

The optional additional `KEY`/`VAL` arguments are used to template all
fragments, i.e. all option values, beyond what is already done based
on the existing global and local text blocks.

#### Fields

The `FIELDS` fragment is inserted into a C structure definition and
has to follow its syntax. It declares fields to hold image state
shared across and generally static during the execution of image
pipelines.

Non-static fields require locking when accessed from image pipelines.

#### Setup

The `SETUP` fragment is called during construction of images and has
to initialize the image state structure.  It can be assured of the
presence of the following C definitions in its context:

|Name		|Content				|
|:---		|:---					|
|`domain`	|Image domain, a geometry, to initialize|
|`param`	|Image parameters, if any, to read	|
|`state`	|Image state structure to initialize	|

All definitions are pointers.

#### Cleanup

The `CLEANUP` fragment is called during destruction of images and is
responsible for releasing any heap-allocated image state.  It can be
assured of the presence of the following C definitions in its context:

|Name		|Content			|
|:---		|:---				|
|`state`	|Image state structure to clear	|

All definitions are pointers.

### <a name='cmd-return'></a> Non-image results

[Up ↑](#nonimage)

|Syntax					|
|:---					|
|`return TYPE SCRIPT [(KEY VAL)...]`	|

Implements an operator returning a value of the specified `type`,
which is not an image. Operators of this kind, taking one or more
inputs and returning a non-image result are generally called
`Accessors`.

The type has to have been declared before, via the
[type](opspec.md#cmd-type) command.

The `script` is a C code fragment implementing the operator.  The
fragment has to conform to the rules for a C function body, for usage
as such.

__Attention__: If the last statement in the fragment (i.e. the last
line) does not contain a `return` statement then the system will add a
`return` in front of the content of that line, under the assumption
that this line contains the statement or expression computing the
value to deliver.

In other words, instead of having to write
`return int { return foo(); }`
with its visual duplication of the `return` it is possible to write
`return int { foo(); }`
and the required `return` statement is added automatically.

The fragment has access to the following C variables:

|Name		|Type		|Content							|
|---		|---		|---								|
|`ip`		|Tcl_Interp*	|Interpreter receiving the result				|
|`<name>`	|aktive_image	|Where `name` references an explicitly named input image	|
|`src`		|aktive_image	|Default for unnamed input. Single input image. Optional	|
|`src<N>`	|aktive_image	|Ditto. One of serveral input images, `N` counting up from 0	|
|`param->P`	|		|Declared parameter `P`	       	   	       	    		|

Whether `src` or `src0`, `src1`, ... are accessible depends on the
number of input images and are used only for those which are not
explicitly named. `src` is made available in case of a single input
image. `src0`, etc. are made available if there is more than one input
image.

__BEWARE__: There is currently no support for a dynamic number of
input images, i.e. `input...` Or if there is (I may have forgotten)
then it is untested.

The optional additional `KEY`/`VAL` arguments after the C code
fragment are used to template that fragment, beyond what is already
done based on the existing global and local text blocks.

### <a name='cmd-void'></a> No results

[Up ↑](#none)

|Syntax				|
|:---				|
|`void SCRIPT [(KEY VAL)...]`	|

Implements an operator returning nothing. Operators of this kind,
taking one or more inputs without returning any result are generally
called `Sinks`. Any result they have is delivered through some kind of
side-effect. For example by writing to a channel or file.

The command is effectively a shorthand for `return void SCRIPT ...`.

The one difference in treatment is that the system will not
auto-insert a `return` command here.

### <a name='cmd-body'></a> Tcl implementations

[Up ↑](#tcllang)

|Syntax				|
|:---				|
|`body SCRIPT [(KEY VAL)...]`	|

Implements an operator in Tcl.

The `script` is a Tcl code fragment implementing the operator.  The
fragment has to conform to the rules for a Tcl procedure body, for
usage as such.

The fragment has access to the following Tcl variables:

|Name		|Content							|
|---		|---								|
|`<name>`	|Where `name` references an explicitly named input image	|
|`src`		|Default for unnamed inputs. Single input image. Optional	|
|`src<N>`	|Ditto. One of serveral input images, `N` counting up from 0	|
|`P`		|Declared parameter `P`						|

Whether `src` or `src0`, `src1`, ... are accessible depends on the
number of input images and are used only for those which are not
explicitly named. `src` is made available in case of a single input
image. `src0`, etc. are made available if there is more than one input
image.

__BEWARE__: There is currently no support for a dynamic number of
input images, i.e. `input...` Or if there is (I may have forgotten)
then it is untested.

The optional additional `KEY`/`VAL` arguments after the Tcl code
fragment are used to template that fragment, beyond what is already
done based on the existing global and local text blocks.

### <a name='cmd-pass'></a> Pass markers

[Up ↑](#tcllang)

|Syntax			|
|:---			|
|`pass CMDWORD...`	|

A prefix command which marks all parameters declared during the
execution of the prefixed command as pass-through.

All such parameters are added to the template block `passthrough`.
The block contains a Tcl code fragment alternating parameter names and
variable access for that parameter.

As example, for a pass through parameter `foo` the block will contain
`... foo $foo ...`.

This simplifies the use of parameters declared through a shared code
block without the body of the operator having to be aware of the exact
set of parameters.

See for example

  - [draw pass](/file?ci=trunk&name=etc/generator/virtual/draw.tcl&ln=79)
  - [wobble pass](/file?ci=trunk&name=etc/transformer/filter/effects.tcl&ln=98)
