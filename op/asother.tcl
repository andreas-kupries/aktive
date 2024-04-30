# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2024 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################

package require debug           ;# Tcllib
package require debug::caller   ;# ditto

debug level  aktive/asother
debug prefix aktive/asother {<[pid]> | }

#debug on     aktive/asother

namespace eval aktive {}

# # ## ### ##### ######## ############# #####################
## Helper walking a DAG and converting into a dict representation.

proc aktive::AsDict {src func} {
    debug.aktive/asother {}

    # Walk the DAG and collect into dict.
    set order {}
    set spec {}
    # id -> 'op'     -> cmd     (string)
    # id -> 'param'  -> param   (dict)
    # id -> 'inputs' -> inputs  (list (ids))
    # id -> 'users'  -> callers (list (ids))

    AsDictWalk $src

    # convert image ids to shorthand atoms
    set order [lmap id $order {
	incr counter ; dict set atom $id $counter ; set counter
    }]

    # rework the entire dict to use atoms instead of ids
    dict for {id def} $spec {
	dict unset spec $id
	dict set def inputs [lmap child [dict get $def inputs] { dict get $atom $child }]
	dict set spec [dict get $atom $id] $def
    }

    # propagate users backwards -- multi-user nodes are shared
    dict for {id def} $spec {
	foreach child [dict get $def inputs] {
	    set v [dict get $spec $child users]
	    lappend v $id
	    dict set spec $child users $v
	}
    }

    # format the collection via the provided emitter
    dict set state last [lindex $order end]
    set lines [$func start state $spec $order]
    foreach id $order {
	lappend lines {*}[$func emit state $id [dict get $spec $id]]
    }
    return [join [$func final state $lines] \n]
}

proc aktive::AsDictWalk {src} {
    debug.aktive/asother {}
    # Recursively walk the dag and collect all the nodes (breadth first)

    upvar 1 spec spec order order

    set id [aktive query id $src]
    if {[dict exists $spec $id]} { return $id }

    set children [aktive query inputs $src]
    set type     [aktive query type   $src]
    set params   [aktive query params $src]

    dict set spec $id op     [string map {:: { }} $type]
    dict set spec $id param  $params
    dict set spec $id inputs [lmap child $children { AsDictWalk $child }]
    dict set spec $id users  {}

    # root after children
    lappend order $id

    return $id
}

# # ## ### ##### ######## ############# #####################
## Helpers emitting various kind of code for a DAG dict rep
## as created by the helper at the top of the file.

namespace eval ::aktive::FromDict {}
namespace eval ::aktive::FromDict::tclscript { namespace export start emit final ; namespace ensemble create }
namespace eval ::aktive::FromDict::d2        { namespace export start emit final ; namespace ensemble create }
namespace eval ::aktive::FromDict::markdown  { namespace export start emit final ; namespace ensemble create }

proc aktive::FromDict::tclscript::start {statevar spec order} {
    debug.aktive/asother {}

    upvar $statevar state
    # compute variable names for all nodes, ahead of time.

    foreach id $order {
	set prefix tmp
	switch -glob -- [dict get $spec $id op] {
	    {read *}       { set prefix file }
	    {image from *} { set prefix virt }
	}
	set vname $prefix$id
	dict set state $id $vname
    }

    dict set state [lindex $order end] result
    return
}

proc aktive::FromDict::tclscript::emit {statevar id spec} {
    debug.aktive/asother {}

    upvar 1 $statevar state
    dict with spec {}
    # op, param, inputs, users

    set inputs [join [lmap i $inputs {
	string cat "\$[dict get $state $i]"
    }] { }]
    if {$inputs ne {}} { set inputs " $inputs" }
    if {$param  ne {}} { set param  " $param" }
    set vname [dict get $state $id]

    set row "set [format %-8s $vname] \[aktive $op$inputs$param\]"
    if {[llength $users] > 1} {
	# map to var names
	set users [lmap i [lsort -integer $users] { dict get $state $i }]
	append row "	;# FO([llength $users]): [join $users {, }]"
    }
    lappend lines $row
    return $lines
}

proc aktive::FromDict::tclscript::final {statevar lines} {
    debug.aktive/asother {}
    return $lines
}

# # ## ### ##### ######## ############# #####################

proc aktive::FromDict::d2::start {statevar spec order} {
    debug.aktive/asother {}

    lappend lines "# -*- d2 -*-"
    lappend lines "direction: left"

    return $lines
}

proc aktive::FromDict::d2::emit {statevar id spec} {
    debug.aktive/asother {}

    upvar 1 $statevar state
    dict with spec {}
    # op, param, inputs, users
    if {[llength $param]} { append op \\n ( $param ) }

    # operator
    lappend lines "${id}: \"aktive $op\""

    # visual formatting -- LOOK into making this configurable
    set color {}
    switch -glob -- $op {
	{read *}       { set shape document ; set color lightgreen }
	{image from *} { set shape hexagon  ; set color lightblue  }
	default        { set shape oval     }
    }
    if {$id eq [dict get $state last]} { set color orange }
    lappend lines "${id}.shape: $shape"
    if {$color ne {}} {
	lappend lines "${id}.style.fill: $color"
    }

    # inbound arrows from inputs
    foreach i $inputs { lappend lines "${i} -> $id" }
    return $lines
}

proc aktive::FromDict::d2::final {statevar lines} {
    debug.aktive/asother {}
    return $lines
}

# # ## ### ##### ######## ############# #####################

proc aktive::FromDict::markdown::start {statevar spec order} {
    debug.aktive/asother {}

    lappend lines "||Id|Command|Config|Inputs|Notes|"
    lappend lines "|:---|:---|:---|:---|:---|:---|"
    return $lines
}

proc aktive::FromDict::markdown::emit {statevar id spec} {
    debug.aktive/asother {}

    upvar 1 $statevar state
    dict with spec {}
    # op, param, inputs, users
    set notes {}
    if {[llength $users] > 1} { set notes "FO([llength $users]): [join $users {, }]" }
    set inputs [join $inputs {, }]

    # some indicators
    set mark {}
    switch -glob -- $op {
	{read *}       { set mark __FILE__ }
	{image from *} { set mark __VIRT__ }
	default        {}
    }
    if {$id eq [dict get $state last]} { set mark __OUT__ }

    append row | $mark | $id |aktive " " $op | $param | $inputs | $notes |
    lappend lines $row
    return $lines
}

proc aktive::FromDict::markdown::final {statevar lines} {
    debug.aktive/asother {}
    return $lines
}

# # ## ### ##### ######## ############# #####################
return

