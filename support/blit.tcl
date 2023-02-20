# -*- mode: tcl ; fill-column: 90 -*-
##
# TODO :: optimizations for zero/copy - memset/memcpy -- clear_all, clear
# TODO :: blit specific assertions
# TODO :: loop unroll (depth/z, 1..4 normally expected)
# TODO :: function inline - this is more in the usage
# TODO ::

package require textutil::adjust

namespace eval dsl::blit {
    namespace export gen into
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc dsl::blit::into {destination scans function} {
    set text [gen [file rootname [file tail $destination]] \
		  $scans $function]

    file mkdir [file dirname $destination]
    set    chan [open $destination w]
    ::puts $chan "#line 2 \"[file tail $destination]\""
    ::puts $chan $text
    close  $chan
    return
}

proc dsl::blit::gen {name scans function} {
    # TODO :: Optimizations - memset, memcpy
    ##
    # - ...    ...    full-z zero    -> zero-all-bands   -- memset pixel
    # - ...    full-x zero-all-bands -> zero-all-columns -- memset row
    # - full-y zero-all-columns      -> zero-all-rows    -- memset
    ##
    # - ...    ...    full-z copy    -> copy-all-bands   -- memcpy pixel
    # - ...    full-x copy-all-bands -> copy-all-columns -- memcpy row
    # - full-y copy-all-columns      -> copy-all-rows    -- memcpy

    # TODO :: Assertions ...

    Init
    set axes [Collect $scans]

    EmitAxisSupport $axes

    foreach scan $scans { EmitLoopSetup $scan ; >>> }

    EmitCellAccess $axes
    EmitFunction   $function

    set rscans [lreverse $scans]
    foreach scan $rscans { EmitLoopCompletion $scan }

    EmitCompletion

    # Prepend introduction. Not done at the beginning as it contains information collected
    # during general code emission

    set code [Get]
    EmitIntro $name $scans $function
    + $code
    Done
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitFunction {function} {
    Comment [string trimright "$function"]
    set args [lassign $function cmd]
    F/$cmd {*}$args
    return
}
proc dsl::blit::F/copy {} {
    + "TRACE (\"blit copy %f\", srcvalue);"
    + "*dstvalue = *srcvalue;"
}

proc dsl::blit::F/zero {} {
    + "TRACE (\"blit set zero\", 0);"
    + "*dstvalue = 0;"
}

proc dsl::blit::F/const {v} {
    + "TRACE (\"blit set %f\", $v);"
    + "*dstvalue = $v;"
}

proc dsl::blit::F/apply1 {op args} {
    append call "$op (*srcvalue"
    foreach a $args { append call ", $a" }
    append call ")"

    append fmt "$op (%f"
    foreach a $args { append fmt ", %f" }
    append fmt ")"

    append values "*srcvalue"
    foreach a $args { append values ", $a" }

    + "double result = ${call};"
    + "TRACE (\"blit set %f = $fmt\", result, $values);"
    + "*dstvalue = result;"
}

proc dsl::blit::F/apply2 {op} {
    + "double result = $op (*src0value, *src1value);"
    + "TRACE (\"blit set %f = $op (%f, %f)\", result, *src0value, *src1value);"
    + "*dstvalue = result;"
}

proc dsl::blit::F/complex-apply-reduce {op} {
    + "TRACE (\"blit complexR $op (%f+i*%f)\", srcvalue\[0], srcvalue\[1]);"
    + "double complex srccvalue = CMPLX (srcvalue\[0], srcvalue\[1]);"
    + "*dstvalue                = $op (srccvalue);"
}

proc dsl::blit::F/complex-apply-unary {op} {
    + "TRACE (\"blit complex1 $op (%f+i*%f)\", srcvalue\[0], srcvalue\[1]);"
    + "double complex srccvalue = CMPLX (srcvalue\[0], srcvalue\[1]);"
    + "double complex result    = $op (srccvalue);"
    + "dstvalue\[0]              = creal (result);"
    + "dstvalue\[1]              = cimag (result);"
}

proc dsl::blit::F/complex-apply-binary {op} {
    + "TRACE (\"blit complex2 = $op (%f, %f)\", src0value\[0], src0value\[1], src1value\[0], src1value\[1]);"
    + "double complex src0cvalue = CMPLX (src0value\[0], src0value\[1]);"
    + "double complex src1cvalue = CMPLX (src1value\[0], src1value\[1]);"
    + "double complex result     = $op (src0cvalue, src1cvalue);"
    + "dstvalue\[0]               = creal (result);"
    + "dstvalue\[1]               = cimag (result);"
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitAxisSupport {axes} {
    set sep 0
    foreach k [lsort -dict [dict keys $axes]] {
	set ax [dict get $axes $k]
	EmitAxes $k $ax
    }

    if {!$sep} return
    + {}

    foreach k [lsort -dict [dict keys $axes]] {
	set ax [dict get $axes $k]
	EmitAxeTrace $k $ax
    }

    + {}
}

proc dsl::blit::EmitAxes {k axes} {
    upvar 1 sep sep
    if {[dict exists $axes y]} { + "aktive_uint [F ${k}pitch] = [Pitch $k];"  ; incr sep }
    if {[dict exists $axes x]} { + "aktive_uint [F ${k}stride] = [Stride $k];" ; incr sep }
}

proc dsl::blit::EmitAxeTrace {k axes} {
    set fmt    "blit [T $k] geo"
    set values {}

    set p [string map {dst D src S} $k]

    append fmt " |W %3d |H %3d |D %3d"
    lappend values ${p}W ${p}H ${p}D
    ArgMark ${p}W
    ArgMark ${p}H
    ArgMark ${p}D

    if {[dict exists $axes y]} { append fmt " |P %3d" }
    if {[dict exists $axes x]} { append fmt " |S %3d" }
    if {[dict exists $axes y]} { lappend values ${k}pitch  }
    if {[dict exists $axes x]} { lappend values ${k}stride }

    + "TRACE (\"$fmt\", [join $values {, }]);"
}

proc dsl::blit::EmitCellAccess {axes} {
    # Compute linearized positions
    foreach k [lsort -dict [dict keys $axes]] {
	set ax [dict get $axes $k]
	+ "aktive_uint [F ${k}pos]   = [EmitCellPosition $k $ax];"
    }
    + {}

    # Trace
    foreach k [lsort -dict [dict keys $axes]] {
	set ax [dict get $axes $k]
	+ "TRACE ([EmitCellTrace $k $ax], ${k}pos, [P $k]CAP);"
    }
    + {}

    # Protect against out-of-bounds positions.
    foreach k [lsort -dict [dict keys $axes]] {
	ArgMark [P $k]CAP
	+ "ASSERT_VA ([F ${k}pos] < [F [P $k]CAP], \"$k out of bounds\", \"%d / %d\", ${k}pos, [P $k]CAP)"
    }
    + {}

    # Pointers to dst and source values, if any
    foreach k [lsort -dict [dict keys $axes]] {
	+ "double*      [F ${k}value] = [P $k] + ${k}pos;"
	ArgMark [P $k]
    }

    + {}
    return
}

proc dsl::blit::EmitCellTrace {k axes} {

    set fmt "\"blit [T $k]"
    set sep " | "
    if {[dict exists $axes y]} { append fmt ${sep}%3d } ;# y
    if {[dict exists $axes x]} { append fmt ${sep}%3d } ;# x
    if {[dict exists $axes z]} { append fmt ${sep}%3d } ;# z
    #if {[dict exists $axes y]} { append fmt ${sep}%3d } ;# pitch
    #if {[dict exists $axes x]} { append fmt ${sep}%3d } ;# stride

    if {[dict exists $axes y]} { lappend values ${k}y } ;# y
    if {[dict exists $axes x]} { lappend values ${k}x } ;# x
    if {[dict exists $axes z]} { lappend values ${k}z } ;# z
    #if {[dict exists $axes y]} { lappend values ${k}pitch  } ;# pitch
    #if {[dict exists $axes x]} { lappend values ${k}stride } ;# stride

    append fmt "$sep\[%3d\] < %3d\", "
    #                 ^pos    ^cap

    return $fmt[join $values {, }]
}

proc dsl::blit::EmitCellPosition {k axes} {
    set pos ""
    set sep {}

    if {[dict exists $axes y]} { append pos $sep${k}y*${k}pitch  ; set sep " + " }
    if {[dict exists $axes x]} { append pos $sep${k}x*${k}stride ; set sep " + " }
    if {[dict exists $axes z]} { append pos $sep${k}z }
    return $pos
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitLoopSetup {scan} {
    # scan  :: list (range block...)
    # block :: axis minvalue delta direction
    Comment $scan

    set blocks [lassign $scan range]
    set kinds  [Kinds $blocks]

    if {[IsArg $range]} { ArgMark $range }

    # Range counter, separate from the position trackers
    + "aktive_uint [F range[L]n] = ${range};"
    + "aktive_uint range[L];"

    # Position trackers, one per block in the scan, definition and initialization
    foreach block $blocks kind $kinds {
	lassign $block axis min delta direction
	set var ${kind}${axis}

	+ "aktive_uint [F $var] = [BlockStart $block $range];"
	BlockPhase $block
    }

    # Begin loop
    + {}
    ## + "TRACE (\"(re)start [L]\", 0);"
    + "for (range[L] = 0; range[L] < range[L]n ; range[L] ++) \{"
    return
}

proc dsl::blit::EmitLoopCompletion {scan} {
    set blocks [lassign $scan range]
    set kinds  [Kinds $blocks]

    + {}
    Comment {Step to next position}

    # Position trackers, one per block in the scan, incrementing
    foreach block $blocks kind $kinds {
	lassign $block axis min delta direction
	set var ${kind}${axis}

	+ "[BlockIncrement $var $block]; // $direction"
    }
    ## + "TRACE (\"next [L]\", 0);"

    <<<
    + "\}"
}

proc dsl::blit::BlockStart {block range} {
    lassign $block axis min delta direction

    if {[IsArg $min]} { ArgMark $min }

    switch -exact -- $direction {
	up { return $min }
	down {
	    set start $min
	    if {$min eq "0"} {
		if {$delta eq "1"} {
		    set start ${range}-1
		} else {
		    set start ${range}*${delta}-1
		}
	    } else {
		if {$delta eq "1"} {
		    append start +${range}-1
		} else {
		    append start +${range}*${delta}-1
		}
	    }
	    return $start
	}
    }
}

proc dsl::blit::BlockPhase {block} {
    lassign $block axis min delta direction
    if {![string match 1/* $delta]} return

    + "aktive_uint [F phase[L]] = PHASE[L];"
    + "TRACE (\".... phase[L] start %d\", phase[L]);"

    ArgMark PHASE[L];
}

proc dsl::blit::BlockIncrement {var block} {
    lassign $block axis min delta direction

    set modifier [dict get {
	up   ++
	down --
    } $direction]

    if {$delta eq "1"} {
	return "${var} $modifier"
    }

    if {[string match 1/* $delta]} {
	set delta [string range $delta 2 end]
	<<< ;# ensure proper level for phase variable
	append increment "phase[L]++ ; phase[L] %= ${delta} ; "
	append increment "if (!phase[L]) { TRACE (\".... phase[L] done\", 0); ${var} $modifier ; }"
	>>>
	return $increment
    }

    set    increment $var
    append increment [dict get {
	up   { += }
	down { -= }
    } $direction]
    append increment $delta
    return $increment
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitIntro {name scans function} {
    global tcl_platform

    Comment "Blitter `$name`"
    Comment {}
    Comment "Generated [clock format [clock seconds]] -- $tcl_platform(user)@[info hostname]"

    Comment "Specification:"
    foreach scan $scans { Comment "- scan $scan" }
    Comment "= $function"
    + {}

    set has 0
    foreach p [ArgUsed] {
	+ "#ifndef $p"
	set default [ADefine $p]
	if {$default eq {}} {
	    + "#error \"[ADesc $p] $p expected, not defined\""
	} else {
	    + "#define $p ($default)"
	}
	+ "#endif"
	incr has
    }
    if {!$has} return
    + {}
    return
}

proc dsl::blit::EmitCompletion {} {
    + {}
    foreach p [ArgUsed] { + "#undef $p" }
    return
}

# # ## ### ##### ######## #############

proc dsl::blit::P {kind} { string map {dst DST src SRC} $kind }
proc dsl::blit::F {x}    { format %-10s $x }
proc dsl::blit::T {x}    { format %-4s $x }

proc dsl::blit::Collect {scans} {
    set axes {}
    foreach scan $scans {
	set n 0
	set kind dst
	foreach block [lassign $scan __] {
	    lassign $block axis min delta direction
	    dict set axes $kind $axis .
	    set kind src$n
	    incr n
	}
    }

    if {$n == 2} {
	dict set axes src [dict get $axes src0]
	dict unset axes src0
    }

    return $axes
}

proc dsl::blit::Kinds {blocks} {
    if {[llength $blocks] > 2} {
	# Multiple sources
	set p dst
	set counter 0
	return [lmap __ $blocks { set r $p ; set p src$counter ; incr counter ; set r }]
    } else {
	set p dst
	return [lmap __ $blocks { set r $p ; set p src ; set r }]
    }
}

proc dsl::blit::Pitch {kind} {
    set prefix [string map {dst D src S} $kind]
    ArgMark ${prefix}W
    ArgMark ${prefix}D
    return "${prefix}W*${prefix}D"
}

proc dsl::blit::Stride {kind} {
    set prefix [string map {dst D src S} $kind]
    ArgMark ${prefix}D
    return "${prefix}D"
}

# # ## ### ##### ######## #############

proc dsl::blit::ArgMark {a} { variable arguments ; dict set arguments $a . }
proc dsl::blit::ArgUsed {}  { variable arguments ; lsort -dict [dict keys $arguments] }

proc dsl::blit::IsArg   {a} { dict exists [Arguments] $a }
proc dsl::blit::ADefine {a} { lindex [dict get [Arguments] $a] 0   }
proc dsl::blit::ADesc   {a} { lindex [dict get [Arguments] $a] end }

proc dsl::blit::Arguments {} {
    return {
	AH      {dst->height		{Destination area height}}
	AW      {dst->width		{Destination area width}}
	AX      {dst->x			{Destination area start column}}
	AY      {dst->y			{Destination area start row}}
	DD      {block->domain.depth	{Destination block depth}}
	DH      {block->domain.height	{Destination block height}}
	DST     {block->pixel		{Destination pixel memory}}
	DSTCAP  {block->used		{Destination capacity}}
	DW      {block->domain.width	{Destination block width}}
	PHASE0  {{}                     {Initial phase for fractional stepping}}
	PHASE1  {{}                     {Initial phase for fractional stepping}}
	PHASE2  {{}                     {Initial phase for fractional stepping}}
	S0D     {srca->domain.depth	{Source 1 depth}}
	S0H     {srca->domain.height	{Source 1 height}}
	S0W     {srca->domain.width     {Source 1 width}}
	S1D     {srcb->domain.depth	{Source 2 depth}}
	S1H     {srcb->domain.height	{Source 2 height}}
	S1W     {srcb->domain.width     {Source 2 width}}
	SD      {src->domain.depth	{Source block depth}}
	SH      {src->domain.height	{Source block height}}
	SRC     {src->pixel		{Source pixel memory}}
	SRC0    {srca->pixel		{Source 1 pixel memory}}
	SRC0CAP {srca->used		{Source 1 capacity}}
	SRC1    {srcb->pixel		{Source 2 pixel memory}}
	SRC1CAP {srcb->used		{Source 2 capacity}}
	SRCCAP  {src->used		{Source capacity}}
	SW      {src->domain.width      {Source block width}}
    }
}

# # ## ### ##### ######## #############

proc dsl::blit::Comment    {x {indent {}}} {
    + [string trimright "$indent// $x"]
}

# # ## ### ##### ######## #############

proc dsl::blit::Init {} {
    variable lines     {}
    variable level     0
    variable arguments {}
}

proc dsl::blit::C   {} { variable level 0 }
proc dsl::blit::>>> {} { variable level ; incr level }
proc dsl::blit::<<< {} { variable level ; incr level -1 }
proc dsl::blit::L   {} { variable level ; return $level }
proc dsl::blit::I   {} { string repeat {    } [L] }

proc dsl::blit::Done {} {
    return -code return [Get]
}

proc dsl::blit::Get {} {
    variable lines
    set text [join $lines \n]
    set lines {}
    return $text
}

proc dsl::blit::+ {x} {
    variable lines
    lappend  lines [I]$x
    return
}

# # ## ### ##### ######## #############
return
