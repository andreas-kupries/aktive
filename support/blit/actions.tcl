# -*- mode: tcl ; fill-column: 90 -*-
## blitter - action management, definition and retrieval

# # ## ### ##### ######## #############

namespace eval ::dsl::blit::action {
    variable db {}    ;# database of registered actions
    #
    namespace export emit flags new optimize
    namespace ensemble create
    namespace import ::dsl::blit::system::abort
    namespace import ::dsl::blit::codegen:://
}
namespace eval ::dsl::blit {
    namespace export action
}

# # ## ### ##### ######## #############
## API implementation

proc ::dsl::blit::action::optimize {action} {
    variable db
    while {1} {
	lassign $action name
	if {![dict exists $db $name]} { E "$name not defined" }
	set spec [dict get $db $name]
	dict with spec {}
	# -> code, comment, optimize, virtual, nopos, allowsrc
	set new [{*}$optimize $action]
	if {$new eq $action} { return $action } ;# passed unchanged - stop
	set action $new
    }
}

proc ::dsl::blit::action::flags {action} {
    set args [lassign $action name]
    variable db
   if {![dict exists $db $name]} { E "$name not defined" }
    set spec [dict get $db $name]
    dict with spec {}
    # -> code, comment, optimize, virtual, nopos, allowsrc
    list $virtual $nopos $allowsrc
}

proc ::dsl::blit::action::emit {action} {
    set args [lassign $action name]
    variable db
   if {![dict exists $db $name]} { E "$name not defined" }
    set spec [dict get $db $name]
    dict with spec {}
    # -> code, comment, optimize, virtual, nopos, allowsrc
    {*}$comment $action
    {*}$code {*}$args
    return
}

proc ::dsl::blit::action::new {name specification} {
    variable db
    if {[dict exists $db $name]} { E "$name already defined" }

    # spec :: dict ('code'     -> string /required (list (args body))
    #               'comment'  -> string /optional (body) /default dsl::blit::action::StdComment
    #               'optimize' -> string /optional (body) /default dsl::blit::action::Pass
    #               'virtual'  -> bool   /optional /default false
    #               'nopos'    -> bool   /optional /default false
    #               'allowsrc' -> bool   /optional /default true

    set spec [dict merge {
	code     {}
	comment  {}
	optimize {}
	virtual  no
	nopos    no
	allowsrc yes
    } $specification]
    dict with spec {}
    # -> code, comment, optimize, virtual, nopos, allowsrc

    if {$code eq {}} { E "$name has no code" }

    dict set spec code [list apply [linsert $code end ::dsl::blit::codegen]]

    if {$comment eq {}} {
	dict set spec comment ::dsl::blit::action::StdComment
    } else {
	dict set spec comment [list apply [list words $comment ::dsl::blit::codegen]]
    }

    if {$optimize eq {}} {
	dict set spec optimize ::dsl::blit::action::Pass
    } else {
	dict set spec optimize [list apply [list words $optimize]]
    }

    dict set db $name $spec
    return
}

# # ## ### ##### ######## #############
## internal helpers

proc ::dsl::blit::action::E {message} {
    abort "action def error: $message"
}

proc ::dsl::blit::action::StdComment {words} { ;#puts [info level 0]
    lappend map "\n" " "
    // [join [lmap w $words { string map $map [string trim $w] }] { }]
}

proc ::dsl::blit::action::Pass {words} { ;#puts [info level 0]
    return $words
}

# # ## ### ##### ######## #############
return
