# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

proc ctable {n ltype} {
    set off 0
    for {set i 0} {$i < $n} {incr i} {
	set ti [format %d $i]
	set ni [string length $ti]

	append  cvt $ti
	lappend len $ni
	lappend at  $off
	incr off $ni
    }

    lappend lines "static const char*    cvt      = \"$cvt\";"
    lappend lines "static const char     len\[$n] = \{[join $len ,]\};"
    lappend lines "static const $ltype at \[$n] = \{[join $at ,]\};"

    join $lines \n
}

touch generated/c8table.c  [ctable   256 uint16_t]
touch generated/c16table.c [ctable 65536 uint32_t]
