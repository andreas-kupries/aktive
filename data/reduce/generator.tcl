# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

critcl::msg "[dsl::reader::blue {Reduction Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

proc reduce-bands {name once setup reduce merge finalize single} {
    upvar 1 decl decl defn defn link link

    lappend link "/* band $name placeholder */" ;# placeholder for replacement series

    global benchmarking testing
    if {$benchmarking} {
	# bands: base line, custom band handling, unrolling
	reduce-band-baseline   $name $once $setup $reduce $merge $finalize $single
	reduce-band-perdepth   $name $once $setup $reduce $merge $finalize $single
	reduce-band-unroll4    $name $once $setup $reduce $merge $finalize $single
	return
    } elseif {$testing} {
	# bands: base line, custom band handling, unrolling
	reduce-band-baseline   $name $once $setup $reduce $merge $finalize $single
	reduce-band-perdepth   $name $once $setup $reduce $merge $finalize $single
	reduce-band-unroll4    $name $once $setup $reduce $merge $finalize $single
	# and use the cross-checking function for all general uses of the band reducers
	reduce-band-crosscheck $name $once $setup $reduce $merge $finalize $single
	return
    }

    if {$name in {sumsquared stddev variance}} {
	# production complex - keep to special, unrolling is worse
	reduce-band-perdepth $name $once $setup $reduce $merge $finalize $single
    } else {
	# production general - unroll
	reduce-band-unroll4 $name $once $setup $reduce $merge $finalize $single
    }
}

proc reduce-rows {name once setup reduce merge finalize single} {
    upvar 1 decl decl defn defn link link

    lappend link "/* row $name placeholder */" ;# placeholder for replacement series

    global benchmarking testing
    if {$benchmarking} {
	# rows: base line, custom band handling, unrolling
	reduce-row-baseline $name $once $setup $reduce $merge $finalize $single
	return
    } elseif {$testing} {
	# rows: base line, custom band handling, unrolling
	reduce-row-baseline $name $once $setup $reduce $merge $finalize $single
	# and use the cross-checking function for all general uses of the band reducers
	#reduce-band-crosscheck $name $once $setup $reduce $merge $finalize $single
	return
    }

    if 0 {if {$name in {sumsquared stddev variance}} {
	# production complex - keep to special, unrolling is worse
	reduce-row-perdepth $name $once $setup $reduce $merge $finalize $single
    } else {
	# production general - unroll
	reduce-row-unroll4 $name $once $setup $reduce $merge $finalize $single
    }}

    reduce-row-baseline $name $once $setup $reduce $merge $finalize $single
    return
}

# # ## ### ##### ######## #############

# generate a band reducer function for a row which simply calls on the existing reduction
# function for the handling of the bands of a pixel - this emulates the existing blitter
# setup. in other words, the baseline to compare perf against.
proc reduce-band-baseline {name _ _ _  _ _ _} {
    upvar 1 decl decl defn defn link link
    lappend map @name@ $name
    reducer-make band baseline $name $map
    return
}

# generate a row reducer function which simply calls on the existing reduction function
# for the handling of the bands of a pixel - this emulates the existing blitter setup. in
# other words, the baseline to compare perf against.
proc reduce-row-baseline {name _ _ _  _ _ _} {
    upvar 1 decl decl defn defn link link
    lappend map @name@ $name
    reducer-make row baseline $name $map
    return
}

# generate a column reducer function which simply calls on the existing reduction function
# for the handling of the bands of a pixel - this emulates the existing blitter setup. in
# other words, the baseline to compare perf against.
proc reduce-column-baseline {name _ _ _  _ _ _} {
    upvar 1 decl decl defn defn link link
    lappend map @name@ $name
    reducer-make column baseline $name $map
    return
}

# # ## ### ##### ######## #############

# generate a band reducer function for a row which checks all implementations against the
# first (base).
proc reduce-band-crosscheck {name _ _ _ _ _ _} {
    upvar 1 decl decl defn defn link link
    lappend map @name@ $name
    reducer-make band crosscheck $name $map
    return
}

# # ## ### ##### ######## #############

