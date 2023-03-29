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

    puts "Reading [blue $specification]"

    source $specification

    if {[llength [Get todos]]} {
	puts "[cyan "Skipped definitions"]: [red [llength [Get todos]]] noted in [blue todo.txt]"
    }

    ::return $state
}

# # ## ### ##### ######## #############
## DSL commands

proc dsl::reader::import? {path} {
    set fullpath [ImportPath $path]
    if {![file exists $fullpath]} {
	puts "    Skip import missing [cyan $path]"
    } elseif {![file isfile $fullpath]} {
	puts "    Skip import nonfile [cyan $path]"
    } else {
	Import $path $fullpath
    }
}

proc dsl::reader::import {path} {
    Import $path [ImportPath $path]
}

proc dsl::reader::ImportPath {path} {
    variable readdir
    file normalize [file join $readdir $path]
}

proc dsl::reader::Import {path fullpath} {
    variable readdir
    variable importing

    incr importing
    puts "Importing [blue $path]"

    set saved   $readdir
    set readdir [file dirname $fullpath]

    uplevel 2 [list source $fullpath]
    incr importing -1

    set readdir $saved
}

proc dsl::reader::type {name critcl ctype conversion {init {}} {finish {}}} {
    OkModes {}
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
    Set types $name init       $init
    Set types $name finish     $finish

    interp alias {} ::dsl::reader::$name      {} ::dsl::reader::Param $name required {}
    interp alias {} ::dsl::reader::${name}... {} ::dsl::reader::Param $name args     {}
    interp alias {} ::dsl::reader::${name}?   {} ::dsl::reader::Param $name optional ;#
    interp alias {} ::dsl::reader::${name}()  {} ::dsl::reader::Param $name vector   {}
}

proc dsl::reader::vector {args} { ;#puts [info level 0]
    OkModes {} C External
    variable importing
    foreach v $args {
	if {[Has vectors $v]} continue
	Set vectors $v $importing
    }
}

proc dsl::reader::operator {args} { ;#puts [info level 0]
    OkModes {}
    # 2 :: operator      NAMES SPEC
    # 3 :: operator VARS NAMES SPEC
    switch -- [llength $args] {
	2       { Operator {} {*}$args }
	3       { Operator    {*}$args }
	default { Abort "wrong#args for operator" }
    }
}

proc dsl::reader::nyi {args} { ;#puts [info level 0]
    OkModes {}
    # Disable a command
    set cmd [lindex $args 0]
    if {$cmd eq "operator"} {
	switch -- [llength $args] {
	    4 {
		lassign $args _ vars values _
		foreach [list __op {*}$vars] $values {
		    #puts "  Skipped $cmd [cyan $__op]"
		    Lappend todos $__op
		}
	    }
	    3 {
		foreach name [lindex $args 1] {
		    #puts "  Skipped $cmd [cyan $name]"
		    Lappend todos $name
		}
	    }
	}
    } else {
	puts "  Skipped [lrange $args 0 1]"
    }
}

# # ## ### ##### ######## #############
## DSL support - (Tcl)Operator handling

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

    Set opmode {}		;# Allow all commands at the beginning.
    Set opname $op		;# Current operator, lock against nesting
    Set opspec notes    {}	;# Description
    Set opspec section  {}	;# Command category
    Set opspec images   {}	;# Input images
    Set opspec params   {}	;# Parameters
    Set opspec overlays {}	;# Policy overlays - checks and simplifications

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

    if {[Get opmode] eq {}} {
	Abort "Incomplete specification, unable to determine implementation language"
    }

    if {[Get opmode] eq "C"} {
	if {[Get opspec result] eq "image"} {
	    # Image result.
	    # Input images, if any, are kept.

	    if {[Get opspec region/fetch] eq {}} { Abort "Returns image, has no pixel fetch"	  }
	    if {[Get opspec state/setup]  eq {}} { Abort "Returns image, has no state/geometry setup" }
	    # Note: state, region state optional
	    #
	    if {[Get opspec rcode] ne {}} { Abort "Returns image, yet has result code" }

	    # Set rc mode of inputs to `keep`.
	    Set opspec images [lmap imspec [Get opspec images] {
		dict set imspec rcmode keep ; set imspec
	    }]
	} else {
	    # Non-image result, possibly void.
	    # Input images are not kept.

	    if {[Get opspec region/fetch]   ne {}} { Abort "No image returned, yet pixel fetch"	 }
	    if {[Get opspec region/fields]  ne {}} { Abort "No image returned, yet region state" }
	    if {[Get opspec region/setup]   ne {}} { Abort "No image returned, yet region state" }
	    if {[Get opspec region/cleanup] ne {}} { Abort "No image returned, yet region state" }
	    #
	    if {[Get opspec state/fields]  ne {}} { Abort "No image returned, yet state fields"  }
	    if {[Get opspec state/setup]   ne {}} { Abort "No image returned, yet state setup"   }
	    if {[Get opspec state/cleanup] ne {}} { Abort "No image returned, yet state cleanup" }
	    #
	    if {[Get opspec rcode] eq {}} { Abort "No image returned, has no result code" }

	    # Set rc mode of inputs to `ignore`.
	    Set opspec images [lmap imspec [Get opspec images] {
		dict set imspec rcmode ignore ; set imspec
	    }]
	}
    }

    Set   opspec lang [Get opmode]
    Unset opspec param
    Unset opspec args

    Set ops [Get opname] [Get opspec]
    Set opname {}
    Set opspec {}
    Set opmode {}
}

