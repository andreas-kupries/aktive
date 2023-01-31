# -*- mode: tcl ; fill-column: 90 -*-

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
    Into ${stem}param-defines.h       ParamDefines       ;# defines - enum
    Into ${stem}param-names.c         ParamNames         ;# variable
    Into ${stem}param-descriptions.c  ParamDescriptions  ;# variable
    Into ${stem}param-types.h         ParamTypes         ;# typedefs
    Into ${stem}param-descriptors.c   ParamDescriptors   ;# variables
    #		       
    Into ${stem}vector-types.h        VectorTypes        ;# typedefs
    Into ${stem}vector-funcs.h        VectorSignatures   ;# signatures
    Into ${stem}vector-funcs.c        VectorFunctions    ;# implementations
    #		       
    Into ${stem}type-defines.h        TypeDefines        ;# defines - enum
    Into ${stem}type-funcs.h          TypeSignatures     ;# signatures
    Into ${stem}type-funcs.c          TypeFunctions      ;# implementations
    Into ${stem}type-descriptor.c     TypeDescriptor     ;# variable
    #		       
    Into ${stem}param-funcs.h         ParamSignatures    ;# signatures
    Into ${stem}param-funcs.c         ParamFunctions     ;# implementations
    #		       
    Into ${stem}op-funcs.h            OperatorSignatures ;# signatures
    Into ${stem}op-funcs.c            OperatorFunctions  ;# implementations
    #		       
    Into ${stem}glue.tcl              OperatorCprocs     ;# Tcl commands
    Into ${stem}ensemble.tcl          OperatorEnsemble   ;# Command ensemble
    return
}

# # ## ### ##### ######## #############
## Main emitter commands -- Parameters

proc dsl::writer::ParamDefines {} {    
    set num   [llength [Parameters]]
    set width [string length $num]
    set names [lmap p [Parameters] { string cat aktive_p_$p }]
    set nl    [Maxlength $names]

    Comment {-*- c -*-}
    Comment {Defines for parameter symbols}
    + {}

    foreach p [Parameters] n $names {
	+ "#define [PadR $nl $n] ([PadL $width [ParameterId $p]])"
    }

    + {}
    Done
}

proc dsl::writer::ParamNames {} {
    set num   [llength [Parameters]]
    set width [string length $num]

    Comment {-*- c -*-}
    Comment {Tables of parameter names}
    + {}
    + "const char* aktive_param_name\[$num\] = {"

    set prefix "  "
    foreach p [Parameters] {
	+ "  /* [PadL $width [ParameterId $p]] */ $prefix\"$p\""
	set prefix ", "
    }

    + "};"
    Done
}

proc dsl::writer::ParamDescriptions {} {
    set num   [llength [Descriptions]]
    set width [string length $num]

    Comment {-*- c -*-}
    Comment {Table of parameter descriptions}
    + {}
    + "const char* aktive_param_desc\[$num\] = {"

    set prefix "  "
    foreach d [Descriptions] {
	+ "  /* [PadL $width [DescriptionId $d]] */ $prefix\"$d\""
	set prefix ", "
    }

    + "};"
    Done
}

proc dsl::writer::ParamTypes {} {
    Comment {-*- c -*-}
    Comment {Parameter block types}
    + {}
    
    foreach op [Operations] {
	if {![OpHasParams $op]} continue
	+ [ParamTypeForOp $op]
    }
    
    Done
}

proc dsl::writer::ParamTypeForOp {op} {
    # collect information needed for generation
    set sname [ParamStructTypename $op]

    set names  [lmap argspec [OpParams $op] { ParameterText   [dict get $argspec name] }]
    set descs  [lmap argspec [OpParams $op] { DescriptionText [dict get $argspec help] }]
    set ctypes [lmap argspec [OpParams $op] { ParameterCType  $argspec }]

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
    Comment {-*- c -*-}
    Comment {Parameter block descriptors}
    + {}
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
    set sname   [ParamStructTypename $op]
    set nparams [llength [OpParams $op]]

    set namex [lmap argspec [OpParams $op] { ParameterText [dict get $argspec name] }]
    set names [lmap name    $namex         { string cat aktive_p_$name }]
    set descs [lmap argspec [OpParams $op] { dict get $argspec help }]
    set types [lmap argspec [OpParams $op] {
	set type [Cname [ParameterType $argspec]]
	if {[ParameterIsVariadic $argspec]} { append type _vec }
	string cat aktive_t_$type
    }]
    
    + "/* `$op` - - -- --- ----- -------- ------------- */"
    + "static aktive_image_parameter $dname\[$nparams\] = \{"

    set nl [Maxlength $names]
    set xl [Maxlength $namex]
    set dl [Maxlength $descs]
    set tl [Maxlength $types]
    
    set prefix "  "
    foreach n $names d $descs t $types x $namex {
	set n [PadR $nl $n]
	set d [PadR $dl $d]
	set t [PadR $tl $t]
	set x [PadR $xl $x]
	set o "offsetof ($sname, $x)"
	
	+ "  ${prefix}\{ $n, $d, $t, $o \}"
	set prefix ", "
    }
    + "\};"
    + {}
    
    Done
}

