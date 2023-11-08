# -*- tcl -*-

foreach path $argv {
    puts "processing $path"

    set chan [open $path]
    while {[gets $chan line] >= 0} {
	set line [string trim $line]
	if {$line eq {}} continue
	if {![string match *micro* $line]} continue

	set cmd     [lindex $line 0]
	set millis  [lindex $line end]

	if {[string match *index* $line]} {
	    set idx [lindex $line 4]
	    set cmd ${cmd}-$idx
	}
	if {[string match *entry* $line]} {
	    upvar 0 h.${cmd}.entry__ hist
	    incr hist($millis)
	    continue
	}
	if {[string match *section* $line]} {
	    upvar 0 h.${cmd}.section hist
	    incr hist($millis)
	    continue
	}
    }
    close $chan
}

proc parray {a} {
    upvar 1 $a array
    if {![array exists array]} {
	return -code error "\"$a\" isn't an array"
    }
    set maxl 0
    set names [lsort -dict [array names array]]
    foreach name $names {
	if {[string length $name] > $maxl} {
	    set maxl [string length $name]
	}
    }
    set maxl [expr {$maxl + [string length $a] + 2}]
    foreach name $names {
	set nameString [format %s(%s) $a $name]
	puts stdout [format "%-*s = %s" $maxl $nameString $array($name)]
    }
}

foreach v [lsort -dict [info globals]] {
    if {![string match h.* $v]} continue
    puts ""

    set names [lsort -dict [array names $v]]
    set nlen [llength $names]
    upvar 0 $v x
    set min Inf
    set max -Inf
    set counts 0
    set millis 0
    foreach n $names {
	incr counts $x($n)
	incr millis [expr {$n * $x($n)}]
	set max [expr {max($max,$n)}]
	set min [expr {min($min,$n)}]
    }
    set mean [format %.0f [expr {double($millis) / $counts}]]
    set t 0 ; foreach n $names { incr t $x($n) ; if {$t>=$counts/2} { set median $n ; break }}

    puts "$v == counts:$counts total:$millis min:$min max:$max mean:$mean median:$median"
    parray $v
    puts ""
}
