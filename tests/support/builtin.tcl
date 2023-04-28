# -*- tcl -*-
## (c) 2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands - Standard images for tests

proc mdbase {} {
    aktive meta create [grad] \
	hello world \
	foo bar \
	mode 1 \
	max 33
}

# grad -- input/gradient 3x4x2
##
##       0 ....   1......   2...... --- 3 columns
##     --------  --------  --------
#	 1  1.5    2  2.5    3  3.5  0
#	 4  4.5    5  5.5    6  6.5  1
#	 7  7.5    8  8.5    9  9.5  2
#	10 10.5   11 11.5   12 12.5  3
##     --- ----  --- ----  --- ----  \- 4 rows
##      0. 1...   0. 1...   0. 1... --- 2 bands

proc grad   {}  { aktive image gradient    width 3 height 4 depth 2 first 1 last 12.5 }
proc flat   {x} { aktive image from value  width 3 height 4 depth 2 value $x }
proc bands  {}  { aktive image from bands  width 4 height 2 value 1 2 3 }
proc matrix {}  { aktive image from matrix width 4 height 2 value 1 2 3 4  5 6 7 8 }

proc gradx {} { aktive image gradient width 20 height  1 depth  1  first 0 last 19 }
proc grady {} { aktive image gradient width  1 height 20 depth  1  first 0 last 19 }
proc gradz {} { aktive image gradient width  1 height  1 depth 20  first 0 last 19 }

proc graybox {} {
    aktive image gradient width 8 height 8 depth 1 first 0 last 1
}

proc colorbox {} {
    set r [graybox]
    set g [aktive op rotate cw   $r]
    set b [aktive op rotate half $r]
    aktive op montage z $r $g $b
}

proc 1pixel {bands} { aktive image from bands width 1 height 1 values {*}$bands }
proc cci {to _ from src}   { check aktive op color $from to $to $src }
proc cc  {to _ from bands} { pixels/ [cci $to <- $from [1pixel $bands]] }

foreach dst {
    sRGB scRGB HSV HSL XYZ Yxy Lab LCh
} {
    interp alias {} ${dst}/i {} cci $dst
    interp alias {} ${dst}   {} cc  $dst
}

proc foreach-color {n colors iv bv script} {
    upvar 1 $iv image $bv bands

    while {[llength $colors]} {
	set bands  [lrange $colors 0  ${n}-1]
	set colors [lrange $colors $n end   ]
	set image  [1pixel $bands]
	uplevel 1 $script
    }
}

proc vectors {space} {
    set space [string tolower $space]
    set values [split [string trim [catx [A webcolors-${space}.txt]]]]
    set values [lmap x $values { if {$x eq {}} continue ; set x }]
    #if {$space in {srgb scrgb hsv hsl}} { set values [u8f $values] }
    return [lmap {a b c} $values { list $a $b $c }]
}

proc webcolors {} {	;# web color sRGB image
    lassign [webcolor-fp-planes] rs gs bs
    set w [llength $rs]
    # Construct image planes
    set r [aktive image from matrix width $w height 1 value {*}$rs]
    set g [aktive image from matrix width $w height 1 value {*}$gs]
    set b [aktive image from matrix width $w height 1 value {*}$bs]
    # And aggregate into single color image
    set i [aktive op montage z $r $g $b]
    #proc webcolors {} [list return $i]
    return $i
}

proc webcolor-fp-planes {} {	;# [0..1] color planes, memoized
    foreach {r g b} [webcolor-table-fp] {
	lappend rs $r
	lappend gs $g
	lappend bs $b
    }
    proc webcolor-fp-planes {} [list list $rs $gs $bs]
    list $rs $gs $bs
}

proc webcolor-table-fp {} {	;# double 3-tuples, [0..1], memoized
    set floats [u8f [webcolor-table]]
    proc webcolor-table-fp {} [list return $floats]
    return $floats
}

proc webcolor-table {} {	;# uint8 3-tuples, [0..255]
    return [split [catx [A webcolors-rgb.txt]]]

    return {
	0   0   0    0   0   51   0   0   102  0   0   153  0   0   204  0   0   255  0   51  0    0   51  51
	0   51  102  0   51  153  0   51  204  0   51  255  0   102 0    0   102 51   0   102 102  0   102 153
	0   102 204  0   102 255  0   153 0    0   153 51   0   153 102  0   153 153  0   153 204  0   153 255
	0   204 0    0   204 51   0   204 102  0   204 153  0   204 204  0   204 255  0   255 0    0   255 51
	0   255 102  0   255 153  0   255 204  0   255 255  51  0   0    51  0   51   51  0   102  51  0   153
	51  0   204  51  0   255  51  51  0    51  51  51   51  51  102  51  51  153  51  51  204  51  51  255
	51  102 0    51  102 51   51  102 102  51  102 153  51  102 204  51  102 255  51  153 0    51  153 51
	51  153 102  51  153 153  51  153 204  51  153 255  51  204 0    51  204 51   51  204 102  51  204 153
	51  204 204  51  204 255  51  255 0    51  255 51   51  255 102  51  255 153  51  255 204  51  255 255
	102 0   0    102 0   51   102 0   102  102 0   153  102 0   204  102 0   255  102 51  0    102 51  51
	102 51  102  102 51  153  102 51  204  102 51  255  102 102 0    102 102 51   102 102 102  102 102 153
	102 102 204  102 102 255  102 153 0    102 153 51   102 153 102  102 153 153  102 153 204  102 153 255
	102 204 0    102 204 51   102 204 102  102 204 153  102 204 204  102 204 255  102 255 0    102 255 51
	102 255 102  102 255 153  102 255 204  102 255 255  153 0   0    153 0   51   153 0   102  153 0   153
	153 0   204  153 0   255  153 51  0    153 51  51   153 51  102  153 51  153  153 51  204  153 51  255
	153 102 0    153 102 51   153 102 102  153 102 153  153 102 204  153 102 255  153 153 0    153 153 51
	153 153 102  153 153 153  153 153 204  153 153 255  153 204 0    153 204 51   153 204 102  153 204 153
	153 204 204  153 204 255  153 255 0    153 255 51   153 255 102  153 255 153  153 255 204  153 255 255
	204 0   0    204 0   51   204 0   102  204 0   153  204 0   204  204 0   255  204 51  0    204 51  51
	204 51  102  204 51  153  204 51  204  204 51  255  204 102 0    204 102 51   204 102 102  204 102 153
	204 102 204  204 102 255  204 153 0    204 153 51   204 153 102  204 153 153  204 153 204  204 153 255
	204 204 0    204 204 51   204 204 102  204 204 153  204 204 204  204 204 255  204 255 0    204 255 51
	204 255 102  204 255 153  204 255 204  204 255 255  255 0   0    255 0   51   255 0   102  255 0   153
	255 0   204  255 0   255  255 51  0    255 51  51   255 51  102  255 51  153  255 51  204  255 51  255
	255 102 0    255 102 51   255 102 102  255 102 153  255 102 204  255 102 255  255 153 0    255 153 51
	255 153 102  255 153 153  255 153 204  255 153 255  255 204 0    255 204 51   255 204 102  255 204 153
	255 204 204  255 204 255  255 255 0    255 255 51   255 255 102  255 255 153  255 255 204  255 255 255
    }
}
