!include ../parts/topnav-dev-b.inc

# <a name='top'></a> Operator Specifications DSL

|Syntax				|Notes							|
|:---				|:---							|
|`operator NAME SPEC`		|Create single named operator				|
|`operator NAMELIST SPEC`	|Create multiple named operators			|
|`operator VARLIST OPLIST SPEC`	|As before, with additional configuration information	|

This command names and specifies one or more (related) image processing
operators, using a suite of subordinate commands within its `spec`.

|Argument	|Notes							|
|:---		|:---							|
|`NAME`		|Name of operator, suitable as Tcl command name		|
|`NAMELIST`	|List of operator names sharing a fixed spec		|
|`VARLIST`	|List of variable names to template the spec with	|
|`OPLIST`	|List of operator names and variable values (1)		|
|`SPEC`		|Specification, a Tcl script   	     			|

  1. The `oplist` starts with an operator name followed by values for all the
     variables in the `varlist`, followed by more sections of the same
     structure.

When variables are specified the `spec` has access to these and their values
both through variables, and through templating.

## <a name='cmds'></a> Specification commands

[Up ↑](#top)

The commands used within specifications fall into 4 categories. These are

  - [Generally usable](#general)
  - [Usable in and declaring a C-level operator](#clang)
  - [Usable in and declaring a Tcl-level operator](#tcllang)
  - [Usable in and declaring an external operator](#external)

Note that the commands for a specific kind of operator cannot be mixed with the
commands for a different kind of operator. The first use of a command requiring
a specific kind the operator is locked to that kind.

### <a name='general'></a> General

[Up ↑](#cmds)

The generally usable commands are mainly focused on support, parameters, and
documentation.

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

|Command			|Description	|
|:---				|:---		|
|[example](#cmd-example)	|Define a operator example		|
|[note](#cmd-note)		|Operator description / documentation	|
|[section](#cmd-section)	|Documentation section for operator	|
|[strict](#cmd-strict)		|Strictness information	   		|

### <a name='clang'></a> C-level Operators

[Up ↑](#cmds)

The C-level operator further divide into

  - [Highlevel](#highlevel)
  - [Image result](#image)
  - [Non-image result](#nonimage)
  - [No result](#none)

with commands for each form.

#### <a name='highlevel'></a> Highlevel

[Up ↑](#clang)

|Command			|Description			|
|:---				|:---				|
|[cached](#cmd-cached)		|Declare a caching operator	|

The highlevel commands on the one hand extremely simplify the creation of the
operators of their kind, yet on the other hand are very specialized and
completely unusable outside of their domain.

Currently we have only a single such command for the construction of operators
using a row- or column cache.

#### <a name='image'></a> Image result

[Up ↑](#clang)

|Command			|Description				|
|:---				|:---					|
|[blit](#cmd-blit)		|Blitter definition			|
|[input](#cmd-input)		|Image input		    		|
|[input...](#cmd-input)		|Variadic image input			|
|[pixels](#cmd-pixels)		|Operator implementation, runtime	|
|[simplify](#cmd-simplify)	|Declare simplification rule		|
|[state](#cmd-state)		|Operator implementation, definition	|

#### <a name='nonimage'></a> Non-image result

[Up ↑](#clang)

|Command			|Description		|
|:---				|:---			|
|[blit](#cmd-blit)		|Blitter definition	|
|[input](#cmd-input)		|Image input		|
|[input...](#cmd-input)		|Variadic image input	|
|[return](#cmd-return)		|Operator implementation|

#### <a name='none'></a> No result

[Up ↑](#clang)

|Command			|Description		|
|:---				|:---			|
|[blit](#cmd-blit)		|Blitter definition	|
|[input](#cmd-input)		|Image input		|
|[input...](#cmd-input)		|Variadic image input	|
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

External means that they are implemented outside of the operator framework, as
regular Tcl commands, be it in C or as a `proc`.

The specification only serves to pull them into the command hierarchy set up by
the generator, and as a means of providing the documentation and examples.

## Command details

[Up ↑](#cmds)

### <a name='cmd-param'></a> Parameters

[Up ↑](#general)

|Syntax					|Notes		|
|:---					|---		|
|`<type> NAME [WORD...]`		|Required	|
|`<type>? DEFAULT NAME [WORD...]`	|Optional	|
|`<type...> NAME [WORD...]`		|Variadic	|

Each type defined via [type](opspec.md#cmd-type) provides these commands to
declare parameters of the operator, of this type.

Required parameters have to be set when constructing an instance of the operator.
Optional parameter can be left unset, and take on their default value.

The `default` can actually be any valid Tcl command. Any such command has access
to the values of all required parameters.

When a variadic parameter is declared no further parameters of any kind, nor
inputs can be declared.

It is not possible to declare a variadic parameter if a variadic input was
declared before. In other words, it is not possible to use a variadic parameter
together with variadic inputs.

When instantiating an operator with a variadic parameter this parameter has to
be specified last, to take all the arguments after it for its value.

### <a name='cmd-example'></a> Examples

[Up ↑](#general)

|Syntax					|
|:---					|
|`example [-post CMDPREFIX] WORD...`	|

__TODO FILL__

The exact form of this command is still in flux, as well as its semantics.

### <a name='cmd-note'></a> Documentation

[Up ↑](#general)

|Syntax			|
|:---			|
|`note [WORD...]`	|

The command records a piece of documentation for the operator.
The words are treated as the words of one or more sentences.

Multiple uses of the command accumulate.

The recorded text is placed into markdown files as is.
Markdown syntax is allowed to be used in the text.

The custom `<!xref: ...>` instruction can be used to insert cross-references
into the text. Currently only operator names can serve as reference targets.
The names have to have the `aktive` prefix and `::`-based separation replaced by
spaces. In other words, to reference the operator `foo::bar` use

```
<!xref: aktive foo bar>
```

### <a name='cmd-op'></a> Operator name access

[Up ↑](#general)

|Syntax			|
|:---			|
|`op -> VARNAME...`	|

The command splits the operator name into pieces (at the `::` separators)
and assigns them to the named variables / text blocks
([def](opspec.md#cmd-def) is used internally).

This makes the information available for templating of the operator.

### <a name='cmd-section'></a> Documentation section

[Up ↑](#general)

|Syntax			|
|:---			|
|`section WORD...`	|

The command declares the documentation section the operator is to be placed in.

The sequence of words describes the section hierarchy from the roots down.

Each use of the command replaces the data from all preceding uses in the same
operator.

### <a name='cmd-strict'></a> Strictness

[Up ↑](#general)

|Syntax				|
|:---				|
|`strict IDS [WORD...]`	|

The command declares in what inputs the operator is strict in.

If the operator is not strict this command can be left out.

The words after the list of argument ids are additional text added to the
documentation, after the note about the strictness.

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
     [aktive_iveccache_fill](/file?ci=trunk&name=runtime/iveccache.h&ln=73),
     or be cast-able to it.

     The `context` argument is assumed to be of `aktive_ivcache_context*`,
     instead of the `void*` in the base signature. If no operators appear which
     do not fit into the code as emitted by the command then
     `aktive_iveccache_fill`s `context` argument may be changed.

Options:

|Name		|Description								|
|:---		|---									|
|`--`		|Stop option processing							|
|`-cdata CD`	|C expression delivering address of client data to use with `FUNC` (1)	|
|`-rsize RS`	|C expression delivering the operator's result size (2)			|
|`-fields F`	|C code fragment declaring additional runtime state fields		|
|`-setup S`	|C code fragment initializing the additional fields			|
|`-cleanup C`	|C code fragment scrubbing the additional fields			|

  1. The expression defines the value for the `.client` field of the internal
     `aktive_ivcache_context*` structure.

     For example, for row/column histograms this is a pointer to the
     `aktive_histogram` structure used by the `aktive_histogram_fill` function
     to collect interim results.

  1. This is for the result size along the uncached axis. As an example, for row
     histograms it is `param->bins` which becomes the width of the result.

Examples

 - [etc/transformer/statistics/cumulation.tcl](/file?ci=trunk&name=etc/transformer/statistics/cumulation.tcl&ln=34)
 - [etc/transformer/statistics/histogram.tcl](/file?ci=trunk&name=etc/transformer/statistics/histogram.tcl&ln=231)
 - [etc/transformer/statistics/profile.tcl](/file?ci=trunk&name=etc/transformer/statistics/profile.tcl&ln=32)

### <a name='cmd-blit'></a> Blitting

[Up ↑](#image)

|Syntax			|
|:---			|
|`blit NAME SCANS FUNC`	|

__TODO FILL__

### <a name='cmd-input'></a> Image inputs

[Up ↑](#image)

|Syntax			|
|:---			|
|`input [WORD...]`	|
|`input... [WORD...]`	|

The first command declares the presence of another input image for the operator.
Multiple uses of the command accumulate.

The second form declares the presence of an arbitrary number of input images,
i.e. zero or more.

After the second form is used no further inputs, nor parameters of any kind can
be declared.

It is not possible to use the second form if a variadic parameter was declared
before. In other words, it is not possible to use variadic inputs together with
a variadic parameter.

__BEWARE__ Due to the ordering of arguments expected at operator instantiation,
inputs before parameters, an operator with variadic inputs actually cannot have
parameters at all.

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

|Name		|Description							|
|:---		|---								|
|`-fields F`	|C code fragment declaring the operator's runtime state fields	|
|`-setup S`	|C code fragment initializing the runtime state fields		|
|`-cleanup C`	|C code fragment scrubbing the runtime state fields		|

The optional additional `KEY`/`VAL` arguments are used to template all
fragments, i.e. `fetch` and option values, beyond what is already done based on
the existing global and local text blocks.

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

__TODO FILL__ C code fragment contexts

Options:

|Name		|Description								|
|:---		|---									|
|`-fields F`	|C code fragment declaring the operator's definition state fields	|
|`-setup S`	|C code fragment initializing the definition state fields		|
|`-cleanup C`	|C code fragment scrubbing the definition state fields			|

The optional additional `KEY`/`VAL` arguments are used to template all
fragments, i.e. all option values, beyond what is already done based on the
existing global and local text blocks.




### <a name='cmd-return'></a> Non-image results

[Up ↑](#nonimage)

|Syntax					|
|:---					|
|`return TYPE SCRIPT [(KEY VAL)...]`	|

Implements an operator returning a value of the specified `type`, which is not
an image. Operators of this kind, taking one or more inputs and returning a
non-image result are generally called `Accessors`.

The type has to have been declared before, via the [type](opspec.md#cmd-type)
command.

The `script` is a C code fragment implementing the operator.
The fragment has to conform to the rules for a C function body, for usage as such.

__Attention__: If the last statement in the fragment (i.e. the last line) does
not contain a `return` statement then the system will add a `return` in front of
the content of that line, under the assumption that this line contains the
statement or expression computing the value to deliver.

In other words, instead of having to write
`return int { return foo(); }`
with its visual duplication of the `return` it is possible to write
`return int { foo(); }`
and the required `return` statement is added automatically.

The fragment has access to the following C variables:

|Name		|Type		|Content						|
|---		|---		|---							|
|`ip`		|Tcl_Interp*	|Interpreter receiving the result			|
|`src`		|aktive_image	|Single input image. Optional				|
|`src<N>`	|aktive_image	|One of serveral input images, `N` counting up from 0	|
|`param->P`	|		|Declared parameter `P`	       	   	       	    	|

Whether `src` or `src0`, `src1`, ... are accessible depends on the number of
input images. `src` is made available in case of a single input image. `src0`,
etc. are made available if there is more than one input image.

__BEWARE__: There is currently no support for a dynamic number of input images,
i.e. `input...` Or if there is (I may have forgotten) then it is untested.

The optional additional `KEY`/`VAL` arguments after the C code fragment are used
to template that fragment, beyond what is already done based on the existing
global and local text blocks.

### <a name='cmd-void'></a> No results

[Up ↑](#none)

|Syntax				|
|:---				|
|`void SCRIPT [(KEY VAL)...]`	|

Implements an operator returning nothing. Operators of this kind, taking one or
more inputs without returning any result are generally called `Sinks`. Any
result they have is delivered through some kind of side-effect. For example by
writing to a channel or file.

The command is effectively a shorthand for `return void SCRIPT ...`.

The one difference in treatment is that the system will not auto-insert a
`return` command here.

### <a name='cmd-body'></a> Tcl implementations

[Up ↑](#tcllang)

|Syntax				|
|:---				|
|`body SCRIPT [(KEY VAL)...]`	|

Implements an operator in Tcl.

The `script` is a Tcl code fragment implementing the operator.
The fragment has to conform to the rules for a Tcl procedure body, for usage as such.

The fragment has access to the following Tcl variables:

|Name		|Content						|
|---		|---							|
|`src`		|Single input image. Optional				|
|`src<N>`	|One of serveral input images, `N` counting up from 0	|
|`P`		|Declared parameter `P`	       	   	       	    	|

Whether `src` or `src0`, `src1`, ... are accessible depends on the number of
input images. `src` is made available in case of a single input image. `src0`,
etc. are made available if there is more than one input image.

__BEWARE__: There is currently no support for a dynamic number of input images,
i.e. `input...` Or if there is (I may have forgotten) then it is untested.

The optional additional `KEY`/`VAL` arguments after the Tcl code fragment are
used to template that fragment, beyond what is already done based on the
existing global and local text blocks.

### <a name='cmd-pass'></a> Pass markers

[Up ↑](#tcllang)

|Syntax			|
|:---			|
|`pass CMDWORD...`	|

__TODO FILL__
