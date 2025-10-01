# -*- mode: tcl ; fill-column: 90 -*-
## blitter - low-level code generation support
##           code collection and formatting

# # ## ### ##### ######## #############

namespace eval ::dsl::blit::codegen {
    variable lines  {}		;# collected code
    variable level  0		;# indentation level
    variable prefix {    }	;# indent per level
    #
    # API
    #
    namespace export begin done get + lf // >>> <<< level ;# reset
    namespace ensemble create
    namespace import ::dsl::blit::system::abort
}

# # ## ### ##### ######## #############
## API implementation

proc ::dsl::blit::codegen::begin {} {
    variable lines {}
    variable level 0
    return
}

proc ::dsl::blit::codegen::done {} {
    return -code return [get]
}

proc ::dsl::blit::codegen::get {} {
    variable lines
    set text  [join $lines \n]
    set lines {}
    return $text
}

proc ::dsl::blit::codegen::+ {text} {
    variable lines
    lappend  lines [I]$text
    return
}

proc ::dsl::blit::codegen::lf {} {
    + {}
}

proc ::dsl::blit::codegen::// {{text {}} {indent {}}} {
    + [string trimright "$indent// $text"]
}

proc ::dsl::blit::codegen::>>> {} { variable level ; incr level    }
proc ::dsl::blit::codegen::<<< {} { variable level ; incr level -1 }

proc ::dsl::blit::codegen::level {} {
    variable level ; set level
}

proc ::dsl::blit::codegen::E {message} {
    abort "codegen error: $message"
}

# # ## ### ##### ######## #############
## internal helpers

proc ::dsl::blit::codegen::I {} {
    variable prefix
    variable level
    string repeat $prefix $level
}

# # ## ### ##### ######## #############
return
