## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Point operations
## -- Fitting completely non-image functionality into the framework

operator point::make {
    section miscellaneous geometry

    example {11 23 | -text}

    note Construct a 2D point from x- and y-coordinates

    int x  Point location, Column
    int y  Point location, Row

    return point {
	aktive_point_def (p, param->x, param->y);
	return p;
    }
}

operator point::add {
    section miscellaneous geometry

    example {{11 23} {-1 7} | -text}

    note Translate a 2D point by a specific amount given as 2D vector

    point point  Point to modify
    point delta  Point to add

    return point {
	aktive_point p;
	p = param->point;
	aktive_point_add (&p, &param->delta);
	return p;
    }
}

operator point::move {
    section miscellaneous geometry

    example {{11 23} -1 7 | -text}

    note Translate a 2D point by a specific amount given as separate x- and y-deltas

    point point  Point to modify
    int   dx     Amount to move left/right, positive to the right
    int   dy     Amount to move up/down, positive downward

    return point {
	aktive_point p;
	p = param->point;
	aktive_point_move (&p, param->dx, param->dy);
	return p;
    }
}

operator point::box {
    section miscellaneous geometry

    example {{11 23} {45 5} {5 45} | -text}

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
