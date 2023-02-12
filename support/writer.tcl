# -*- mode: tcl ; fill-column: 90 -*-

package require textutil::adjust

namespace eval dsl::writer {
    namespace export do
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc dsl::writer::do {stem specification} {
    variable state $specification

    Clear $stem
    Emit  $stem
    return
}

# # ## ### ##### ######## #############

proc dsl::writer::Clear {stem} {
    file delete -- [glob -nocomplain ${stem}*]
    return
}

proc dsl::writer::Emit {stem} {
    Into ${stem}operators.txt         Operators          ;# List of operators
    #
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
    Into ${stem}op-funcs.h            OperatorSignatures ;# signatures
    Into ${stem}op-funcs.c            OperatorFunctions  ;# implementations
    #
    Into ${stem}glue.tcl              OperatorCprocs     ;# Tcl commands
    Into ${stem}overlay.tcl           OperatorOverlays   ;# Constructor wrappers
    Into ${stem}wraplist.txt          OperatorWrapRecord ;# List of wrap elements
    Into ${stem}ensemble.tcl          OperatorEnsemble   ;# Command ensemble
    return
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
	if {![OpParamVariadic $op]} continue

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
	if {![OpParamVariadic $op]} continue

	lappend names [ParamInitFuncname   $op]
	lappend names [ParamFinishFuncname $op]
	lappend types [ParamStructTypename $op]
	lappend types [ParamStructTypename $op]

	lassign {{} {}} heap free
	foreach argspec [OpParams $op] {
	    if {![ParameterIsVariadic $argspec]} continue

	    # Note: Match vector-func-* // Callee

	    set t [ParameterCType $argspec]
	    set n [dict get $argspec name]

	    lappend heap "${t}_heapify (&p->$n);"
	    lappend free "${t}_free (&p->$n);"
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

    foreach type [Vectors] {
	set ct [TypeCritcl $type]
	set t  [TypeCType  $type]
	set tx [TypeVector $type]

	set n [Maxlength [list int *$ct]]

	Comment "--- --- --- --- --- --- --- --- ---"
	Comment "Vector `$type` ..."
	+ {}
	+ "typedef struct ${tx} \{"
	+ "  [PadR $n    int] c ; /* Number of elements               */"
	+ "  [PadR $n ${ct}*] v ; /* Array of the elements, allocated */"
	+ "\} ${tx};"
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

proc dsl::writer::Operators {} {
    if {![llength [Operations]]} return

    set names [lmap op [Operations] { set op }]
    set nl [Maxlength $names]

    foreach op $names {
	set notes [lindex [dict get [Get ops $op] notes] 0]
	+ "[PadR $nl $op] :: $notes"
    }
    Done
}

proc dsl::writer::OperatorSignatures {} {
    if {![llength [Operations]]} return

    set names   {}
    set sigs    {}
    set results {}

    foreach op [Operations] {
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

proc dsl::writer::OperatorFunctions {} {
    if {![llength [Operations]]} return

    CHeader {operator function implementations}

    foreach op [Operations] {
	+ [OperatorFunctionForOp $op]
    }

    Done
}

proc dsl::writer::OperatorFunctionForOp {op} {
    set spec [Get ops $op]

    dict with spec {}
    # notes, images, params, result, rcode, statec, stater, statef, geometry
    unset notes
    ##       images          result, rcode, statec, stater, statef, geometry

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
	+ "  TRACE_FUNC(\"((aktive_region_info*) %p)\", info);"

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
	+ [FormatCode ${region/setup}]
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
	+ "[StateSetupFuncname $op] (aktive_image_info* info) \{"
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

    if {$result ne "aktive_image" ||
	[FunctionIgnoresImages $spec]} {
	# Main implementation and pixel filler need manual writing

	if {$result eq "aktive_image"} {
	    + [Placeholder ${op}-fetch {}]
	    + {}
	}

	+ "extern $result $fn $sig \{"

	if {$rcode eq {}} {
	    + [Placeholder $op]
	} elseif {$result eq "void"} {
	    # We have a C code fragment implementing the doer
	    + [FormatCode $rcode]
	} else {
	    # We have a C code fragment implementing the getter
	    + [FormatCodeWithReturn $rcode]
	}

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

    if {![regexp return $last]} { set last "return $last" }

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

    foreach op [Operations] {
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
    if {[OpHasOverlays $op]} {
	TclComment {}
	TclComment "Note: This constructor has a Tcl wrapper performing"
	TclComment "Note: construction time peep-hole optimizations"

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
	+ "  return;"
    } else {
	+ [CprocBody $op $spec {
	    + "  [CprocResultC $spec] _r = [FunctionCall $op $spec];"
	}]
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
    lappend defaults {}

    foreach argspec $params {
	set n  [dict get $argspec name]
	set t  [dict get $argspec type]
	set ct [TypeCritcl $t]
	set t  [TypeCType  $t]
	set v  [dict get $argspec args]
	if {$v} { set n args }

	if {[dict exists $argspec default]} {
	    set d [dict get $argspec default]
	} else {
	    set d {}
	}

	lappend names    $n
	lappend ctypes   $ct
	lappend defaults $d
    }

    set single [expr {[llength $images] == 1}]

    set id 0
    foreach i $images {
	set n src$id ; incr id
	if {$single} { set n src }
	set v [dict get $i args]
	if {$v} { set n args }

	lappend names    $n
	lappend ctypes   aktive_image
	lappend defaults {}
    }

    set nl [Maxlength $names]
    set tl [Maxlength $ctypes]

    foreach n $names t $ctypes d $defaults {
	if {$d ne {}} {
	    + "  [PadR $tl $t] \{[PadR $nl $n] $d\}"
	    continue
	}
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
	set n src$id ; incr id
	if {$single} { set n src }
	set v [dict get $i args]
	if {$v} { set n args }

	lappend igvariadic $v

	if {$m in {
	    keep-ignore keep-pass-ignore
	}} {
	    lappend ignames ${n}_ignored
	    if {$v} {
		set t aktive_int_vector
	    } else {
		set t int
	    }
	    lappend igtypes $t
	} elseif {$m in {
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
    if {$result eq "void"} { return $result }
    return [TypeCritcl $result]
}

proc dsl::writer::CprocResultC {spec} {
    dict with spec {}
    # notes, images, params, result
    return [TypeCType $result]
}

proc dsl::writer::FunctionIgnoresImages {spec} {
    dict with spec {}
    # notes, images, params, result
    unset notes params result

    foreach i $images {
	set m [dict get $i rcmode]
	if {$m in {
	    keep-ignore keep-pass-ignore
	}} {
	    return 1
	} elseif {$m in {
	    ignore
	}} {
	    continue
	}
    }
    return 0
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
	set m [dict get $i rcmode]
	set n src$id ; incr id

	set it aktive_image

	if {$single} { set n src }
	set v [dict get $i args]
	if {$v} {
	    set n  srcs
	    set it aktive_image_vector*
	}

	if {$m in {
	    keep-ignore keep-pass-ignore
	}} {
	    lappend ignames ${n}_ignored
	    if {$v} {
		set t aktive_int_vector
	    } else {
		set t int
	    }
	    lappend igtypes $t
	} elseif {$m in {
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
	set v [dict get $i args]
	# ATTENTION: This assumes and REQUIRES that
	# aktive_image_vector ==structurally critcl_variadic_aktive_image
	if {$v} { set n "(aktive_image_vector*) &args" }

	if {$m in {
	    keep-ignore keep-pass-ignore
	}} {
	    lappend ignames ${n}_ignored
	    lappend igtypes .
	} elseif {$m in {
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
	if {[OpParamVariadic $op]} {
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
	    append call ", args"
	} else {
	    # case 1
	    set arity [llength $images]
	    if {$arity > 1} {
		+ "  aktive_image srci\[$arity] = \{"
		set id 0
		set prefix "  "
		foreach i $images {
		    set n src$id ; incr id
		    + "    $prefix$n" ; set prefix ", "
		}
		+ "  \};"
		set ref srci
	    } else {
		set ref &src
	    }
	    + "  aktive_image_vector srcs = \{"
	    + "      .c = $arity"
	    + "    , .v = $ref"
	    + "  \};"
	    + {}
	    append call ", &srcs"
	}
    } else {
	append call ", NULL"	;# No input images.
    }

    + "  aktive_image r = aktive_image_new (&$opspecvar$call);"
    + "  TRACE_RETURN (\"(aktive_image) %p\", r);"
    return [join $lines \n]
}


proc dsl::writer::OperatorOverlays {} {
    if {![llength [Operations]]} return

    set ops [lmap op [Operations] {
	if {![OpHasOverlays $op]} continue
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

    # translate the overlays
    lappend hmap {for }     "for   "
    lappend hmap { returns} "\treturns"
    foreach hint $overlays {
        TclComment "- [string map $hmap $hint]" {    }
    }
    foreach hint [dict get $spec overlays] {
	#::puts ////////////////////////////////////////////////
	+ "    aktive simplify do [TranslateHint {*}$hint]"
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
	    return "src/type image::constant src/const $value [TranslateHint {*}$action]"
	}
	constant {
	    set params [lassign $args tclfunc]
	    set arity  [llength $params]
	    return "src/type image::constant /fold/constant/$arity $tclfunc $params"
	}
	src/pop   { return "$cmd [TranslateHint {*}$args]" }
	src/attr  -
	src/value {
	    set action [lassign $args a b]
	    return "$cmd $a $b [TranslateHint {*}$action]"
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

proc dsl::writer::ProcArguments {spec} {
    join [ProcArgumentNames $spec] { }
}

proc dsl::writer::ProcCallWords {spec} {
    join [lmap n [ProcArgumentNames $spec] {
	string cat "\$$n"
    }] { }
}

proc dsl::writer::ProcArgumentNames {spec} {
    dict with spec {}
    # notes, images, params, result

    set names {}

    foreach argspec $params {
	lappend names  [dict get $argspec name]
    }

    set single [expr {[llength $images] == 1}]

    set id 0
    foreach i $images {
	set n src$id ; incr id
	if {$single} { set n src }

	set v [dict get $i args]
	if {$v} { set n args }

	lappend names $n
    }
    return $names
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
	    + "SIMPL ::aktive::$op[TranslateHint {*}$hint]"
	}
    }

    Done
}


proc dsl::writer::OperatorEnsemble {} {
    if {![llength [Operations]]} return

    foreach op [Operations] {
	set op [string map {:: { }} aktive::$op]
	dict set n {*}$op .
    }

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
    # imported critcl ctype conversion

    if {[dict get $argspec args]} {
	if {![string match aktive_* $critcl]} { set critcl aktive_$critcl }
	set ctype ${critcl}_vector
    }
    return $ctype
}

proc dsl::writer::Operations    {}   { lsort -dict [dict keys [Get ops]] }
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

proc dsl::writer::Into {destination textcmd} {
    set text [$textcmd]
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
## Messaging

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
