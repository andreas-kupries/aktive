## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Rectangle operations -- fractional rectangles, i.e. double attributes, not gridded
##
## -- Fitting completely non-image functionality into the framework

# # ## ### ##### ######## ############# #####################

operator frectangle::make {
    section miscellaneous geometry

    example {11 23 30 20 | -text}

    note Construct a 2D rectangle from x- and y-coordinates and width/height dimensions

    double xlo  Rectangle location, minimal x
    double ylo  Rectangle location, minimal y
    double xhi  Rectangle location, maximal x
    double yhi  Rectangle location, maximal y

    return frect {
	aktive_frectangle_def (r, param->xlo, param->ylo, param->xhi, param->yhi);
	return r;
    }
}

operator frectangle::grow {
    section miscellaneous geometry

    example {{11 23 30 20} 1 7 5 10 | -text}

    note Modify 2D rectangle by moving its 4 borders by a specific amount

    frect  rect    Rectangle to modify
    double left    Amount to grow the left border, positive to the left
    double right   Amount to grow the right border, positive to the right
    double top     Amount to grow the top border, positive upward
    double bottom  Amount to grow the bottom border, positive downward

    return frect {
	aktive_frectangle r;
	r = param->rect;
	aktive_frectangle_grow (&r,
			       param->left, param->right,
			       param->top,  param->bottom);
	return r;
    }
}

operator frectangle::move {
    section miscellaneous geometry

    example {{11 23 30 20} -5 7 | -text}

    note Translate a 2D rectangle by a specific amount given as separate x- and y-deltas

    frect rect  Rectangle to modify
    double   dx    Amount to move left/right, positive to the right
    double   dy    Amount to move up/down, positive downward

    return frect {
	aktive_frectangle r;
	r = param->rect;
	aktive_frectangle_move (&r, param->dx, param->dy);
	return r;
    }
}

# # ## ### ##### ######## ############# #####################

operator frectangle::equal {
    section miscellaneous geometry

    example {{11 23 41 43} {11 23 41 43} | -text}
    example {{11 23 41 43} {11 23 21 43} | -text}

    note Test two 2D rectangles for equality (location and dimensions)

    frect a   First rectangle to compare
    frect b   Second rectangle to compare

    return int { aktive_frectangle_is_equal (&param->a, &param->b) ; }
}

operator frectangle::subset {
    section miscellaneous geometry

    example {{11 23 41 43} {11 23 41 43} | -text}
    example {{11 23 41 43} {12 22 22 37} | -text}
    example {{11 23 41 43} {10 20 50 45} | -text}

    note Test if the first 2D rectangle is a subset of the second.

    frect a   First rectangle to compare
    frect b   Second rectangle to compare

    return int { aktive_frectangle_is_subset (&param->a, &param->b) ; }
}

operator frectangle::empty {
    section miscellaneous geometry

    example {{11 23  30  20} | -text}
    example {{11 23 -10 -22} | -text}

    note Test a 2D rectangle for emptiness

    frect rect   Rectangle to check

    return int { aktive_frectangle_is_empty (&param->rect) ; }
}

# # ## ### ##### ######## ############# #####################

operator frectangle::union {
    section miscellaneous geometry

    example {{11 23 41 43} {10 20 50 45} | -text}

    note Compute the minimum axis-aligned 2D rectangle encompassing all input rectangles

    frect... rects   Rectangles to union

    return frect {
	if (param->rects.c == 0) {
	    aktive_frectangle_def (zero, 0, 0, -1, -1);
	    TRACE_RETURN ("(zero)", zero);
	}

	aktive_frectangle r;
	r = param->rects.v [0];
	if (param->rects.c > 1) {
	    aktive_uint i;
	    for (i = 1; i < param->rects.c; i++) {
		aktive_frectangle_union (&r, &r, &param->rects.v [i]);
	    }
	}
	return r;
    }
}

operator frectangle::intersect {
    section miscellaneous geometry

    example {{11 23 41 43} {10 20 50 45} | -text}
    # TODO: empty intersection, some intersection

    note Compute the maximum axis-aligned 2D rectangle shared by all input rectangles

    frect... rects   Rectangles to intersect

    return frect {
	if (param->rects.c == 0) {
	    aktive_frectangle_def (zero, 0, 0, -1, -1);
	    TRACE_RETURN ("(zero)", zero);
	}

	aktive_frectangle r;
	r = param->rects.v [0];
	if (param->rects.c > 1) {
	    aktive_uint i;
	    for (i = 1; i < param->rects.c; i++) {
		aktive_frectangle_intersect (&r, &r, &param->rects.v [i]);
	    }
	}
	return r;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
