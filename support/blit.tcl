# -*- mode: tcl ; fill-column: 90 -*-
##

# TODO :: optimizations for zero/copy - memset/memcpy -- clear_all, clear
# TODO :: blit specific assertions
# TODO :: loop unroll (depth/z, 1..4 normally expected)
# TODO :: function inline - this is more in the usage

#
# loop nest specification
#
# blit      :: list (scan...)				| ordered from outermost to innermost loop
# scan      :: list (range iterator...)			| iterators running in parallel
# iterator     :: list (axis min stride direction)
#
# NOTE: The first iterator in a scan always iterates the destination.
#       All following iterators iterate the zero or more sources.
#
# range     :: C value					| number of loops to perform
# axis      :: "x" | "y" | "z" | "xz"			| coordinate the loop is over
# min       :: C value					| min loop value
# stride    :: C value | "1/x"				| delta between loop values
# direction :: "up" | "down"				| iteration direction, sign of the delta
#
# range, min, stride, and direction determine start & end values for the loop.
# we only have to know the start value. the internal loop variable always counts up (0..range-1).
#
# The stride "1/x" is special. It indicates fractional stepping with phase contant `x`.
# The iterator steps `x` times slower than the other iterators of this loop
#
# direction
# - "up":    start = min,                end = min+stride*(range-1)
# - "down":  start = min+range*stride-1, end = min
#

package require textutil::adjust

namespace eval dsl::blit {
    namespace export gen into
    namespace ensemble create
    namespace import codegen::*
}

# # ## ### ##### ######## #############

