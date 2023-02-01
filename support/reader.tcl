# -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## #############

namespace eval dsl::reader {
    namespace export do
    namespace ensemble create

    variable state {}
}

# # ## ### ##### ######## #############

proc dsl::reader::do {specification} {
    variable state
    Init

    puts "  ops generator reading $specification"

    source $specification
    ::return $state
}

# # ## ### ##### ######## #############
## DSL commands

proc dsl::reader::type {name critcl ctype conversion} {
    if {$name in {
	type vector operator note void result input
    } || [string match {[A-Z]*} $name]} {
	Abort "Rejected attempt to replace DSL command with user type"
    }

    if {[Has types $name]} {
	Abort "Duplicate definition of type `$name`"
    }

    if {$critcl eq "-"} { set critcl $name   }
    if {$ctype  eq "-"} { set ctype  $critcl }

    Set types $name [list $critcl $ctype $conversion]

    interp alias {} ::dsl::reader::$name      {} ::dsl::reader::Param $name required {}
    interp alias {} ::dsl::reader::${name}... {} ::dsl::reader::Param $name args     {}
    interp alias {} ::dsl::reader::${name}?   {} ::dsl::reader::Param $name optional ;#
}

proc dsl::reader::vector {args} { ;#puts [info level 0]
    Lappend vectors {*}$args
}

proc dsl::reader::operator {args} { ;#puts [info level 0]
    switch -- [llength $args] {
	2       { Operator {} {*}$args }
	3       { Operator    {*}$args }
	default { Abort "wrong#args for operator" }
    }
}

# # ## ### ##### ######## #############
## DSL support - Operator handling

proc dsl::reader::Operator {vars ops specification} {
    foreach [list __op {*}$vars] $ops {
	OpStart $__op
	eval $specification
	OpFinish
    }
}

proc dsl::reader::OpStart {op} {
    if {[Get opname] ne {}} { Abort "Nested operator definition `$op`" }
    if {[Has ops $op]}      { Abort "Duplicate operator definition" }

    Set opname $op		;# Current operator, lock against nesting
    Set opspec notes    {}	;# Description
    Set opspec images   {}	;# Input images
    Set opspec params   {}	;# Parameters
    Set opspec result   image	;# Return value
    Set opspec rcode    {}	;# C code fragment for non-image return (getter)
    Set opspec statec   {}	;# State constructor, optional
    Set opspec stater   {}	;# State destructor, optional
    Set opspec statef   {}	;# State fields, C decl code
    Set opspec geometry {}	;# Geometry initializer, optional
    Set opspec args     0	;# Presence of variadic input or parameter
}

proc dsl::reader::OpFinish {} {
    Unset opspec param
    Unset opspec args

    Set ops [Get opname] [Get opspec]
    Set opname {}
    Set opspec {}
}

# # ## ### ##### ######## #############
## DSL support - operator details

proc dsl::reader::note {args} { ;#puts [info level 0]
    LappendX opspec notes $args
}

proc dsl::reader::void   {} { return void }
proc dsl::reader::return {type {script {}}} { ;#puts [info level 0]
    Set opspec result $type
    Set opspec rcode  $script
}

proc dsl::reader::geometry {script args} {
    Set opspec geometry [string map $args $script]
}

proc dsl::reader::state {fields cons {release {}} args} {
    Set opspec statec [string map $args $cons]
    Set opspec stater [string map $args $release]
    Set opspec statef [string map $args $fields]
}

proc dsl::reader::input {rc {mode required}} { ;#puts [info level 0]
    if {[Has opspec args] &&
	[Get opspec args]} { Abort "Rejecting more image arguments, we have a variadic" }

    if {$rc ni {
	keep keep-pass keep-ignore keep-pass-ignore ignore
    }} { Abort "Bad image rc-management mode '$rc'" }

    dict set imspec rcmode $rc
    switch -exact -- $mode {
	required { dict set imspec args 0	                             }
	...      { dict set imspec args 1 ; Set opspec args 1 ; vector image }
    }

    LappendX opspec images $imspec
}

