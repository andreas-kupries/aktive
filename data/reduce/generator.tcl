# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

critcl::msg "[dsl::reader::blue {Reduction Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

proc reduce {name once setup reduce merge finalize} {
    upvar 1 decl decl defn defn link link

    # bands: base line
    reduce-band-base $name $once $setup $reduce $merge $finalize
    # bands: inlined base
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
proc reduce-band-base {name once setup reduce merge finalize} {
    upvar 1 decl decl defn defn link link

    lappend map @name@ $name
    # all the other placeholders do not matter for the baseline.

    upvar 2 basedecl basedecl baseimpl baseimpl

    lappend decl [string map $map $basedecl]
    lappend defn [string map $map $baseimpl]
    lappend link "#define aktive_reduce_row_bands_$name aktive_reduce_row_bands_base_$name"
    return
}

apply {{} {
    source tests/support/files.tcl	;# catx, touch+
    source data/reduce/spec.tcl

    # generate reduction loops, simple and super-scalar (header, implementation)

    set decl {}	;# declarations ...
    set defn {}	;# ... and definitions
    set link {}	;# system integration

    foreach op $reducers {
	critcl::msg "\treduce [dsl::reader::blue $op]"

        set once {} ; catch { set once [dict get $reduce once $op] }
        set setup    [dict get $reduce setup    $op]
        set core     [dict get $reduce reduce   $op]
        set merge    [dict get $reduce merge    $op]
        set finalize [dict get $reduce finalize $op]
	reduce $op $once $setup $core $merge $finalize
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

# # ## ### ##### ######## #############
return
