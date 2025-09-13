# -*- tcl -*-
#
# Benchmark tooling to
# - return a common set of testable configurations.
# - run a specific command through the configurations.
#
# (c) 2025 Andreas Kupries <andreas_kupries@users.sourceforge.net>

proc configurations {args} {
    # varying sinks ... unordered, ordered/sequential
    foreach sink {
	null
	null-s
    } {
	#bench_puts "Sink: $sink"

	# varying concurrency ... unthreaded, threads up to num cpu cores, then overcommitted cpu ...
	foreach cores {
	    -1 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
	} {
	    #puts "Sink: $sink Core: $cores"

	    # varying sizes ... small to large
	    foreach size {
		1 10 100 1000 10000 100000 1000000 10000000
	    } { ;#       1K   10K   100K   1M      10M
		#puts "Sink: $sink Core: $cores Size: $size"

		# varying shapes of the same size ... tall to wide
		for {
		    set h $size
		    set w 1
		} {
		   $h > 0
	        } {
		    set w [expr {$w*10}]
		    set h [expr {$h/10}]
		} {
		    #puts "Sink: $sink Core: $cores Size: $size WXH: $w x $h"

		    # ... run the bench
		    {*}$args $cores [iter $size] $sink $w $h $size [aspect $w $h]
		}
	    }

	    #aktive processors 0
	}
    }

    return
}

proc iter {size} {
    return [dict get {
	1         1000
	10        1000
	100       1000
	1000      1000
	10000      100
	100000      10
	1000000      1
	10000000     1
    } $size]
}

proc aspect {w h} {
    set aspect [expr {$w/$h}]
    if {$aspect == 0} {
	return 1:[expr {$h/$w}]
    } else {
	return ${aspect}:1
    }
}

proc generate {file code} {
    puts "Generating $file ..."
    file mkdir [file dirname $file]

    set    ch [open $file w]
    puts  $ch "# -*- tcl -*- tcl.tk//DSL tclbench//EN// Tcl Benchmark File"
    puts  $ch [map [string trim {
	# clear trace files from previous benchmark
	file delete {*}[glob -nocomplain -type f *.trace]
	#
	kb::check   Tcl 8.6
	kb::require support   debug
	kb::local   benchmark aktive
    }] "\n\t" "\n"]
    puts  $ch {bench_puts "[join [info loaded] \n]"}
    puts  $ch $code
    close $ch
    return
}

proc map {s args} { string map $args $s }

proc op-bench {spec} {
    set spec [string trim $spec]
    set cmd  [string map {{ // } { }} $spec]
    set op   [string trim [regsub {//.*$} $spec {}]]

    configurations apply {{
	cmd op cores iter sink w h size aspect
    } {
	set label [list $op $sink $cores $size $aspect $w $h]
	set cmd   [string map [list %W $w %H $h] $cmd]
	set lsink [dict get {
	    null   unordered
	    null-s sequential
	} $sink]

	set base [file root [info script]]

	generate generated/$base/${lsink}_cpu${cores}_w${w}_h${h}.bench \
	    [map {
		aktive processors %cores%
		bench_puts {SINK       %sink%}
		bench_puts {CORES      %cores%}
		bench_puts {ITERATIONS %iter%}
		bench_puts {WIDTH      %width%}
		bench_puts {HEIGHT     %height%}
		#
		bench -iter %iter% -desc {%label%} -pre {
		    set i [%cmd%]
		} -body {
		    aktive format as %sink% 2string $i
		} -post {
		    unset i
		}
	    }    %cores%      $cores \
		 %iter%       $iter  \
		 %label%      $label \
		 %sink%       $sink  \
		 %cmd%        $cmd   \
		 %width%      $w     \
		 %height%     $h     \
		 "\n\t\t"     "\n"]
	#
    }} $cmd $op
    return
}





# -----------------------------------------------------------------------------

if 0 {
    set maxp [aktive processors 0]

# depth == 1
    ##
    #   #geometries x #concurrencies
    # = 21          x ((16+1) x 2)
    # = 21          x 34
    # = 714
    ##
    # # ## ### #####
    ##
    # = 21          x ((8+1) x 2)
    # = 21          x 18
    # = 378

    set configs {}

    foreach {w h} {
	- -----------------/1
	1    1
	- -----------------/10
	1   10
	10   1
	- -----------------/100
	1   100
	10   10
	100   1
	- -----------------/1,000
	1   1000
	10   100
	100   10
	1000   1
	- -----------------/10,000
        1   10000
	10   1000
	100   100
	1000   10
	10000   1
	- -----------------/100,000
	1   100000
        10   10000
	100   1000
	1000   100
	10000   10
	100000   1
	- -----------------/1,000,000
	1   10000000
	10   1000000
        100   100000
	1000   10000
	10000   1000
	100000   100
	1000000   10
	10000000   1
	- -----------------/10,000,000
	1   1000000000
	10   100000000
	100   10000000
        1000   1000000
	10000   100000
	100000   10000
	1000000   1000
	10000000   100
	100000000   10
	1000000000   1
	- -----------------
    } {
	if {$w eq "-"} continue
	# # ## ### ##### ######## #############

	set size   [expr {$w*$h}]
	set aspect [expr {$w/$h}]
	if {$aspect == 0} {
	    set aspect 1:[expr {$h/$w}]
	} else {
	    set aspect ${aspect}:1
	}

	# -1 => threading disabled, no threads.
	#  0 => threads = #processors
	foreach threads {
	    -1 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
	} {
	    if 0 {
		if {$threads < 0} {
		    lappend configs [list $size $w $h $aspect $threads n/a]
		    continue
		}
	    }

	    # for now do not go over the number of hardware threads/cores
	    if {$threads > $::maxp} continue

	    foreach sink {
		null
		null-s
	    } {
		lappend configs [list $size $w $h $aspect $threads $sink]
	    }
	}
    }

    return $configs
}
