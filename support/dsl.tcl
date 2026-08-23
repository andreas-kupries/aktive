# -*- mode: tcl ; fill-column: 90 -*-

namespace eval ::dsl {
    namespace export generate blit reduce structs xref
    namespace ensemble create
}

proc ::dsl::generate {pkg in out {doc {}}} {
    puts ""
    puts "  Ops processing \[$pkg\]"

    writer do $out $doc [reader do $pkg $in]

    puts ""
    puts "  Done \[$pkg\]"
    puts ""
}

apply {{selfdir} {
    source [file join $selfdir ops/reader.tcl]
    source [file join $selfdir ops/writer.tcl]
    source [file join $selfdir blit/system.tcl]
    source [file join $selfdir blit/arguments.tcl]
    source [file join $selfdir blit/codegen.tcl]
    source [file join $selfdir blit/actions.tcl]
    source [file join $selfdir blit/spec.tcl]
    source [file join $selfdir blit.tcl]
    source [file join $selfdir blit/builtin-actions.tcl]
    source [file join $selfdir ops/reduce.tcl]
    source [file join $selfdir ops/structs.tcl]
    source [file join $selfdir ops/xref.tcl]
}} [file dirname [file normalize [info script]]]
return