# generate a band reducer function for a row which provides custom loops for the most used
# depths, plus a generic loop handling things outside of that set. note that the loops
# still handle each pixel separately, just the code used for a pixel is optimized.
proc reduce-band-perdepth {name once setup reduce _ finalize single} {
    upvar 1 decl decl defn defn link link

    lappend map @name@    $name
    lappend map @once@    $once
    #
    lappend map @single@  [single $single stride]
    #
    lappend map @setup@         [map $setup    @N stride @A acc]           ;# loop setup
    lappend map @final@   [trim [map $finalize @N stride @A acc @R *d]]   ;# post-processing
    lappend map @reduce@        [map $reduce   @N stride @A acc @I j @V {s[j]}] ;# generic loop
    #
    lappend map @reduce0@ [map $reduce   @I 0 @N stride @A acc @V {s[0]}] ;# unrolled inner
    lappend map @reduce1@ [map $reduce   @I 1 @N stride @A acc @V {s[1]}] ;# s.a
    lappend map @reduce2@ [map $reduce   @I 2 @N stride @A acc @V {s[2]}] ;# s.a
    lappend map @reduce3@ [map $reduce   @I 3 @N stride @A acc @V {s[3]}] ;# s.a

    reducer-make band perdepth $name $map
    return
}

# # ## ### ##### ######## #############

# generate a band reducer function for a row which behaves like `perdepth` above, except
# it also unrolls the pixel loop.
proc reduce-band-unroll4 {name once setup reduce _ finalize single} {
    upvar 1 decl decl defn defn link link

    lappend map @name@    $name
    lappend map @once@    $once
    #
    lappend map @single@       [single $single stride]
    lappend map @single0@ [map [single $single stride] *s {s[0]}]
    lappend map @single1@ [map [single $single stride] *s {s[1]}]
    lappend map @single2@ [map [single $single stride] *s {s[2]}]
    lappend map @single3@ [map [single $single stride] *s {s[3]}]
    #
    lappend map @setup@   [map $setup         @N stride @A acc]           ;# loop setup
    lappend map @final@   [map $finalize      @N stride @A acc @R *d]     ;# post-processing
    lappend map @reduce@  [map $reduce   @I j @N stride @A acc @V {s[j]}] ;# generic loop
    lappend map @reduce0@ [map $reduce   @I 0 @N stride @A acc @V {s[0]}] ;# unrolled inner
    lappend map @reduce1@ [map $reduce   @I 1 @N stride @A acc @V {s[1]}] ;# s.a
    lappend map @reduce2@ [map $reduce   @I 2 @N stride @A acc @V {s[2]}] ;# s.a
    lappend map @reduce3@ [map $reduce   @I 3 @N stride @A acc @V {s[3]}] ;# s.a
    #
    #
    lappend map @setup0@     [map $setup             @N stride @A acc0]              ;# loop setup, lane 0
    lappend map @final0@     [map $finalize          @N stride @A acc0 @R {d[0]}]    ;# post-processing
    lappend map @reduce0*@   [map $reduce   @I (0+j) @N stride @A acc0 @V {s[0+j]}]  ;# unrolled inner
    lappend map @reduce0/0@  [map $reduce   @I 0     @N stride @A acc0 @V {s[d0+0]}] ;# unrolled inner
    lappend map @reduce0/1@  [map $reduce   @I 1     @N stride @A acc0 @V {s[d0+1]}] ;# unrolled inner
    lappend map @reduce0/2@  [map $reduce   @I 2     @N stride @A acc0 @V {s[d0+2]}] ;# unrolled inner
    lappend map @reduce0/3@  [map $reduce   @I 3     @N stride @A acc0 @V {s[d0+3]}] ;# unrolled inner
    #
    lappend map @setup1@     [map $setup             @N stride @A acc1]              ;# loop setup, lane 1
    lappend map @final1@     [map $finalize          @N stride @A acc1 @R {d[1]}]    ;# post-processing
    lappend map @reduce1*@   [map $reduce   @I (1+j) @N stride @A acc1 @V {s[1+j]}]  ;# s.a
    lappend map @reduce1/0@  [map $reduce   @I 0     @N stride @A acc1 @V {s[d1+0]}] ;# unrolled inner
    lappend map @reduce1/1@  [map $reduce   @I 1     @N stride @A acc1 @V {s[d1+1]}] ;# unrolled inner
    lappend map @reduce1/2@  [map $reduce   @I 2     @N stride @A acc1 @V {s[d1+2]}] ;# unrolled inner
    lappend map @reduce1/3@  [map $reduce   @I 3     @N stride @A acc1 @V {s[d1+3]}] ;# unrolled inner
    #
    lappend map @setup2@     [map $setup             @N stride @A acc2]              ;# loop setup, lane 2
    lappend map @final2@     [map $finalize          @N stride @A acc2 @R {d[2]}]    ;# post-processing
    lappend map @reduce2*@   [map $reduce   @I (2+j) @N stride @A acc2 @V {s[2+j]}]  ;# s.a
    lappend map @reduce2/0@  [map $reduce   @I 0     @N stride @A acc2 @V {s[d2+0]}] ;# unrolled inner
    lappend map @reduce2/1@  [map $reduce   @I 1     @N stride @A acc2 @V {s[d2+1]}] ;# unrolled inner
    lappend map @reduce2/2@  [map $reduce   @I 2     @N stride @A acc2 @V {s[d2+2]}] ;# unrolled inner
    lappend map @reduce2/3@  [map $reduce   @I 3     @N stride @A acc2 @V {s[d2+3]}] ;# unrolled inner
    #
    lappend map @setup3@     [map $setup             @N stride @A acc3]              ;# loop setup, lane 3
    lappend map @final3@     [map $finalize          @N stride @A acc3 @R {d[3]}]    ;# post-processing
    lappend map @reduce3*@   [map $reduce   @I (3+j) @N stride @A acc3 @V {s[3+j]}]  ;# s.a
    lappend map @reduce3/0@  [map $reduce   @I 0     @N stride @A acc3 @V {s[d3+0]}] ;# unrolled inner
    lappend map @reduce3/1@  [map $reduce   @I 1     @N stride @A acc3 @V {s[d3+1]}] ;# unrolled inner
    lappend map @reduce3/2@  [map $reduce   @I 2     @N stride @A acc3 @V {s[d3+2]}] ;# unrolled inner
    lappend map @reduce3/3@  [map $reduce   @I 3     @N stride @A acc3 @V {s[d3+3]}] ;# unrolled inner

    reducer-make band unroll4 $name $map
    return
}

