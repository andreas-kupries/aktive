# -*- mode: tcl ; fill-column: 90 -*-
##

namespace eval template {}

proc template::process {text args} {
    # locate all <<<...>>> sequences and replace them with the string returned
    # by the processor command prefix in `args` for that sequence.
    while {[regexp -line -indices {<<<.*?>>>} $text match]} {
	set text [string replace $text {*}$match [{*}$args [string trim [string range $text {*}$match] <>]]]
    }
    return $text
}
