#! /usr/bin/env tclsh
# -*- tcl -*-
# # ## ### ##### ######## ############# #####################

## Raster editor using a point cloud on a canvas, actually circles of
## varying radii. This is converted into an actual raster image by
## means of SDF circles. All circles with a common radius are placed
## into one SDF image, the set of images for all radii is then merged
## through a union operation, and the result saved.

# # ## ### ##### ######## ############# #####################
## Bindings
#
# Button-1 and hold : Create new point at mouse position, until button release.
# Button-2 and hold : Remove point at mouse position, until button release.

# # ## ### ##### ######## ############# #####################
## Requirements

package require Tcl 8.5-

package require Tk
package require canvas::edit::points
package require canvas::track::circle
package require aktive

# # ## ### ##### ######## ############# #####################
## configuration

set drawwidth  600
set drawheight 800

# # ## ### ##### ######## ############# #####################
## Radius management

set radius    50	;# current radius
set shadow    50	;# backup to revert bad changes
set threshold  5	;# half radius for overlap
set timer     {}	;# radius to tracker delay

trace add variable radius write {apply {{name detail op} {
    global shadow radius threshold timer
    if {![string is int -strict $radius]} { set radius $shadow ; return }
    set threshold [expr {$radius / 2.}]
    EDITOR configure -radius $radius
    catch { after cancel $timer }
    set timer [after 200 tracker]
    return
}}}

# # ## ### ##### ######## ############# #####################
## Engine state - Support code

set last   {}	;# last new point           :: extended point data
set points {}	;# all points               :: list (point data...)
set tagged {}   ;# item mapping             :: dict (point tag -> point data),
#               ;# point data               :: list (x y radius)
#               ;# extended point data      :: list (x y radius tag)
set toremove {} ;# tags of points to remove :: list (tag...)

proc distance {x y px py args} { expr {hypot($x-$px,$y-$py)} }

# naive search -- for large clouds look towards kd-tree or similar
proc min-distance {x y} {
    global points
    set min Inf
    foreach p $points {
	set d [distance $x $y {*}$p] ; if {$d >= $min} continue ; set min $d
    }
    return $min
}

# # ## ### ##### ######## ############# #####################
## GUI

set w .plot
catch {destroy $w}
wm withdraw .

toplevel       $w
wm title       $w "Raster Editor"
wm iconname    $w "RED"

label  $w.msg -text {} -relief raised -bd 2 -anchor w

button $w.exit   -command ::exit -text Exit
button $w.save   -command save   -text Save
button $w.clear  -command clear  -text Clear
button $w.five   -command { set radius  5 } -text 5
button $w.ten    -command { set radius 10 } -text 10
button $w.twenty -command { set radius 20 } -text 20
button $w.fifty  -command { set radius 50 } -text 50

canvas $w.c     -relief raised -bd 2 -width $drawwidth -height $drawheight
entry  $w.rad   -relief sunken -bd 2 -bg white -textvariable radius

# # ## ### ##### ######## ############# #####################

grid rowconfigure    $w 0 -weight 0
grid rowconfigure    $w 1 -weight 0
grid rowconfigure    $w 2 -weight 1

grid columnconfigure $w 0 -weight 0
grid columnconfigure $w 1 -weight 1
grid columnconfigure $w 2 -weight 0
grid columnconfigure $w 3 -weight 0
grid columnconfigure $w 4 -weight 0
grid columnconfigure $w 5 -weight 0
grid columnconfigure $w 6 -weight 0
grid columnconfigure $w 7 -weight 0

grid $w.msg    -row 0 -column 0 -columnspan 8 -sticky swen
grid $w.exit   -row 1 -column 0               -sticky swen
grid $w.rad    -row 1 -column 1               -sticky swen
grid $w.five   -row 1 -column 2               -sticky swen
grid $w.ten    -row 1 -column 3               -sticky swen
grid $w.twenty -row 1 -column 4               -sticky swen
grid $w.fifty  -row 1 -column 5               -sticky swen
grid $w.save   -row 1 -column 6               -sticky swen
grid $w.clear  -row 1 -column 7               -sticky swen
grid $w.c      -row 2 -column 0 -columnspan 8 -sticky swen

