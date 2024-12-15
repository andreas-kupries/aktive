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

  - <!xref: src affine>
  - <!xref: src geometry>
  - <!xref: src indexed>
  - <!xref: src labeled regions>
  - <!xref: src sdf>
  - <!xref: src wobble>

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

     As example see <!xref: ../aktive query geometry>.

     - Use `aktive ...` from within operator documentation.
     - Use `./aktive ...` from toplevel documentation.
     - Use `../aktive ...` from second level documentation (like here).

     All forms set a proper relative link.

  2. Source references of the form `src ...` where `...` is the label
     given to a source code location via the `!xref-mark` designator.
     See for example the <!xref: src affine location marker>.

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
     <!xref: src aktive_iveccache_fill>
     or be cast-able to it.

     The `context` argument is assumed to be a
     <!xref: src aktive_ivcache_context*>,
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

 - <!xref: src cumulation>
 - <!xref: src histogram>
 - <!xref: src profile>

### <a name='cmd-blit'></a> Blitting

[Up ↑](#image)

|Syntax			|
|:---			|
|`blit NAME SCANS FUNC`	|

__TODO FILL__

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

  - <!xref: src draw pass>
  - <!xref: src wobble pass>
