# -*- tcl -*-
# ------------------------------------------------------------------------------

package require aktive

# ------------------------------------------------------------------------------

puts ""
puts loaded:\t[join [info loaded] \nloaded:\t]
puts ""
puts "have   aktive v[aktive version] / cpu count [aktive processors]"
puts "shell  [info nameofexecutable]"
puts "script $argv0"
puts ""

# ------------------------------------------------------------------------------

namespace eval tcltest [list variable testsDirectory $tests]

source [file join $tests support builtin.tcl]
source [file join $tests support image.tcl]
source [file join $tests support match.tcl]
source [file join $tests support files.tcl]
source [file join $tests support paths.tcl]

# ------------------------------------------------------------------------------

proc cc.max {ccs} {
    # keep only the max sized cc's
    # -- for perimeters this is the perimeter length
    # -- this may not be the desired perimeter, if the longest is ... curdled (space filling).

    # find max
    set maxarea -1
    dict for {id spec} $ccs {
	set a [dict get $spec area] ; if {$a < $maxarea} continue ; set maxarea $a
    }
    # extract max
    set single {}
    dict for {id spec} $ccs {
	if {[dict get $spec area] < $maxarea} continue
	set single $id
	dict set new $id $spec
    }
    # relabel if single
    if {([dict size $new] == 1) && ($single != 1)} {
	dict set new 1 [dict get $new $single]
	dict unset new $single
    }
    # done
    return $new
}

proc cc.bbox.max {ccs} {
    # keep only the max sized bbox cc's
    # find max
    set bba {}
    set maxarea -1
    dict for {id spec} $ccs {
	set box [dict get $spec box]
	lassign $box xmin ymin xmax ymax
	set w [expr {$xmax - $xmin}]
	set h [expr {$ymax - $ymin}]
	set a [expr {$w * $h}]
	dict set bba $id $a
	#puts BB($id)=$a\t($spec)
	if {$a < $maxarea} continue
	set maxarea $a
    }

    #puts MA.BBOX=|$maxarea|

    # extract max
    set single {}
    dict for {id spec} $ccs {
	if {[dict get $bba $id] < $maxarea} continue
	set single $id
	dict set new $id $spec
	#puts MAX($id)=$spec
    }
    # relabel if single
    if {([dict size $new] == 1) && ($single != 1)} {
	dict set new 1 [dict get $new $single]
	dict unset new $single
    }
    # done
    return $new
}

proc pretty-print-cc {ccs} {
    foreach id [lsort -integer [dict keys $ccs]] {
	lappend lines "$id \{"
	set cc [dict get $ccs $id] ; dict with cc {}
	# xmin, ymin, xmax, ymax, area, parts
	lappend lines "    bb   ($xmin $xmax / $ymin $ymax)"
	lappend lines "    area $area"
	lappend lines "    parts \{"

	set last ""
	set buf ""
	foreach part [lsort -dict $parts] {
	    lassign $part y xmin xmax
	    if {$last eq $y} {
		append buf ", $xmin..$xmax"
	    } else {
		if {$last ne {}} { lappend lines $buf ; set buf "" }
		append buf "        @$y $xmin..$xmax"
	    }
	    set last $y
	}
	lappend lines $buf
	lappend lines "    \}"
	lappend lines "\}"
    }
    join $lines \n
}

proc pretty-print-ccp {ccp} {
    foreach id [lsort -integer [dict keys $ccp]] {
	lappend lines "$id \{"
	set cc [dict get $ccp $id] ; dict with cc {}
	# xmin, ymin, xmax, ymax, length, points, clockwise
	lappend lines "    bb     ($xmin $xmax / $ymin $ymax)"
	lappend lines "    clockw $clockwise"
	lappend lines "    length $length"
	lappend lines "    points \{"

	set last ""
	set buf ""
	set n 0
	foreach point $points {
	    lassign $point x y
	    append buf "($x,$y) "
	    incr n;
	    if {$n == 20} {
		lappend lines "        [string trimright $buf]" ; unset n ; set buf ""
	    }
	}
	lappend lines "        [string trimright $buf]"
	lappend lines "    \}"
	lappend lines "\}"
    }
    join $lines \n
}

# ------------------------------------------------------------------------------

proc skip {args} {}

# ------------------------------------------------------------------------------

proc at  {x y i} { aktive op select x [aktive op select y $i from $y to $y] from $x to $x }
proc atv {x y i} { aktive op swap xz  [at $x $y $i] }

proc gauss {{s 13.3}} { aktive image kernel gauss discrete sigma $s } ;# radius 40

