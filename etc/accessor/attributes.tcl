## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Getters -- Retrieving image attributes

operator query::id {
    section accessor

    note Returns implementation-specific image identity

    # This is special. It provides an identification of the image, i.e. a value unique to
    # it. This enables equality comparisons, and nothing else.
    #
    # WARE this is the integerized memory address of the thing, with some whitening to
    # make it not as obvious.
    input
    return wide { return 0x25d94395245495a2 ^ (long int) src ; }
    #                      0123456789012345
}

operator query::type {
    section accessor

    note Returns image type

    input
    return image-type { aktive_image_get_type (src); }
}

operator query::location {
    section accessor

    note Returns 2D image location, a 2D point

    input
    return point { *aktive_image_get_location (src); }
}

operator query::domain {
    section accessor

    note Returns image geometry, a 2D rectangle

    input
    return rect { *aktive_image_get_domain (src); }
}

operator query::geometry {
    section accessor

    note Returns image geometry, a 2D rectangle, plus depth.

    input
    return geometry { *aktive_image_get_geometry (src); }
}

operator attribute {
    query::x    x
    query::xmax xmax
    query::y    y
    query::ymax ymax
} {
    section accessor

    note Returns image $attribute location

    input

    return int "aktive_image_get_$attribute (src);"
}

operator attribute {
    query::width  width
    query::height height
    query::depth  depth
    query::pixels pixels
    query::pitch  pitch
    query::size   size
} {
    section accessor

    note Returns image $attribute

    input

    return uint "aktive_image_get_$attribute (src);"
}

operator query::inputs {
    section accessor

    note Returns list of input images, if any

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

    note Returns dictionary of image parameters, if any.

    input

    return object0 {
	aktive_uint c = aktive_image_get_nparams (src);
	Tcl_Obj* r    = Tcl_NewDictObj();

	for (aktive_uint i = 0; i < c; i++) {
	  const char* n = aktive_image_get_param_name (src, i);
	  Tcl_Obj*    v = aktive_image_get_param_value (src, i, ip);
	  Tcl_DictObjPut (ip, r, Tcl_NewStringObj (n,-1), v);
	}
	return r;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
