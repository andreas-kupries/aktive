#!/usr/bin/env tclsh
# ------------------------------------------------------------------------------
## Decode AKTIVE image files into a plain text form for human inspection

proc main {} {
    do {*}[cmdline]
}

proc cmdline {} {
    global argv
    if {[llength $argv] != 2} usage
    return $argv
}

proc usage {{m {}}} {
    global argv0
    puts stderr "Usage: $argv0 infile outfile"
    if {$m ne {}} { puts stderr "       $m" }
    exit 1
}

proc warn {m} { puts stderr $m ; flush stderr }
proc err  {m} { puts stderr $m ; flush stderr ; exit 1 }

proc do {infile outfile} {
    if {![file exists $infile]} { usage "Input not found: $infile" }
    if {![file isfile $infile]} { usage "Input not a file: $infile" }
    if {$outfile eq "-"} {
	set out stdout
    } else {
	set out [open $outfile w]
    }
    set in [open $infile rb]
    decode $in $out [file size $infile]
}

proc decode {in out fsize} {
    # 32 bytes fixed HEADER
    # - 6 a6 "AKTIVE"
    # - 2 a2 "00"
    # - 4 I  x
    # - 4 I  y
    # - 4 I  w \
    # - 4 I  h  <- w*h*d : C
    # - 4 I  d /
    # - 4 I  metasize : N
    # Variable sized META data string
    # - N a
    # 8 bytes fixed HEADER CLOSE
    # - 8 a8 "AKTIVE_D"
    # Variable sized PIXEL data
    # - X Q

    set header [read $in 32]
    set sn     [string length $header]
    if {$sn < 32} { usage "Short header: $sn, expected 32" }

    set int   I
    set float Q
    set comp  0
    binary scan $header A6A2 magic version
    set header [string range $header 8 end] ; incr sn -8
    if {$magic eq "AKTIVE" && $version eq "LE"} {
	binary scan $header A2 version
	set header    [string range $header 2 end] ; incr sn -2
	append header [read $in 2]                 ; incr sn  2

	set int   i
	set float q
	set comp  2
    }
    if {$version ne "00"} { usage "Bad version '$version', expected '00'" }
    binary scan $header ${int}${int}${int}u${int}u${int}u${int}u x y w h d msize

    #puts stderr "$x $y $w $h $d $msize"
    #exit

    set meta   [read $in $msize]
    set magicb [read $in 8]
    set mn     [string length $magicb]
    if {$mn < 8} { usage "Short header: meta and/or magicb too short" }
    binary scan $magicb A8 magicb
    if {$magicb ne "AKTIVE_D"} { usage "Bad 2nd magic '$magicb', expected 'AKTIVE_D'" }

    set  esize 40                  ;# base header, plus closer
    incr esize $comp               ;# compensation for LE format
    incr esize $msize              ;# meta data
    incr esize [expr {$w*$h*$d*8}] ;# pixels

    if {$fsize != $esize} { warn "Bad file size, have $fsize, expected $esize" }

    # emit readable header

    puts $out "AKTIVE ${w}x${h}x${d} @${x},${y} # [expr {$w*$h*$d}]"
    if {$meta ne {}} {
	puts $out META
	puts $out [encoding convertfrom utf-8 $meta]
	puts $out MEND
    }

    # read, count and emit pixels - row wise, possibly split by pixels for large depth

    if {$d > 10} {
	# pixels by pixel, just depth values
	# loop row*column times

	set n [expr {$d * 8}]
	set c [expr {$w * $h}]

	lassign {0 0} row col
	while {$c} {
	    set values [read $in $n]
	    set vn [string length $values]
	    if {$vn < $n} { err "Short pixel read for cell r$row/c$col, got $vn" }
	    binary scan $values ${float}$d bands
	    puts $out "CELL $row $col = $bands"
	    incr c -1
	    incr col
	    if {$col == $w} { set col 0 ; incr row }
	}
	return
    }

    # pixels by row
    # loop row times

    set f [expr {$w * $d}]
    set n [expr {$f * 8}]
    set c $h

    set row 0
    while {$c} {
	set values [read $in $n]
	set vn [string length $values]
	if {$vn < $n} { err "Short pixel read for row $row, got $vn" }
	binary scan $values ${float}$f rvalues
	puts $out "ROW $row = $rvalues"
	incr c -1
	incr row
    }
    return
}

main
# ------------------------------------------------------------------------------
exit
