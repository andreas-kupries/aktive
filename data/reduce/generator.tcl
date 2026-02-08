# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

critcl::msg "[dsl::reader::blue {Reduction Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

proc reduce {name once setup reduce merge finalize single} {
    upvar 1 decl decl defn defn link link

    global benchmarking testing
    if {$benchmarking} {
	# bands: base line, custom band handling, unrolling
	reduce-band-base       $name $once $setup $reduce $merge $finalize $single
	reduce-band-special    $name $once $setup $reduce $merge $finalize $single
	reduce-band-unroll4    $name $once $setup $reduce $merge $finalize $single
	return
    } elseif {$testing} {
	# bands: base line, custom band handling, unrolling
	reduce-band-base       $name $once $setup $reduce $merge $finalize $single
	reduce-band-special    $name $once $setup $reduce $merge $finalize $single
	reduce-band-unroll4    $name $once $setup $reduce $merge $finalize $single
	# and use the cross-checking function for all general uses of the band reducers
	reduce-band-crosscheck $name $once $setup $reduce $merge $finalize $single
	return
    }

    # production complex - keep to special, unrolling is worse
    if {$name in {sumsquared stddev variance}} {
	reduce-band-special $name $once $setup $reduce $merge $finalize $single
	return
    }

    # production general - unroll
    reduce-band-unroll4 $name $once $setup $reduce $merge $finalize $single

    # TODO :: row, column reducer
    # NOTE :: image reducers use concurrent row reduction with result merging
}

# generate a band reducer function for a row which simply calls on the existing reduction
# function for the handling of the bands of a pixel - this emulates the existing blitter
# setup. in other words, the baseline to compare perf against.
proc reduce-band-base {name /ign/once /ign/setup /ign/reduce /ign/merge /ign/finalize /ign/single} {
    upvar 1 decl decl defn defn link link

    lappend map @name@ $name
    # all the other placeholders do not matter for the baseline.

    upvar 2 basedecl bdecl baseimpl bimpl

    lappend decl [string map $map $bdecl]
    lappend defn [string map $map $bimpl]
    set     link [lreplace $link end end]
    #lappend link "#undef  aktive_reduce_row_bands_$name"
    lappend link "#define aktive_reduce_row_bands_$name aktive_reduce_row_bands_base_$name"
    return
}

# generate a band reducer function for a row which checks all implementations against the first (base).
proc reduce-band-crosscheck {name /ign/once /ign/setup /ign/reduce /ign/merge /ign/finalize /ign/single} {
    upvar 1 decl decl defn defn link link

    lappend map @name@ $name
    # all the other placeholders do not matter to the chross check

    upvar 2 crosscheckdecl cdecl crosscheckimpl cimpl

    lappend decl [string map $map $cdecl]
    lappend defn [string map $map $cimpl]
    set     link [lreplace $link end end]
    #lappend link "#undef  aktive_reduce_row_bands_$name"
    lappend link "#define aktive_reduce_row_bands_$name aktive_reduce_row_bands_crosscheck_$name"
    return
}

# generate a band reducer function for a row which provides custom loops for the most used
# band numbers, plus a generic loop handling things outside of that. the loops still
# handle each pixel separately, just the code applied for a pixel is optimized.
proc reduce-band-special {name once setup reduce /ign/merge finalize single} {
    upvar 1 decl decl defn defn link link

    lappend map @name@    $name
    lappend map @once@    $once
    #
    lappend map @single@  [single $single]
    #
    lappend map @setup@   [map $setup    @N depth @A acc]           ;# loop setup
    lappend map @final@   [trim [map $finalize @N depth @A acc @R *d]]   ;# post-processing
    lappend map @reduce@  [map $reduce   @I j @N depth @A acc @V {s[j]}] ;# generic loop
    #
    lappend map @reduce0@ [map $reduce   @I 0 @N depth @A acc @V {s[0]}] ;# unrolled inner
    lappend map @reduce1@ [map $reduce   @I 1 @N depth @A acc @V {s[1]}] ;# s.a
    lappend map @reduce2@ [map $reduce   @I 2 @N depth @A acc @V {s[2]}] ;# s.a
    lappend map @reduce3@ [map $reduce   @I 3 @N depth @A acc @V {s[3]}] ;# s.a

    upvar 2 specialdecl sdecl specialimpl simpl

    lappend decl [string map $map $sdecl]
    lappend defn [string map $map $simpl]
    set     link [lreplace $link end end]
    #lappend link "#undef  aktive_reduce_row_bands_$name"
    lappend link "#define aktive_reduce_row_bands_$name aktive_reduce_row_bands_special_$name"
    return
}