# parameter commands - See `type` above for setup, and `Param` below for handling.

# # ## ### ##### ######## #############
## DSL support - Parameter handling

proc dsl::reader::Param {type mode dvalue name args} { ;#puts [info level 0]
    # args :: help text

    if {$name eq {}}              { Abort "Bad parameter name, empty" }
    if {[Has opspec param $name]} { Abort "Duplicate parameter `$name`" }
    if {[Has opspec args] &&
	[Get opspec args]}        { Abort "Rejecting more parameters, we have a variadic" }

    set isargs [expr {$mode eq "args"}]
    if {$isargs && [llength [Get opspec images]]} {
	Abort "Rejecting variadic parameter, we have images"
    }

    dict set argspec name [Pname $name]
    dict set argspec help [Help  [join $args { }]]
    dict set argspec type $type
    dict set argspec args $isargs

    switch -exact -- $mode {
	required {}
	optional { dict set argspec default $dvalue }
	args     { Set opspec args 1 ; vector $type }
    }

    Set      opspec param  $name .
    LappendX opspec params $argspec
}

proc dsl::reader::Pname {x} { ;#puts [info level 0]
    if {[Has pname text $x]} { ::return [Get pname text $x] }

    set id [llength [Get pname texts]]
    LappendX pname texts $x
    Set      pname text  $x $id
    ::return $id
}

proc dsl::reader::Help {x} { ;#puts [info level 0]
    if {$x eq {}} { Abort "Empty description" }

    if {[Has help text $x]} { ::return [Get help text $x] }

    set id [llength [Get help texts]]
    LappendX help texts $x
    Set      help text  $x $id
    ::return $id
}

# # ## ### ##### ######## #############
## State management (changing, querying)

proc dsl::reader::Init {} {
    variable state {
	types   {}
	ops     {}
	opname  {}
	opspec  {}
	argspec {}
	imspec  {}
	kind    {}
	help    {
	    text  {}
	    texts {}
	}
	pname   {
	    text  {}
	    texts {}
	}
    }
}

proc dsl::reader::Set {args} {
    variable state
    set keypath [lreverse [lassign [lreverse $args] value]]
    dict set state {*}$keypath $value
}

proc dsl::reader::Unset {args} {
    variable state
    dict unset state {*}$args
}

proc dsl::reader::Lappend {key args} {
    variable state
    dict lappend state $key {*}$args
}

proc dsl::reader::LappendX {args} {
    variable state
    set keypath [lreverse [lassign [lreverse $args] value]]
    set words [dict get $state {*}$keypath]
    lappend words $value
    dict set state {*}$keypath $words
}

proc dsl::reader::Get {args} {
    variable state
    dict get $state {*}$args
}

proc dsl::reader::Has {args} {
    variable state
    dict exists $state {*}$args
}

# ... ... ... ingestion commands ... ... ... ... ... ...
## Data
##  - types   :: dict (typename -> list (critcl ctype))
##  - ops     :: dict (opname -> opspec)
##  - opname  :: string
##  - opspec  :: dict (key -> value)
##  - help    :: list (string)
##  - pname   :: list (string)
##
## During collection
##  - help    :: dict (text -> id, text -> list (string))
##  - pname   :: dict (text -> id, text -> list (string))
##
## opspec keys
##  - notes  :: list (string)
##  - images :: list (imspec)
##  - params :: list (argspec)
##  - result :: string
##  - args   :: bool
##  - param  :: dict (string -> '.') [During collection only]
##
## argspec keys
##  - name    :: id
##  - type    :: string
##  - args    :: bool
##  - default :: string, optional
##  - help    :: id
##
## imspec keys
##  - rcmode :: string
##  - args   :: bool

proc dsl::reader::Abort {x} {
    set opname [Get opname]
    if {$opname ne {}} { set x "Operation $opname: $x" }
    ::return -code error $x
}

# # ## ### ##### ######## #############
return