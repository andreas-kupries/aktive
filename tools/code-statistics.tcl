#!/usr/bin/env tclsh

## CWD:    repository top directory
## Syntax: tools/code-statistics.tcl > statistics.md

proc main {} {
    ingest Runtime        {runtime .c .h .tcl} error.tcl meta.tcl parameters.tcl simplifier.tcl
    ingest Runtime/C      {runtime .c .h}
    ingest Runtime/Tcl    {runtime .tcl} error.tcl meta.tcl parameters.tcl simplifier.tcl
    ingest DSL            {support .tcl}
    ingest Operators      {etc .tcl}
    ingest {Doc Source}   {docsrc .md} {etc .md} README.md
    ingest Generated      {generated .c .h .tcl}
    ingest Generated/C    {generated .c .h}
    ingest Generated/Tcl  {generated .tcl}

    emit Runtime %Runtime/C %Runtime/Tcl \
	DSL Operators \
	Generated %Generated/C %Generated/Tcl \
	{Doc Source}
}

proc ingest {code args} {
    #puts stderr [info level 0]

    foreach spec $args {
	ingest1 $code {*}$spec
    }
}

proc ingest1 {code path args} {
    if {[file isfile $path]} {
	if {[llength $args]} { error "bad spec $code: file with arguments" }
	ingest1file $code $path
	return
    }

    if {[file isdirectory $path]} {
	if {![llength $args]} { error "bad spec $code: directory without arguments" }
	ingest1dir $code $path $args
	return
    }

    error "bad spec $code: $path $args"
}

proc ingest1file {code path} {
    #puts stderr \t++$path
    add $code [llength [split [cat $path] \n]]
}

proc ingest1dir {code path extensions} {
    package require fileutil
    foreach file [fileutil::find $path] {
	if {![file isfile $file]} continue
	#puts stderr \t\t\tfound\t$file\t[file extension $file]\t($extensions)
	if {[file extension $file] ni $extensions} continue
	ingest1file $code $file
    }
    return
}

proc cat {path} {
    set c [open $path r]
    set d [read $c]
    close $c
    return $d
}

proc add {code count} { global counts ; dict incr counts $code $count }
proc get {code}       { global counts ; dict get $counts $code }

proc emit {args} {
    foreach code $args {
	if {[string match %* $code]} continue
	incr total [get $code]
    }

    set tp 0

    row Section Lines Percent
    row :---    ---:  ---:
    foreach code $args {
	set prefix ""
	set span __
	set display $code
	set hidden [string match %* $code]
	if {$hidden} {
	    set prefix "\u2192 "
	    set span ""
	    set code [string range $code 1 end]
	    set display [lindex [split $code /] end]
	}
	set count   [get $code]
	set p       [expr {100*double($count)/$total}]
	set percent [F $p]

	row $prefix$display $span$count$span $span$percent$span

	if {!$hidden} { set tp [expr {$tp + $p}] }

    }
    row Total $total [F $tp]
}

proc F {x} { string trim [format %6.2f $x] }

proc row {args} {
    puts |[join $args |]|
}

main
exit