# # ## ### ##### ######## #############
## DSL support - general operator details

proc dsl::reader::note {args} { ;#puts [info level 0]
    OkModes {} C Tcl External
    LappendX opspec notes $args
}

proc dsl::reader::section {args} { ;#puts [info level 0]
    OkModes {} C Tcl External
    Set opspec section $args
}

# # ## ### ##### ######## #############
## DSL support - External operator details

proc dsl::reader::external! {} { ;#puts [info level 0]
    OkModes {}
    Set opmode External
}

# # ## ### ##### ######## #############
## DSL support - Tcl operator details

proc dsl::reader::body {script args} {
    OkModes {} Tcl
    Set opmode Tcl
    Set opspec body [TemplateCode $script $args]
}

# # ## ### ##### ######## #############
## DSL support - C operator details

proc dsl::reader::void   {script args} { return void $script {*}$args }
proc dsl::reader::return {type script args} { ;#puts [info level 0]
    OkModes {} C
    Set opmode C
    Set opspec result $type
    Set opspec rcode  [TemplateCode $script $args]
}

proc dsl::reader::blit {name scans function} {
    OkModes {} C
    Set opmode C
    def $name [dsl blit gen $name $scans $function]
}

proc dsl::reader::def {name text args} {
    OkModes {} C Tcl
    set text [TemplateCode $text $args]
    if {[Get opname] eq {}} {
	Set blocks $name $text
    } else {
	Set opspec blocks $name $text
    }
    upvar 1 $name var
    set var $text
}

