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
    foreach v $args {
	if {[Has vectors $v]} continue
	Set vectors $v $importing
    }
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
	foreach v $vars { def $v [set $v] }

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

    Set opspec state/setup   {}	;# State constructor - Geometry initialization at least
    Set opspec state/cleanup {}	;# State destructor, optional
    Set opspec state/fields  {}	;# State fields, C decl code, optional

    Set opspec region/setup   {} ;# Region state constructor, optional
    Set opspec region/cleanup {} ;# Region state destructor, optional
    Set opspec region/fields  {} ;# Region state fields, C decl code, optional
    Set opspec region/fetch   {} ;# Region pixel fetcher

    Set opspec args     0	;# Presence of variadic input or parameter
    Set opspec blocks   {}	;# Shared text blocks
}

proc dsl::reader::OpFinish {} {
    # Cross check operator specification for missing code fragments.
    if {[Get opspec result] eq "image"} {
	# Image result

	if {[Get opspec region/fetch] eq {}} { Abort "Returns image, has no pixel fetch"	  }
	if {[Get opspec state/setup]  eq {}} { Abort "Returns image, has no state/geometry setup" }
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

	if {[Get opspec region/fetch]   ne {}} { Abort "No image returned, yet pixel fetch"	 }
	if {[Get opspec region/fields]  ne {}} { Abort "No image returned, yet region state"	 }
	if {[Get opspec region/setup]   ne {}} { Abort "No image returned, yet region state"	 }
	if {[Get opspec region/cleanup] ne {}} { Abort "No image returned, yet region state"	 }
	#
	if {[Get opspec state/fields]  ne {}} { Abort "No image returned, yet state fields"  }
	if {[Get opspec state/setup]   ne {}} { Abort "No image returned, yet state setup"   }
	if {[Get opspec state/cleanup] ne {}} { Abort "No image returned, yet state cleanup" }
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
    Set opspec rcode  [TemplateCode $script $args]
}

proc dsl::reader::def {name script args} {
    if {[Get opname] eq {}} {
	Set blocks $name [TemplateCode $script $args]
    } else {
	Set opspec blocks $name [TemplateCode $script $args]
    }
}

proc dsl::reader::state {args} {
    lassign {} fields setup cleanup
    while {[string match -* [set o [lindex $args 0]]]} {
	switch -exact -- $o {
	    --       { set args [lassign $args _] ; break }
	    -fields  { set args [lassign $args _ fields]  }
	    -setup   { set args [lassign $args _ setup]    }
	    -cleanup { set args [lassign $args _ cleanup] }
	    default  { Abort "Bad option '$o', expected -fields, -setup, -cleanup, or --" }
	}
    }
    # Remainder of args is key/value map for templating.

    if {($fields ne {}) && ($setup eq {})} { Abort "Setup required when fields specified" }

    State $fields $setup $cleanup $args
}

proc dsl::reader::State {fields setup cleanup map} { ;# puts [info level 0]
    Set opspec state/setup   [TemplateCode $setup   $map]
    Set opspec state/cleanup [TemplateCode $cleanup $map]
    Set opspec state/fields  [TemplateCode $fields  $map]
}

proc ::dsl::reader::pixels {args} { ;# puts [info level 0]
    lassign {} fields setup cleanup
    while {[string match -* [set o [lindex $args 0]]]} {
	switch -exact -- $o {
	    --       { set args [lassign $args _] ; break }
	    -state   { set args [lassign $args _ fields]  }
	    -setup   { set args [lassign $args _ setup]   }
	    -cleanup { set args [lassign $args _ cleanup] }
	    default  { Abort "Bad option '$o', expected -state, -setup, -cleanup, or --" }
	}
    }
    # Remainder of args is fetch and key/value map for templating.

    if {($fields ne {}) && ($setup eq {})} { Abort "Setup required when fields specified" }
    if {![llength $args]} { Abort "Fetch specification missing, required" }
    set args [lassign $args fetch]

    Pixels $fields $setup $cleanup $fetch $args
}

proc ::dsl::reader::Pixels {fields setup cleanup fetch map} { ;#puts [info level 0]
    Set opspec region/setup   [TemplateCode $setup   $map]
    Set opspec region/cleanup [TemplateCode $cleanup $map]
    Set opspec region/fields  [TemplateCode $fields  $map]
    Set opspec region/fetch   [TemplateCode $fetch   $map]
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

proc dsl::reader::TemplateCode {code map} {

    set code [FormatCode $code]

    set     blocks    [Get blocks]
    lappend blocks {*}[Get opspec blocks]

    foreach key [lsort -dict [dict keys $blocks]] {
	set needle @@${key}@@
	if {![string match *${needle}* $code]} continue

	set replacement [dict get $blocks $key]

	# Block present.
	# Multi-line expansion expansion needed and supported ?

	set pattern "\n(\S*)$needle"
	if {![string match *\n* $replacement] ||
	    ![regexp -- $pattern $code -> prefix]
	} {
	    set code [string map [list $needle $replacement] $code]
	    continue
	}

	set replacement [textutil::adjust::indent $replacement $prefix  1]
	set code [string map [list $needle $replacement] $code]
    }

    set code [string map $map  $code]
    ::return $code
}

proc dsl::reader::FormatCode {code} {
    set code [textutil::adjust::undent $code]
    set code [string trim $code]
    ::return $code
}

# # ## ### ##### ######## #############
## State management (changing, querying)

proc dsl::reader::Init {package} {
    variable state {
	types   {}
	vectors {}
	blocks  {}
	ops     {}
	opname  {}
	opspec  {blocks {}}
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
##  - state/setup
##  - state/cleanup
##  - state/fields
##  - region/setup
##  - region/cleanup
##  - region/fields
##  - region/fetch
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