# # ## ### ##### ######## #############

proc single {mode size} {
    string map [list @N $size] [dict get {
	pass   {*s}
	zero   {0}
	square {(*s) * (*s)}
	forn   "(*s) != 0 ? 0 : @N"
	lorn   {(*s) != 0 ? 0 : -1}
    } $mode]
}

proc map    {s args} { string map $args $s }
proc trim   {s}      { string trim $s }
proc asline {s}      { trim [map $s "\n" ""] }

# retrieve spec section data, resolve references
proc get {reduce key name} {
    while 1 {
	#puts \t\t\t/$key\t/$name
	set val [dict get $reduce $key $name]
	if {![string match @* $val]} { return $val }
	set name [string range $val 1 end]
    }
}

# retrieve spec optional section data, resolve references,
proc get? {reduce key name {default {}}} {
    if {[catch {
	set val [get $reduce $key $name]
    }]} { return $default }
    return $val
}

# # ## ### ##### ######## #############
## main generator execution

apply {{} {
    source tests/support/files.tcl	;# catx, touch+
    source data/reduce/spec.tcl

    # generate reduction loops, simple and super-scalar (header, implementation)

    set decl {}	;# declarations ...
    set defn {}	;# ... definitions ...
    set link {}	;# ... and system integration

    foreach name $reducers {
	critcl::msg "\treduce bands [dsl::reader::blue $name]"
        set once     [asline [get? $reduce once     $name]]
        set setup    [asline [get  $reduce setup    $name]]
        set core     [asline [get  $reduce reduce   $name]]
        set merge    [asline [get  $reduce merge    $name]]
	set finalize [trim   [get  $reduce finalize $name]]
        set single   [asline [get  $reduce single   $name]]

	reduce-bands $name $once $setup $core $merge $finalize $single
    }

    lappend decl {}
    lappend link {}
    foreach name $reducers {
	critcl::msg "\treduce rows [dsl::reader::blue $name]"
        set once     [asline [get? $reduce once     $name]]
        set setup    [asline [get  $reduce setup    $name]]
        set core     [asline [get  $reduce reduce   $name]]
        set merge    [asline [get  $reduce merge    $name]]
	set finalize [trim   [get  $reduce finalize $name]]
        set single   [asline [get  $reduce single   $name]]

	reduce-rows $name $once $setup $core $merge $finalize $single
    }

    lappend zmap @decl@ [join $decl \n]
    lappend zmap @defn@ [join $defn \n]
    lappend zmap @link@ [join $link \n]

    touch generated/xreduce.h [string map $zmap [catx data/reduce/template.h]]
    touch generated/xreduce.c [string map $zmap [catx data/reduce/template.c]]
    return
}}

# # ## ### ##### ######## #############
## cleanup

rename asline                 {}
rename get                    {}
rename get?                   {}
rename map                    {}
rename reduce-band-baseline   {}
rename reduce-band-crosscheck {}
rename reduce-band-perdepth   {}
rename reduce-band-unroll4    {}
rename reduce-row-baseline    {}
rename single                 {}
rename trim                   {}

# # ## ### ##### ######## #############
return
