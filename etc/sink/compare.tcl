## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- Image comparisons

operator {fun} {
    op::compare::mse  {}
    op::compare::rmse sqrt
} {
    section sink statistics

    def metric [lindex [split $__op :] 4]

    # As sinks cannot be stacked, simplification is not applicable.

    note Compares the two input images and returns the \
	[string toupper $metric] metric for their difference

    input
    input

    body {
	set n [aktive query pixels $src0]
	set d [aktive op image sumsquared [aktive op math sub $src0 $src1]]
	return [expr {@@fun@@ (double ($d) / double($n))}]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
