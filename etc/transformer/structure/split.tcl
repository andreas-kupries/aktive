## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Split into rows, columns, or bands

tcl-operator {coordinate dimension thing} {
    op::split::x  x width  column
    op::split::y  y height row
    op::split::z  z depth  band
} {
    note Transformer. Structure. \
	Split the input into a list of ${thing}s.

    arguments src
    body {
	set end [aktive query @@dimension@@ $src]
	set r {}
	for {set k 0} {$k < $end} {incr k} {
	    lappend r [aktive op select @@coordinate@@ $k $k $src]
	}
	return $r
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
