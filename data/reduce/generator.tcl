# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

critcl::msg "[dsl::reader::blue {Reduction Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

proc reduce {name once setup reduce merge finalize single} {
    upvar 1 decl decl defn defn link link

    # bands: base line, custom band handling
    reduce-band-base    $name $once $setup $reduce $merge $finalize $single
    reduce-band-special $name $once $setup $reduce $merge $finalize $single
    # bands: 2-unroll
    # bands: 3-unroll
    # bands: 4-unroll

    ## __UNROLL__ note: single band is simplified, see above, not relevant here.
    ##
    ## __UNROLL__ option: specialized code handling 2,3,many bands, for the pixel
    ## __UNROLL__ issue:  still 1 function call per pixel
    ##
    ## __UNROLL__ option: specialized code handling 2,3,many bands, for the entire row
    ## __UNROLL__         single call for the entire row, per row
    ## __UNROLL__         hide specializations in a single function
    ##
    ## __UNROLL__ note: look into code generation for the reducers
}

# generate a band reducer function for a row which simply calls on the existing reduction
# function for the handling of the bands of a pixel - this emulates the existing blitter
# setup. in other words, the baseline to compare perf against.
proc reduce-band-base {name /ign/once /ign/setup /ign/reduce /ign/merge /ign/finalize /ign/single} {
    upvar 1 decl decl defn defn link link

    lappend map @name@ $name
    # all the other placeholders do not matter for the baseline.

    upvar 2 basedecl basedecl baseimpl baseimpl

    lappend decl [string map $map $basedecl]
    lappend defn [string map $map $baseimpl]
    lappend link "#undef  aktive_reduce_row_bands_$name"
    lappend link "#define aktive_reduce_row_bands_$name aktive_reduce_row_bands_base_$name"
    return
}

# generate a band reducer function for a row which provides custom loops for the most used
# band numbers, plus a generic loop handling things outside of that. the loops still
# handle each pixel separately, just the code applied for a pixel is optimized.
proc reduce-band-special {name once setup reduce /ign/merge finalize single} {
    upvar 1 decl decl defn defn link link

    lappend map @name@ $name
    lappend map @once@ $once
    lappend map @single@ [dict get {
	pass  {*s}
	zero  {0}
	twice {(*s) * (*s)}
    } $single]

    lappend map @setup@   [map $setup    @N depth @A acc]           ;# loop setup
    lappend map @final@   [map $finalize @N depth @A acc @R *d]     ;# post-processing
    lappend map @reduce@  [map $reduce   @I j @N depth @A acc @V {s[j]}] ;# generic loop
    lappend map @reduce0@ [map $reduce   @I 0 @N depth @A acc @V {s[0]}] ;# unrolled inner
    lappend map @reduce1@ [map $reduce   @I 1 @N depth @A acc @V {s[1]}] ;# s.a
    lappend map @reduce2@ [map $reduce   @I 2 @N depth @A acc @V {s[2]}] ;# s.a
    lappend map @reduce3@ [map $reduce   @I 3 @N depth @A acc @V {s[3]}] ;# s.a

    upvar 2 specialdecl specialdecl specialimpl specialimpl

    lappend decl [string map $map $specialdecl]
    lappend defn [string map $map $specialimpl]
    lappend link "#undef  aktive_reduce_row_bands_$name"
    lappend link "#define aktive_reduce_row_bands_$name aktive_reduce_row_bands_special_$name"
    return
}

proc map {s args} { string map $args $s }

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

proc asline {s} { string trim [map $s "\n" ""] }

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
	set finalize [get  $reduce finalize $name]
        set single   [asline [get  $reduce single   $name]]
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