proc smooth {i {s 13.3}} {
    set g [gauss $s]
    set t [aktive op transpose $g]
    set r [expr {([aktive query width $g]-1)/2}]
    set e [aktive op embed mirror $i left $r right $r top $r bottom $r]
    set e [aktive op convolve xy $g $e]
    set e [aktive op convolve xy $t $e]
    return $e
}

proc smooth-s {series {s 13.3} {embed mirror}} {
    set gs [gauss $s]
    set r  [expr {([aktive query width $gs]-1)/2}]
    2series [aktive op convolve xy \
		 $gs [aktive op embed $embed \
			  [2image $series] left $r right $r]]
}

proc threshold {i {r 7}} {
    aktive op math1 invert [aktive image mask per phansalkar $i radius $r]
}

# remove white speckles // 0-rank // min
proc despeckle-white {i {r 5}} {
    set i [aktive op embed mirror $i left $r right $r top $r bottom $r]
    set i [aktive op tile rank $i rank 0 radius 5]
}

proc stretch {i} { aktive op math1 fit min-max $i }
proc rmse  {a b} { aktive op compare rmse $a $b }

proc coords-x {series} { set x -1 ; return [lmap y $series { incr x ; list $x $y }] }
proc coords-y {series} { set y -1 ; return [lmap x $series { incr y ; list $x $y }] }

proc sparse {args} { aktive image from sparse points coords {*}$args }

# 0      -> (at-1)
# (at-1) -> 0
proc flip1 {at v}      { incr at -1 ; expr {$at - $v} }
proc flip  {at series} { incr at -1 ; lmap v $series { expr {$at - $v} } }
proc flip* {at args}   { flip $at $args }

# might be something for the main package
proc zero {i ew eh} {
    lassign [aktive query geometry $i] x y w h _

puts //$x/$y/$w/$h//

    lassign {0 0 0 0} l r t b
    if {$x > 0} { set l $x }
    if {$y > 0} { set t $y }
    set r [expr {$ew - $w - $l}] ; if {$r < 0} { set r 0}
    set b [expr {$eh - $h - $t}] ; if {$b < 0} { set b 0}

puts //$l/$r/$t/$b//

    aktive op embed black $i left $l right $r top $t bottom $b
}

proc int1 {v}      { expr {int($v)} }
proc ints {series} { lmap v $series { expr {int($v)} } }
proc pos  {series} { lmap v $series { expr {$v < 0 ? 0 : $v} } }

proc max {series} { set max -Inf ; foreach v $series { set max [expr {max($max,$v)}] } ; set max }
proc min {series} { set min  Inf ; foreach v $series { set min [expr {min($min,$v)}] } ; set min }

proc clip   {max series} { lmap v $series { expr {min($max,$v)} } }
proc clipsz {sz  series} { incr sz -1 ; clip $sz $series }

# ------------------------------------------------------------------------------
## process exit intercept

proc on-exit {args} { lappend ::__exitcmds $args ; return }

rename exit __exit
proc   exit {args} {
    foreach cmd $::__exitcmds {
	#puts ($cmd)
	{*}$cmd
    }
    __exit {*}$args
}

proc do {script} { uplevel 1 $script }

# ------------------------------------------------------------------------------
## file mgmt

proc base!    {path} { global __basepath ; set __basepath $path ; return }
proc current! {id}   { global __cid      ; set __cid      $id   ; return }
proc current {} { global __cid ; set __cid }

proc find {stem {ext {}}} {
    global __basepath
    set found [glob -tails -directory $__basepath/$stem *$ext]
    lsort -dict [lmap f $found { file rootname $f }]
}

proc phases {entry spec} {
    set fmt %02d

    set k 1
    lappend srcs [format $fmt $k].$entry
    foreach {cmd dst body} $spec {
	incr k
	set dst [format $fmt $k].$dst
	switch -- $cmd {
	    skip - / continue
	    def - = {
		phase [lindex $srcs end] $dst $body
		lappend srcs $dst
	    }
	    pop - ^ {
		set srcs [lrange $srcs 0 end-1]
		phase [lindex $srcs end] $dst $body
		lappend srcs $dst
	    }
	    default continue
	}
    }
}

proc phase {in out body} {
    puts ($in)-->($out)
    foreach file [find {*}$in] {
	current! $file
	if {[file exists [pathof {*}$out]]} continue
	apply [list {in out} $body] $in $out
    }
}

proc skipforfile {stem ext args} {
    if {[file exists [pathof $stem $ext]]} return
    uplevel 1 $args
}