proc dsl::blit::into {destination blit function} {
    set name [file rootname [file tail $destination]]
    set text [gen $name $blit $function]

    file mkdir [file dirname $destination]
    set     chan [open $destination w]
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

    argument clear
    codegen begin
    spec setup $blit $function

    EmitAxisSupport
    EmitRangeSupport $blit
    EmitBlitTraceHeader
    set depth 0 ; foreach scan $blit { EmitIteratorOpen $scan $depth ; incr depth }
    EmitBlitBody $function
    foreach scan [lreverse $blit]    { EmitIteratorClose }
    EmitTrailer $name

    # Prepend the introduction to the code generated so far. This is done out of order
    # because the intro needs information collected during the general code
    # emission. Namely the set of arguments used.

    set code [codegen get]
    EmitHeader $name $blit $function
    + $code
    codegen done
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitAxisSupport {} {
    variable spec::prefixes

    # pitch/stride data, iterator increments
    set sep 0
    foreach prefix $prefixes { EmitAxisIncrements $prefix }
    # no increments -> no tracing
    if {!$sep} return
    lf
    // "trace geometry information"
    + "TRACE (\"blit [T geo] | W... | H... | D... | Pit | Str |\", 0);"
    foreach prefix $prefixes { EmitAxisTraces $prefix }
    lf
}

proc dsl::blit::EmitAxisIncrements {prefix} {
    upvar 1 sep sep
    foreach a [dict get $spec::axes $prefix] {
	set cvar [IncrementModifier $prefix $a]
	if {$cvar eq {}} continue
	if {!$sep} { // "iterator increments" }
	+ "aktive_uint [F $cvar] = [AxisDeltaVar $prefix $a];"
	incr sep
    }
    return
}

proc dsl::blit::EmitAxisTraces {prefix} {
    set axes   [dict get $spec::axes $prefix]
    set p      [PS $prefix]

    argument mark ${p}W
    argument mark ${p}H
    argument mark ${p}D

    set     fmt    "blit [T $prefix]"
    append  fmt    " | %4d | %4d | %4d"
    if {"y" in $axes} { append fmt " | %4d" }
    if {"x" in $axes} { append fmt " | %4d" }
    append fmt " |"

    lappend values ${p}W ${p}H ${p}D
    if {"y" in $axes} { lappend values ${prefix}pitch  }
    if {"x" in $axes} { lappend values ${prefix}stride }

    + "TRACE (\"$fmt\", [join $values {, }]);"
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitRangeSupport {blit} {
    // "iterator ranges, outer to inner"
    set depth 0 ; foreach scan $blit { EmitRangeData  $scan $depth ; incr depth }
    set depth 0 ; foreach scan $blit { EmitRangeTrace $scan $depth ; incr depth }
    lf
    return
}

proc dsl::blit::EmitRangeData {scan depth} {
    lassign $scan range
    if {[argument is $range]} {
	argument mark $range
    } else {
	foreach {a _} $argument::known {
	    if {![string match "*${a}*" $range]} continue
	    argument mark $a
	}
    }
    + "aktive_uint [F range${depth}n] = ${range};"
    return
}

proc dsl::blit::EmitRangeTrace {scan depth} {
    set axis [lindex [lassign $scan __] 0 0]
    if {!$depth} lf
    + "TRACE (\"blit $axis range: %u\", range${depth}n);"
    return
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitBlitTraceHeader {} {
    variable spec::prefixes
    variable spec::axes
    // "blit table header ..."
    + "TRACE_HEADER (1); TRACE_ADD(\"blit @\", 0);"
    foreach prefix $prefixes {
	set iaxes [dict get $axes $prefix]
	+ "TRACE_ADD (\" | [T $prefix]\", 0);"
	if {"y" in $iaxes} { + "TRACE_ADD (\" | y..\", 0);" }
	if {"x" in $iaxes} { + "TRACE_ADD (\" | x..\", 0);" }
	if {"z" in $iaxes} { + "TRACE_ADD (\" | z..\", 0);" }
	+ "TRACE_ADD (\" | pos/cap\", 0);"
    }
    + "TRACE_CLOSER;"
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitIteratorOpen {scan depth} {
    variable spec::span
    variable spec::frac

    # DS iterator signature, S alone is fractional -> supported
    if {$span == 2} {
	lassign $scan _ dst src
	if {![Fractional $dst] && [Fractional $src]} {
	    EmitIteratorOpenCore BLIT_SCAN_DSF $scan
	    return
	}
    }

    # No support beyond DSS, nor for general fractionals
    if {($span > 3) || [dict get $frac $depth]} {
	error "old-style loop -- not supported anymore"
    }

    # D, DS, or DSS iterator signature, per span
    EmitIteratorOpenCore [dict get {
	1 BLIT_SCAN_D
	2 BLIT_SCAN_DS
	3 BLIT_SCAN_DSS
    } $span] $scan
    return
}

proc dsl::blit::EmitIteratorOpenCore {cmd scan} {
    variable spec::prefixes

    lf
    // $scan
    set iterators [lassign $scan range]

    // "variables tracking the iterator positions"
    set variables [lmap iterator $iterators prefix $prefixes {
	lassign $iterator axis min delta direction
	set var ${prefix}${axis}
    }]
    + "aktive_uint [join $variables {, }];"

    # special variables for fractional stepper
    foreach iterator $iterators { IteratorPhase $iterator }

    # iterator setup command
    append cmd " \([level], range[level]n"
    foreach iterator $iterators var $variables prefix $prefixes {
	lassign $iterator axis min delta direction
	set step [dict get {up 1 down -1} $direction]
	append cmd ", $var"
	append cmd ", [IteratorStart $prefix $iterator $range]"
	append cmd ", [IteratorStep  $prefix $iterator]"
    }
    append cmd ") \{"
    + $cmd
    >>>
    return
}

proc dsl::blit::EmitIteratorClose {} {
    <<<
    + "\}"
}

proc dsl::blit::EmitBlitBody {function} {
    variable spec::prefixes

    // "compute linearized positions of the iterators"
    foreach prefix $prefixes {
	if {![PremulIter $prefix]} continue
	+ "aktive_uint [F ${prefix}pos]   = [EmitIteratorPosition $prefix];"
    }
    lf

    // "trace iterator positions, including protection against out of bounds"
    + "TRACE_HEADER (1); TRACE_ADD(\"blit @\", 0);"
    foreach prefix $prefixes { EmitIteratorTrace $prefix }
    lf

    // "convert positions to pointers into the []double vectors, where needed"
    foreach prefix $prefixes {
	if {[NoPosition $prefix]} continue
	+ "double*      [F ${prefix}value] = [P $prefix] + ${prefix}pos;"
	argument mark [P $prefix]
    }
    lf

    # perform blit action
    action emit $function
    + "TRACE_CLOSER;"
    return
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitIteratorTrace {prefix} {
    variable spec::virtual
    variable spec::nopos

    set premuliter [PremulIter $prefix]

    + "TRACE_ADD (\" | [T $prefix]\", 0);"
    foreach a [dict get $spec::axes $prefix] {
	if {$premuliter} { IncrementAppend a / $prefix $a }
	+ "TRACE_ADD (\" | %4d\", $prefix$a);"
    }

    if {![IsSource $prefix]} {
	# dst iterator
	argument mark [P $prefix]CAP
	+ "TRACE_ADD (\" | %4d/%4d\", ${prefix}pos, [P $prefix]CAP);"
    } elseif {!$nopos} {
	# src iterator, pos requested
	if {$virtual} {
	    # src, virtual, pos, no cap
	    + "TRACE_ADD (\" | %4d\", ${prefix}pos);"
	} else {
	    # src, physical, pos and cap
	    argument mark [P $prefix]CAP
	    + "TRACE_ADD (\" | %4d/%4d\", ${prefix}pos, [P $prefix]CAP);"
	}
    } ;# src, no pos, virtual, nothing

    # If needed, protection against out of bounds access. Closes tracing and aborts.
    if {[NoPosition $prefix]} return
    + "BLIT_BOUNDS ($prefix, ${prefix}pos, [P $prefix]CAP);"
    return
}

proc dsl::blit::EmitIteratorPosition {prefix} {
    set sep {}
    return [join [lmap a [dict get $spec::axes $prefix] {
	set pos $sep${prefix}$a ; set sep " + " ; set pos
    }] {}]
}

# # ## ### ##### ######## #############

proc dsl::blit::IteratorPhase {iterator} {
    if {![Fractional $iterator]} return
    upvar __done done
    if {![info exists done]} { // "variables for fractional stepper" } ; set done .
    argument mark PHASE[level];
    + "aktive_uint [F phase[level]] = PHASE[level];"
    + "TRACE (\".... phase[level] start %d\", phase[level]);"
    return
}

proc dsl::blit::IteratorStart {prefix iterator range} {
    variable spec::nopos

    lassign $iterator axis min delta direction
    if {[argument is $min]} { argument mark $min }

    switch -exact -- $direction {
	up   { set start $min }
	down {
	    if {$delta eq "1"} {
		set modifier  ${range}-1
	    } else {
		set modifier  ${range}*${delta}-1
	    }
	    if {$min eq "0"} {
		set start $modifier
	    } else {
		set start ${min}+$modifier
	    }
	}
    }

    if {$start eq "0"} { return $start }

    # premultiply pitch/stride data
    if {[PremulIter $prefix]} {
	set start ($start)
	IncrementAppend start * $prefix $axis
	if {[string match (*) $start]} { set start [string trim $start ()] }
    }

    return $start
}

proc dsl::blit::IteratorStep {prefix iterator} {
    lassign $iterator axis min delta direction
    set fstep ""
    if {[Fractional $iterator]} {
	set fstep ", [string range $delta 2 end]"
	set delta 1
    }
    if {[PremulIter $prefix]} {
	set modifier [IncrementModifier $prefix $axis]
	if {$modifier ne {}} {
	    if {$delta eq "1"} {
		set delta $modifier
	    } else {
		append delta *$modifier
	    }
	}
    }
    return "[dict get {
	up   {}
	down -
    } $direction]$delta$fstep"
}

# # ## ### ##### ######## #############

proc dsl::blit::EmitHeader {name blit function} {
    global tcl_platform

    // "Blitter `$name`"
    //
    // "Generated [clock format [clock seconds]] -- $tcl_platform(user)@[info hostname]"
    // "Specification:"
    foreach scan $blit { // "- scan $scan" }
    lappend map "\n" " "
    // "= [join [lmap w $function { string map $map [string trim $w] }] { }]"
    lf

    set arguments [argument used]
    if {![llength $arguments]} return

    // "arguments: [join $arguments {, }]"
    foreach p $arguments {
	+ "#ifndef $p"
	lassign [argument definition $p] default description
	if {$default eq {}} {
	    + "#error \"$description `$p` expected, not defined\""
	} else {
	    + "#define $p ($default)"
	}
	+ "#endif"
    }
    lf
    return
}

proc dsl::blit::EmitTrailer {name} {
    lf
    // "arguments: drop"
    foreach p [argument used] { + "#undef $p" }
    lf
    // "Blitter `$name` end"
    return
}

# # ## ### ##### ######## #############

proc dsl::blit::IncrementAppend {var op prefix axis} {
    set modifier [IncrementModifier $prefix $axis]
    if {$modifier eq {}} return
    upvar 1 $var v ; append v $op $modifier
    return
}

proc dsl::blit::IncrementModifier {prefix axis} {
    switch -exact -- $axis {
	y       { set modifier ${prefix}pitch  }
	x       { set modifier ${prefix}stride }
	default { set modifier "" }
    }
    return $modifier
}

proc dsl::blit::IsSource {prefix} {
    string match src* $prefix
}

proc dsl::blit::PremulIter {prefix} {
    variable spec::nopos
    expr {![IsSource $prefix] || !$nopos}
}

proc dsl::blit::NoPosition {prefix} {
    variable spec::nopos
    variable spec::virtual
    expr {[IsSource $prefix] && ($nopos || $virtual)}
}

proc dsl::blit::P  {prefix} { string map {dst DST src SRC} $prefix }
proc dsl::blit::PS {prefix} { string map {dst D   src S  } $prefix }
proc dsl::blit::F  {x}      { format %-10s $x }
proc dsl::blit::T  {x}      { format %-4s $x }

proc dsl::blit::Fractional {iterator} {
    lassign $iterator axis min delta dir
    return [string match 1/* $delta]
}

proc dsl::blit::AxisDeltaVar {prefix axis} {
    switch -exact -- $axis {
	y       { return [PitchData  $prefix] }
	x       { return [StrideData $prefix] }
	default { error "Bad axis" }
    }
}

proc dsl::blit::PitchData {prefix} {
    set prefix    [PS $prefix]
    argument mark ${prefix}W
    argument mark ${prefix}D
    return "${prefix}W*${prefix}D"
}

proc dsl::blit::StrideData {prefix} {
    set var       [PS $prefix]D
    argument mark $var
    return        $var
}

# # ## ### ##### ######## #############
return
