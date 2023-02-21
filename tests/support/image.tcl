# -*- tcl -*-
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands -- Image Matching

proc 4f {xs} { lmap x $xs { format %.4f $x }}

# Run image operation. Record operation (coverage)

proc check {args} {
    if 0 {if {[lindex $args 0] eq "aktive"} {
	set ws [lmap w $args { skiparg $w ; set w }]
	puts "AKTIVE [join $ws ::]"
    }}
    {*}$args
}

proc skiparg {w} {
    if {$w eq "<aktive::image>"} { return -code continue }
    if {[numbers $w]}            { return -code continue }
    return
}

proc numbers {w} {
    if {[string is double $w]} { return 1 }
    foreach x $w { if {![string is double $x]} { return 0 } }
    return 1
}

# Get image Tcl representation

proc astcl  {args} { astcl/ [check {*}$args] }
proc astcl/ {i}    { aktive format tcl $i }

# Get image input graph

proc dag  {args} { dag/ [{*}$args] }
proc dag/ {i} {
    lappend r [aktive query type   $i]
    lappend r [aktive query id     $i]
    lappend r [aktive query params $i]
    foreach c [aktive query inputs $i] { lappend r [dag/ $c] }
    return $r
}

# Construct image in tcl representation for comparisons
proc makei {op x y w h d config pixels} {
    dict set domain x      $x
    dict set domain y      $y
    dict set domain width  $w
    dict set domain height $h
    dict set domain depth  $d

    dict set i type   $op
    dict set i domain $domain
    if {$config ne {}} { dict set i config $config }
    dict set i pixels $pixels

    return $i
}

##
# # ## ### ##### ######## ############# #####################
return
