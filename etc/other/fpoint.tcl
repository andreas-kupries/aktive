## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Point operations -- fractional points, i.e. double coordinates, not gridded
##
## -- Fitting completely non-image functionality into the framework

operator fpoint::make {
    section miscellaneous geometry

    example {11 23 | -text}

    note Construct a 2D point from x- and y-coordinates

    double x  Point location, Column
    double y  Point location, Row

    return fpoint {
	aktive_fpoint_def (p, param->x, param->y);
	return p;
    }
}

operator fpoint::add {
    section miscellaneous geometry

    example {{11 23} {-1 7} | -text}

    note Translate a 2D point by a specific amount given as 2D vector

    fpoint point  Point to modify
    fpoint delta  Point to add

    return fpoint {
	aktive_fpoint p;
	p = param->point;
	aktive_fpoint_add (&p, &param->delta);
	return p;
    }
}

operator fpoint::move {
    section miscellaneous geometry

    example {{11 23} -1 7 | -text}

    note Translate a 2D point by a specific amount given as separate x- and y-deltas

    fpoint point  Point to modify
    double dx     Amount to move left/right, positive to the right
    double dy     Amount to move up/down, positive downward

    return fpoint {
	aktive_fpoint p;
	p = param->point;
	aktive_fpoint_move (&p, param->dx, param->dy);
	return p;
    }
}

operator fpoint::box {
    section miscellaneous geometry

    example {{11 23} {45 5} {5 45} | -text}

    note Compute minimum axis-aligned 2D rectangle enclosing the set of 2D points

    fpoint... points  Points to find the bounding box for

    return frect {
	aktive_frectangle bb;
	aktive_fpoint_union (&bb, param->points.c, param->points.v);
	return bb;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
