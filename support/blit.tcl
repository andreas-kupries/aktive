# -*- mode: tcl ; fill-column: 90 -*-
##
# TODO :: optimizations for zero/copy - memset/memcpy -- clear_all, clear
# TODO :: blit specific assertions
# TODO :: loop unroll (depth/z, 1..4 normally expected)
# TODO :: function inline - this is more in the usage
# TODO ::

#
# loop nest specification
#
# blit      :: list (scan...)				| ordered from outermost to innermost loop
# scan      :: list (range block...)			| blocks iterating together
# block     :: list (axis min stride direction)
#
# NOTE: The first block in a scan always iterates the destination.
#       All following blocks iterate the zero or more sources.
#
# range     :: C value					| number of loops to perform
# axis      :: "x" | "y" | "z"				| coordinate the loop is over
# min       :: C value					| min loop value
# stride    :: C value | "1/x"				| delta between loop values
# direction :: "up" | "down"				| iteration direction, sign of the delta
#
# range, min, stride, and direction determine start & end values for the loop.
# we only have to know the start value. the internal loop variable always counts up (0..range-1).
#
# The stride "1/x" is special. It indicates fractional stepping with phase contant `x`.
# The block steps `x` times slower than the other blocks of this loop
#
# direction
# - "up":    start = min,                end = min+stride*(range-1)
# - "down":  start = min+range*stride-1, end = min
#
# actions .........................................................................
#
# raw      label code		| Code to run per position
# copy				| Copy source to destination
#
#				| Set destination to ...
# zero				| Set destination to 0
# const    v			| ... value `v`
#
# point    C-expression		| ... value computed from `f (x,y,z)` for C expression `f`
# point/2d C-expression		| ... value computed from `f (x,y)` for C expression `f`
# pos      C-expression		| ... value computed from `f (@)` for C expression `f` and linear pos `@`
#
# apply1   op args		| ... value computed from `op (source, {*}args)`
# apply1z  op args		| ... value computed from `op (source, {*}args, z)`
# apply2   op			| ... value computed from `op (source1, source2)`
# complex-apply-reduce op	| ... value computed from `complex-op (source1)`
# complex-apply-unary  op	| ... complex value from `complex-op (source1)`
# complex-apply-binary op      	| ... complex value from `complex-op (source1, source2)`
#
# for the `point*` nd `pos` actions the source iterated over is virtual, there is no
# actual input. only the iteration coordinates are of importance.
#
# for `raw` the code has access to
#
# - dstx, dsty, dstz, dstpos, dstvalue - destination coordinates, linear position, and buffer pointer
# - srcx, srcy, srcz, srcpos, srcvalue - ditto for a single source
# - src0x, ...                         - for first source of several, i.e. 0, 1, ...
#
# - dstpitch, dststride   - destination #row values, #column values
# - srcpitch, srcstride   - ditto for a single source
# - src0pitch, src0stride - ditto for first source of several
#

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

