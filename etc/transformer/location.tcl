## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Location changes

# # ## ### ##### ######## ############# #####################

operator op::translate::to {
    note Transformer. Returns an image translationally shifted along the x- and y-axes to a specific location

    input

    int x  New absolute x location of image in the plane
    int y  New absolute y location of image in the plane

    # Elide the operation if the input is already at the desired location
    simplify for \
	src/attr x __x src/attr y __y \
	if {($x == $__x) && ($y == $__y)} \
	returns src

    # Chain reduction when input is a translation of any kind as well.
    # The new location supercedes the previous movement.
    # This may cause full elision in the recursion.

    simplify for src/type @self \
	src/pop \
	returns op translate to : x y

    simplify for src/type op::translate::by \
	src/pop \
	returns op translate to : x y

    state -fields {
	aktive_point delta;
    } -setup {
	// geometry setup
	// - get input geometry in local store
	// - compute and save difference to desired location
	// - update local store for desired location

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));

	aktive_uint dx = domain->x - param->x;
	aktive_uint dy = domain->y - param->y;
	aktive_point_set (&state->delta, dx, dy);

	aktive_point_set (aktive_geometry_as_point(domain), param->x, param->y);
    }
    pixels {
	// rewrite request for passing to input, translate to the origin location
	// fetch data, and save to local store

	aktive_rectangle_add (request, &istate->delta);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);
	aktive_blit_copy0 (block, dst, src);
    }
}

operator op::translate::by {
    note Transformer. Returns an image translationally shifted along the x- and y-axes by a specific amount

    input

    int dx  Shift amount for x location of image in the plane, positive to the right, negative left
    int dy  Shift amount for y location of image in the plane, positive downward, negative upward

    # Elide the operation if there is no actual shift
    simplify for   if {($dx == 0) && ($dy == 0)}   returns src

    # Chain reduction when input is a translation of any kind as well.
    # The preceding movement is folded into the current.
    # This may cause full elision in the recursion

    simplify for src/type @self \
	src/value dx __dx src/value dy __dy \
	calc __ndx {$__dx + $dx} \
	calc __ndy {$__dy + $dy} \
	src/pop \
	returns op translate by : __ndx __ndy

    simplify for src/type op::translate::to \
	src/value x __x src/value y __y \
	calc __nx {$__x + $dx} \
	calc __ny {$__y + $dy} \
	src/pop \
	returns op translate to : __nx __ny

    state -fields {
	aktive_point delta;
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	aktive_point_set (&state->delta, - param->dx, - param->dy);

	domain->x += param->dx;
	domain->y += param->dy;
    }
    pixels {
	// rewrite request for passing to input, translate to the origin location
	// fetch data, and save to local store

	aktive_rectangle_add (request, &istate->delta);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);
	aktive_blit_copy0 (block, dst, src);
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
