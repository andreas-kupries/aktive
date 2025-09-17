#!/usr/bin/env tclsh
# ------------------------------------------------------------------------------
## Convert any PPM file into PPM ASCII form.

package require aktive

proc main {} {
    do {*}[cmdline]
}

proc cmdline {} {
    global argv
    if {[llength $argv] != 2} usage
    return $argv
}

proc usage {m} {
    global argv0
    puts stderr "Usage: $argv0 infile outfile"
    if {$m ne {}} { puts stderr "       $m" }
    exit 1
}

proc warn {m} { puts stderr $m ; flush stderr }
proc err  {m} { puts stderr $m ; flush stderr ; exit 1 }

proc do {infile outfile} {
    if {![file exists $infile]} { usage "Input not found: $infile" }
    if {![file isfile $infile]} { usage "Input not a file: $infile" }

    set image [aktive read from netpbm file path $infile]
    aktive format as ppm text 2file $image into $outfile
    return
}

main
# ------------------------------------------------------------------------------
exit
