# -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## #############

namespace eval dsl::reader {
    namespace export do
    namespace ensemble create

    variable state {}
}

# # ## ### ##### ######## #############

proc dsl::reader::do {package specification} {
    variable state
    variable readdir
    variable importing

    Init $package

    set readdir   [file dirname [file normalize $specification]]
    set importing 0

    puts "  ops generator reading $specification"

    source $specification
    ::return $state
}

# # ## ### ##### ######## #############
## DSL commands

proc dsl::reader::import {path} {
    variable readdir
    variable importing

    incr importing
    puts "  ops generator [string repeat {  } $importing] importing $path"

    set path    [file normalize [file join $readdir $path]]
    set saved   $readdir
    set readdir [file dirname $path]

    source $path
    incr importing -1

    set readdir $saved
}

proc dsl::reader::type {name critcl ctype conversion} {
variable importing

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

    Set types $name imported   $importing
    Set types $name critcl     $critcl
    Set types $name ctype      $ctype
    Set types $name conversion $conversion

    interp alias {} ::dsl::reader::$name      {} ::dsl::reader::Param $name required {}
    interp alias {} ::dsl::reader::${name}... {} ::dsl::reader::Param $name args     {}
    interp alias {} ::dsl::reader::${name}?   {} ::dsl::reader::Param $name optional ;#
}

proc dsl::reader::vector {args} { ;#puts [info level 0]
    variable importing
    foreach v $args { Set vectors $v $importing }
}

proc dsl::reader::operator {args} { ;#puts [info level 0]
    switch -- [llength $args] {
	2       { Operator {} {*}$args }
	3       { Operator    {*}$args }
	default { Abort "wrong#args for operator" }
    }
}

proc dsl::reader::nyi {args} { ;#puts [info level 0]
    # Disable a command
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
    Set opspec rcode    {}	;# C code fragment for non-image return (getter, doer)

    Set opspec statec   {}	;# State constructor, optional
    Set opspec stater   {}	;# State destructor, optional
    Set opspec statef   {}	;# State fields, C decl code

    Set opspec regionc  {}	;# Region state constructor, optional
    Set opspec regionr  {}	;# Region state destructor, optional
    Set opspec regionf  {}	;# Region state fields, C decl code
    Set opspec regionm  {}	;# Region pixel (M)aker - I.e. fetch pixels

    Set opspec geometry {}	;# Geometry initializer, optional
    Set opspec args     0	;# Presence of variadic input or parameter
}

