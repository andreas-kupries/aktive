## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Point operations
## -- Fitting completely non-image functionality into the framework

operator point::make {
    int x  Point location, Column
    int y  Point location, Row

    return point {
	aktive_point_def (r, param->x, param->y);
	return r;
    }
}

operator point::add {
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
