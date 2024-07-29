## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Accessor -- Retrieve the connected components of the (binary) image.

# # ## ### ##### ######## ############# #####################
##

operator op::connected-components::get {
    section accessor morphology

    set values [string map [list \n { } \t {}] {
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
    }]

    example [string map [list VALUES $values] {
	aktive image from matrix width 33 height 11 values VALUES | times 8
	@1                                                        | -text cc.norm
    }]

    unset values

    note Returns a dictionary describing all the connected components of the single-band input.

    note The input is expected to be binary. If not, all `values > 0` are \
	treated as the foreground searched for components.

    note The components are identified by integer numbers.

    note The data of each component is a dictionary providing the elements \
	of the component's bounding box, its area (in pixels), and an \
	unordered list of the row ranges the component consists of.

    note See \"<!xref: aktive op connected-components labeled>\" \
	for a transformer command built on top of this.

    input

    return object0 {
	if (aktive_image_get_depth (src) > 1) aktive_fail ("Reject image with depth > 1");

	aktive_cc_block* block = aktive_cc_find (src);
	Tcl_Obj*         cc    = aktive_cc_as_tcl_dict (ip, block);
	aktive_cc_release_block (block);
	return cc;
    }
}