proc dsl::reader::OpFinish {} {
    # Cross check operator specification for missing code fragments.
    if {[Get opspec result] eq "image"} {
	# Image result

	if {[Get opspec regionm]  eq {}} { Abort "Returns image, has no pixel fetch"	}
	if {[Get opspec geometry] eq {}} { Abort "Returns image, has no geometry setup"	}
	# Note: state, region state optional
	#
	if {[Get opspec rcode] ne {}} { Abort "Returns image, yet has result code" }
    } else {
	# Non-image result, possibly void.
	# Input images cannot be kept. RC mode has to be `ignore`

	foreach imspec [Get opspec images] {
	    set rc [dict get $imspec rcmode]
	    if {$rc eq "ignore"} continue
	    Abort "No image returned, yet attempting to keep input"
	}

	if {[Get opspec regionm]  ne {}} { Abort "No image returned, yet pixel fetch"	 }
	if {[Get opspec regionf]  ne {}} { Abort "No image returned, yet region state"	 }
	if {[Get opspec regionc]  ne {}} { Abort "No image returned, yet region state"	 }
	if {[Get opspec regionr]  ne {}} { Abort "No image returned, yet region state"	 }
	#
	if {[Get opspec geometry] ne {}} { Abort "No image returned, yet geometry setup" }
	#
	if {[Get opspec statef] ne {}} { Abort "No image returned, yet state setup" }
	if {[Get opspec statec] ne {}} { Abort "No image returned, yet state setup" }
	if {[Get opspec stater] ne {}} { Abort "No image returned, yet state setup" }
	#
	if {[Get opspec rcode] eq {}} { Abort "No image returned, has no result code" }
    }

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

proc dsl::reader::void   {script args} { return void $script {*}$args }
proc dsl::reader::return {type script args} { ;#puts [info level 0]
    Set opspec result $type
    Set opspec rcode  [string map $args $script]
}

proc dsl::reader::geometry {script args} {
    Set opspec geometry [string map $args $script]
}

proc dsl::reader::state {args} {
    lassign {} fields cons release
    while {[string match -* [set o [lindex $args 0]]]} {
	switch -exact -- $o {
	    --       { set args [lassign $args _] ; break }
	    -state   { set args [lassign $args _ fields]  }
	    -cons    { set args [lassign $args _ cons]    }
	    -release { set args [lassign $args _ release] }
	    default  { Abort "Bad option '$o', expected -state, -cons, -release, or --" }
	}
    }
    # Remainder of args is key/value map for templating.

    if {($fields ne {}) && ($cons eq {})} { Abort "Constructor required when fields specified" }

    State $fields $cons $release $args
}

proc dsl::reader::State {fields cons release map} { ;# puts [info level 0]
    Set opspec statec [string map $map $cons]
    Set opspec stater [string map $map $release]
    Set opspec statef [string map $map $fields]
}

proc ::dsl::reader::pixels {args} { ;# puts [info level 0]
    lassign {} fields cons release
    while {[string match -* [set o [lindex $args 0]]]} {
	switch -exact -- $o {
	    --       { set args [lassign $args _] ; break }
	    -state   { set args [lassign $args _ fields]  }
	    -cons    { set args [lassign $args _ cons]    }
	    -release { set args [lassign $args _ release] }
	    default  { Abort "Bad option '$o', expected -state, -cons, -release, or --" }
	}
    }
    # Remainder of args is fetch and key/value map for templating.

    if {($fields ne {}) && ($cons eq {})} { Abort "Constructor required when fields specified" }
    if {![llength $args]} { Abort "fetch specification missing" }
    set args [lassign $args fetch]

    Pixels $fields $cons $release $fetch $args
}

proc ::dsl::reader::Pixels {fields cons release fetch map} { ;#puts [info level 0]
    Set opspec regionc [string map $map $cons]
    Set opspec regionr [string map $map $release]
    Set opspec regionf [string map $map $fields]
    Set opspec regionm [string map $map $fetch]
}

proc dsl::reader::input... {rc} { Input $rc ...      }
proc dsl::reader::input    {rc} { Input $rc required }

proc dsl::reader::Input {rc {mode required}} { ;#puts [info level 0]
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

    set desc [join $args { }]
        if {$desc eq {}} { Abort "Empty description" }

    dict set argspec name $name
    dict set argspec desc $desc
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

# # ## ### ##### ######## #############
## State management (changing, querying)

proc dsl::reader::Init {package} {
    variable state {
	types   {}
	vectors {}
	vcached 0
	ops     {}
	opname  {}
	opspec  {}
	argspec {}
	imspec  {}
    }
    dict set state package $package
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
##  - name
##  - types   :: dict (typename -> typespec)
##  - vectors :: dict (typename -> imported)
##  - ops     :: dict (opname -> opspec)
##  - opname  :: string               [Only during collection]
##  - opspec  :: dict (key -> value)  [Only during collection]
##
## typespec keys
##  - imported
##  - critcl
##  - ctype
##  - conversion
##
## opspec keys
##  - args   :: bool
##  - images :: list (imspec)
##  - notes  :: list (string)
##  - param  :: dict (string -> '.') [Only during collection]
##  - params :: list (argspec)
##  - result :: string
##
## argspec keys
##  - args    :: bool
##  - default :: string, optional
##  - desc    :: string
##  - name    :: string
##  - type    :: string
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
