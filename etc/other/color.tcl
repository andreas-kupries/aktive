## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Color database

operator color::css {
    section color
    external!

    # TODO :: command to return entire database of names -- then use it below instead of shades

    example {
	lavenderblush | -text
    }
    example {
	set shades {
	    black silver gray white maroon red purple fuchsia green lime
	    olive yellow navy blue teal aqua orange aliceblue antiquewhite aquamarine
	    azure beige bisque blanchedalmond blueviolet brown burlywood cadetblue chartreuse chocolate
	    coral cornflowerblue cornsilk crimson cyan aqua darkblue darkcyan darkgoldenrod darkgray
	    darkgreen darkgrey darkkhaki darkmagenta darkolivegreen darkorange darkorchid darkred darksalmon darkseagreen
	    darkslateblue darkslategray darkslategrey darkturquoise darkviolet deeppink deepskyblue dimgray dimgrey dodgerblue
	    firebrick floralwhite forestgreen gainsboro ghostwhite gold goldenrod greenyellow grey honeydew
	    hotpink indianred indigo ivory khaki lavender lavenderblush lawngreen lemonchiffon lightblue
	    lightcoral lightcyan lightgoldenrodyellow lightgray lightgreen lightgrey lightpink lightsalmon lightseagreen lightskyblue
	    lightslategray lightslategrey lightsteelblue lightyellow limegreen linen magenta fuchsia mediumaquamarine mediumblue
	    mediumorchid mediumpurple mediumseagreen mediumslateblue mediumspringgreen mediumturquoise mediumvioletred midnightblue mintcream mistyrose
	    moccasin navajowhite oldlace olivedrab orangered orchid palegoldenrod palegreen paleturquoise palevioletred
	    papayawhip peachpuff peru pink plum powderblue rosybrown royalblue saddlebrown salmon sandybrown
	    seagreen seashell sienna skyblue slateblue slategray slategrey snow springgreen steelblue
	    tan thistle tomato turquoise violet wheat whitesmoke yellowgreen rebeccapurple black
	}
    } {
	!!aktive image from color-matrix width 30 height 5 values {*}$shades | times 16
    }

    note Returns the RGB values for the named color. \
	The command knows the CSS colors up to CSS level 4.

    str name Color name to look up.
}

##
# # ## ### ##### ######## ############# #####################
::return
