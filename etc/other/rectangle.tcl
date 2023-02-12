## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Rectangle operations
## -- Fitting completely non-image functionality into the framework

# # ## ### ##### ######## ############# #####################

operator rectangle::make {
    note Construct a 2D rectangle from x- and y-coordinates and width/height dimensions

    int  x  Rectangle location, Column
    int  y  Rectangle location, Row
    uint w  Rectangle width
    uint h  Rectangle height

    return rect {
	aktive_rectangle_def (r, param->x, param->y, param->w, param->h);
	return r;
    }
}

operator rectangle::grow {
    note Modify 2D rectangle by moving its 4 borders by a specififc amount

    rect r       Rectangle to modify
    int  left    Amount to grow the left border, positive to the left
    int  right   Amount to grow the right border, positive to the right
    int  top     Amount to grow the top border, positive upward
    int  bottom  Amount to grow the bottom border, positive downward

    return rect {
	aktive_rectangle r;
	r = param->r;
	aktive_rectangle_grow (&r,
			       param->left, param->right,
			       param->top,  param->bottom);
	return r;
    }
}

operator rectangle::move {
    note Translate a 2D rectangle by a specific amount given as separate x- and y-deltas

    rect r   Rectangle to modify
    int  dx  Amount to move left/right, positive to the right
    int  dy  Amount to move up/down, positive downward

    return rect {
	aktive_rectangle r;
	r = param->r;
	aktive_rectangle_move (&r, param->dx, param->dy);
	return r;
    }
}

# # ## ### ##### ######## ############# #####################

operator rectangle::equal {
    note Test two 2D rectangles for equality (location and dimensions)

    rect a   First rectangle to compare
    rect b   Second rectangle to compare

    return int { aktive_rectangle_is_equal (&param->a, &param->b) ; }
}

operator rectangle::subset {
    note Test if the first 2D rectangle is a subset of the second.

    rect a   First rectangle to compare
    rect b   Second rectangle to compare

    return int { aktive_rectangle_is_subset (&param->a, &param->b) ; }
}

operator rectangle::empty {
    note Test a 2D rectangle for emptiness

    rect r   Rectangle to check

    return int { aktive_rectangle_is_empty (&param->r) ; }
}

# # ## ### ##### ######## ############# #####################

operator rectangle::union {
    note Compute the minimum axis-aligned 2D rectangle encompassing all input rectangles

    rect... r   Rectangles to union

    return rect {
	if (param->r.c == 0) {
	    aktive_rectangle_def (zero, 0, 0, 0, 0);
	    return zero;
	}

	aktive_rectangle r;
	r = param->r.v [0];
	if (param->r.c > 1) {
	    for (aktive_uint i = 1; i < param->r.c; i++) { aktive_rectangle_union (&r, &r, &param->r.v [i]); }
	}
	return r;
    }
}

operator rectangle::intersect {
    note Compute the maximum axis-aligned 2D rectangle shared by all input rectangles

    rect... r   Rectangles to intersect

    return rect {
	if (param->r.c == 0) {
	    aktive_rectangle_def (zero, 0, 0, 0, 0);
	    return zero;
	}

	aktive_rectangle r;
	r = param->r.v [0];
	if (param->r.c > 1) {
	    for (aktive_uint i = 1; i < param->r.c; i++) { aktive_rectangle_intersect (&r, &r, &param->r.v [i]); }
	}
	return r;
    }
}

# # ## ### ##### ######## ############# #####################

operator rectangle::zones {
    note Compute a set of 2D rectangles describing the relation of the request to the domain.

    rect domain  Area covered by image pixels
    rect request Area to get the pixels for

    return object0 {
	aktive_uint c;
	aktive_rectangle v[5];

	aktive_rectangle_outzones (&param->domain, &param->request, &c, v);

	Tcl_Obj* r = Tcl_NewListObj (c, 0);

	for (aktive_uint i = 0; i < c; i++) {
	    Tcl_Obj* vo = aktive_new_rectangle_obj (&v[i]);
	    Tcl_ListObjReplace(ip, r, i, 1, 1, &vo);
	}
	return r;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