# generate a band reducer function for a row which behaves like `special` (see above),
# except it unrolls the pixel loop as well.
proc reduce-band-unroll4 {name once setup reduce /ign/merge finalize single} {
    upvar 1 decl decl defn defn link link

    lappend map @name@    $name
    lappend map @once@    $once
    #
    lappend map @single@  [single $single]
    lappend map @single0@ [map [single $single] *s {s[0]}]
    lappend map @single1@ [map [single $single] *s {s[1]}]
    lappend map @single2@ [map [single $single] *s {s[2]}]
    lappend map @single3@ [map [single $single] *s {s[3]}]
    #
    lappend map @setup@   [map $setup         @N depth @A acc]           ;# loop setup
    lappend map @final@   [map $finalize      @N depth @A acc @R *d]     ;# post-processing
    lappend map @reduce@  [map $reduce   @I j @N depth @A acc @V {s[j]}] ;# generic loop
    lappend map @reduce0@ [map $reduce   @I 0 @N depth @A acc @V {s[0]}] ;# unrolled inner
    lappend map @reduce1@ [map $reduce   @I 1 @N depth @A acc @V {s[1]}] ;# s.a
    lappend map @reduce2@ [map $reduce   @I 2 @N depth @A acc @V {s[2]}] ;# s.a
    lappend map @reduce3@ [map $reduce   @I 3 @N depth @A acc @V {s[3]}] ;# s.a
    #
    #
    lappend map @setup0@     [map $setup             @N depth @A acc0]              ;# loop setup, lane 0
    lappend map @final0@     [map $finalize          @N depth @A acc0 @R {d[0]}]    ;# post-processing
    lappend map @reduce0*@   [map $reduce   @I (0+j) @N depth @A acc0 @V {s[0+j]}]  ;# unrolled inner
    lappend map @reduce0/0@  [map $reduce   @I 0     @N depth @A acc0 @V {s[d0+0]}] ;# unrolled inner
    lappend map @reduce0/1@  [map $reduce   @I 1     @N depth @A acc0 @V {s[d0+1]}] ;# unrolled inner
    lappend map @reduce0/2@  [map $reduce   @I 2     @N depth @A acc0 @V {s[d0+2]}] ;# unrolled inner
    lappend map @reduce0/3@  [map $reduce   @I 3     @N depth @A acc0 @V {s[d0+3]}] ;# unrolled inner
    #
    lappend map @setup1@     [map $setup             @N depth @A acc1]              ;# loop setup, lane 1
    lappend map @final1@     [map $finalize          @N depth @A acc1 @R {d[1]}]    ;# post-processing
    lappend map @reduce1*@   [map $reduce   @I (1+j) @N depth @A acc1 @V {s[1+j]}]  ;# s.a
    lappend map @reduce1/0@  [map $reduce   @I 0     @N depth @A acc1 @V {s[d1+0]}] ;# unrolled inner
    lappend map @reduce1/1@  [map $reduce   @I 1     @N depth @A acc1 @V {s[d1+1]}] ;# unrolled inner
    lappend map @reduce1/2@  [map $reduce   @I 2     @N depth @A acc1 @V {s[d1+2]}] ;# unrolled inner
    lappend map @reduce1/3@  [map $reduce   @I 3     @N depth @A acc1 @V {s[d1+3]}] ;# unrolled inner
    #
    lappend map @setup2@     [map $setup             @N depth @A acc2]              ;# loop setup, lane 2
    lappend map @final2@     [map $finalize          @N depth @A acc2 @R {d[2]}]    ;# post-processing
    lappend map @reduce2*@   [map $reduce   @I (2+j) @N depth @A acc2 @V {s[2+j]}]  ;# s.a
    lappend map @reduce2/0@  [map $reduce   @I 0     @N depth @A acc2 @V {s[d2+0]}] ;# unrolled inner
    lappend map @reduce2/1@  [map $reduce   @I 1     @N depth @A acc2 @V {s[d2+1]}] ;# unrolled inner
    lappend map @reduce2/2@  [map $reduce   @I 2     @N depth @A acc2 @V {s[d2+2]}] ;# unrolled inner
    lappend map @reduce2/3@  [map $reduce   @I 3     @N depth @A acc2 @V {s[d2+3]}] ;# unrolled inner
    #
    lappend map @setup3@     [map $setup             @N depth @A acc3]              ;# loop setup, lane 3
    lappend map @final3@     [map $finalize          @N depth @A acc3 @R {d[3]}]    ;# post-processing
    lappend map @reduce3*@   [map $reduce   @I (3+j) @N depth @A acc3 @V {s[3+j]}]  ;# s.a
    lappend map @reduce3/0@  [map $reduce   @I 0     @N depth @A acc3 @V {s[d3+0]}] ;# unrolled inner
    lappend map @reduce3/1@  [map $reduce   @I 1     @N depth @A acc3 @V {s[d3+1]}] ;# unrolled inner
    lappend map @reduce3/2@  [map $reduce   @I 2     @N depth @A acc3 @V {s[d3+2]}] ;# unrolled inner
    lappend map @reduce3/3@  [map $reduce   @I 3     @N depth @A acc3 @V {s[d3+3]}] ;# unrolled inner

    upvar 2 unroll4decl udecl unroll4impl uimpl

    lappend decl [string map $map $udecl]
    lappend defn [string map $map $uimpl]
    set     link [lreplace $link end end]
    #lappend link "#undef  aktive_reduce_row_bands_$name"
    lappend link "#define aktive_reduce_row_bands_$name aktive_reduce_row_bands_unroll4_$name"
    return
}