proc pathof {stem ext} {
    global __basepath __cid ; file mkdir $__basepath/$stem ; return $__basepath/$stem/$__cid$ext
}

proc inx {x} { ini {*}$x }
proc ini {stem ext} { inv i $stem $ext ; return $i }
proc inv {var stem ext} {
    upvar 1 $var data
    set reader [dict get {
	.ppm    netpbm
	.pgm    netpbm
	.aktive aktive
	.txt    text
    } $ext]
    puts "$var <-- $reader -- [pathof $stem $ext]"
    set data [r/$reader [pathof $stem $ext]]
    return
}

proc r/netpbm {path} { aktive read from netpbm path $path }
proc r/aktive {path} { aktive read from aktive path $path }
proc r/text   {path} { fileutil::cat $path }

proc outx {x i} { outi $i {*}$x }
proc outi {i stem ext} { outv i $stem $ext }
proc outv {var stem ext} {
    upvar 1 $var img
    set writer [dict get {
	.ppm    ppm
	.pgm    pgm
	.aktive aktive
	.txt    text
    } $ext]
    w/$writer $img [pathof $stem $ext]
    return
}

proc w/ppm    {i path} { to $path $i aktive format as ppm byte }
proc w/pgm    {i path} { to $path $i aktive format as pgm byte }
proc w/aktive {i path} { to $path $i aktive format as aktive }
proc w/text   {i path} { fileutil::writeFile $path $i }

package require fileutil
# ------------------------------------------------------------------------------

proc wr {path text} {
    puts "writing $path"
    set c [open $path w]
    puts -nonewline $c $text
    close $c
    return $text
}

proc ! {label args} {
    upvar 1 $label i ; set i [uplevel 1 $args]
}

proc !g {label args} { append label .pgm    ; gw $label [uplevel 1 $args] }
proc !c {label args} { append label .ppm    ; cw $label [uplevel 1 $args] }
proc !a {label args} { append label .aktive ; aw $label [uplevel 1 $args] }

proc gw {label i} { to $label $i aktive format as pgm byte }
proc cw {label i} { to $label $i aktive format as ppm byte }
proc aW {label i} { to $label $i aktive format as aktive   }

proc !file {label srcpath} {
    append label .ppm
    puts "$srcpath --> $label"
    exec convert $srcpath $label
    def $label
}

proc !jg {dstpath label} {
    append label .pgm
    puts "$label --> $dstpath"
    exec convert $label $dstpath
}

proc !jc {dstpath label} {
    append label .ppm
    puts "$label --> $dstpath"
    exec convert $label $dstpath
}

proc to {path src args} {
    #def $path
    puts "[desc $src] --> $path"
    set dst [open $path w]
    lappend args 2chan $src into $dst
    uplevel 1 $args
    close $dst
}

# ------------------------------------------------------------------------------

proc g {label} { append label .pgm    ; p* $label }
proc c {label} { append label .ppm    ; p* $label }
proc a {label} { append label .aktive ; a* $label }

proc p* {path} { puts "<-- $path" ; aktive read from netpbm path $path }
proc a* {path} { puts "<-- $path" ; aktive read from aktive path $path }

# ------------------------------------------------------------------------------

proc = {label args} {
    upvar 1 $label i ; set i [uplevel 1 $args]
    puts ${label}=$i
}

proc head     {series} { lindex $series 0 }
proc tail     {series} { lindex $series end }
proc 2iseries {image} { ints [aktive query values $image] }
proc 2series  {image} { aktive query values $image }
proc 2image   {series} { aktive op lut from values {*}$series }

# ------------------------------------------------------------------------------
## tmp file management

set __tmps {}
proc def {label} { global __tmps ; lappend __tmps $label }
proc keep {} { set ::__tmps {} }

on-exit apply {{} {
    global __tmps
    foreach tmp [lsort -dict [lsort -unique $__tmps]] { file delete $tmp }
}}

# ------------------------------------------------------------------------------
## Photo display support

set ::__photo {} ;# last created photo for display

if 0 {proc pvs {is args} {
    set itail [lassign $is   ifirst]
    set ntail [lassign $args nfirst]
    pv $ifirst $nfirst
    foreach n $ntail i $itail { pv+ $i $n }
    return
}}

#proc pv  {i {title {}}} { window ; view $i $title }
#proc pv+ {i {title {}}} {          view $i $title }