proc dsl::blit::gen {name blit function} {
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
    set axes [CollectAxes $blit]
    # axes :: dict (prefix -> axis -> ".")
    #         prefix in (dst, src|srcX)
    EmitAxisSupport $axes

    set f       [lindex $function 0]
    set virtual [expr {$f in {pos point point/2d}}]
    set nopos   [expr {$f in     {point point/2d}}]

    Comment "range information"
    set id 0 ; foreach scan $blit { EmitLoopRange  $scan $id ; incr id }
    set id 0 ; foreach scan $blit { EmitRangeTrace $scan $id ; incr id }

    EmitCellIntro $axes ;# blit table header, tracing

    foreach scan $blit { EmitLoopSetup $scan $virtual $nopos ; >>> }

    EmitCellAccess $axes $virtual $nopos
    EmitFunction   $function
    + "TRACE_CLOSER;"	;# starting in EmitCellAccess

    foreach scan [lreverse $blit] { EmitLoopCompletion $scan }

    EmitCompletion

    # Prepend introduction. Not done at the beginning as it contains information collected
    # during general code emission. Namely the set of arguments used by the loop nest.

    set code [Get]
    EmitIntro $name $blit $function
    + $code
    Done
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitFunction {function} {
    switch -exact -- [lindex $function 0] {
	raw {
	    Comment [lrange $function 0 1] ;# cmd + label
	}
	default {
	    lappend map "\n" " "
	    Comment [lmap w $function { string map $map [string trim $w] }]
	}
    }
    set args [lassign $function cmd]
    F/$cmd {*}$args
    return
}

proc dsl::blit::F/raw {label code} {
    + "TRACE_ADD (\" :: raw code - $label\", 0);"
    + $code
}

proc dsl::blit::F/copy {} {
    + "TRACE_ADD (\" :: copy %f\", *srcvalue);"
    + "*dstvalue = *srcvalue;"
}

proc dsl::blit::F/zero {} {
    + "TRACE_ADD (\" :: zero\", 0);"
    + "*dstvalue = 0;"
}

proc dsl::blit::F/const {v} {
    + "TRACE_ADD (\" :: set %f\", $v);"
    + "*dstvalue = $v;"
}

proc dsl::blit::F/point {cexpr} {
    set cexpr [string trim $cexpr]
    set dexpr [string map {z srcz x srcx y srcy} $cexpr]
    + "double value = $dexpr;"
    + "TRACE_ADD (\" :: %f = \[$cexpr](%u %u %u)\", value, srcy, srcx, srcz);"
    + "*dstvalue = value;"
}

proc dsl::blit::F/point/2d {cexpr} {
    set cexpr [string trim $cexpr]
    set dexpr [string map {x srcx y srcy} $cexpr]
    + "double value = $dexpr;"
    + "TRACE_ADD (\" :: %f = \[$cexpr](%u %u)\", value, srcy, srcx);"
    + "*dstvalue = value;"
}

proc dsl::blit::F/pos {cexpr} {
    set cexpr [string trim $cexpr]
    set dexpr [string map {@ srcpos} $cexpr]
    + "double value = $dexpr;"
    + "TRACE_ADD (\" :: %f = \[$cexpr](%f)\", value, srcpos);"
    + "*dstvalue = value;"
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
    + "TRACE_ADD (\" :: set %f = $fmt\", result, $values);"
    + "*dstvalue = result;"
}

proc dsl::blit::F/apply1z {op args} {
    append call "$op (*srcvalue"
    foreach a $args { append call ", $a" }
    append call ", srcz)"

    append fmt "$op (%f"
    foreach a $args { append fmt ", %p" }
    append fmt ", %u)"

    append values "*srcvalue"
    foreach a $args { append values ", $a" }
    append values ", srcz"

    + "double result = ${call};"
    + "TRACE_ADD (\" :: set %f = $fmt\", result, $values);"
    + "*dstvalue = result;"
}

proc dsl::blit::F/apply2 {op} {
    + "double result = $op (*src0value, *src1value);"
    + "TRACE_ADD (\" :: set %f = $op (%f, %f)\", result, *src0value, *src1value);"
    + "*dstvalue = result;"
}

proc dsl::blit::F/complex-apply-reduce {op} {
    + "TRACE_ADD (\" :: complexR $op (%f+i*%f)\", srcvalue\[0], srcvalue\[1]);"
    + "double complex srccvalue = CMPLX (srcvalue\[0], srcvalue\[1]);"
    + "*dstvalue                = $op (srccvalue);"
}

proc dsl::blit::F/complex-apply-unary {op} {
    + "TRACE_ADD (\" :: complex1 $op (%f+i*%f)\", srcvalue\[0], srcvalue\[1]);"
    + "double complex srccvalue = CMPLX (srcvalue\[0], srcvalue\[1]);"
    + "double complex result    = $op (srccvalue);"
    + "dstvalue\[0]              = creal (result);"
    + "dstvalue\[1]              = cimag (result);"
}

proc dsl::blit::F/complex-apply-binary {op} {
    + "TRACE_ADD (\" :: complex2 = $op (%f, %f)\", src0value\[0], src0value\[1], src1value\[0], src1value\[1]);"
    + "double complex src0cvalue = CMPLX (src0value\[0], src0value\[1]);"
    + "double complex src1cvalue = CMPLX (src1value\[0], src1value\[1]);"
    + "double complex result     = $op (src0cvalue, src1cvalue);"
    + "dstvalue\[0]               = creal (result);"
    + "dstvalue\[1]               = cimag (result);"
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitAxisSupport {axes} {
    set prefixes [lsort -dict [dict keys $axes]]

    # fixed pitch/stride data
    set sep 0
    foreach prefix $prefixes {
	EmitAxes $prefix [dict get $axes $prefix]
    }

    if {!$sep} return
    + {}

    # tracing geometries
    Comment "trace geometry information"
    + "TRACE (\"blit [T geo] | W... | H... | D... | Pit | Str |\", 0);"
    foreach prefix $prefixes {
	EmitAxeTrace $prefix [dict get $axes $prefix]
    }

    + {}
}

proc dsl::blit::EmitAxes {prefix axes} {
    upvar 1 sep sep
    if {[dict exists $axes y]} {
	if {!$sep} { Comment "destination/source pitch/stride" }
	+ "aktive_uint [F ${prefix}pitch] = [Pitch $prefix];"
	incr sep
    }
    if {[dict exists $axes x]} {
	if {!$sep} { Comment "destination/source pitch/stride" }
	+ "aktive_uint [F ${prefix}stride] = [Stride $prefix];"
	incr sep
    }
}

proc dsl::blit::EmitAxeTrace {prefix axes} {
    set fmt    "blit [T $prefix]"
    set values {}

    set p [string map {dst D src S} $prefix]

    append fmt " | %4d | %4d | %4d"
    lappend values ${p}W ${p}H ${p}D
    ArgMark ${p}W
    ArgMark ${p}H
    ArgMark ${p}D

    if {[dict exists $axes y]} { append fmt " | %4d" }
    if {[dict exists $axes x]} { append fmt " | %4d" }
    append fmt " |"
    if {[dict exists $axes y]} { lappend values ${prefix}pitch  }
    if {[dict exists $axes x]} { lappend values ${prefix}stride }

    + "TRACE (\"$fmt\", [join $values {, }]);"
}

proc dsl::blit::EmitCellIntro {axes} {
    + {}
    Comment {blit table header ...}
    + "TRACE_HEADER (1); TRACE_ADD(\"blit @\", 0);"
    foreach prefix [lsort -dict [dict keys $axes]] {
	set ax [dict get $axes $prefix]
	+ "TRACE_ADD (\" | [T $prefix]\", 0);"
	foreach a {y x z} {
	    if {![dict exists $ax $a]} continue
	    + "TRACE_ADD (\" | ${a}..\", 0);"
	}
	+ "TRACE_ADD (\" | pos/cap\", 0);"
    }
    + "TRACE_CLOSER;"
}

proc dsl::blit::EmitCellAccess {axes virtual nopos} {
    set prefixes [lsort -dict [dict keys $axes]]
    + {}
    # Compute linearized positions
    foreach prefix $prefixes {
	if {[string match src* $prefix] && $nopos} continue
	+ "aktive_uint [F ${prefix}pos]   = [EmitCellPosition $prefix [dict get $axes $prefix]];"
    }
    + {}

    # Trace, including protection against out of bounds
    Comment {blit table rows ...}
    + "TRACE_HEADER (1); TRACE_ADD(\"blit @\", 0);"
    foreach prefix $prefixes {
	EmitCellTrace $prefix [dict get $axes $prefix] $virtual $nopos
    }
    + {}

    # Pointers to dst and source values, if any
    foreach prefix $prefixes {
	if {[string match src* $prefix] && ($nopos||$virtual)} continue
	+ "double*      [F ${prefix}value] = [P $prefix] + ${prefix}pos;"
	ArgMark [P $prefix]
    }

    + {}
    return
}

proc dsl::blit::EmitCellTrace {prefix axes virtual nopos} {
    set pitched [expr {!([string match src* $prefix] && $nopos)}]
    + "TRACE_ADD (\" | [T $prefix]\", 0);"
    foreach a {y x z} {
	if {![dict exists $axes $a]} continue
	if {$pitched} {
	    switch -exact -- $a {
		y { append a /${prefix}pitch  }
		x { append a /${prefix}stride }
	    }
	}
	+ "TRACE_ADD (\" | %4d\", $prefix$a);"
    }

    if {![string match src* $prefix]} {
	# dst
	ArgMark [P $prefix]CAP
	+ "TRACE_ADD (\" | %4d/%4d\", ${prefix}pos, [P $prefix]CAP);"
    } elseif {!$nopos} {
	# src, pos requested
	if {$virtual} {
	    # src, virtual, pos, no cap
	    + "TRACE_ADD (\" | %4d\", ${prefix}pos);"
	} else {
	    # src, physical, pos and cap
	    ArgMark [P $prefix]CAP
	    + "TRACE_ADD (\" | %4d/%4d\", ${prefix}pos, [P $prefix]CAP);"
	}
    } ;# src, no pos virtual, nothing

    # If needed, protection against out of bounds access. Closes tracing and aborts.
    if {[string match src* $prefix] && ($nopos||$virtual)} return
    + "BLIT_BOUNDS ($prefix, ${prefix}pos, [P $prefix]CAP);"
    return
}

proc dsl::blit::EmitCellPosition {prefix axes} {
    set pos ""
    set sep {}
    # y - pitch, x - stride
    if {[dict exists $axes y]} { append pos $sep${prefix}y ; set sep " + " }
    if {[dict exists $axes x]} { append pos $sep${prefix}x ; set sep " + " }
    if {[dict exists $axes z]} { append pos $sep${prefix}z }
    return $pos
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitLoopRange {scan id} {
    lassign $scan range
    if {[IsArg $range]} { ArgMark $range }

    # Range counter, separate from the position trackers
    + "aktive_uint [F range${id}n] = ${range};"
}

proc dsl::blit::EmitRangeTrace {scan id} {
    set axis [lindex [lassign $scan __] 0 0]
    if {!$id} { + {} }
    + "TRACE (\"blit $axis range: %u\", range${id}n);"
}

proc dsl::blit::EmitLoopSetup {scan virtual nopos} {
    # scan  :: list (range block...)
    # block :: axis minvalue delta direction
    + {}
    Comment $scan

    set blocks   [lassign $scan range]
    set prefixes [Prefixes $blocks]
    set nb       [llength $blocks]

    # DS loop, S is fractional -> able to use new canned loop start
    if {($nb == 2)
	&& ![FractionalBlock [lindex $blocks 0]]
	&&  [FractionalBlock [lindex $blocks 1]]} {
	EmitLoopSetupCanned BLIT_SCAN_DSF $range $blocks $prefixes $virtual $nopos
	return
    }

    # too many blocks or general fractional stepping -> emit old style loop
    if {($nb > 3) || [Fractional $scan]} {
	error "old-style loop -- bad pitch/stride handling"
	EmitLoopSetupGeneric $range $blocks $prefixes
	return
    }

    EmitLoopSetupCanned [dict get {
	1 BLIT_SCAN_D
	2 BLIT_SCAN_DS
	3 BLIT_SCAN_DSS
    } $nb] $range $blocks $prefixes $virtual $nopos
    return
}

proc dsl::blit::EmitLoopSetupGeneric {range blocks prefixes} {
    # Define the variables for the parallel position trackers of the block
    foreach block $blocks prefix $prefixes {
	lassign $block axis min delta direction
	set var ${prefix}${axis}

	+ "aktive_uint [F $var] = [BlockStart $prefix $block 0 0 $range];"
	BlockPhase $block
    }
    # Begin loop
    + "BLIT_SCAN ([L], range[L]n) \{"
    return
}

proc dsl::blit::EmitLoopSetupCanned {cmd range blocks prefixes virtual nopos} {
    # Define the position trackers per block of the scan.
    set variables [lmap block $blocks prefix $prefixes {
	lassign $block axis min delta direction
	set var ${prefix}${axis}
    }]
    + "aktive_uint [join $variables {, }];"
    foreach block $blocks { BlockPhase $block }

    append cmd " \([L], range[L]n"
    foreach block $blocks var $variables prefix $prefixes {
	lassign $block axis min delta direction
	set step [dict get {up 1 down -1} $direction]
	append cmd ", $var"
	append cmd ", [BlockStart $prefix $block $virtual $nopos $range]"
	append cmd ", [BlockStep  $prefix $block $virtual $nopos]"
    }
    append cmd ") \{"
    + $cmd
    return
}

proc dsl::blit::EmitLoopCompletion {scan} {
    set blocks    [lassign $scan range]
    set prefixes  [Prefixes $blocks]
    set nb        [llength $blocks]

    if {($nb == 2)
	&& ![FractionalBlock [lindex $blocks 0]]
	&&  [FractionalBlock [lindex $blocks 1]]} {
	# DSF loop setup - no fractional stepping at the end
	<<<
	+ "\}"
	return
    }

    if {($nb > 3) || [Fractional $scan]} {
	# too many parallel blocks, or fractional - old style loop end
	+ {}
	Comment {Step to next position}
	# Position trackers, one per block in the scan, incrementing
	foreach block $blocks prefix $prefixes {
	    lassign $block axis min delta direction
	    set var ${prefix}${axis}
	    + "[BlockIncrement $var $block]; // $direction"
	}
	## + "TRACE (\"next [L]\", 0);"
    }

    <<<
    + "\}"
}

proc dsl::blit::BlockStart {prefix block virtual nopos range} {
    lassign $block axis min delta direction

    if {[IsArg $min]} { ArgMark $min }

    switch -exact -- $direction {
	up {
	  set start $min
	}
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
	}
    }

    if {$start == 0} { return $start }

    if {!([string match src* $prefix] && $nopos)} {
	switch -exact -- $axis {
	    y { set start "($start)*${prefix}pitch" }
	    x { set start "($start)*${prefix}stride" }
	}
    }

    return $start
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
	set increment "BLIT_STEP_FRACTION ([L], $delta, $var $modifier)"
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

proc dsl::blit::BlockStep {prefix block virtual nopos} {
    lassign $block axis min delta direction
    set fstep ""
    if {[string match 1/* $delta]} {
	set fstep ", [string range $delta 2 end]"
	set delta 1
    }
    if {!([string match src* $prefix] && $nopos)} {
	if {$delta == 1} {
	    switch -exact -- $axis {
		y { set delta ${prefix}pitch  }
		x { set delta ${prefix}stride }
	    }
	} elseif {$delta == -1} {
	    switch -exact -- $axis {
		y { set delta -${prefix}pitch  }
		x { set delta -${prefix}stride }
	    }
	} else {
	    switch -exact -- $axis {
		y { append delta *${prefix}pitch  }
		x { append delta *${prefix}stride }
	    }
	}
    }
    set modifier [dict get {
	up   {}
	down -
    } $direction]
    return "$modifier$delta$fstep"
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitIntro {name blit function} {
    global tcl_platform

    Comment "Blitter `$name`"
    Comment {}
    Comment "Generated [clock format [clock seconds]] -- $tcl_platform(user)@[info hostname]"

    Comment "Specification:"
    foreach scan $blit { Comment "- scan $scan" }
    lappend map "\n" " "
    Comment "= [join [lmap w $function { string map $map [string trim $w] }] { }]"
    + {}

    set arguments [ArgUsed]
    if {[llength $arguments]} {
	Comment "arguments: [join $arguments {, }]"
	foreach p [ArgUsed] {
	    + "#ifndef $p"
	    set default [ADefine $p]
	    if {$default eq {}} {
		+ "#error \"[ADesc $p] $p expected, not defined\""
	    } else {
		+ "#define $p ($default)"
	    }
	    + "#endif"
	}
	+ {}
    }
    return
}

proc dsl::blit::EmitCompletion {} {
    + {}
    Comment "remove argument defines"
    foreach p [ArgUsed] { + "#undef $p" }
    return
}

# # ## ### ##### ######## #############

proc dsl::blit::P {prefix} { string map {dst DST src SRC} $prefix }
proc dsl::blit::F {x}    { format %-10s $x }
proc dsl::blit::T {x}    { format %-4s $x }

proc dsl::blit::FractionalBlock {block} {
    lassign $block axis min delta dir
    return [string match 1/* $delta]
}

proc dsl::blit::Fractional {scan} {
    foreach block [lassign $scan __] {
	if {[FractionalBlock $block]} { return 1 }
    }
    return 0
}

proc dsl::blit::CollectAxes {blit} {
    set axes {}
    foreach scan $blit {
	# Prefixes inlined with axis collection per prefix
	set n 0
	set prefix dst
	foreach block [lassign $scan __] {
	    lassign $block axis min delta direction
	    dict set axes $prefix $axis .
	    set prefix src$n
	    incr n
	}
    }

    if {$n == 2} {
	dict set axes src [dict get $axes src0]
	dict unset axes src0
    }

    # axes :: dict (prefix -> axis -> ".")
    #         prefix in (dst, src|srcX)
    return $axes
}

# Prefixes - determine dst, src, src0, src1 ... for the blocks of a scan
proc dsl::blit::Prefixes {blocks} {
    switch -exact -- [llength $blocks] {
	1 {
	    # no sources
	    return dst
	}
	2 {
	    # single source
	    return {dst src}
	}
	default {
	    # multiple sources
	    set p dst
	    set counter 0
	    return [lmap __ $blocks { set r $p ; set p src$counter ; incr counter ; set r }]
	    # dst, src0, src1, ...
	}
    }
}

proc dsl::blit::Pitch {prefix} {
    set prefix [string map {dst D src S} $prefix]
    ArgMark ${prefix}W
    ArgMark ${prefix}D
    return "${prefix}W*${prefix}D"
}

proc dsl::blit::Stride {prefix} {
    set prefix [string map {dst D src S} $prefix]
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
