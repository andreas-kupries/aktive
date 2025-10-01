# -*- mode: tcl ; fill-column: 90 -*-
## blitter - action management, definition and retrieval

# # ## ### ##### ######## #############

namespace eval ::dsl::blit::action {
    variable db {}    ;# database of registered actions
    #
    namespace export emit flags new
    namespace ensemble create
    namespace import ::dsl::blit::system::abort
    namespace import ::dsl::blit::codegen:://
}
namespace eval ::dsl::blit {
    namespace export action
}

# # ## ### ##### ######## #############
## API implementation

proc ::dsl::blit::action::flags {action} {
    set args [lassign $action name]
    variable db
   if {![dict exists $db $name]} { E "$name not defined" }
    set spec [dict get $db $name]
    dict with spec {}
    # -> code, comment, virtual, nopos, allowsrc
    list $virtual $nopos $allowsrc
}

proc ::dsl::blit::action::emit {action} {
    set args [lassign $action name]
    variable db
   if {![dict exists $db $name]} { E "$name not defined" }
    set spec [dict get $db $name]
    dict with spec {}
    # -> code, comment, virtual, nopos, allowsrc
    {*}$comment $args
    {*}$code {*}$args
    return
}

proc ::dsl::blit::action::new {name specification} {
    variable db
    if {[dict exists $db $name]} { E "$name already defined" }

    # spec :: dict ('code'     -> string /required
    #               'comment'  -> string /optional /default dsl::blit::action::StdComment
    #               'virtual'  -> bool   /optional /default false
    #               'nopos'    -> bool   /optional /default false
    #               'allowsrc' -> bool   /optional /default true

    set spec [dict merge {
	code     {}
	comment  {}
	virtual  no
	nopos    no
	allowsrc yes
    } $specification]
    dict with spec {}
    # -> code, comment, virtual, nopos, allowsrc

    if {$code eq {}} { E "$name has no code" }

    dict set spec code [list apply [linsert $code end ::dsl::blit::codegen]]

    if {$comment eq {}} {
	dict set spec comment ::dsl::blit::action::StdComment
    } else {
	dict set spec comment [list apply [list words $comment ::dsl::blit::codegen]]
    }

    dict set db $name $spec
    return
}

# # ## ### ##### ######## #############
## internal helpers

proc ::dsl::blit::action::E {message} {
    abort "action def error: $message"
}

proc ::dsl::blit::action::StdComment {words} { ;puts [info level 0]
    lappend map "\n" " "
    // [join [lmap w $words { string map $map [string trim $w] }] { }]
}

# # ## ### ##### ######## #############
return