proc view {i title} {
    package require aktive::tk

    global __photo
    set    __photo [aktive tk photo $i]

    set w [window/last]
    set n [id/new]

    ### TODO ### canvas based, auto-scrolling ### proper package
    frame $w.f$n
    label $w.f$n.t -text  $title   ; pack $w.f$n.t -fill both -side top
    label $w.f$n.p -image $__photo ; pack $w.f$n.p -fill both -side top -expand 1
    pack  $w.f$n -fill both -side left -expand 1
    # allow chaining
    return $i
}

# ------------------------------------------------------------------------------
## Plot display support

set ::__plot {} ;# last created plot for display
set ::__plots 1

proc plots! {e} { set ::__plots $e ; return }
proc plots? {}  { if {$::__plots} return ; return -code return }

# ------------------------------------------------------------------------------

proc plot {} {
    plots?
    package require aktive::plot

    set w [window/last]
    set n [id/new]

    global __plot
    set    __plot $w.plot$n

    aktive::plot $__plot
    pack         $__plot -expand 1 -fill both -side left

    return $w.plot$n
}

proc plot/last {} { return $::__plot }

# ------------------------------------------------------------------------------

proc plot/series {series args} { plots? ; [plot/last] add        $series {*}$args }
proc plot/xy     {points args} { plots? ; [plot/last] add-xy     $points {*}$args }
proc plot/hline  {y w args}    { plots? ; [plot/last] horizontal $y 0 $w {*}$args }
proc plot/vline  {x h args}    { plots? ; [plot/last] vertical   $x 0 $h {*}$args }
proc plot/rect   {rect args}   { plots? ; [plot/last] add-rect   $rect   {*}$args }
proc plot/marks  {points args} { plots? ; [plot/last] add-marks  $points {*}$args }

# ------------------------------------------------------------------------------
if 0 {
    proc plot0 {} { plots? ; window/new ; plot/new ; return }
    proc plotn {} { plots? ;              plot/new ; return }

    proc plot    {series args} { plots? ; window/new  ; [plot/new] add $series {*}$args }
    proc plot/w+ {series args} { plots? ;               [plot/new] add $series {*}$args }
    proc plot+   {series args} { plots? ; [plot/last]              add $series {*}$args }
    #
    proc plotxy    {series args} { plots? ; window/new; [plot/new ] add-xy $series {*}$args }
    proc plotxy/w+ {series args} { plots? ;             [plot/new ] add-xy $series {*}$args }
    proc plotxy+   {series args} { plots? ;             [plot/last] add-xy $series {*}$args }
    #
    proc plot+v  {x h args}    { plots? ; [plot/last] vertical   $x 0 $h -color black {*}$args }
    proc plot+h  {y w args}    { plots? ; [plot/last] horizontal $y 0 $w -color black {*}$args }
}
# ------------------------------------------------------------------------------
## Window support, used by photo and plot display

set ::__wincount 0  ;# number of open windows
set ::__winlast     {} ;# last created toplevel

proc window {{title {}}} {
    package require Tk
    wm withdraw .

    global __wincount __winlast

    set  __winlast     .t[id/new]
    incr __wincount

    toplevel    $__winlast
    wm protocol $__winlast WM_DELETE_WINDOW [list window/done $__winlast]

    if {$title eq {}} return
    wm title $__winlast $title
    return
}

proc window/last {} { global __winlast ; return $__winlast }

proc window/done {w} {
    global __wincount
    destroy $w
    incr __wincount -1
    return
}

on-exit apply {{} {
    global __wincount
    while {$__wincount} { puts windows=$__wincount ; vwait ::__wincount }
    return
}}

# ------------------------------------------------------------------------------

set ::__counter 0  ;# id counter for windows, photos, labels, etc.

proc id/new  {} { global __counter ; incr __counter ; return $__counter }
proc id/last {} { global __counter ;                  return $__counter }

# ------------------------------------------------------------------------------

proc perf {label sz args} {
    set base [clock milliseconds]

    set r [uplevel 1 $args]

    set delta [expr {[clock milliseconds] - $base}]

    set vms [expr {double($sz) / double ($delta)}]
    set msv [expr {double ($delta) / double($sz)}]

    puts "perf: $label ($sz values) :: $delta millis :: $vms v/ms :: $msv ms/v"
    return $r
}

# ------------------------------------------------------------------------------

