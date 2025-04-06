<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||
|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|[Developer Index ↗](index.md)|


# <a name='top'></a> Operator Specifications DSL

## Overview

AKTIVE uses a Tcl-based domain-specific language to simplify the
specification of image processing operators.

The implementation of the DSL translates the specifications into the

  - Boilerplate code (C and Tcl) embedding and linking the operator
    into AKTIVE's runtime framework.

  - Operator documentation in Markdown, including examples
    (and underlying example Tcl code).

## Implementation

[Up ↑](#top)

Files:

  - [Main](/file?ci=trunk&name=support/dsl.tcl)
  - [Reader Frontend](/file?ci=trunk&name=support/reader.tcl)
  - [Writer Backend](/file?ci=trunk&name=support/writer.tcl)
  - [Example Support](/file?ci=trunk&name=support/esupport.tcl)
  - [Blitter Generator](/file?ci=trunk&name=support/blit.tcl)
  - [Reductor Generator](/file?ci=trunk&name=support/reduce.tcl)
  - [Struct Parsing](/file?ci=trunk&name=support/structs.tcl)
  - [Xref Parsing](/file?ci=trunk&name=support/xref.tcl)

## <a name='cmds'></a> Main commands

[Up ↑](#top)

|Command			|Description								|
|:---				|:---									|
|[def](#cmd-def)		|Defines a sharable text block. Global or local to an operator		|
|[import](#cmd-import)		|Imports definitions from the specified file, fail for a mising file	|
|[import?](#cmd-import)		|See above, except it ignores a missing file   	      	       		|
|[nyi](#cmd-nyi)		|Disables the command it is a prefix of					|
|[operator](#cmd-operator)	|Defines a (set of) operators  	      	       	     			|
|[type](#cmd-type)		|Defines a type for use with parameters and results			|
|[vector](#cmd-vector)		|Declares which types require vector/slice support			|

### <a name='cmd-def'></a> `def`

[Up ↑](#cmds)

|Syntax					|
|:---					|
|`def NAME TEXT [(KEY VALUE)...]`	|

The command creates a named sharable block of `text`, either at global
level or local to an operator specification. The created block is
usable wherever templating is performed.

The command further creates a Tcl variable of the same `name` in the
calling scope, also containing the `text`.

__Note__ that this command applies templating to the `text` before it
is saved.  In other words, the definition of a block can reference
blocks defined before it.

Furthermore the optional set of `key` and `value` arguments serves as
map of ultra-local placeholders to use in the templating.

### <a name='cmd-import'></a> `import`, `import?`

[Up ↑](#cmds)

|Syntax		|
|:---		|
|`import PATH`	|
|`import? PATH`	|

Both commands read the referenced file and execute the commands in the
context of the import. This can be global or within an operator
specification.

The `import?` variant ignores a missing `PATH`, whereas `import` will
throw an error in that case.

### <a name='cmd-nyi'></a> `nyi`

[Up ↑](#cmds)

|Syntax			|
|:---			|
|`nyi [WORD...]`	|

The command is a prefix command whose use disables the command it is
made a prefix of.

The name stands for __not yet implemented__.

### <a name='cmd-operator'></a> `operator`

[Up ↑](#cmds)

|Syntax				|
|:---				|
|`operator NAME SPEC`		|
|`operator NAMELIST SPEC`	|
|`operator VARLIST OPLIST SPEC`	|

The command names and specifies one or more (related) image processing
operators, using a suite of subordinate commands within its `spec`.

The [full details](opspec-op.md) about operator arguments and
subordinate commands are found in [their own page](opspec-op.md).

### <a name='cmd-type'></a> `type`

[Up ↑](#cmds)

|Syntax				|
|:---				|
|`type ID CRITCL C CONVERTER`	|

The command declares a type the DSL can use for operator parameters and
results.

__Note__ that types have to be declared before their use.

The core types needed by AKTIVE's runtime framework itself are
declared in

  - [etc/runtime.tcl](/file?ci=trunk&name=etc/runtime.tcl)

Arguments:

|Name		|Description									|
|:---		|---										|
|`ID`		|Name the type is identified by when used in `vector` and `operator` commands	|
|`CRITCL`	|The associated Critcl type. `-` defaults to the `ID`				|
|`C`		|The associated C type. `-` defaults to the `CRITCL` name			|
|`CONVERTER`	|C code fragment to convert a C value of the type into a Tcl_Obj		|

Converter notes:

  - The fragment has to return a `Tcl_Obj*` value.

  - The fragment expects to have access to a C variable `value`
    holding a pointer to the C value to convert

### <a name='cmd-vector'></a> `vector`

[Up ↑](#cmds)

|Syntax			|
|:---			|
|`vector [NAME...]`	|

The command declares that we need vector/slice support for the named types.

In other words, it arranges for the generator to emit C code that
provides the types and functions for the management of __dynamic arrays__
for values of this type.