proc single {mode} {
    dict get {
	pass  {*s}
	zero  {0}
	twice {(*s) * (*s)}
    } $mode
}

proc map  {s args} { string map $args $s }
proc trim {s}      { string trim $s }

# retrieve section data, resolve references
proc get {reduce key name} {
    while 1 {
	#puts \t\t\t/$key\t/$name
	set val [dict get $reduce $key $name]
	if {![string match @* $val]} { return $val }
	set name [string range $val 1 end]
    }
}

# retrieve section optional data, resolve references,
proc get? {reduce key name {default {}}} {
    if {[catch {
	set val [get $reduce $key $name]
    }]} { return $default }
    return $val
}

proc asline {s} { trim [map $s "\n" ""] }

apply {{} {
    source tests/support/files.tcl	;# catx, touch+
    source data/reduce/spec.tcl

    # generate reduction loops, simple and super-scalar (header, implementation)

    set decl {}	;# declarations ...
    set defn {}	;# ... and definitions
    set link {}	;# system integration

    foreach name $reducers {
	critcl::msg "\treduce [dsl::reader::blue $name]"
        set once     [asline [get? $reduce once     $name]]
        set setup    [asline [get  $reduce setup    $name]]
        set core     [asline [get  $reduce reduce   $name]]
        set merge    [asline [get  $reduce merge    $name]]
	set finalize [trim   [get  $reduce finalize $name]]
        set single   [asline [get  $reduce single   $name]]

	lappend link "/* $name placeholder */" ;# placeholder for replacement series
	reduce $name $once $setup $core $merge $finalize $single
    }

    lappend zmap @decl@ [join $decl \n]
    lappend zmap @defn@ [join $defn \n]
    lappend zmap @link@ [join $link \n]

    touch generated/xreduce.h [string map $zmap [catx data/reduce/template.h]]
    touch generated/xreduce.c [string map $zmap [catx data/reduce/template.c]]
    return
}}

# # ## ### ##### ######## #############
rename reduce           {}
rename reduce-band-base {}
rename get              {}
rename get?             {}
rename map              {}

# # ## ### ##### ######## #############
return
