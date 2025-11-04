#!/home/aku/opt/ActiveTcl/bin/tclsh
# ------------------------------------------------------------------------------

set top   [file dirname [file dirname [file normalize [info script]]]]
set tests [file join $top tests]

namespace eval tcltest [list variable testsDirectory $tests]

source [file join $top tools trial-base.tcl]

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
exit
