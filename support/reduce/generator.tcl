# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

global benchmarking

critcl::msg "[dsl::reader::blue {Reduction Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

source tests/support/files.tcl		;# import catx, touch+
source support/reduce/db.tcl		;# generator data base
source support/template.tcl		;# template support

# # ## ### ##### ######## #############

apply {{} {
    source support/reduce/assets/ops.tcl
    foreach entry [lsort -dict [glob support/reduce/assets/*/*/func.tcl]] { source $entry } ;# funcs & placeholders
    foreach entry [lsort -dict [glob support/reduce/assets/*/main.tcl]]   { source $entry } ;# gen-* // func selection

    # generate reduction loops, simple and super-scalar (header, implementation)
    code-init
    foreach axis {
	band row
    } {
	foreach name [names] {
	    critcl::msg "\treduce $axis [dsl::reader::blue $name]"
	    gen-$axis $name
	}
    }

    set zmap [code-map]
    touch generated/xreduce.h [string map $zmap [catx support/reduce/assets/template.h]]
    touch generated/xreduce.c [string map $zmap [catx support/reduce/assets/template.c]]
} reduce}

# # ## ### ##### ######## #############

namespace delete reduce

# # ## ### ##### ######## #############
return
