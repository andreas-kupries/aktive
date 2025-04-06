# -*- mode: tcl ; fill-column: 90 -*-

package require textutil::adjust
package require struct::matrix

namespace eval dsl::writer {
    namespace export do
    namespace ensemble create
}

set dsl::writer::here [file dirname [file normalize [info script]]]

# # ## ### ##### ######## #############

proc dsl::writer::do {stem doc specification} {
    variable state $specification

    Clear $stem/
    Emit  $stem/

    if {$doc eq {}} return
    EmitDoc $doc/
    return
}

# # ## ### ##### ######## #############

proc dsl::writer::Clear {stem} {
    file delete -- [glob -nocomplain ${stem}*]
    return
}

proc dsl::writer::Emit {stem} {
    Into ${stem}param-types.h         ParamTypes         ;# typedefs
    Into ${stem}param-descriptors.c   ParamDescriptors   ;# variables
    #
    Into ${stem}vector-types.h        VectorTypes        ;# typedefs
    Into ${stem}vector-funcs.h        VectorSignatures   ;# signatures
    Into ${stem}vector-funcs.c        VectorFunctions    ;# implementations
    #
    Into ${stem}type-funcs.h          TypeSignatures     ;# signatures
    Into ${stem}type-funcs.c          TypeFunctions      ;# implementations
    #
    Into ${stem}param-funcs.h         ParamSignatures    ;# signatures
    Into ${stem}param-funcs.c         ParamFunctions     ;# implementations
    #
    Into ${stem}op-funcs.h            COperatorSignatures ;# C operator core signatures
    Into ${stem}op-funcs.c            COperatorFunctions  ;# C operator core implementations
    #
    Into ${stem}glue.tcl              OperatorCprocs     ;# Tcl glue commands for C
    Into ${stem}ops.tcl               OperatorTclProcs   ;# Tcl operator commands
    Into ${stem}overlay.tcl           OperatorOverlays   ;# C constructor wrappers
    Into ${stem}wraplist.txt          OperatorWrapRecord ;# List of wrap elements
    Into ${stem}ensemble.tcl          OperatorEnsemble   ;# Command ensemble
    #
    Into ${stem}operators.txt         Operators          ;# List of operators
    Into ${stem}todo.txt              Todo               ;# List of skipped operators (`nyi`)
    Into ${stem}undocumented.txt      Undocumented       ;# List of undocumented operators
    Into ${stem}noexamples.txt        NoExamples         ;# List of operators without examples
    #
    return
}

