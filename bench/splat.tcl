#!/usr/bin/env tclsh

puts "version,suite,round,name,sink,thread,size,pitch,aspect,paspect,width,height,depth"

incr first
while {![eof stdin]} {
    if {[gets stdin line] < 0} continue
    if {[string match *tcl-version* $line]} continue

    set line [split $line ,]
    set line [lmap field $line { string trim $field \" }]

    lassign $line shell version suite round label micros

    set suite [file join {*}[lrange [file split $suite] end-1 end]]

    set label [split $label /]
    lassign $label name sink thread size pitch aspect paspect w h d __

    if 1 {
	set thread  [string range $thread  1 end]
	set size    [string range $size    2 end]
	set pitch   [string range $pitch   1 end]
	set aspect  [string range $aspect  1 end]
	set paspect [string range $paspect 2 end]
	set w       [string range $w       1 end]
	set h       [string range $h       1 end]
	set d       [string range $d       1 end]
    }

    if {![string match *:* $aspect]} {
	set aspect $aspect/1
    } else {
	set aspect [join [split $aspect :] /]
    }
    if {![string match *:* $paspect]} {
	set paspect $paspect/1
    } else {
	set paspect [join [split $paspect :] /]
    }

    puts [join [list $version $suite $round $name $sink $thread $size $pitch $aspect $paspect $w $h $d $micros] ,]
}