proc dsl::reader::state {args} {
    OkModes {} C
    Set opmode C
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
    OkModes {} C
    Set opmode C
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

proc dsl::reader::simplify {args} {
    OkModes {} C
    Set opmode C
    LappendX opspec overlays $args
}

proc dsl::reader::input... {} { Input ...      }
proc dsl::reader::input    {} { Input required }

proc dsl::reader::Input {mode} { ;#puts [info level 0]
    OkModes {} C Tcl
    if {[Has opspec args] &&
	[Get opspec args]} { Abort "Rejecting more image arguments, we have a variadic" }

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
    OkModes {} C Tcl External
    # args :: help text

    if {$mode ni {required args optional vector}} { Abort "Internal: Bad mode $mode" }

    if {$name eq {}}              { Abort "Bad parameter name, empty" }
    if {[Has opspec param $name]} { Abort "Duplicate parameter `$name`" }
    if {[Has opspec args] &&
	[Get opspec args]}        { Abort "Rejecting more parameters, we have a variadic" }

    set isargs   [expr {$mode eq "args"}]
    set isvector [expr {$mode eq "vector"}]
    if {$isargs && [llength [Get opspec images]]} {
	Abort "Rejecting variadic parameter, we have images"
    }

    set desc [join $args { }]
        if {$desc eq {}} { Abort "Empty description" }

    dict set argspec name   $name
    dict set argspec desc   $desc
    dict set argspec type   $type
    dict set argspec args   $isargs
    dict set argspec vector $isvector

    switch -exact -- $mode {
	required {}
	optional { dict set argspec default $dvalue }
	args     { vector $type ; Set opspec args 1 }
	vector   { vector $type }
    }

    Set      opspec param  $name .
    LappendX opspec params $argspec
}

# # ## ### ##### ######## #############
## Messaging

proc dsl::reader::red {message} {
    string cat \033\[31m$message\033\[0m
}

proc dsl::reader::blue {message} {
    string cat \033\[34m$message\033\[0m
}

proc dsl::reader::cyan {message} {
    string cat \033\[36m$message\033\[0m
}

proc dsl::reader::puts {message} {
    variable importing
    set indent [string repeat {  } $importing]

    ::puts "  - $indent$message"
}

# # ## ### ##### ######## #############
## Templating

proc dsl::reader::TemplateCode {code map} {
    set code [FormatCode $code]

    # Operator blocks first - May contain references to global blocks

    set blocks [Get opspec blocks]
    foreach key [lsort -dict [dict keys $blocks]] {
	set code [TemplateBlock $code $key [dict get $blocks $key]]
    }

    # Global blocks

    set blocks [Get blocks]
    foreach key [lsort -dict [dict keys $blocks]] {
	set code [TemplateBlock $code $key [dict get $blocks $key]]
    }

    # Last minute things

    set code [string map $map $code]

    # Check for use of internal functionality

    if {[string match *aktive_void_fail* $code]} {
	Abort "User code rejected due to forbidden use of internal `aktive_void_fail*` facilities."
    }

    ::return $code
}

proc dsl::reader::TemplateBlock {code key replacement} {
    set needle @@${key}@@

    if {![string match *${needle}* $code]} { ::return $code }
    # Block present.

    set pattern "\n(\S*)$needle"
    if {[string match *\n* $replacement] &&
	[regexp -- $pattern $code -> prefix]
    } {
	# Multi-line expansion expansion is needed and supported
	set replacement [textutil::adjust::indent $replacement $prefix 1]
    }

    string map [list $needle $replacement] $code
}

proc dsl::reader::FormatCode {code} {
    set code [textutil::adjust::undent $code]
    set code [string trim $code]
    ::return $code
}

proc dsl::reader::OkModes {args} {
    if {[Get opmode] ni $args} {
	Abort "Command '[lindex [info level -1] 0]' not allowed for mode [Get opmode]"
    }
}

# # ## ### ##### ######## #############
## State management (changing, querying)

proc dsl::reader::Init {package} {
    variable state {
	argspec {}
	blocks  {}
	imspec  {}
	opmode  {}
	opname  {}
	ops     {}
	opspec  {blocks {}}
	todos   {}
	tops    {}
	types   {}
	vectors {}
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
##  - todos   :: list (string)
##  - types   :: dict (typename -> typespec)
##  - vectors :: dict (typename -> imported)
##  - blocks  :: dict (name -> c-code-fragment)
##  - ops     :: dict (opname -> opspec)
##  - opname  :: string               [Only during collection]
##  - opmode  :: string               [Only during collection]
##  - opspec  :: dict (key -> value)  [Only during collection]
##
## typespec keys
##  - imported   :: bool
##  - critcl     :: string
##  - ctype      :: string
##  - conversion :: string
##  - init       :: string
##  - finish     :: string
##
## opspec keys
##  - lang     :: string	[auto set] C|Tcl
##  - body     :: string	[presence indicates tcl operator]
##  - blocks   :: dict (name -> c-code-fragment)
##  - overlays :: list (overspec)
##  - args     :: bool
##  - images   :: list (imspec)
##  - notes    :: list (string)
##  - section  :: list (string)
##  - param    :: dict (string -> '.') [Only during collection]
##  - params   :: list (argspec)
##  - result   :: string
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
##
## # # ## ### ##### ######## #############
##
## overspec
##   /1/ input overlay-type overlay-action... :: run action if input is of given type
##   /2/ constant MATH-FUNC                   :: return constant, mathfunc applied to input param value
##
## overlay-type
##   @self
##   operator-name
##
## overlay-action
##   pass            :: return input as construction result
##   pass-grandchild :: return input of input as construction result

proc dsl::reader::Abort {x} {
    set opname [Get opname]
    if {$opname ne {}} { set x "Operation $opname: $x" }
    ::return -code error $x
}

# # ## ### ##### ######## #############
return
