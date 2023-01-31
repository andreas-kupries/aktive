# -*- mode: tcl ; fill-column: 90 -*-

namespace eval ::dsl {
    namespace export generate
    namespace ensemble create
}

proc ::dsl::generate {in out} {
    writer do $out [reader do $in]
}

apply {{selfdir} {
    source [file join $selfdir reader.tcl]
    source [file join $selfdir writer.tcl]
}} [file dirname [file normalize [info script]]]
return
