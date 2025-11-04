#!/home/aku/opt/ActiveTcl/bin/tclsh
# ------------------------------------------------------------------------------

set top   [file dirname [file dirname [file normalize [info script]]]]
set tests [file join $top tests]

namespace eval tcltest [list variable testsDirectory $tests]

source [file join $top tools trial-base.tcl]

# ------------------------------------------------------------------------------

set base [aktive op select x [gradx] from 0 to 4]

puts [pixels aktive op align left $base border black size 7]
#show $out

exit

set  in [aktive read from netpbm file path [A crop.pgm]]
set  in [aktive op equalization global $in]
show $in

exit

# ------------------------------------------------------------------------------

set in  [gradx]
set ni  [aktive op flip x $in]

set sub [aktive op math sub $in $ni]
set fin [aktive op select x $sub from 0 to 18]

set sin [aktive op select x $in from 0 to 18]
set sni [aktive op select x $ni from 0 to 18]
set ssb [aktive op math sub $sin $sni]

puts =============================================
#show $in
#show $ni
#show $sub
show $fin
exit
puts =============================================
show $sin
show $sni
show $ssb
puts =============================================

# ------------------------------------------------------------------------------
exit