proc dsl::writer::EmitDoc {stem} {
    # Collect operators into a document tree based.
    # Various indices:
    #
    #   - by section
    #   - alphanumeric by name
    #   - by implementation
    #
    # Note: As the description of each operator itself is quite small they are aggregated
    # into section files, where they are referenced from by the indices.

    # collect doc structure (sections, languages, alphanum, operators (for xref))
    set docs {}
    set xref {}
    foreach op [Operations] {
	set spec    [Get ops $op]
	set section [dict get $spec section]
	set lang    [dict get $spec lang]
	set strict  [dict get $spec strict]

	foreach {prefix base} {
	    {}  {}
	    ./     ref/
	    ../ ../ref/
	} {
	    # create multiple references, for use in different relative locations.
	    set ref \[[OpName $op]\](${base}[OpSectionKey $section].md#[OpKey $op])
	    lappend xref [list xref ${prefix}[OpName $op] $ref]
	}

	dict set docs section $section op $op [OpDoc $stem $op $spec]
	dict set docs lang    $lang $op $section
	dict set docs alpha         $op $section
	dict set docs roots   [lindex $section 0] .

	# roots have no parent
	if {[llength $section] > 1} {
	    dict set docs section [lrange $section 0 end-1] children $section .
	}

	if {!$strict} continue
	dict set docs strict $op $section
    }

    Into ${stem}xref.tcl string cat [join $xref \n] \n

    # Emit by-section operator collections (= by section index)
    dict for {section spec} [dict get $docs section] {
	Into ${stem}[OpSectionKey $section].md OperatorSection $spec $section
    }

    # Emit base indices: names, sections, languages, strictness
    Into ${stem}byname.md    OperatorsByName  [dict get $docs alpha]
    Into ${stem}bysection.md OperatorSections $docs
    Into ${stem}bylang.md    OperatorsByLang  [dict get $docs lang]
    Into ${stem}strict.md    OperatorsStrict  [dict get $docs strict]

    # Emit permuted indices: names, sections
    Into ${stem}bypname.md     OperatorPermutedNames    $docs
    Into ${stem}bypsection.md  OperatorPermutedSections $docs

    # Emit main page referencing all the indices.
    Into ${stem}index.md  OperatorIndex   $docs

}

# # ## ### ##### ######## #############
## Main emitter commands -- Parameters

proc dsl::writer::ParamTypes {} {
    if {![llength [Operations]]} return

    CHeader {Parameter block types}

    foreach op [Operations] {
	if {![OpHasParams $op]} continue
	+ [ParamTypeForOp $op]
    }

    Done
}

proc dsl::writer::ParamTypeForOp {op} {
    # collect information needed for generation
    set sname [ParamStructTypename $op]

    set names  [lmap argspec [OpParams $op] { dict get $argspec name }]
    set descs  [lmap argspec [OpParams $op] { dict get $argspec desc }]
    set ctypes [lmap argspec [OpParams $op] { ParameterCType $argspec }]

    # determine column widths
    set nl [Maxlength $names]
    set tl [Maxlength $ctypes]
    set dl [Maxlength $descs]

    # emit ....

    + "/* `$op` - - -- --- ----- -------- ------------- */"
    + "typedef struct $sname \{"

    foreach n $names t $ctypes d $descs {
	+ "  [PadR $tl $t] [PadR $nl $n] ; /* [PadR $dl $d] */"
    }

    + "\} $sname;"
    + {}

    Done
}

proc dsl::writer::ParamDescriptors {} {
    if {![llength [Operations]]} return

    CHeader {Parameter block descriptors}

    + {#include <stddef.h> /* offsetof */}
    + {}

    foreach op [Operations] {
	if {![OpHasParams $op]} continue
	+ [ParamDescriptorsForOp $op]
    }

    Done
}

proc dsl::writer::ParamDescriptorsForOp {op} {
    # collect information needed for generation
    set dname   [ParamDescriptorVarname $op]
    set sname   [ParamStructTypename    $op]
    set nparams [llength [OpParams $op]]

    set names [lmap argspec [OpParams $op] { dict get $argspec name }]
    set descs [lmap argspec [OpParams $op] { dict get $argspec desc }]
    set types [lmap argspec [OpParams $op] {
	set typeid [ParameterType $argspec]
	if {[ParameterIsVariadic $argspec]} {
	    set type [TypeVecValueFunc $typeid]
	} else {
	    set type [TypeValueFunc $typeid]
	}
	set type
    }]

    + "/* `$op` - - -- --- ----- -------- ------------- */"
    + "static aktive_image_parameter $dname\[$nparams\] = \{"

    set prefix "  "
    foreach n $names d $descs t $types {
	set o "offsetof ($sname, $n)"

	+ "  ${prefix}\{ \"$n\""
	+ "    , \"$d\""
	+ "    , (aktive_param_value) $t"
	+ "    , $o"
	+ "    \}"
	set prefix ", "
    }
    + "\};"
    + {}

    Done
}

# Declarations of Init/Finish functions for operations with a variadic parameter
proc dsl::writer::ParamSignatures {} {
    if {![llength [Operations]]} return

    set names {}
    set types {}

    foreach op [Operations] {
	if {![OpHasParams     $op]} continue
	if {![OpParamFIHooks  $op]} continue

	lappend names [ParamInitFuncname   $op]
	lappend names [ParamFinishFuncname $op]
	lappend types [ParamStructTypename $op]
	lappend types [ParamStructTypename $op]
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]

    CHeader {Parameter block init/finish declarations}

    foreach n $names t $types {
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	+ "extern void $n ($t* p);"
    }

    + {}
    Done
}

# Implementation of Init/Finish functions for operations with a variadic parameter
proc dsl::writer::ParamFunctions {} {
    if {![llength [Operations]]} return

    set names {}
    set types {}
    set codes {}

    foreach op [Operations] {
	if {![OpHasParams     $op]} continue
	if {![OpParamFIHooks  $op]} continue

	lappend names [ParamInitFuncname   $op]
	lappend names [ParamFinishFuncname $op]
	lappend types [ParamStructTypename $op]
	lappend types [ParamStructTypename $op]

	lassign {{} {}} heap free
	foreach argspec [OpParams $op] {
	    set n [dict get $argspec name]

	    if {[ParameterIsVariadic $argspec]} {
		# Note: Match vector-func-* // Callee

		set t [ParameterCType $argspec]

		lappend heap "${t}_heapify (&p->$n);"
		lappend free "${t}_free (&p->$n);"
		continue
	    }
	    if {[ParameterHooked $argspec init finis]} {
		lappend heap "$init (p->$n);"
		lappend free "$finis (p->$n);"
		continue
	    }
	}
	lappend codes $heap $free
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]

    CHeader {Parameter block init/finish functions}

    foreach n $names t $types code $codes {
	+ "extern void $n ($t* p) \{"
	foreach c $code {
	    + "  $c"
	}
	+ "\}"
	+ {}
    }

    Done
}

# # ## ### ##### ######## #############
## Main emitter commands -- Vectors

proc dsl::writer::VectorTypes {} {
    if {![llength [Vectors]]} return

    CHeader {Structures for types used in variadics}

    + "#include <base.h>"

    foreach type [Vectors] {
	set ct [TypeCritcl $type]
	set t  [TypeCType  $type]
	set tx [TypeVector $type]

	set n [Maxlength [list int *$ct Tcl_Obj**]]

	Comment "--- --- --- --- --- --- --- --- ---"
	Comment "Vector `$type` ..."
	Comment ""
	Comment "  Structurally matches `critcl_variadic_$ct`."
	Comment "  Simplifies handling of variadics."
	+ {}
	+ "A_STRUCTURE (${tx}) \{"
	+ "  A_FIELD ([PadR $n Tcl_Obj**], o) ; /* Generally superfluous */"
	+ "  A_FIELD ([PadR $n    int], c) ; /* Number of elements               */"
	+ "  A_FIELD ([PadR $n ${ct}*], v) ; /* Array of the elements, allocated */"
	+ "\} A_END (${tx});"
	+ {}
    }

    Done
}

proc dsl::writer::VectorSignatures {} {
    if {![llength [Vectors]]} return

    set names {}
    set types {}
    set plus  {}

    foreach t [Vectors] {
	set tx [TypeVector $t]

	# Note: Match param-func-* // Callers

	lappend names ${tx}_new
	lappend names ${tx}_heapify
	lappend names ${tx}_free
	lappend names {}
	lappend types $tx
	lappend types $tx
	lappend types $tx
	lappend types {}
	lappend plus  ", aktive_uint n"
	lappend plus  {}
	lappend plus  {}
	lappend plus  {}
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]

    CHeader {Vector utility functions for types used in variadics}

    foreach n $names t $types p $plus {
	if {$n eq {}} { + {} ; continue }
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	+ "extern void $n (${t}* vec$p);"
    }

    + {}
    Done
}

proc dsl::writer::VectorFunctions {} {
    if {![llength [Vectors]]} return

    set names {}
    set types {}
    set plus  {}
    set codes {}

    foreach t [Vectors] {
	set tx [TypeVector $t]
	set ct [TypeCritcl $t]

	lappend names ${tx}_new
	lappend names ${tx}_heapify
	lappend names ${tx}_free
	lappend names {}
	lappend types $tx
	lappend types $tx
	lappend types $tx
	lappend types {}
	lappend plus  ", aktive_uint n"
	lappend plus  {}
	lappend plus  {}
	lappend plus  {}
	lappend codes "vec->c = n; vec->v = memset (NALLOC ($ct, n), 0, n * sizeof($ct));"
	lappend codes "vec->v = memcpy (NALLOC ($ct, vec->c), vec->v, vec->c * sizeof($ct));"
	lappend codes "ckfree ((char*) vec->v);"
	lappend codes {}
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]
    set cl [Maxlength $codes]

    CHeader {Vector utility functions for types used in variadics}

    foreach n $names t $types p $plus c $codes {
	if {$n eq {}} { + {} ; continue }
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	set c [PadR $cl $c]
	+ "extern void $n (${t}* vec$p) \{ $c \}"
    }

    + {}
    Done
}

# # ## ### ##### ######## #############
## Main emitter commands -- Types

proc dsl::writer::TypeSignatures {} {
    if {![llength [Types]] && ![llength [Vectors]]} return

    set names {}
    set types {}

    foreach t [Types] {
	lappend names [TypeValueFunc $t]
	lappend types [TypeCType $t]
    }

    lappend names {}
    lappend types {}

    foreach t [Vectors] {
	lappend names [TypeVecValueFunc $t]
	lappend types [TypeVector $t]
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]

    CHeader {Type conversion declarations }

    foreach n $names t $types {
	if {$t eq {}} {
	    + {}
	    continue
	}

	set n [PadR $nl $n]
	set t [PadR $tl $t]
	+ "extern Tcl_Obj* $n (Tcl_Interp* interp, ${t}* value);"
    }

    + {}
    Done
}

proc dsl::writer::TypeFunctions {} {
    if {![llength [Types]] && ![llength [Vectors]]} return

    set names {} ; set vnames {}
    set types {} ; set vtypes {}
    set conv  {} ; set vconv  {}

    foreach t [Types] {
	lappend names [TypeValueFunc $t]
	lappend types [TypeCType $t]
	lappend conv  [TypeConv $t]
    }

    foreach t [Vectors] {
	lappend vnames [TypeVecValueFunc $t]
	lappend vtypes [TypeVector $t]
	lappend vconv  [TypeValueFunc $t]
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]
    set cl [Maxlength $conv]

    CHeader {Type conversion functions }

    foreach n $names t $types c $conv {
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	set c [PadR $cl $c]
	+ "extern Tcl_Obj* $n (Tcl_Interp* interp, ${t}* value) \{ return $c; \}"
    }
    + {}

    foreach n $vnames t $vtypes c $vconv {
	+ "extern Tcl_Obj* $n (Tcl_Interp* interp, ${t}* value) \{"
	+ "  Tcl_Obj*  r = NULL;"
	+ "  Tcl_Obj** v = NALLOC (Tcl_Obj*, value->c);"
	+ "  for (int k = 0; k < value->c; k++) \{"
	+ "    Tcl_Obj* vk = $c (interp, &value->v\[k]);"
	+ "    if (!vk) goto done;"
	+ "    v\[k] = vk;"
	+ "  \}"
	+ "  r = Tcl_NewListObj (value->c, v);"
	+ "done:"
	+ "  ckfree ((char*) v);"
	+ "  return r;"
	+ "\}"
	+ {}
    }

    Done
}

# # ## ### ##### ######## #############
## Main emitter commands -- Operators

proc dsl::writer::Todo {} {
    if {![llength [Get todos]]} return

    foreach todo [lsort -dict [Get todos]] {
	+ $todo
    }
    Done
}

proc dsl::writer::OperatorPermutedNames {docs} {
    set ops [dict keys [dict get $docs alpha]]

    set perm {}
    foreach op $ops {
	foreach p [Permute [lrange [OpName $op] 1 end]] {
	    dict set perm $p $op .
	}
    }

    + "<img src='../assets/aktive-logo-128.png' style='float:right;'>"
    + {}
    + [OpNav pname]
    + {}
    + [NavLetter [dict keys $perm]]
    + {}
    + "# Documentation -- Reference Pages -- Permuted Index Of Operator Names"

    set last {}
    foreach p [lsort -dict [dict keys $perm]] {
	set initial [string index $p 0]
	if {$initial ne $last} {
	    + {}
	    + "## <a name='_$initial'></a> $initial"
	    + {}
	}
	set last $initial
	foreach op [lsort -dict [dict keys [dict get $perm $p]]] {
	    set section [dict get $docs alpha $op]
	    + "  - \[$p]([OpSectionKey $section].md#[OpKey $op])"
	}
    }

    Done
}

proc dsl::writer::OperatorPermutedSections {docs} {
    set sections [dict keys [dict get $docs section]]

    set perm {}
    foreach section $sections {
	foreach p [Permute $section] {
	    dict set perm $p $section .
	}
    }

    + "<img src='../assets/aktive-logo-128.png' style='float:right;'>"
    + {}
    + [OpNav psection]
    + {}
    + [NavLetter [dict keys $perm]]
    + {}
    + "# Documentation -- Reference Pages -- Permuted Index Of Sections"

    set last {}
    foreach p [lsort -dict [dict keys $perm]] {
	set initial [string index $p 0]
	if {$initial ne $last} {
	    + {}
	    + "## <a name='_$initial'></a> $initial"
	    + {}
	}
	set last $initial
	foreach section [lsort -dict [dict keys [dict get $perm $p]]] {
	    + "  - \[$p]([OpSectionKey $section].md)"
	}
    }

    Done
}

proc dsl::writer::OperatorIndex {docs} {
    + "<img src='../assets/aktive-logo-128.png' style='float:right;'>"
    + {}
    + [OpNav entry]
    + {}
    + "# Documentation -- Reference Pages"
    + {}
    + "Reference pages for all the package's public operators and commands."
    + "See the navigation bar at the top for the available indices."
    + {}
    Done
}

proc dsl::writer::OperatorSections {docs} {
    + "<img src='../assets/aktive-logo-128.png' style='float:right;'>"
    + {}
    + [OpNav section]
    + {}
    + "# Documentation -- Reference Pages -- Index Of Sections"
    + {}

    # generate linear section tree from implied tree in docs collection
    # -- depth first walk --
    set stack  [lreverse [lsort -dict [dict get $docs roots]]]
    set prefix ""
    while {[llength $stack]} {
	set top   [lindex $stack end]
	set stack [lrange $stack 0 end-1]

	if {$top eq "."} continue

	if {$top eq "++"} {
	    append prefix "  "
	    continue
	} elseif {$top eq "--"} {
	    set prefix [string range $prefix 0 end-2]
	    continue
	}

	+ "$prefix  - \[[lindex $top end]\]([OpSectionKey $top].md)"

	if {![dict exists $docs section $top children]} continue
	set children [dict keys [dict get $docs section $top children]]
	if {![llength $children]} continue

	lappend stack -- {*}[lreverse [lsort -dict $children]] ++
    }

    + {}
    Done
}

proc dsl::writer::OperatorsByLang {spec} {
    # spec = dict (lang -> op -> section)

    set langs [dict keys $spec]
    set map  {
	C        C
	Tcl      Tcl
	External Direct
    }
    set desc {
	C {
	    The operators listed here are implemented in C. We ignore supporting Tcl code.
	}
	Tcl {
	    The operators listed here are implemented wholly in Tcl.
	}
	External {
	    The commands listed here are implemented outside of the operator framework.
	}
    }

    + "<img src='../assets/aktive-logo-128.png' style='float:right;'>"
    + {}
    + [OpNav language]
    + {}
    + [NavWords [lmap {lang label} $map {
	if {![dict exists $spec $lang]} continue
	set label
    }]]
    + {}
    + "# Documentation -- Reference Pages -- Operators By Implementation"
    + {}

    foreach {lang label} $map {
	if {![dict exists $spec $lang]} continue

	+ "## <a name='_$label'></a> $label"
	+ {}

	set d [string map {
	    {	    } {}
	} [string trim [dict get $desc $lang]]]

	+ $d
	+ {}

	foreach op [lsort -dict [dict keys [dict get $spec $lang]]] {
	    set section [dict get $spec $lang $op]
	    + " - \[[OpName $op]\]([OpSectionKey $section].md#[OpKey $op])"
	}
	+ {}
    }

    Done
}

proc dsl::writer::OperatorsByName {spec} {
    # spec = dict (op -> section)

    + "<img src='../assets/aktive-logo-128.png' style='float:right;'>"
    + {}
    + [OpNav name]
    + {}
    + [NavLetter [lmap {op section} $spec {
	set op
    }]]
    + {}
    + "# Documentation -- Reference Pages -- Operators By Name"

    set last {}
    foreach op [lsort -dict [dict keys $spec]] {
	set initial [string index $op 0]
	if {$initial ne $last} {
	    + {}
	    + "## <a name='_$initial'></a> $initial"
	    + {}
	}
	set last $initial
	set section [dict get $spec $op]
	+ " - \[[OpName $op]\]([OpSectionKey $section].md#[OpKey $op])"
    }

    + {}
    Done
}

proc dsl::writer::OperatorsStrict {spec} {
    # spec = dict (op -> section)

    + "<img src='../assets/aktive-logo-128.png' style='float:right;'>"
    + {}
    + [OpNav strict]
    + {}
    + [NavLetter [lmap {op section} $spec {
	set op
    }]]
    + {}
    + "# Documentation -- Reference Pages -- StrictOperators"
    + {}
    + [string map {"\t" ""} [string trim {
	All operators listed here are strict in at least one of their image arguments.

	This means that these operators execute the image pipelines to calculate the
	pixels of the input images they are strict in.

	Note that this does not necessarily mean that these inputs are fully materialized
	in memory, only that the pixels are computed. These pixels may then be saved
	to disk, or reduced by some statistical measure, or, yes, indeed materialized.

	It all depends on the details of the operator in question.
    }]]

    set last {}
    foreach op [lsort -dict [dict keys $spec]] {
	set initial [string index $op 0]
	if {$initial ne $last} {
	    + {}
	    + "## <a name='_$initial'></a> $initial"
	    + {}
	}
	set last $initial
	set section [dict get $spec $op]
	+ " - \[[OpName $op]\]([OpSectionKey $section].md#[OpKey $op])"
    }

    + {}
    Done
}

proc dsl::writer::OperatorSection {spec section} {
    # spec = dict ( op    -> doc,
    #               child -> section . )

    + "<img src='../assets/aktive-logo-128.png' style='float:right;'>"
    + {}
    + [OpNav] ;# link to all indices
    + {}
    + "# Documentation -- Reference Pages -- $section"
    + {}
    + "## <anchor='top'> Table Of Contents"

    # navigation up to parent section, or main (for roots)
    if {[llength $section] > 1} {
	set parent [lrange $section 0 end-1]
	+ {}
	+ "  - \[$parent]([OpSectionKey $parent].md) \u2197"
	+ {}
    } else {
	+ {}
	+ "  - \[Roots](bysection.md) \u2197"
	+ {}
    }

    # navigation down to subordinate sections
    if {[dict exists $spec children]} {
	+ {}
	+ "## Subsections"
	+ {}

	set children [dict keys [dict get $spec children]]
	if {[llength $children]} {
	    + {}

	    foreach child [lsort -dict $children] {
		+ " - \[$child\]([OpSectionKey $child].md) \u2198"
	    }
	}
    }

    # list of operators
    if {[dict exists $spec op]} {
	+ {}
	+ "### Operators"
	+ {}

	# operators, first run, local TOC with links
	foreach {op __} [lsort -dict -index 0 -stride 2 [dict get $spec op]] {
	    + " - \[[OpName $op]\](#[OpKey $op])"
	}

	+ {}
	+ "## Operators"
	+ {}

	# operators, second run, actual documentation
	foreach {op text} [lsort -dict -index 0 -stride 2 [dict get $spec op]] {
	    + $text
	}
    }

    Done
}

proc dsl::writer::OpNav {{current {}}} {
    set h |
    set s |
    set d |
    foreach {label ref} {
	"Project \u2197"       "../../README.md"
	"Documentation \u2197" "../index.md"
	- -
	"Tutorials \u2197"     "../tutorials.md"
	"How To's \u2197"      "../howtos.md"
	"Explanations \u2197"  "../explanations.md"
    } {
	append h |
	append s ---|
	if {$label eq "-"} {
	    append d "&mdash;|"
	} else {
	    append d "\[$label]($ref)|"
	}
    }
    append h |
    append s ---|
    append d References|
    + $h
    + $s
    + $d
    + {}
    set h |
    set s |
    set d |
    foreach {key label ref} {
	entry "Entry \u2197"            "index.md"
	- - -
	section  "Sections \u2198"          bysection.md
	psection "Permuted Sections \u2198" bypsection.md
	name     "Names \u2198"             byname.md
	pname    "Permuted Names \u2198"    bypname.md
	strict   "Strict \u2198"            strict.md
	language "Implementations \u2198"   bylang.md
    } {
	append h |
	append s ---|
	if {$label eq "-"} {
	    append d "&mdash;|"
	} elseif {$key eq $current} {
	    # strip the arrow from the label
	    append d "[string range $label 0 end-2]|"
	} else {
	    append d "\[$label]($ref)|"
	}
    }
    + $h
    + $s
    + $d
    Done
}

proc dsl::writer::Operators {} {
    if {![llength [Operations]]} return

    set names [Operations]
    set nl    [Maxlength $names]
    set ns    [Maxlength [lmap op $names { join [Get ops $op section] / }]]
    set nd    [Maxlength [lmap op $names { join [Get ops $op defloc]  " @" }]]

    foreach op [lsort -dict $names] {
	set kind [dict get {
	    C        {(C)  }
	    Tcl      {(Tcl)}
	    External {(Ext)}
	} [Get ops $op lang]]
	set notes   [join [lindex [Get ops $op notes] 0] { }]
	set section [join [Get ops $op section] /]
	set loc     [join [Get ops $op defloc] " @"]
	+ "[PadR $nl $op] :: [PadR 5 $kind] [PadR $ns $section] :: [PadR $nd $loc] :: $notes"
    }
    Done
}

proc dsl::writer::OpName {op} {
    return "aktive [string map {:: { }} $op]"
}

proc dsl::writer::OpKey {op} {
    return [string map {:: _ - _} $op]
}

proc dsl::writer::OpSectionKey {section} {
    return [join [string map {- {}} $section] _]
}

proc dsl::writer::OpDoc {stem op spec} {
    dict with spec {}
    # c:   examples notes references section params images ...
    # tcl: examples notes references section args body

    set sig [DocSignature $op $spec]

    lassign [dict get $spec defloc] path line
    + "---"
    + "### \[\u2191\](#top) <a name='[OpKey $op]'></a> [OpName $op]"
    + ""
    + "Syntax: __[OpName $op]__ $sig \[\[\u2192 definition\](/file?ci=trunk&ln=${line}&name=${path})\]"

    foreach note $notes {
	+ ""
	+ [join $note { }]
    }

    if {[llength $images]} {
	+ {}
	+ "|Input|Description|"
	+ "|:---|:---|"

	set single [expr {[llength $images] == 1}]
	set id 0
    	foreach i $images {
	    dict with i {}
	    # args name rcmode desc
	    set n src$id ; incr id
	    if {$single} { set n src }
	    if {$name ne {}} { set n $name }
	    if {$args} { set n args... }
	    if {$desc eq "" && $single} {
		set desc [dict get {
		    0 {Source image}
		    1 {Source images}
		} $args]
	    }
	    + "|$n|$desc|"
	    unset -nocomplain args name rcmode desc
	}
    }

    if {[llength $params]} {
	+ {}
	+ "|Parameter|Type|Default|Description|"
	+ "|:---|:---|:---|:---|"

	foreach p $params {
	    dict with p {}
	    # args default desc name type
	    if {![info exists default]} { set default {} }
	    if {$args}   { append type ...  }
	    if {$vector} { append type {[]} }
	    + "|$name|$type|$default|$desc|"
	    unset -nocomplain args default desc name type
	}
    }

    if {[llength $examples]} {
	+ {}
	+ "#### <a name='[OpKey $op]__examples'></a> Examples"
	+ {}

	# examples :: list (example...)
	foreach example $examples {
	    # example :: list (run...)
	    incr k
	    set n [llength $example]
	    set id 0
	    set varmap {}
	    set ref "<a name='[OpKey $op]__examples__e${k}'></a>"
	    + ${ref}[ExampleRender $op [lmap run $example {
		# run :: list (gencmd showcmds format int desc)
		incr n -1 ; set islast [expr {$n == 0}]
		incr id
		set label   [expr {$islast ? "[lindex $run 0]" : "@$id"}]
		lappend varmap @$id "\$x$id"
		list $label {*}[ExampleScript $op $stem $id $varmap {*}$run]
	    }]]
	    + {}
	}
    }

    if {[llength $references]} {
    	+ {}
	+ "#### <a name='[OpKey $op]__references'></a> References"

	foreach ref $references {
	    + {}
	    + "  - <${ref}>"
	}
    }

    + ""
    Done
}

proc dsl::writer::ExampleRender {op example} {
    # example :: list (run...)
    # run     :: list (label desc results)
    # results :: list (result...)
    # result  :: list (show format dstfile)

    set labels [lmap run $example {
	lassign $run label desc
	if {$desc eq {}} { set desc "&nbsp;" } else { set desc ($desc) }
	append label "\n    <br>" $desc
	set label
    }]
    set data [lmap run $example { RR {*}$run }]

    lappend lines "<table>\n<tr><th>[join $labels "</th>\n    <th>"]</th></tr>"
    lappend lines "<tr><td valign='top'>[join $data "</td>\n    <td valign='top'>"]</td></tr>\n</table>"

    # render complete
    return [join $lines \n]
}

proc dsl::writer::RR {label desc results} {
    if {$desc ne {}} { append label "<br>(" $desc ")" }
    if {[llength $results] == 1} {
	return [RR1 1 $label [lindex $results 0]]
    }
    return [TR1 [join [lmap res $results { RR1 0 $label $res }] {}]]
}

proc dsl::writer::RR1 {single label result} {
    lassign $result show format dst
    switch -exact -- $format {
	text   -
	matrix { set cell "<!include: $dst>" }
	image  {
	    set dlabel [string map {<br> { }} $label]
	    set cell "<img src='$dst' alt='$dlabel' style='border:4px solid gold'>\n    <br><!include: ${dst}.txt>" }
    }

    if {$single} {
	if {$show eq {}} { return $cell }
	return [TR1 [TD $show][TD $cell]]
    }

    if {$show eq {}} { return [TD $cell] }
    return [TD $show][TD $cell]
}

proc dsl::writer::TR1 {row}  { return "<table><tr>$row</tr></table>" }
proc dsl::writer::TD  {cell} { return "<td valign='top'>$cell</td>" }

proc dsl::writer::ExampleScript {op stem id varmap gencmd showcmds format int desc} {
    # intro
    if {$id == 1} { lappend script "puts \"\"" }
    lappend script "puts \{# Example: ($id) $gencmd ($desc)\}"

    # generation command
    set gencmd [string map $varmap $gencmd]
    lappend script "# generate _____________________"
    lappend script "set x$id \[$gencmd\]"

    # show commands, plus final formatting
    set results [list $desc [lmap show $showcmds {
    	set dst [File example- [dict get {
	    image  .gif
	    matrix .md
	    text   .txt
	} $format]]
	if {$show ne {}} {
	    lappend script "set x${id}t \[$show \$x$id\]"
	    lappend script "emit-$format ${stem}$dst $int \$x${id}t"
	} else {
	    lappend script "emit-$format ${stem}$dst $int \$x$id"
	}
	list $show $format $dst
    }]]

    # Save script for execution after compilation and installation
    Stash [join $script \n]
    return $results
    # results :: list (list (show format dst desc)...)
}

proc dsl::writer::File {prefix ext} {
    variable counter
    return $prefix[format %05d [incr counter]]$ext
}

proc dsl::writer::Permute {words} {
    if {[llength $words] < 2} { return $words }

    set r {}
    set i 0

    # compute rotations of the words.
    foreach w $words {
	set pivot  [lindex $words $i]
	set before [lrange $words 0 $i-1]
	set after  [lrange $words $i+1 end]
	# rotation left places pivot at the front, then after, then before
	lappend r [string map {{  } { }} \
		       [string trimright "$pivot &mdash; $after $before"]]
	incr i
    }
    return $r
}

proc dsl::writer::NavLetter {words} {
    set initial {}
    foreach w $words {
	dict set initial [string index $w 0] .
    }

    NavWords [lsort -dict [dict keys $initial]]
}

proc dsl::writer::NavWords {words} {
    append h |
    append s |
    append d |
    foreach w $words {
	append h |
	append s "---|"
	append d "&nbsp;\[$w\](#_$w)&nbsp;|"
    }

    + $h
    + $s
    + $d
    Done
}

proc dsl::writer::Undocumented {} {
    if {![llength [Operations]]} return

    set names [Operations]
    set nl    [Maxlength $names]
    set undocumented 0

    foreach op [lsort -dict $names] {
	set kind [dict get {
	    C        {(C)  }
	    Tcl      {(Tcl)}
	    External {(Ext)}
	} [Get ops $op lang]]
	set notes   [join [lindex [Get ops $op notes] 0] { }]
	set section [join [Get ops $op section] /]

	if {($notes ne {}) && ($section ne {})} continue

	if {$notes   eq {}} { append miss "; no note"    }
	if {$section eq {}} { append miss "; no section" }
	+ "[PadR $nl $op] :: $kind$miss"
	unset miss
	incr undocumented
    }

    if {$undocumented} {
	puts "Undocumented operators: [red $undocumented]"
	Done
    }
    return
}

proc dsl::writer::NoExamples {} {
    if {![llength [Operations]]} return

    set names [Operations]
    set nl    [Maxlength $names]
    set noexamples 0
    set examples   0

    foreach op [lsort -dict $names] {
	if {[llength [Get ops $op examples]]} {
	    incr examples; continue
	}
	set loc     [join [Get ops $op defloc] " @"]
	+ "[PadR $nl $op] :: $loc"
	incr noexamples
    }

    if {$noexamples} {
	puts "Operators with    examples: [blue $examples]"
	puts "Operators without examples: [red  $noexamples]"
	Done
    }
    return
}

proc dsl::writer::COperatorSignatures {} {
    if {![llength [COperations]]} return

    set names   {}
    set sigs    {}
    set results {}

    foreach op [COperations] {
	set spec [Get ops $op]

	set result [dict get $spec result]
	if {$result ne "void"} { set result [CprocResultC $spec] }

	lappend names   [FunctionName          $op $spec]
	lappend sigs    [FunctionDeclSignature $op $spec]
	lappend results $result
    }

    set nl [Maxlength $names]
    set sl [Maxlength $sigs]
    set rl [Maxlength $results]

    CHeader {Operator function declarations}

    foreach n $names s $sigs r $results {
	set n [PadR $nl $n]
	set s [PadR $sl $s]
	set r [PadR $rl $r]
	+ "extern $r $n $s;"
    }

    + {}
    Done
}

proc dsl::writer::COperatorFunctions {} {
    if {![llength [COperations]]} return

    CHeader {operator function implementations}

    + "#define NOSRCS NULL"
    + ""

    foreach op [COperations] {
	+ [OperatorFunctionForOp $op]
    }

    Done
}

proc dsl::writer::OperatorFunctionForOp {op} {
    set spec [Get ops $op]

    dict with spec {}
    # notes, images, params, result, rcode, statec, stater, statef, geometry, support, key
    unset notes
    ##       images          result, rcode, statec, stater, statef, geometry, support, key

    if {$result ne "void"} {
	set result [CprocResultC $spec]
    }

    set fn  [FunctionName          $op $spec]
    set sig [FunctionDeclSignature $op $spec]

    set paramtype  void ; if {[llength $params]}      { set paramtype  [ParamStructTypename $op] }
    set statetype  void ; if {${state/fields}  ne {}} { set statetype  [StateStructTypename $op] }
    set regiontype void ; if {${region/fields} ne {}} { set regiontype [RegionStateTypename $op] }

    set hasimages [llength $images]

    Comment "- - -- --- ----- -------- ------------- ---------------------"
    Comment "Operator \"$op\" ..."
    + {}

    if {[llength $support]} {
	Comment "- - -- --- ----- -------- ------------- " {    }
	Comment " -- BEGIN supporting definitions"         {    }
	+ {}
	+ "#ifndef OPERATOR_GROUP_$key"
	+ "#define OPERATOR_GROUP_$key"
	foreach cfragment $support {
	    + [FormatCode $cfragment {    }]
	    + {}
	}
	+ "#endif /* OPERATOR_GROUP_$key */"
	+ {}
	Comment " -- END supporting definitions"           {    }
	Comment "- - -- --- ----- -------- ------------- " {    }
	+ {}
    }

    ## %% TODO %% move into separate emitter for placement into its own header file, sourcable elsewhere
    if {${state/fields} ne {}} {
	+ "typedef struct $statetype \{"
	+ [FormatCode ${state/fields}]
	+ "\} $statetype;"
	+ {}
    }

    if {${region/fields} ne {}} {
	+ "typedef struct $regiontype \{"
	+ [FormatCode ${region/fields}]
	+ "\} $regiontype;"
	+ {}
    }

    if {${region/setup} ne {}} {
	+ "static void"
	+ "[RegionSetupFuncname $op] (aktive_region_info* info) \{"
	+ "  TRACE_FUNC(\"((aktive_region_info*) %p\", info);"

	# Enhance fragment with code providing the info data in properly typed form.
	set types {}
	if {$hasimages}                       {           lappend types aktive_region_vector* }
	set pt 0 ; if {$paramtype  ne "void"} { incr pt ; lappend types *$paramtype  }
	set rt 0 ; if {$regiontype ne "void"} { incr rt ; lappend types *$regiontype }
	set st 0 ; if {$statetype  ne "void"} { incr st ; lappend types *$statetype  }
	set tl [Maxlength $types] ; set tlx $tl ; incr tlx 2

	if {$pt}        { + "  [PadR $tl ${paramtype}*] param  = [PadR $tlx (${paramtype}*)] info->param;" }
	if {$st}        { + "  [PadR $tl ${statetype}*] istate = [PadR $tlx (${statetype}*)] info->istate;" }
	if {$hasimages} { + "  [PadR $tl aktive_region_vector*] srcs   = [PadR $tlx ""] &info->srcs;" }
	if {$rt}        {
	    # region state type is known. allocate it.
	    + "  [PadR $tl ${regiontype}*] state  = [PadR $tlx (${regiontype}*)] ALLOC ($regiontype);"
	    + "  info->state = state;"
	} else {
	    + "#define state (info->state)"
	}

	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	+ {}
	+ [VoidCode [FormatCode ${region/setup}]]
	+ {}
	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	if {!$rt} { + "#undef state" }
	+ "  TRACE_RETURN_VOID;"
	+ "\}"
	+ {}
    }

    if {${region/cleanup} ne {}} {
	+ "static void"
	+ "[RegionFinalFuncname $op] (${regiontype}* state) \{"
	+ "  TRACE_FUNC(\"(($regiontype*) %p)\", state);"
	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	+ {}
	+ [FormatCode ${region/cleanup}]
	+ {}
	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	+ "  TRACE_RETURN_VOID;"
	+ "\}"
	+ {}
    }

    if {${state/setup} ne {}} {
	+ "static int"
	+ "[StateSetupFuncname $op] (aktive_image_info* info, Tcl_Obj** meta) \{"
	+ "  TRACE_FUNC(\"((aktive_image_info*) %p)\", info);"

	# Enhance fragment with code providing the info data in properly typed form.
	set types [list aktive_geometry*]
	if {$hasimages}                       {           lappend types aktive_image_vector* }
	set pt 0 ; if {$paramtype  ne "void"} { incr pt ; lappend types *$paramtype  }
	set st 0 ; if {$statetype  ne "void"} { incr st ; lappend types *$statetype  }
	set tl [Maxlength $types] ; set tlx $tl ; incr tlx 2

	if {$pt}        { + "  [PadR $tl ${paramtype}*] param  = [PadR $tlx (${paramtype}*)] info->param;" }
	if {$hasimages} { + "  [PadR $tl aktive_image_vector*] srcs   = [PadR $tlx ""] &info->srcs;" }
	+ "  [PadR $tl aktive_geometry*] domain = [PadR $tlx ""] &info->domain;"
	if {$st}        {
	    # state type is known. allocate it.
	    + "  [PadR $tl ${statetype}*] state  = [PadR $tlx (${statetype}*)] ALLOC ($statetype);"
	    + "  info->state = state;"
	} else {
	    + "#define state  (info->state)"
	}
	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	+ {}
	+ [FormatCode ${state/setup}]
	+ {}
	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	+ "  TRACE_GEOMETRY (domain);"
	if {!$st} { + "#undef state" }
	+ "  TRACE_RETURN (\"(ok) %d\", 1);"
	+ "\}"
	+ {}
    }

    if {${state/cleanup} ne {}} {
	+ "static void"
	+ "[StateFinalFuncname $op] (${statetype}* state) \{"
	+ "  TRACE_FUNC(\"(($statetype*) %p)\", state);"
	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	+ {}
	+ [FormatCode ${state/cleanup}]
	+ {}
	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	+ "\}"
	+ {}
    }

    if {$result ne "aktive_image"} {
	# Main implementation and pixel filler need manual writing

	if {$result eq "aktive_image"} {
	    + [Placeholder ${op}-fetch {}]
	    + {}
	}

	+ "extern $result"
	+ "$fn $sig \{"
	+ "  TRACE_FUNC(\"((Tcl_Interp*) %p)\", ip);"
	ParamTracing $params
	# TODO src, ... if present

	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	+ {}

	if {$rcode eq {}} {
	    + [Placeholder $op]
	} elseif {$result eq "void"} {
	    # We have a C code fragment implementing the doer
	    + [VoidCode [FormatCode $rcode]]
	    + "  TRACE_RETURN_VOID;"
	} else {
	    # We have a C code fragment implementing the getter.
	    # Hide fail/vfail difference from user.
	    + [FormatCodeWithReturn $rcode]
	}

	+ {}
	Comment {- - -- --- ----- -------- ------------- ---------------------} {  }

	+ "\}"
	+ {}
    } else {
	# image result -- Pixel fetch function first
	set fun [RegionFetchFuncname $op]
	set spc [string repeat { } [string length $fun]]

        + "static void"
        + "$fun ( aktive_region_info* info    // Parameters, inputs, state, image state"
        + "$spc , aktive_rectangle*   request // Area caller wants the pixels for"
        + "$spc , aktive_rectangle*   dst     // Area of `block` to blit the pixels into"
        + "$spc , aktive_block*       block   // Pixel storage"
        + "$spc ) \{"
        + "  TRACE_FUNC(\"((aktive_region_info*) %p)\", info);"
	+ "  TRACE_RECTANGLE_M (\"request\", request);"
	+ "  TRACE_RECTANGLE_M (\"dst....\", dst);"

	if {${region/fetch} ne {}} {
	    # Enhance fragment with code providing the info data in properly typed form.
	    set types aktive_geometry*
	    if {$hasimages}                       {           lappend types *aktive_region_vector }
	    set pt 0 ; if {$paramtype  ne "void"} { incr pt ; lappend types *$paramtype  }
	    set rt 0 ; if {$regiontype ne "void"} { incr rt ; lappend types *$regiontype }
	    set st 0 ; if {$statetype  ne "void"} { incr st ; lappend types *$statetype  }
	    set tl [Maxlength $types] ; set tlx $tl ; incr tlx 2

	    if {$pt}        { + "  [PadR $tl ${paramtype}*] param   = [PadR $tlx (${paramtype}*)] info->param;" }
	    if {$rt}        { + "  [PadR $tl ${regiontype}*] state   = [PadR $tlx (${regiontype}*)] info->state;" }
	    if {$st}        { + "  [PadR $tl ${statetype}*] istate  = [PadR $tlx (${statetype}*)] info->istate;" }
	    if {$hasimages} { + "  [PadR $tl aktive_region_vector*] srcs    = [PadR $tlx ""] &info->srcs;" }
	    +                   "  [PadR $tl aktive_geometry*] idomain = [PadR $tlx ""] info->domain;"
	    +                   "  TRACE_GEOMETRY_M  (\"idomain\", idomain);"
	    + "  TRACE(\"block (init %d cap %d used %d)\", block->initialized, block->capacity, block->used);"
	    + "  TRACE(\"block region   %p\", block->region);"
	    + "  TRACE_POINT_M(\"block location\", &block->location);"
	    + "  TRACE_GEOMETRY_M(\"block geometry\", &block->domain);"

	    # Show parameter values going into the fetch.
	    ParamTracing $params

	    Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	    + {}
	    + [FormatCode ${region/fetch}]
	    + {}
	    Comment {- - -- --- ----- -------- ------------- ---------------------} {  }
	} else {
	    + [Placeholder ${op}-fetch]
	}
	+ "  TRACE_RETURN_VOID;"
	+ "\}"
	+ {}

	# Main function can be generated, and refers to pixel fill function

	+ "extern $result"
	+ "$fn $sig \{"
	+ [FunctionBodyImageConstructor $op $spec]
	+ "\}"
	+ {}
    }

    Done
}

proc dsl::writer::ParamTracing {params} {
    upvar 1 lines lines

    set pnames [lmap p $params { dict get $p name }]
    set pnl    [Maxlength $pnames]
    # Match to type specs in aktive.tcl, runtime.tcl ==> get from reader
    set tmap  {
	uint    u	channel      p
	double  f	take-channel p
	int     d
	bool    d
	object0 p
    }
    set ptypes [lmap p $params {
	# The types here have to include all the parameter types used in etc/aktive.tcl and sourced.
	set t [dict get $p type]
	expr {[dict exists $tmap $t] ? [dict get $tmap $t] : "%binary"}
    }]

    foreach p $pnames t $ptypes {
	+ "  TRACE(\"param \[[PadR $pnl $p]] = %$t\", param->$p);"
    }
}

proc dsl::writer::VoidCode {code} {
    return [string map {aktive_fail aktive_void_fail} $code]
}

proc dsl::writer::FormatCode {code {indent {  }}} {
    set code [textutil::adjust::undent $code]
    set code [string trim $code]

    return [textutil::adjust::indent $code $indent]
}

proc dsl::writer::FormatCodeWithReturn {code {indent {  }}} {
    # Note: Engineering a `return` into the last line / C statement of the block.
    set code  [textutil::adjust::undent $code]
    set code  [string trim $code]
    set lines [split $code \n]
    set lines [lreverse [lassign [lreverse $lines] last]]

    if {[regexp TRACE_RETURN $last]} {
	# do nothing
    } elseif {![regexp return $last]} {
	set last "TRACE_RETURN (\"\", [string trimright $last ";"]);"
    } else {
	regexp {return (.*);} $last -> expr
	set last "TRACE_RETURN (\"\", $expr);"
    }

    lappend lines $last
    set code [join $lines \n]

    return [textutil::adjust::indent $code $indent]
}

proc dsl::writer::Placeholder {key {prefix {  }}} {
    + "${prefix}/* -- BEGIN PLACEHOLDER $key -- */"
    # TODO: query for pre-existing code. insert if present
    + "${prefix}/* -- END   PLACEHOLDER $key -- */"

    return [join $lines \n]
}

proc dsl::writer::OperatorCprocs {} {
    if {![llength [Operations]]} return

    TclHeader {Glue commands, per operator}

    foreach op [COperations] {
	+ [OperatorCprocForOp $op]
    }

    Done
}

proc dsl::writer::OperatorCprocForOp {op} {
    set spec [Get ops $op]
    set sn   [ParamStructTypename $op]

    dict with spec {}
    # notes, images, params, result
    unset images params
    # notes                  result

    TclComment "--- --- --- --- --- --- --- --- ---"
    TclComment "Operator `$op` ..."
    foreach n $notes { TclComment "Note: [join $n { }]" }

    set cmd $op

    if {[OpMakeWrapper $op]} {
	TclComment {}
	TclComment "Note: This constructor has a Tcl wrapper."

	if {[OpHasOverlays $op]} {
	    TclComment "Note: It performs construction time peep-hole optimizations."
	}
	if {[OpParamOptional $op]} {
	    TclComment "Note: It the manages non-image parameters."
	}

	set stem [namespace qualifiers $op]
	set base [namespace tail $op]
	set cmd ${stem}::I$base
    }

    + {}
    + "critcl::cproc aktive::$cmd \{"
    + [CprocArguments $spec]
    + "\} [CprocResult $spec] \{"
    + [CprocBodyImages $spec]
    + [CprocParameterSetup $op $spec]

    if {$result eq "void"} {
	+ [CprocBody $op $spec {
	    + "  [FunctionCall $op $spec];"
	}]
	+ "  if (aktive_error_raised ()) { aktive_error_set (ip); return TCL_ERROR; }"
	+ "  return TCL_OK;"
    } else {
	+ [CprocBody $op $spec {
	    + "  [CprocResultC $spec] _r = [FunctionCall $op $spec];"
	}]
	if {$result in { object0 }} {
	    + "  if (aktive_error_raised () || !_r) { if (_r) Tcl_DecrRefCount (_r); aktive_error_set (ip); return 0; }"
	}
	+ "  return _r;"
    }

    + "\}"

    + {}
    Done
}

proc dsl::writer::CprocArguments {spec} {
    dict with spec {}
    # notes, images, params, result
    unset notes result
    #        images, params

    lappend names    ip
    lappend ctypes   Tcl_Interp*

    foreach argspec $params {
	set n  [dict get $argspec name]
	set t  [dict get $argspec type]
	set ct [TypeCritcl $t]
	set t  [TypeCType  $t]
	set v  [dict get $argspec args]
	if {$v} { set n args }

	lappend names    $n
	lappend ctypes   $ct
    }

    set single [expr {[llength $images] == 1}]

    set id 0
    foreach i $images {
	set n src$id ; incr id
	if {$single} { set n src }
	set ni [dict get $i name]
	if {$ni ne {}} { set n $ni }
	set v [dict get $i args]
	if {$v} { set n args }

	lappend names    $n
	lappend ctypes   aktive_image
    }

    set nl [Maxlength $names]
    set tl [Maxlength $ctypes]

    foreach n $names t $ctypes {
	+ "  [PadR $tl $t] [PadR $nl $n]"
    }

    return [join $lines \n]
}

proc dsl::writer::CprocBodyImages {spec} {
    dict with spec {}
    # notes, images, params, result
    unset notes params result
    #        images

    if {![llength $images]} {
	+ "  /* no input images */"
	return [join $lines \n]
    }

    set single [expr {[llength $images] == 1}]
    set inames {}
    set imodes {}

    set id 0
    foreach i $images {
	set m [dict get $i rcmode]
	set n src$id ; incr id
	if {$single} { set n src }
	set ni [dict get $i name]
	if {$ni ne {}} { set n $ni }
	set v [dict get $i args]
	if {$v} { set n args }

	lappend inames $n
	lappend imodes $m
    }

    set il [Maxlength $inames]

    foreach i $inames m $imodes {
	+ "  /* [PadR $il $i] :: $m */"
    }

    return [join $lines \n]
}

proc dsl::writer::CprocParameterSetup {op spec} {
    dict with spec {}
    # notes, images, params, result
    unset notes images result
    #                params

    if {![llength $params]} {
	+ "  /* no parameters */"
	return [join $lines \n]
    }

    set sn     [ParamStructTypename $op]
    set fields [lmap argspec $params { dict get $argspec name }]
    set fl     [Maxlength $fields]

    + "  $sn p = \{"

    set prefix "  "
    foreach p $params n $fields {
	set v     [dict get $p args]
	set field $n
	if {$v} {
	    # Explicit assignment of fields to semi-cast
	    # from critcl_variadic_X
	    # to   aktive_X_vector
	    + "    ${prefix}.[PadR $fl $field] = \{"
	    + "        .c = args.c"
	    + "      , .v = args.v"
	    + "      \}"
	} else {
	    + "    ${prefix}.[PadR $fl $field] = $n"
	}
	set prefix ", "
    }

    + "  \};"
    + {}

    return [join $lines \n]
}

proc dsl::writer::CprocBody {op spec script} {
    dict with spec {}
    # notes, images, params, result
    unset notes params result
    #        images

    set single     [expr {[llength $images] == 1}]
    set ignames    {}
    set igtypes    {}
    set igvariadic {}

    set id 0
    foreach i $images {
	set m [dict get $i rcmode]
	# TODO - move name generation into a helper - TODO
	set n src$id ; incr id
	if {$single} { set n src }
	set ni [dict get $i name]
	if {$ni ne {}} { set n $ni }
	set v [dict get $i args]
	if {$v} { set n args }

	lappend igvariadic $v

	if {$m in {
	    ignore
	}} {
	    lappend ignames $n
	    lappend igtypes {}
	}
    }

    if {![llength $ignames]} {
	eval $script
	return [join $lines \n]
    }

    set tl [Maxlength $igtypes]
    set nl [Maxlength $ignames]
    set al [expr {$nl - 6}]

    set added 0
    foreach i $ignames t $igtypes {
	if {$t eq {}} continue
	+ "  [PadR $tl $t] $i;"
	incr added
    }
    if {$added} { + {} }

    eval $script

    + {}

    foreach i $ignames t $igtypes v $igvariadic {
	set im [string map {_ignored {}} $i]

	if {!$v} {
	    if {$t eq "int"} {
		set im [PadR $al ($im)]
		+ "  if ([PadR $nl $i] && aktive_image_unused $im) { aktive_image_unref $im; }"
		continue
	    }
	    if {$t eq {}} {
		set im [PadR $al ($im)]
		+ "  if (aktive_image_unused $im) { aktive_image_unref $im; }"
		continue
	    }
	    error XXXX
	}

	# image argument and associated flag are variadic
	+ "  for (int k = 0; k < $i.c; k++) \{"
	+ "    if ($i.v\[k] && aktive_image_unused ($im.v\[k])) { aktive_image_unref ($im.v\[k]); }"
	+ "  \}"
    }

    return [join $lines \n]
}

proc dsl::writer::CprocResult {spec} {
    dict with spec {}
    # notes, images, params, result
    if {$result eq "void"} { return "ok" }
    return [TypeCritcl $result]
}

proc dsl::writer::CprocResultC {spec} {
    dict with spec {}
    # notes, images, params, result
    return [TypeCType $result]
}

proc dsl::writer::FunctionCall {op spec} {
    append func [FunctionName $op $spec] " " [FunctionCallSignature $spec]
    if {[dict get $spec result] eq "image"} {
	set func "aktive_image_check (ip, $func)"
    }
    return $func
}

proc dsl::writer::FunctionName {op spec} {
    append fn "aktive_[Cname $op]"
    switch -exact -- [dict get $spec result] {
	image   { append fn _new }
	void    { append fn _do  }
	default { append fn _get }
    }
    return $fn
}

proc dsl::writer::DocSignature {op spec} {
    dict with spec {}
    # notes, images, params, result, args, ...

    set isexternal [string equal [dict get $spec lang] External]
    set haswrapper [OpMakeWrapper $op]
    set hasopt     [OpParamOptional $op]
    set rawargs    [expr {$isexternal || !$haswrapper}]

    set sig {}

    if {$rawargs && [llength $params]}  {
	lappend sig {*}[lmap p $params {
	    set n [dict get $p name]
	    if {[dict get $p args  ]} { append n ...  }
	    if {[dict get $p vector]} { append n {[]} }
	    set n
	}]
    }

    set single [expr {[llength $images] == 1}]
    set id     0

    foreach i $images {
	set n src$id ; incr id
	if {$single} { set n src }
	set ni [dict get $i name]
	if {$ni ne {}} { set n $ni }
	set v [dict get $i args]
	if {$v} { set n srcs... }
	lappend sig $n
    }

    set sig [join $sig { }]

    if {!$rawargs && [llength $params]} {
	set m "(param value)..."
	if {$hasopt} { set m "?${m}?" }
	append sig " $m"
    }

    return $sig
}

proc dsl::writer::FunctionDeclSignature {op spec} {
    dict with spec {}
    # notes, images, params, result
    unset notes result
    #        images, params

    set single  [expr {[llength $images] == 1}]
    set id      0
    set ignames {}
    set igtypes {}

    foreach i $images {
	set it aktive_image
	set m [dict get $i rcmode]
	set n src$id ; incr id
	if {$single} { set n src }
	set ni [dict get $i name]
	if {$ni ne {}} { set n $ni }
	set v [dict get $i args]
	if {$v} {
	    set n  srcs
	    set it aktive_image_vector*
	}

	if {$m in {
	    ignore
	}} {
	    lappend ignames $n
	    lappend igtypes {}
	}
	lappend inames $n
	lappend itypes $it
    }

    set sig "Tcl_Interp* ip"
    set prefix ", "
    if {[llength $params]}  {
	append sig "${prefix}[ParamStructTypename $op]* param" ; set prefix ", "
    }
    if {[llength $images]}  {
	foreach image $inames {
	    append sig "${prefix}$it $image" ; set prefix ", "
	}
    }
    if {[llength $ignames]} {
	foreach i $ignames t $igtypes {
	    if {$t eq {}} continue
	    append sig "${prefix}${t}* $i"
	    set prefix ", "
	}
    }

    return ($sig)
}

proc dsl::writer::FunctionCallSignature {spec} {
    dict with spec {}
    # notes, images, params, result
    unset notes result
    #        images, params

    set single  [expr {[llength $images] == 1}]
    set id      0
    set ignames {}
    set igtypes {}

    foreach i $images {
	set m [dict get $i rcmode]
	set n src$id ; incr id
	if {$single} { set n src }
	set ni [dict get $i name]
	if {$ni ne {}} { set n $ni }
	set v [dict get $i args]
	# ATTENTION: This assumes and REQUIRES that
	# aktive_image_vector structurally/== critcl_variadic_aktive_image
	if {$v} { set n "(aktive_image_vector*) &args" }

	if {$m in {
	    ignore
	}} {
	    lappend ignames $n
	    lappend igtypes {}
	}
	lappend inames $n
    }

    set sig "ip"
    set prefix ", "
    if {[llength $params]}  { append sig ${prefix}&p                   ; set prefix ", " }
    if {[llength $images]}  { append sig ${prefix}[join $inames  ", "] ; set prefix ", " }
    if {[llength $ignames]} {
	foreach i $ignames t $igtypes {
	    if {$t eq {}} continue
	    append sig ${prefix}&$i
	    set prefix ", "
	}
    }

    return ($sig)
}

proc dsl::writer::FunctionBodyImageConstructor {op spec} {
    dict with spec {}
    # notes, images, params, result, rcode, statec, stater, geometry
    unset notes result rcode
    # images, params,                       statec, stater, geometry

    set opspecvar [OperatorSpecVarname $op]

    set call ""

    + "  TRACE_FUNC(\"\", 0);"
    + {}
    + "  static aktive_image_type $opspecvar = \{"
    + "      .name         = \"$op\""
    #        .param_init
    #        .param_finish .
    #        .sz_param
    #        .n_param
    #        .param
    #        .setup
    #        .final
    #        .geo_setup

    if {[llength $params]} {
	append call ", param"
	+ "    , .sz_param     = sizeof ([ParamStructTypename $op])"
	+ "    , .n_param      = [llength $params]"
	+ "    , .param        = [ParamDescriptorVarname $op]"
	if {[OpParamFIHooks $op]} {
	    + "    , .param_init   = (aktive_param_init)   [ParamInitFuncname   $op]"
	    + "    , .param_finish = (aktive_param_finish) [ParamFinishFuncname $op]"
	}
    } else {
	+ "    , .sz_param   = 0"
	append call ", NULL"	;# No parameters
    }

    if {${state/setup}   ne {}} { + "    , .setup        = (aktive_image_setup)      [StateSetupFuncname $op]" }
    if {${state/cleanup} ne {}} { + "    , .final        = (aktive_image_final)      [StateFinalFuncname $op]" }

    + "    , .region_fetch = (aktive_region_fetch)     [RegionFetchFuncname $op]"

    if {${region/setup}   ne {}} { + "    , .region_setup = (aktive_region_setup)     [RegionSetupFuncname $op]" }
    if {${region/cleanup} ne {}} { + "    , .region_final = (aktive_region_final)     [RegionFinalFuncname $op]" }

    + "  \};"
    + {}

    if {[llength $images]} {
	# case 1: fixed arity
	# case 2: infinite arity
	# case 3: fixed prefix, infinite suffix - not supported
	##
	# 1: create fixed structure on stack to images
	# 2: pass the argument as is
	# 3: not supported!

	if {([llength $images] == 1) && [dict get [lindex $images 0] args]} {
	    # case 2
	    append call ", srcs"
	} else {
	    # case 1
	    set arity [llength $images]
	    if {$arity > 1} {
		+ "  aktive_image srci\[$arity] = \{"
		set id 0
		set prefix "  "
		foreach i $images {
		    set n src$id ; incr id
		    set ni [dict get $i name]
		    if {$ni ne {}} { set n $ni }
		    + "    $prefix$n" ; set prefix ", "
		}
		+ "  \};"
		set ref srci
	    } else {
		set n src
		set ni [dict get [lindex $images 0] name]
		if {$ni ne {}} { set n $ni }
		set ref &$n
	    }
	    + "  aktive_image_vector srcs = \{"
	    + "      .c = $arity"
	    + "    , .v = $ref"
	    + "  \};"
	    + {}
	    append call ", &srcs"
	}
    } else {
	append call ", NOSRCS"	;# No input images.
    }

    + "  aktive_image r = aktive_image_new (&$opspecvar$call);"
    + "  TRACE_RETURN (\"(aktive_image) %p\", r);"
    return [join $lines \n]
}


proc dsl::writer::OperatorOverlays {} {
    if {![llength [COperations]]} return

    set ops [lmap op [COperations] {
	if {![OpMakeWrapper $op]} continue
	set op
    }]
    if {![llength $ops]} return

    TclHeader {Overlay commands, per operator}

    foreach op $ops {
	+ [OperatorOverlaysForOp $op]
    }

    Done
}

proc dsl::writer::OperatorOverlaysForOp {op} {
    set spec [Get ops $op]
    dict with spec {}
    # notes, images, params, result, overlays

    TclComment "--- --- --- --- --- --- --- --- ---"
    TclComment "Operator `$op` ..."
    foreach n $notes { TclComment "Note: [join $n { }]" }
    + {}

    + "proc aktive::$op \{[ProcArguments $spec]\} \{"
    ProcArgumentSetup $spec

    # translate the overlays
    lappend hmap {for }     "for   "
    lappend hmap { returns} "\treturns"
    foreach hint $overlays {
        TclComment "- [string map $hmap $hint]" {    }
    }
    foreach hint [dict get $spec overlays] {
	#::puts ////////////////////////////////////////////////
	+ "    ::aktive simplify do [TranslateHint {*}$hint]"
    }

    + "    I[namespace tail $op] [ProcCallWords $spec]"
    + "\}"

    + {}
    Done
}

proc dsl::writer::TranslateHint {cmd args} {
    #::puts [info level 0]
    upvar 1 op op
    switch -exact -- $cmd {
	for      -
	returns  { return "\t[TranslateHint {*}$args]" }
	src/type {
	    set action [lassign $args type]
	    if {$type eq "@self"} { set type $op }
	    return "src/type $type [TranslateHint {*}$action]"
	}
	param {
	    set action [lassign $args name relation value]
	    set relation [dict get {
		== eq != ne
		<  lt <= le
		>  gt >= ge
	    } $relation]
	    return "param/$relation $name $value [TranslateHint {*}$action]"
	}
	if {
	    set action [lassign $args expr]
	    return "iff [list $expr] [TranslateHint {*}$action]"
	}
	src/const {
	    set action [lassign $args value]
	    return "src/type image::from::value src/const $value [TranslateHint {*}$action]"
	}
	constant {
	    set params [lassign $args tclfunc]
	    set arity  [llength $params]
	    return "src/type image::from::value /fold/constant/$arity $tclfunc $params"
	}
	src/pop   { return "$cmd [TranslateHint {*}$args]" }
	src/attr  -
	src/value {
	    set action [lassign $args a b]
	    return "$cmd $a $b [TranslateHint {*}$action]"
	}
	input/count {
	    set action [lassign $args var]
	    return "$cmd $var [TranslateHint {*}$action]"
	}
	calc {
	    set action [lassign $args var expr]
	    return "calc $var [list $expr] [TranslateHint {*}$action]"
	}
	src       -
	src/child -
	op        -
	constv    -
	const     { return [string trimright "/$cmd $args"] }
    }
    return -code error "Unknown simplifier command (($cmd) $args)"
}

proc dsl::writer::ProcArgumentSetup {spec} {
    upvar 1 lines lines

    dict with spec {}
    # notes, images, params, result

    if {![llength $params]} return

    set all [concat {*}[lmap argspec $params {
	set n [dict get $argspec name]
	set a [dict get $argspec args]
	list $n $a
    }]]
    + ""
    + "    # ___ begin generated glue code ___ ___ ___"
    + "    ::aktive parameter validate         $all"

    set required [lmap argspec $params {
	if {[dict exists $argspec default]} continue
	dict get $argspec name
    }]

    if {[llength $required]} {
	+ "    ::aktive parameter collect required $required"
    }

    set optional [lmap argspec $params {
	if {![dict exists $argspec default]} continue
	set n [dict get $argspec name]
	set d [dict get $argspec default]

	if {$d in $required} { set d \$$d }
	+ "    set $n $d"
	set n
    }]

    if {[llength $optional]} {
	+ "    ::aktive parameter collect optional $optional"
    }

    + "    # ___ end generated glue code _ ___ ___ ___"
    + ""
}

proc dsl::writer::ProcArguments {spec} {
    dict with spec {}
    # notes, images, params, result

    set names [ProcImageArguments $spec]

    if {[llength $params]} { lappend names args }

    join $names { }
}

proc dsl::writer::ProcCallWords {spec} {
    dict with spec {}
    # notes, images, params, result

    set cw {}
    foreach argspec $params {
	set n [dict get $argspec name]
	set a [dict get $argspec args]
	set n \$$n
	if {$a} {  set n "{*}$n" }
	lappend cw $n
    }

    lappend cw {*}[ProcImageCall $spec]

    join $cw { }
}

proc dsl::writer::ProcImageArguments {spec} {
    dict with spec {}
    # notes, images, params, result

    set names {}

    set single [expr {[llength $images] == 1}]

    set id 0
    foreach i $images {
	set n src$id ; incr id
	if {$single} { set n src }
	set ni [dict get $i name]
	if {$ni ne {}} { set n $ni }
	set v [dict get $i args]
	if {$v} { set n args }

	lappend names $n
    }

    return $names
}

proc dsl::writer::ProcImageCall {spec} {
    dict with spec {}
    # notes, images, params, result

    set refs {}
    set single [expr {[llength $images] == 1}]

    set id 0
    foreach i $images {
	set n src$id ; incr id
	if {$single} { set n src }
	set ni [dict get $i name]
	if {$ni ne {}} { set n $ni }
	set v [dict get $i args]
	if {$v} {
	    set n "\{*\}\$args"
	} else {
	    set n "\$$n"
	}
	lappend refs $n
    }

    return $refs
}

proc dsl::writer::OperatorWrapRecord {} {
    if {![llength [Operations]]} return

    set ops [lmap op [Operations] {
	if {![OpHasOverlays $op]} continue
	set op
    }]
    if {![llength $ops]} return

    set ol [Maxlength $ops]

    foreach op $ops {
	set spec [Get ops $op]
	set overlays [lsort -dict [dict get $spec overlays]]
	foreach hint $overlays {
	    + "::aktive::$op[TranslateHint {*}$hint]"
	}
    }

    Done
}

proc dsl::writer::OperatorTclProcs {} {
    if {![llength [TclOperations]]} return

    TclHeader {Operators purely implemented in Tcl}

    foreach op [TclOperations] {
	set spec [Get ops $op]
	# params, body

	TclComment "--- --- --- --- --- --- --- --- ---"
	TclComment "Operator `$op` ..."

	+ {}
	+ "proc aktive::$op \{[ProcArguments $spec]\} \{"
	ProcArgumentSetup $spec
	if {[OpHasOverlays $op]} {
	    foreach hint [dict get $spec overlays] {
		+ "    ::aktive simplify do [TranslateHint {*}$hint]"
	    }
	}
	+ [FormatCode [dict get $spec body] {    }]
	+ "\}"
	+ {}
    }

    Done
}

proc dsl::writer::OperatorEnsemble {} {
    if {![llength [Operations]]} return

    foreach op [Operations] { dict set n {*}[string map {:: { }} aktive::$op] . }

    TclHeader {Ensemble setup}

    + [Dump $n ""]
    + {}

    Done
}

proc dsl::writer::Dump {dict indent} {
    set keys [lsort -dict [dict keys $dict]]
    foreach k $keys {
	set v [dict get $dict $k]
	if {$v eq "."} {
	    + "${indent}namespace export $k"
	    continue
	}
	+ "${indent}namespace eval $k \{"
	+ [Dump $v "    $indent"]
	+ "${indent}    namespace ensemble create"
	+ "${indent}\}"
	+ "${indent}namespace export $k"
    }

    Done
}

# # ## ### ##### ######## #############
## Group specific support

proc dsl::writer::Vectors {} {
    # Exclude imported vector types from code generation.
    if {![Has vcached]} {
	set vs {}
	dict for {v imported} [Get vectors] {
	    if {$imported} continue
	    lappend vs $v
	}
	Set vcached [lsort -dict $vs]
    }
    return [Get vcached]
}

proc dsl::writer::ParameterIsVariadic {argspec} { dict get $argspec args }
proc dsl::writer::ParameterType       {argspec} { dict get $argspec type }
proc dsl::writer::ParameterCType      {argspec} {
    # type-ctype! type-vector

    set typeid   [dict get $argspec type]
    set typespec [Get types $typeid]

    dict with typespec {}
    # imported critcl ctype conversion init finish

    if {[dict get $argspec args]} {
	if {![string match aktive_* $critcl]} { set critcl aktive_$critcl }
	set ctype ${critcl}_vector
    }
    return $ctype
}

proc dsl::writer::ParameterHooked {argspec iv fv} {
    upvar 1 $iv in $fv fin

    set typeid   [dict get $argspec type]
    set typespec [Get types $typeid]

    dict with typespec {}
    # imported critcl ctype conversion init finish

    if {$init   eq {}} { return 0 }
    if {$finish eq {}} { return 0 }

    set in  $init
    set fin $finish
    return 1
}

proc dsl::writer::Operations {}   { lsort -dict [dict keys [Get ops]] }

proc dsl::writer::COperations {}   {
    lmap op [Operations] {
	if {[Get ops $op lang] ne "C"} continue
	set op
    }
}

proc dsl::writer::TclOperations {}   {
    lmap op [Operations] {
	if {[Get ops $op lang] ne "Tcl"} continue
	set op
    }
}

proc dsl::writer::OpMakeWrapper {op} {
    if {[OpHasOverlays $op]} { return 1 }
    # no overlays
    if {[OpHasParams $op] && [OpHasImages $op]} { return 1 }
    # no params or no images
    if {[Get ops $op result] eq "image"} { return 1 }
    # no params or no images, non-image result
    return 0
}

proc dsl::writer::OpHasImages   {op} { llength [OpImages $op] }
proc dsl::writer::OpImages      {op} { Get ops $op images }
proc dsl::writer::OpHasParams   {op} { llength [OpParams $op] }
proc dsl::writer::OpParams      {op} { Get ops $op params }
proc dsl::writer::OpHasOverlays {op} { llength [OpOverlays $op] }
proc dsl::writer::OpOverlays    {op} { Get ops $op overlays }

proc dsl::writer::OpParamVariadic {op} {
    foreach argspec [Get ops $op params] {
	if {[dict get $argspec args]} { return 1 }
    }
    return 0
}

proc dsl::writer::OpParamOptional {op} {
    foreach argspec [Get ops $op params] {
	if {[dict exists $argspec default]} { return 1 }
    }
    return 0
}

proc dsl::writer::OpParamFIHooks {op} {
    if {[OpParamVariadic $op]} { return 1 }

    foreach argspec [Get ops $op params] {
	set typeid [dict get $argspec type]
	set typespec [Get types $typeid]
	set i [dict get $typespec init]
	set f [dict get $typespec finish]

	if {($i ne {}) && ($f ne {})} { return 1 }
    }
    return 0
}

proc dsl::writer::Types {} {
    # Exclude imported types from code generation.
    if {![Has tcached]} {
	set ts {}
	dict for {t spec} [Get types] {
	    if {[dict get $spec imported]} continue
	    lappend ts $t
	}
	Set tcached [lsort -dict $ts]
    }
    return [Get tcached]
    #return [lsort -dict [dict keys [Get types]]]
}

# type: 0/critt 1/ctype 2/conv
proc dsl::writer::TypeCritcl {t} { Get types $t critcl     }
proc dsl::writer::TypeCType  {t} { Get types $t ctype      }
proc dsl::writer::TypeConv   {t} { Get types $t conversion }
proc dsl::writer::TypeVector {t} { ;# note similarities to ParameterCType
    set typespec [Get types $t]
    dict with typespec {}
    # imported critcl ctype conversion
    if {![string match aktive_* $critcl]} { set ctype aktive_$critcl }
    return ${ctype}_vector
}

# # ## ### ##### ######## #############
## State access

proc dsl::writer::Set {args} {
    variable state
    set keypath [lreverse [lassign [lreverse $args] value]]
    dict set state {*}$keypath $value
}

proc dsl::writer::Get {args} {
    variable state
    return [dict get $state {*}$args]
}

proc dsl::writer::Has {args} {
    variable state
    dict exists $state {*}$args
}

# # ## ### ##### ######## #############
## (Base) names for Structures, Variables, Functions, ...

proc dsl::writer::TypeValueFunc    {t} { return "aktive_t_[Cname $t]_value" }
proc dsl::writer::TypeVecValueFunc {t} { return "aktive_t_[Cname $t]_vec_value" }

proc dsl::writer::StateStructTypename    {op} { return "aktive_[Cname $op]_state"        }
proc dsl::writer::ParamStructTypename    {op} { return "aktive_[Cname $op]_param"        }
proc dsl::writer::ParamDescriptorVarname {op} { return "aktive_[Cname $op]_descriptor"   }
proc dsl::writer::ParamInitFuncname      {op} { return "aktive_[Cname $op]_param_init"   }
proc dsl::writer::ParamFinishFuncname    {op} { return "aktive_[Cname $op]_param_finish" }
proc dsl::writer::OperatorSpecVarname    {op} { return "aktive_[Cname $op]_opspec"       }

proc dsl::writer::RegionStateTypename    {op} { return "aktive_[Cname $op]_region_state" }
proc dsl::writer::RegionFetchFuncname    {op} { return "aktive_[Cname $op]_region_fetch" }
proc dsl::writer::RegionSetupFuncname    {op} { return "aktive_[Cname $op]_region_setup" }
proc dsl::writer::RegionFinalFuncname    {op} { return "aktive_[Cname $op]_region_final" }

proc dsl::writer::StateSetupFuncname     {op} { return "aktive_[Cname $op]_setup"        }
proc dsl::writer::StateFinalFuncname     {op} { return "aktive_[Cname $op]_final"        }

# # ## ### ##### ######## #############
## General emitter support

proc dsl::writer::Into {destination args} {
    if {[file rootname [file tail $destination]] eq ""} {
	return -code error "Bad destination, no file name, just extension or nothing"
    }

    set text [{*}$args]
    if {$text eq {}} return

    puts "Writing [blue $destination]"
    file mkdir [file dirname $destination]
    set    chan [open $destination w]
    ::puts $chan $text
    close  $chan
    return
}

proc dsl::writer::Maxlength {words} {
    return [lindex [lsort -integer [lmap w $words { string length $w }]] end]
}

proc dsl::writer::PadR  {n w}  { return [format %-${n}s $w] }
proc dsl::writer::PadL  {n w}  { return [format %${n}s  $w] }
proc dsl::writer::Cname {name} { return [string map {* _ :: _ - _ / _} $name] }

proc dsl::writer::+           {x} { upvar 1 lines lines ; lappend lines $x      ; return }
proc dsl::writer::Comment     {x {indent {}}} { upvar 1 lines lines ; lappend lines "$indent// $x" ; return }
proc dsl::writer::TclComment  {x {indent {}}} { upvar 1 lines lines ; lappend lines "$indent# $x"  ; return }
proc dsl::writer::Done        {}  { upvar 1 lines lines ; return -code return [join $lines \n] }

proc dsl::writer::CHeader {text} {
    global tcl_platform
    upvar 1 lines lines
    Comment {-*- c -*-}
    Comment "-- $text"
    Comment {}
    Comment "Generated [clock format [clock seconds]] -- $tcl_platform(user)@[info hostname]"
    + {}
}

proc dsl::writer::TclHeader {text} {
    global tcl_platform
    upvar 1 lines lines
    TclComment {-*- tcl -*-}
    TclComment "-- $text"
    TclComment {}
    TclComment "Generated [clock format [clock seconds]] -- $tcl_platform(user)@[info hostname]"
    + {}
}

# # ## ### ##### ######## #############
## Stash of tclscript to run when the package
## is available.

proc dsl::writer::stash-to {path} {
    variable stash

    lappend s "#!/usr/bin/env/tclsh"
    lappend s "package require aktive"
    lappend s "package require fileutil"
    lappend s [Cat esupport.tcl]
    lappend s ""
    lappend s [join $stash \n\n]
    lappend s ""
    lappend s exit

    fileutil::writeFile $path [join $s \n]
}

proc dsl::writer::Stash {script} {
    variable stash
    lappend  stash $script
}

proc dsl::writer::Cat {path} {
    variable here
    set c [open [file join $here $path] r]
    set d [read $c]
    close  $c
    return $d
}

# # ## ### ##### ######## #############
## Messaging

proc dsl::writer::red {message} {
    string cat \033\[31m$message\033\[0m
}

proc dsl::writer::blue {message} {
    return \033\[34m$message\033\[0m
}

proc dsl::writer::puts {message} {
    #variable importing
    set indent "" ;#"[string repeat {  } $importing]"

    ::puts "  - $indent$message"
}

# # ## ### ##### ######## #############
return
