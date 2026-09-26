## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Accessor -- Retrieve the connected components of the (binary) image.

# # ## ### ##### ######## ############# #####################
##

operator op::connected-components::get {
    section accessor morphology

    esupport {
	set map [list \n { } \t {} {    } {} _ {0 } * {1 }]
    }

    # !xref-mark labeled regions
    example {
	set va [string map $map {
	    _____*___________________________
	    _____*__**__***_*****___*******__
	    ******__**__*_*_*___*__*********_
	    _______**___***_*___*_***********
	    _*******_*______*___*_***_____***
	    _*_______*______*___*_**___*___**
	    _*_*******______*****__**__*__**_
	    __**____________________**_*_**__
	    _**__******_********_______*_____
	    _**__*______********__***********
	    _____*______**____**______***____
	}]
    } {
	aktive image from matrix width 33 height 11 values {*}$va | times 8
	@1                                                        | -text cc.pretty
    }

    example {
	set va [string map $map {
	    _____*___________________________
	    _____*__**__***_*****___*******__
	    ******__**__*_*_*___*__*********_
	    _______**___***_*___*_***********
	    _*******_*______*___*_***_____***
	    _*_______*______*___*_**___*___**
	    _*_*******______*****__**__*__**_
	    __**____________________**_*_**__
	    _**__******_********_______*_____
	    _**__*______********__***********
	    _____*______**____**______***____
	}]
    } {
	aktive image from matrix width 33 height 11 values {*}$va | times 8
	@1 neighbour8 yes                                         | -text cc.pretty
    }

    example {
	set vb [string map $map {
	    _________________________
	    _****____**************__
	    _****____________________
	    _****__*********_________
	    _****__*********_________
	    _****__*********_________
	    _****__***___***_________
	    _****__*********_________
	    _______*********_________
	    _______*********_________
	    ___________*______******_
	    _____________***********_
	    _____________***********_
	}]
    } {
	aktive image from matrix width 25 height 13 values {*}$vb | times 8
	aktive op morph gradient internal @1 radius 1             | times 8
	@2                                                        | -text cc.pretty
    }

    example {
	set vb [string map $map {
	    _________________________
	    _****____**************__
	    _****____________________
	    _****__*********_________
	    _****__*********_________
	    _****__*********_________
	    _****__***___***_________
	    _****__*********_________
	    _______*********_________
	    _______*********_________
	    ___________*______******_
	    _____________***********_
	    _____________***********_
	}]
    } {
	aktive image from matrix width 25 height 13 values {*}$vb | times 8
	aktive op morph gradient internal @1 radius 1             | times 8
	@2 neighbour8 yes                                         | -text cc.pretty
    }

    # !xref-mark /end

    note Returns a dictionary describing all the connected components of the single-band input.

    note The input is expected to be binary. If not, all `values > 0` are \
	treated as the foreground searched for components.

    note The components are identified by integer numbers.

    note The data of each component is a dictionary providing the component's \
	`area`, bounding `box`, `centroid` location, and `parts` list. __Note__ \
	that the centroid is not the same as the center of the bounding box.

    note The `area` value is an unsigned integer number indicating the number of \
	pixels covered by the component.

    note The bounding `box` value is a 4-element list holding the x- and y-coordinates \
	of the upper-left and lower-right points of the bounding box, in this order. \
	In other words the x- and y- min coordinates followed by the x- and y- max \
	coordinates.

    note The `centroid` value is a 2-element list holding the x- and y-coordinates \
	of the point, in this order.

    note The `parts` value is an __unordered__ list of the row ranges the component \
	consists of. A single range value is a 3-element list holding the y-coordinate \
	of the range, followed by the min and max x-coordinates the range covers.

    note See \"<!xref: aktive op connected-components labeled>\" \
	for a transformer command built on top of this.

    note __Note__ that this operation can also be used to determine the perimeters \
	of the connected components. Instead of using the image with the regions \
	directly as the operation's input pre-process it with \
	\"<!xref: aktive op morph gradient internal>\" (radius 1) to highlight the \
	region boundaries and feed that result in. The boundary components are the \
	desired perimeters of the original regions. See the second example. \
	__Beware__. \
	The morphological gradient is based on a 8-neighbourhood. \
	Connected components on the other hand uses a 4-neighourhood by default.

    input

    bool? 0 neighbour8	\
	Flag controlling the neighbourhood used to detect linked pixels. \
	When false (default) a 4-neighbourhood is used, else an 8-neighbourhood.

    return object0 {
	if (aktive_image_get_depth (src) > 1) aktive_fail ("Reject image with depth > 1");

	aktive_cc_block* block = aktive_cc_find (src, param->neighbour8);
	Tcl_Obj*         cc    = aktive_cc_as_tcl_dict (ip, block);
	aktive_cc_release_block (block);
	return cc;
    }
}
