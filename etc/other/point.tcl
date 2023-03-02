## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Point operations
## -- Fitting completely non-image functionality into the framework

operator point::make {
    section miscellaneous geometry

    note Construct a 2D point from x- and y-coordinates

    int x  Point location, Column
    int y  Point location, Row

    return point {
	aktive_point_def (r, param->x, param->y);
	return r;
    }
}

operator point::add {
    section miscellaneous geometry

    note Translate a 2D point by a specific amount given as 2D vector

    point r      Point to modify
    point delta  Point to add

    return point {
	aktive_point r;
	r = param->r;
	aktive_point_add (&r, &param->delta);
	return r;
    }
}

operator point::move {
    section miscellaneous geometry

    note Translate a 2D point by a specific amount given as separate x- and y-deltas

    point r   Point to modify
    int   dx  Amount to move left/right, positive to the right
    int   dy  Amount to move up/down, positive downward

    return point {
	aktive_point r;
	r = param->r;
	aktive_point_move (&r, param->dx, param->dy);
	return r;
    }
}

operator point::box {
    section miscellaneous geometry

    note Compute minimum axis-aligned 2D rectangle enclosing the set of 2D points

    point... points  Points to find the bounding box for

    return rect {
	aktive_rectangle bb;
	aktive_point_union (&bb, param->points.c, param->points.v);
	return bb;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