proc null       {src} { aktive format as null   2string $src }
proc nulls      {src} { aktive format as null-s 2string $src }
proc ppm   {path src} { to $path $src aktive format as ppm byte }
proc pgm   {path src} { to $path $src aktive format as pgm byte }
proc ppm16 {path src} { to $path $src aktive format as ppm short }
proc pgm16 {path src} { to $path $src aktive format as pgm short }
proc ppmt  {path src} { to $path $src aktive format as ppm text }
proc pgmt  {path src} { to $path $src aktive format as pgm text }
proc ppmet {path src} { to $path $src aktive format as ppm etext }
proc pgmet {path src} { to $path $src aktive format as pgm etext }
proc akt   {path src} { to $path $src aktive format as aktive }
proc ppms  {src} { aktive format as ppm text 2string $src }
proc pgms  {src} { aktive format as pgm text 2string $src }
proc akts  {src} { aktive format as aktive   2string $src }

# ------------------------------------------------------------------------------

proc rgb {r g b} { aktive op montage z $r $g $b }

proc graybig  {} { aktive image gradient width 256 height 256 depth 1 first 0 last 1 }
proc colorbig {} { set r [graybig] ; rgb $r [aktive op rotate cw $r] [aktive op rotate half $r] }
proc sines {} { rgb \
		    [aktive image sines width 256 height 256 hf 0.3 vf 0.4] \
		    [aktive image sines width 256 height 256 hf 2   vf 0.5] \
		    [aktive image sines width 256 height 256 hf 1   vf 3] }

proc dots {i {n 8}} { aktive op sample replicate xy $i by $n }

proc desc {i} { return "[aktive query type $i] ([aktive query params $i])" }

proc showbasic {label i} {
    puts "$label = [aktive query id $i] [aktive query type $i] \{"
    puts "  pa ([aktive query params $i])"
    puts "  x,y [aktive query x $i]..[aktive query xmax $i],[aktive query y $i]..[aktive query ymax $i]"
    puts "  whd [set w [aktive query width $i]] x [set h [aktive query height $i]] x [set d [aktive query depth  $i]]"
    puts "\}"
    flush stdout
}

proc showgeo {label i} {
    lassign [aktive query domain $i] x y w h d
    puts "$label = [aktive query id $i] $w x $h x $d @$x,$y"
    flush stdout
}

proc dag {i} { set count 0 ; set have {} ; dagc $i }
proc dagc {i {indent {}}} {
    upvar 1 have have count count
    set id [aktive query id $i]
    if {[dict exists $have $id]} { puts "      :: ${indent}---> [dict get $have $id]" ; return }
    incr count ; set me $count
    dict set have $id $count

    puts "[format %5d $count] :: $indent$id  [aktive query type $i] ([aktive query params $i])"
    set children [aktive query inputs $i]
    if {![llength $children]} {
	puts "      :: ${indent}***"
	return
    }
    foreach x $children { dagc $x "$indent  " }
    puts "      :: ${indent}\\-- $me"
}

proc insn {i} {
    upvar 1 have have count count

    set id [aktive query id $i]
    if {![info exists have] || ![dict exists $have $id]} {
	set cids [join [lmap child [aktive query inputs $i] {
	    string cat "\$i" [insn $child]
	}] { }]
	if {$cids ne {}} { set cids " $cids" }

	set pa [aktive query params $i]
	if {$pa ne {}} { set pa " $pa" }

	set op [string map {:: { }} [aktive query type $i]]

	incr count
	puts "set [format %6s i$count] \[aktive $op$cids$pa\]"

	dict set have $id $count
    }

    return [dict get $have $id]
}

proc show {i {scale {}}} {
    puts "[aktive query type $i] \{"
    puts "  pa ([aktive query params $i])"
    if 0 {foreach x [aktive query inputs $i] {
	set x [aktive format as tcl $x]
	dict unset x pixels
	puts "  in ($x)"
    }}
    flush stdout
    puts "  x,y [aktive query x $i]..[aktive query xmax $i],[aktive query y $i]..[aktive query ymax $i]"
    puts "  whd [set w [aktive query width  $i]] x [set h [aktive query height $i]] x [set d [aktive query depth  $i]]"
    flush stdout

    set pi [aktive query pitch  $i]
    puts "  pi  $pi"

    puts -nonewline "\n\t= "
    set k 0
    foreach v [aktive query values $i] {
	if {$k} {
	    if {($k % $pi) == 0} {
		puts -nonewline "\n\t= "
	    } elseif {($k % $d) == 0} {
		puts -nonewline " ="
	    }
	}

	if {$scale ne {}} {
	    set v [expr {$v * $scale}]
	    puts -nonewline " [format %3.0f $v]"
	} else {
	    puts -nonewline " [format %8.4f $v]"
	}
	incr k
    }
    puts ""
    flush stdout
    puts "\}"
    puts ""
}

# ------------------------------------------------------------------------------
## validate memory, if supported by the interpreter

catch { memory validate on }

# ------------------------------------------------------------------------------
return