# # ## ### ##### ######## ############# #####################
## Setup the behavioral triggers and responses ...

canvas::edit  points EDITOR $w.c -mode draw -data-cmd M -radius $radius
canvas::track circle TC     $w.c
TC radius $radius

# dispatch data commands from the engine
proc M {args} { ;#puts [info level 0]
    message $args ; set args [lassign $args c] ; M/$c {*}$args
}

# mouse track - adding points ends - clear state
proc M/add-end {_} { global last ; set last {} }

# mouse track - adding points - check for admittance
proc M/add-query {_ x y} { ;# puts [info level 0]
    global last threshold drawwidth drawheight
    # reject fast when going outside of the drawing area
    if {$x < 0 || $x >= $drawwidth || $y < 0 || $y >= $drawheight} { return 0 }
    # reject fast if not far enough away from the last admitted point of the track
    if {($last ne {}) && ([distance $x $y {*}$last] <= $threshold)} { return 0 }
    # not bailed - check everything for deep overlap
    if {[min-distance $x $y] < $threshold} { return 0 }
    # admitted
    return 1
}

# mouse track - adding points - actual placement, was admitted
proc M/add {_ tag x y} { ;# puts [info level 0]
    global points tagged last radius
    set last [list $x $y $radius]
    dict set tagged $tag $last
    lappend  last   $tag ; lappend points $last
    return
}

# mouse track - removing points ends, nothing to do
proc M/remove-end {_} { }

# mouse track - removing points - locate points at mouse position within circle
proc M/remove-query {_ x y} {
    global points radius
    # locate and return points to remove -- naive
    ## TODO :: expose kd-tree to Tcl, range query - more difficult to remove entries
    lmap p $points {
	lassign $p px py pradius
	if {$radius <= [distance $x $y $px $py]} continue
	lindex $p end ;# report just tags
    }
}

# mouse track - removing points - remove point identified by tag
proc M/remove {_ tag} { ;# puts [info level 0]
    global tagged points
    dict unset tagged $tag
    set points [lmap p $points {
	if {[lindex $p end] eq $tag} continue ;# == skip
	set p
    }]
    return
}

# move/drag activity - should not happen
proc M/move {method args} { error SNH }

# # ## ### ##### ######## ############# #####################
##

proc message {text} {
    global w ; $w.msg configure -text $text
    after 100 { $w.msg configure -text {} }
}

proc tracker {} { global radius ; TC radius $radius ; return }

proc clear {} {
    EDITOR clear
    global                points tagged toremove last
    lassign {{} {} {} {}} points tagged toremove last
}

proc save {} {
    global points drawwidth drawheight
    if {![llength $points]} { message "Nothing to save" ; return }

    set path [tk_getSaveFile \
		  -title "Save to PGM" \
		  -defaultextension .pgm]
    if {$path eq {}} {
	message "Saving canceled"
	return
    }

    dict for {radius centers} [byradius $points] {
	lappend layers \
	    [aktive image sdf circles \
		 width $drawwidth height $drawheight \
		 radius $radius centers {*}$centers]
    }
    if {[llength $layers] > 1} {
	set result [aktive op sdf or {*}$layers]
    } else {
	set result [lindex $layers 0]
    }
    # sdf generated black on white - make it white on black
    set result [aktive op math1 invert $result]
    # and save ...
    aktive format as pgm byte 2file $result into $path
    message "Saved to $path"
    #after 500 clear
}

proc byradius {points} {
    set centers {}
    foreach p $points {	lassign $p x y r _ ; dict lappend centers $r [list $x $y] }
    return $centers
}

# # ## ### ##### ######## ############# #####################
## Invoke event loop.

EDITOR enable

vwait __forever__
exit
