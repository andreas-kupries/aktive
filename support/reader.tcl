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
    return $state
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
    return
}

proc dsl::reader::vector {args} { ;#puts [info level 0]
    Lappend vectors {*}$args
    return
}

proc dsl::reader::operator {args} { ;#puts [info level 0]
    switch -- [llength $args] {
	2 { Operator {} {*}$args }
	3 { Operator    {*}$args }
	default { Abort "wrong#args for operator" }
    }
    return
}

# # ## ### ##### ######## #############
## DSL support - Operator handling

proc dsl::reader::Operator {vars ops specification} {
    foreach [list __op {*}$vars] $ops {
	OpStart $__op
	eval $specification
	OpFinish
    }
    return
}

proc dsl::reader::OpStart {op} {
    if {[Get opname] ne {}} { Abort "Nested operator definition in `$opname`" }
    if {[Has ops $op]}      { Abort "Duplicate operator definition for `$op`" }

    Set opname $op
    Set opspec {
	notes  {}
    	images {}
	params {}
	result image
	args   0
    }
    return
}

proc dsl::reader::OpFinish {} {
    Unset opspec param
    Unset opspec args
    
    Set ops [Get opname] [Get opspec]
    Set opname {}
    Set opspec {}
    return
}

# # ## ### ##### ######## #############
## DSL support - operator details

proc dsl::reader::note {args} { ;#puts [info level 0]
    LappendX opspec notes $args
    return
}

proc dsl::reader::void   {} { result void }
proc dsl::reader::result {type} { ;#puts [info level 0]
    Set opspec result $type
    return
}

proc dsl::reader::input {rc {mode required}} { ;#puts [info level 0]
    if {[Has opspec args] &&
	[Get opspec args]} { Abort "In [Get opname]: Bad image, infinity set" }

    if {$rc ni {
	keep keep-pass keep-ignore keep-pass-ignore ignore
    }} { Abort "In [Get opname]: Bad ref-counting mode '$rc'" }
    
    dict set imspec rcmode $rc
    switch -exact -- $mode {
	required { dict set imspec args 0	              }
	...      { dict set imspec args 1 ; Set opspec args 1 }
    }
    
    LappendX opspec images $imspec
    return
}

# parameter commands - See `type` above for setup, and `Param` below for handling.

# # ## ### ##### ######## #############
## DSL support - Parameter handling

proc dsl::reader::Param {type mode dvalue name args} { ;#puts [info level 0]
    # args :: help text

    if {$name eq {}}              { Abort "In [Get opname]: Bad parameter name, empty" }
    if {[Has opspec param $name]} { Abort "In [Get opname]: Duplicate parameter `$name`" }
    if {[Has opspec args] &&
	[Get opspec args]}        { Abort "In [Get opname]: Bad parameter, infinity set" }

    dict set argspec name [Pname $name]
    dict set argspec help [Help  [join $args { }]]
    dict set argspec type $type
    dict set argspec args [expr {$mode eq "args"}]

    switch -exact -- $mode {
	required {}
	optional { dict set argspec default $dvalue }
	args     { Set opspec args 1 } 
    }

    Set      opspec param  $name .
    LappendX opspec params $argspec
    return
}

proc dsl::reader::Pname {x} { ;#puts [info level 0]
    if {[Has pname text $x]} { return [Get pname text $x] }

    set id [llength [Get pname texts]]
    LappendX pname texts $x
    Set      pname text  $x $id
    return $id
}

proc dsl::reader::Help {x} { ;#puts [info level 0]
    if {$x eq {}} { Abort "In [Get opname]: Empty help" }    

    if {[Has help text $x]} { return [Get help text $x] }

    set id [llength [Get help texts]]
    LappendX help texts $x
    Set      help text  $x $id
    return $id
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
    return
}

proc dsl::reader::Set {args} {
    variable state
    set keypath [lreverse [lassign [lreverse $args] value]]
    dict set state {*}$keypath $value
    return
}

proc dsl::reader::Unset {args} {
    variable state
    dict unset state {*}$args
    return
}

proc dsl::reader::Lappend {key args} {
    variable state
    dict lappend state $key {*}$args
    return
}

proc dsl::reader::LappendX {args} {
    variable state
    set keypath [lreverse [lassign [lreverse $args] value]]
    set words [dict get $state {*}$keypath]
    lappend words $value
    dict set state {*}$keypath $words
    return
}

proc dsl::reader::Get {args} {
    variable state
    return [dict get $state {*}$args]
}

proc dsl::reader::Has {args} {
    variable state
    return [dict exists $state {*}$args]
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
    return -code error $x
}

# # ## ### ##### ######## #############
return
