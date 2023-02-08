## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Getters -- Retrieving image attributes

operator query::type {
    input ignore
    return image-type { aktive_image_get_type (src); }
}

operator query::location {
    input ignore
    return point { *aktive_image_get_location (src); }
}

operator query::domain {
    input ignore
    return rect { *aktive_image_get_domain (src); }
}

operator query::geometry {
    input ignore
    return geometry { *aktive_image_get_geometry (src); }
}

operator attribute {
    query::x    x
    query::xmax xmax
    query::y    y
    query::ymax ymax
} {
    input ignore

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
    input ignore

    return uint "aktive_image_get_$attribute (src);"
}

operator query::inputs {
    input ignore

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
    input ignore

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
