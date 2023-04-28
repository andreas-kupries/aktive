## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Getters -- Retrieving image attributes

operator query::id {
    section accessor

    note Returns implementation-specific image identity.

    # This is special. It provides an identification of the image, i.e. a value unique to
    # it. This enables equality comparisons, and nothing else.
    #
    # BEWARE. This is the integerized memory address of the thing, with some whitening to
    # make it not as obvious.
    input
    return wide {
	Tcl_WideInt r = 0x25d94395245495a2 ^ (long int) src ;
	//                0123456789012345
	return r;
    }
}

operator query::type {
    section accessor

    note Returns image type.

    input
    return image-type {
	aktive_image_type* r = aktive_image_get_type (src);
	return r;
    }
}

operator query::location {
    section accessor geometry

    note Returns 2D image location, a 2D point.

    input
    return point {
	aktive_point* r = aktive_image_get_location (src);
	return *r;
    }
}

operator query::domain {
    section accessor geometry

    note Returns image domain, a 2D rectangle.

    input
    return rect {
	aktive_rectangle* r = aktive_image_get_domain (src);
	return *r;
    }
}

operator query::geometry {
    section accessor geometry

    note Returns full image geometry, i.e. domain plus depth.

    input
    return geometry {
	aktive_geometry* r = aktive_image_get_geometry (src);
	return *r;
    }
}

operator attribute {
    query::x    x
    query::xmax xmax
    query::y    y
    query::ymax ymax
} {
    section accessor geometry

    note Returns image $attribute location.

    input

    return int {
	int r = aktive_image_get_@@attribute@@ (src);
	return r;
    }
}

operator attribute {
    query::width  width
    query::height height
    query::depth  depth
    query::pixels pixels
    query::pitch  pitch
    query::size   size
} {
    section accessor geometry

    note Returns image ${attribute}.

    input

    return uint {
	aktive_uint r = aktive_image_get_@@attribute@@ (src);
	return r;
    }
}

operator query::inputs {
    section accessor

    note Returns list of the image inputs, if any.

    input

    return object0 {
	aktive_uint c = aktive_image_get_nsrcs (src);
	Tcl_Obj**   v = NALLOC (Tcl_Obj*, c);

	for (aktive_uint i = 0; i < c; i++) {
	  v [i] = aktive_new_image_obj  (aktive_image_get_src (src, i));
	}
	Tcl_Obj* r = Tcl_NewListObj (c, v);
	ckfree ((char*) v);
	return r;
    }
}

operator query::params {
    section accessor

    note Returns dictionary of the image parameters, if any.

    input

    return object0 {
	Tcl_Obj* r = aktive_op_params (ip, src);
	if (!r) { r = Tcl_NewDictObj (); }
	return r;
    }
}

operator query::setup {
    section accessor

    note Returns dictionary of the image setup. \
	IOW type, geometry, and parameters, if any. \
	No inputs though, even if the image has any.

    input

    return object0 {
	Tcl_Obj* r = aktive_op_setup (ip, src);
	return r;
    }
}

operator query::meta {
    section accessor metadata

    note Returns the image meta data (a Tcl dictionary).

    input

    return object0 {
	Tcl_Obj* r = aktive_image_meta_get (src);
	if (!r) { r = Tcl_NewDictObj (); }
	return r;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
