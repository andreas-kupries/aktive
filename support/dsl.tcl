# -*- mode: tcl ; fill-column: 90 -*-

namespace eval ::dsl {
    namespace export generate blit reduce
    namespace ensemble create
}

proc ::dsl::generate {pkg in out {doc {}}} {
    puts ""
    puts "  Ops processing \[$pkg\]"

    writer do $out $doc [reader do $pkg $in]
}

apply {{selfdir} {
    source [file join $selfdir reader.tcl]
    source [file join $selfdir writer.tcl]
    source [file join $selfdir blit.tcl]
    source [file join $selfdir reduce.tcl]
}} [file dirname [file normalize [info script]]]
return
