# -*- mode: tcl ; fill-column: 90 -*-
##
## Scan for and record !xref-marker locations for reference by the documentation.

namespace eval dsl::xref {
    namespace export scan
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc dsl::xref::scan {_into_ destination _from_ args} {
    # _into_ and _from_ are dummies to make the call syntax nicer to read
    Init
    foreach directory $args { Scan $directory }
    EmitTo $destination
}

# # ## ### ##### ######## #############

proc dsl::xref::Init {} {
    variable marker  {} ;# dict (name -> link)
    return
}

proc dsl::xref::Add {name path lines} {
    variable marker
    dict set marker $name /file?ci=trunk&name=${path}&ln=${lines}
    return
}

proc dsl::xref::Scan {directory} {
    foreach path [glob -nocomplain -directory $directory *] {
	if {[file isdirectory $path]} { Scan $path ; continue }
	Ingest $path
    }
}

proc dsl::xref::Ingest {path} {
    puts "Scanning [dsl::writer::blue $path] ..."

    # local database of accumulated (partial) references
    set mark {}
    set lno 0
    set current {}
    foreach line [split [fileutil::cat $path] \n] {
	incr lno
	if {![string match {* !xref-mark *} $line]} continue
	if {![regexp {.* !xref-mark (.*)$} $line -> spec]} continue
	# marker detect and extracted
	set spec [string trim $spec]
	if {$spec eq "/end"} {
	    # possible end marker for a larger block.
	    if {![dict exists $mark $current]} continue
	    # block found, extend line information
	    dict append mark $current -[expr {$lno - 1}]
	    continue
	}
	# record a marker
	dict set mark $spec [expr {$lno + 1}]
	set current   $spec
    }

    # commit the found markers to the main database
    dict for {name lines} $mark { Add $name $path $lines }
    return
}

proc dsl::xref::EmitTo {destination} {
    variable marker

    # commit all markers into a usable xref file
    set c [open $destination w]
    dict for {name link} $marker {
	puts $c [list xref "src $name" "\[$name\]($link)"]
    }
    close $c

    unset marker
    return
}

# # ## ### ##### ######## #############
return