# Declarations of Init/Finish functions for operations with a variadic parameter
proc dsl::writer::ParamSignatures {} {

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
    
    Comment {-*- c -*-}
    Comment {Parameter block init/finish declarations}
    + {}

    foreach n $names t $types {
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	+ "static void $n ($t* p);"
    }
    
    + {}
    Done
}

# Implementation of Init/Finish functions for operations with a variadic parameter
proc dsl::writer::ParamFunctions {} {
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
	    set n [ParameterText [dict get $argspec name]]
	    
	    lappend heap "${t}_heapify (&p->$n);"
	    lappend free "${t}_free (&p->$n);"
	}
	lappend codes $heap $free
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]
    
    Comment {-*- c -*-}
    Comment {Parameter block init/finish functions}
    + {}

    foreach n $names t $types code $codes {
	+ "static void $n ($t* p) \{"
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
    Comment {-*- c -*-}
    Comment {Structures for types used in variadics}
    + {}
    
    foreach type [Vectors] {
	lassign [Get types $type] ct t
	set tx  [TypeVector $type]

	set n [Maxlength [list int *$ct]]

	Comment "--- --- --- --- --- --- --- --- ---\n * Vector `$type` ...\n"
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
    set names {}
    set types {}
    
    foreach t [Vectors] {
	set tx [TypeVector $t]

	# Note: Match param-func-* // Callers
	
	lappend names ${tx}_heapify
	lappend names ${tx}_free
	lappend names {}
	lappend types $tx
	lappend types $tx
	lappend types {}
    }
    
    set nl [Maxlength $names]
    set tl [Maxlength $types]

    Comment {-*- c -*-}
    Comment {Vector utility functions for types used in variadics}
    + {}

    foreach n $names t $types {
	if {$n eq {}} { + {} ; continue }
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	+ "static void $n (${t}* vec);"
    }

    + {}
    Done
}

proc dsl::writer::VectorFunctions {} {
    set names {}
    set types {}
    set codes {}
    
    foreach t [Vectors] {
	set tx [TypeVector $t]
	set ct [TypeCritcl $t]
	
	lappend names ${tx}_heapify
	lappend names ${tx}_free
	lappend names {}
	lappend types $tx
	lappend types $tx
	lappend types {}
	lappend codes "vec->v = memcpy (NALLOC ($ct, vec->c), vec->v, vec->c * sizeof($ct));"
	lappend codes "ckfree ((char*) vec->v);"
	lappend codes {}
    }
    
    set nl [Maxlength $names]
    set tl [Maxlength $types]
    set cl [Maxlength $codes]
    
    Comment {-*- c -*-}
    Comment {Vector utility functions for types used in variadics}
    + {}

    foreach n $names t $types c $codes {
	if {$n eq {}} { + {} ; continue }
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	set c [PadR $cl $c]
	+ "static void $n (${t}* vec) \{ $c \}"
    }

    + {}
    Done
}

# # ## ### ##### ######## #############
## Main emitter commands -- Types

proc dsl::writer::TypeDefines {} {
    set  num   [llength [Types]]
    incr num   [llength [Vectors]]
    set  width [string length $num]

    set types {}
    set ids   {}
    
    set k -1
    foreach t [Types] {
	lappend types aktive_t_[Cname $t]
	lappend ids   [incr k]
    }

    lappend types {}
    lappend ids   {}

    foreach t [Vectors] {
	lappend types aktive_t_[Cname $t]_vec
	lappend ids   [incr k]
    }

    set tl [Maxlength $types]
    set il [Maxlength $ids]

    Comment {-*- c -*-}
    Comment {Defines for type symbols}
    + {}

    foreach t $types k $ids {
	if {$t eq {}} {
	    + {}
	    continue
	}
	+ "#define [PadR $tl $t] ([PadL $il $k])"
    }

    + {}
    Done
}

proc dsl::writer::TypeSignatures {} {
    set names {}
    set types {}
    
    foreach t [Types] {
	lappend names aktive_t_[Cname $t]_value
	lappend types [TypeCType $t]
    }

    lappend names {}
    lappend types {}

    foreach t [Vectors] {
	lappend names aktive_t_[Cname $t]_vec_value
	lappend types [TypeVector $t]
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]
    
    Comment {-*- c -*-}
    Comment {Type conversion declarations }
    + {}

    foreach n $names t $types {
	if {$t eq {}} {
	    + {}
	    continue
	}
	
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	+ "static Tcl_Obj* $n (Tcl_Interp* interp, ${t}* value);"
    }

    + {}
    Done
}

proc dsl::writer::TypeFunctions {} {
    set names {} ; set vnames {}
    set types {} ; set vtypes {}
    set conv  {} ; set vconv  {}
    
    foreach t [Types] {
	lappend names aktive_t_[Cname $t]_value
	lappend types [TypeCType $t]
	lappend conv  [TypeConv $t]
    }

    foreach t [Vectors] {
	lappend vnames aktive_t_[Cname $t]_vec_value
	lappend vtypes [TypeVector $t]
	lappend vconv  "aktive_t_[Cname $t]_value"
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]
    set cl [Maxlength $conv]
    
    Comment {-*- c -*-}
    Comment {Type conversion functions }
    + {}

    foreach n $names t $types c $conv {
	set n [PadR $nl $n]
	set t [PadR $tl $t]
	set c [PadR $cl $c]
	+ "static Tcl_Obj* $n (Tcl_Interp* interp, ${t}* value) \{ return $c; \}"
    }
    + {}
    
    foreach n $vnames t $vtypes c $vconv {
	+ "static Tcl_Obj* $n (Tcl_Interp* interp, ${t}* value) \{"
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

proc dsl::writer::TypeDescriptor {} {
    set names {}
    set ids   {}
    set types {}
    
    set k -1
    foreach t [Types] {
	lappend types $t
	lappend names aktive_t_[Cname $t]_value
	lappend ids [incr k]
    }

    lappend names {}
    lappend ids   {}
    lappend types {}

    set xl [Maxlength [Vectors]]
    
    foreach t [Vectors] {
	lappend types "[PadR $xl "$t"] \[\]"
	lappend names aktive_t_[Cname $t]_vec_value
	lappend ids [incr k]
    }

    set nl [Maxlength $names]
    set tl [Maxlength $types]
    set il [Maxlength $ids]

    Comment {-*- c -*-}
    Comment {Type descriptor}
    + {}

    incr k
    + "static aktive_type_spec aktive_type_descriptor\[$k] = \{"
    set prefix "  "
    foreach n $names t $types k $ids {
	if {$n eq {}} {
	    + {}
	    continue
	}
	
	set k [PadL $il $k]
	set n [PadR $nl $n]
	set t [PadR $tl $t]
    
	+ "  /* ($k) $t */ ${prefix}\{ (aktive_param_value) $n \}"
	set prefix ", "
    }
    + "\};"

    + {}    
    Done
}

# # ## ### ##### ######## #############
## Main emitter commands -- Operators

proc dsl::writer::OperatorSignatures {} {
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
    
    Comment {-*- c -*-}
    Comment {Operator function declarations}
    + {}

    foreach n $names s $sigs r $results {
	set n [PadR $nl $n]
	set s [PadR $sl $s]
	set r [PadR $rl $r]
	+ "static $r $n $s;"
    }

    + {}
    Done
}

proc dsl::writer::OperatorFunctions {} {
    Comment {-*- c -*-}
    Comment {operator function implementations}
    + {}

    foreach op [Operations] {
	+ [OperatorFunctionForOp $op]
    }

    Done
}

proc dsl::writer::OperatorFunctionForOp {op} {
    set spec [Get ops $op]
	
    dict with spec {}
    # notes, images, params, result
    unset notes images params
    ##                       result

    if {$result ne "void"} {
	set result [CprocResultC $spec]
    }

    set n   [FunctionName $op $spec]
    set sig [FunctionDeclSignature $op $spec]
    
    Comment "- - -- --- ----- -------- ------------- ---------------------\n * Operator \"$op\" ...\n"
    + {}

    if {$result ne "aktive_image" ||
	[FunctionIgnoresImages $spec]} {
	# Main implementation and pixel filler need manual writing

	if {$result eq "aktive_image"} {
	    + [Placeholder ${op}-fill {}]
	    + {}
	}

	+ "static $result $n $sig \{"
	+ [Placeholder $op]
	+ "\}"
	+ {}
    } else {
	# Pixel fill function needs manual writing
	
	+ "static void"
	+ "[OperatorFillFuncname $op] (aktive_region region) \{"
	+ [Placeholder ${op}-fill]
	+ "\}"
	+ {}

	# Main function can be generated, and refers to pixel fill function
	
	+ "static $result $n $sig \{"
	+ [FunctionBodyImageConstructor $op $spec]
	+ "\}"
	+ {}
    }
    
    Done
}

proc dsl::writer::Placeholder {key {prefix {  }}} {
    + "${prefix}/* -- BEGIN PLACEHOLDER $key -- */"
    # TODO: query for pre-existing code. insert if present
    + "${prefix}/* -- END   PLACEHOLDER $key -- */"

    return [join $lines \n]
}

proc dsl::writer::OperatorCprocs {} {
    TclComment {-*- tcl -*-}
    TclComment {Glue commands, per operator}
    + {}

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
        
    TclComment "--- --- --- --- --- --- --- --- ---\n# Operator `$op` ..."
    foreach n $notes { TclComment "Note: $n" }
    + {}

    + "critcl::cproc aktive::$op \{"
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
	    + "  [CprocResultC $spec] r = [FunctionCall $op $spec];"
	}]
	+ "  return r;"
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
	set n [ParameterText [dict get $argspec name]]
	lassign [Get types   [dict get $argspec type]] ct t
	set v                [dict get $argspec args]
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
	set m [dict get $i rcmode]	
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
    set fields [lmap argspec $params { ParameterText [dict get $argspec name] }]
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

    set single  [expr {[llength $images] == 1}]
    set ignames {}
    set igtypes {}
    
    set id 0
    foreach i $images {
	set m [dict get $i rcmode]	
	set n src$id ; incr id
	if {$single} { set n src }
	set v [dict get $i args]
	if {$v} { set n args }

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
    
    foreach i $ignames t $igtypes {
	set im [string map {_ignored {}} $i] 

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
    unset notes images params
    #                        result

    if {$result eq "void"} { return $result }

    lassign [Get types $result] ct t
    return $ct
}

proc dsl::writer::CprocResultC {spec} {
    dict with spec {}
    # notes, images, params, result
    unset notes images params
    #                        result

    lassign [Get types $result] ct t
    return $t
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
	    set n  args
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

    set sig ""
    set prefix ""
    if {[llength $params]}  {
	append sig "${prefix}[ParamStructTypename $op]* p" ; set prefix ", "
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

    set sig ""
    set prefix ""
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
    # notes, images, params, result
    unset notes result
    # images, params

    set opspecvar [OperatorSpecVarname $op]
    
    set call ""

    + {}
    + "  static aktive_image_type $opspecvar = \{"
    + "      .name     = \"$op\""
    + "    , .fill     = [OperatorFillFuncname $op]"
    #        .init
    #        .finish
    #        .sz_param .

    if {[llength $params]} {
	append call ", p"
	+ "    , .sz_param = sizeof ([ParamStructTypename $op])"
	+ "    , .n_param  = [llength $params]"
	+ "    , .param    = [ParamDescriptorVarname $op]"
	if {[OpParamVariadic $op]} {
	    + "    , .init     = (aktive_image_param_init)   [ParamInitFuncname   $op]"
	    + "    , .finish   = (aktive_image_param_finish) [ParamFinishFuncname $op]"
	}
    } else {
	+ "    , .sz_param = 0"
	append call ", NULL"	;# No parameters
    }
    
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
    
    + "  return aktive_image_new (&$opspecvar$call);"    
    return [join $lines \n]
}

proc dsl::writer::OperatorEnsemble {} {
    foreach op [Operations] {
	set op [string map {:: { }} aktive::$op]
	dict set n {*}$op .
    }
    
    TclComment {-*- tcl -*-}
    TclComment {Glue commands, per operator}

    + {}
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

proc dsl::writer::Vectors {} { lsort -dict -uniq [Get vectors] }

proc dsl::writer::Parameters    {}   { Get pname texts }
proc dsl::writer::ParameterId   {x}  { Get pname text $x }
proc dsl::writer::ParameterText {id} { lindex [Parameters] $id }

proc dsl::writer::ParameterIsVariadic {argspec} { dict get $argspec args }
proc dsl::writer::ParameterType       {argspec} { dict get $argspec type }
proc dsl::writer::ParameterCType      {argspec} {
    # type-ctype! type-vector

    set typeid [dict get $argspec type]
    lassign [Get types $typeid] critt ctype _
    if {[dict get $argspec args]} {
	if {![string match aktive_* $critt]} { set critt aktive_$critt }
	set ctype ${critt}_vector
    }
    return $ctype
}

proc dsl::writer::Descriptions    {}   { Get help texts }
proc dsl::writer::DescriptionId   {x}  { Get help text $x }
proc dsl::writer::DescriptionText {id} { lindex [Descriptions] $id }

proc dsl::writer::Operations  {}   { lsort -dict [dict keys [Get ops]] }
proc dsl::writer::OpHasParams {op} { llength [OpParams $op] }
proc dsl::writer::OpParams    {op} { Get ops $op params }

proc dsl::writer::OpParamVariadic {op} {
    foreach argspec [Get ops $op params] {
	if {[dict get $argspec args]} { return 1 }
    }
    return 0
}

proc dsl::writer::Types {} { lsort -dict [dict keys [Get types]] }

# type: 0/critt 1/ctype 2/conv
proc dsl::writer::TypeCritcl {t} { lindex [Get types $t] 0 }
proc dsl::writer::TypeCType  {t} { lindex [Get types $t] 1 }
proc dsl::writer::TypeConv   {t} { lindex [Get types $t] 2 }
proc dsl::writer::TypeVector {t} {
    lassign [Get types $t] critt ctype conv
    if {![string match aktive_* $critt]} { set ctype aktive_$critt }
    return ${ctype}_vector
}

# # ## ### ##### ######## #############
## State access

proc dsl::writer::Get {args} {
    variable state
    return [dict get $state {*}$args]
}

# # ## ### ##### ######## #############
## (Base) names for Structures, Variables, Functions, ...

proc dsl::writer::ParamStructTypename    {op} { return "aktive_[Cname $op]_param"        }
proc dsl::writer::ParamDescriptorVarname {op} { return "aktive_[Cname $op]_descriptor"   }
proc dsl::writer::ParamInitFuncname      {op} { return "aktive_[Cname $op]_param_init"   }
proc dsl::writer::ParamFinishFuncname    {op} { return "aktive_[Cname $op]_param_finish" }
proc dsl::writer::OperatorSpecVarname    {op} { return "aktive_[Cname $op]_opspec"       }
proc dsl::writer::OperatorFillFuncname   {op} { return "aktive_[Cname $op]_fill"         }

# # ## ### ##### ######## #############
## General emitter support

proc dsl::writer::Into {destination textcmd} {
    puts "  ops generator writing $destination"
    file mkdir [file dirname $destination]
    set    chan [open $destination w]
    puts  $chan [$textcmd]
    close $chan
    return
}

proc dsl::writer::Maxlength {words} {
    return [lindex [lsort -integer [lmap w $words { string length $w }]] end]
}

proc dsl::writer::PadR  {n w}  { return [format %-${n}s $w] }
proc dsl::writer::PadL  {n w}  { return [format %${n}s  $w] }
proc dsl::writer::Cname {name} { return [string map {* _ :: _ - _ / _} $name] }

proc dsl::writer::+           {x} { upvar 1 lines lines ; lappend lines $x         ; return }
proc dsl::writer::Comment     {x} { upvar 1 lines lines ; lappend lines "/* $x */" ; return }
proc dsl::writer::TclComment {x} { upvar 1 lines lines ; lappend lines "# $x"     ; return }
proc dsl::writer::Done        {}  { upvar 1 lines lines ; return -code return [join $lines \n] }

# # ## ### ##### ######## #############
return
