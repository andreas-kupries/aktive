## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Accessor -- Retrieve the connected components of the (binary) image.

# # ## ### ##### ######## ############# #####################
##

operator op::connected-components::get {
    section accessor morphology

    example -post cc.norm -text {aktive image from matrix width 33 height 11 values {*}{
	0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 1 0 0 1 1 0 0 1 1 1 0 1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 0 0
	1 1 1 1 1 1 0 0 1 1 0 0 1 0 1 0 1 0 0 0 1 0 0 1 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 1 1 0 0 0 1 1 1 0 1 0 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1
	0 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 0 1 0 1 1 1 0 0 0 0 0 1 1 1
	0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 1 0 1 1 0 0 0 1 0 0 0 1 1
	0 1 0 1 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 0 0 1 1 0 0 1 0 0 1 1 0
	0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 1 0 1 1 0 0
	0 1 1 0 0 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 0 0 0 0 0
	0 1 1 0 0 1 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1
	0 0 0 0 0 1 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 0 0 1 1 1 0 0 0 0
    }} @1

    note Returns a Tcl dictionary describing all the connected components found in the (binary) input.

    note The components are identified by integer numbers.

    note The data of each component is a dictionary providing the elements \
	of the component's bounding box, its area (in pixels), and an \
	unordered list of the row ranges the component consists of.

    input

    return object0 {
	aktive_cc_block* block = aktive_cc_find (src);
	Tcl_Obj*         cc    = aktive_cc_as_tcl_dict (ip, block);
	aktive_cc_release_block (block);
	return cc;
    }
}
