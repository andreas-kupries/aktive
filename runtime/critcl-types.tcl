# -*- tcl -*-
# # ## ### ##### ######## #############
## Project specific Critcl argument/result types

critcl::argtype aktive_string = char*

# # ## ### ##### ######## #############
## uint

critcl::argtype aktive_uint {
    Tcl_WideInt tmp;
    if (Tcl_GetWideIntFromObj(interp, @@, &tmp) != TCL_OK) {
	return TCL_ERROR;
    } else if ((tmp < 0) || (tmp > ((Tcl_WideInt) 4294967295))) {
	Tcl_SetResult (interp, "integer out of range [0..4294967295]", TCL_STATIC);
	return TCL_ERROR;
    }
    @A = tmp;
} aktive_uint aktive_uint

critcl::resulttype aktive_uint = wideint

# # ## ### ##### ######## #############
## 2d points

critcl::argtype aktive_point {
    Tcl_Size  c;
    Tcl_Obj** v;

    if (Tcl_ListObjGetElements (interp, @@, &c, (Tcl_Obj***) &v) != TCL_OK) { /* OK tcl9 */
	return TCL_ERROR;
    }
    if (c != 2) {
	Tcl_SetResult (interp, "Bad #elements for point", TCL_STATIC);
	return TCL_ERROR;
    }

    int x, y;
    if (Tcl_GetIntFromObj (interp, v[0], &x) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj (interp, v[1], &y) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */

    aktive_point_set (&@A, x, y);
} aktive_point aktive_point

critcl::resulttype aktive_point {
    Tcl_SetObjResult (interp, aktive_new_point_obj(&rv));
    return TCL_OK;
} aktive_point

# # ## ### ##### ######## #############
## 2d rectangle

critcl::argtype aktive_rectangle {
    Tcl_Size  c;
    Tcl_Obj** v;

    if (Tcl_ListObjGetElements (interp, @@, &c, (Tcl_Obj***) &v) != TCL_OK) { /* OK tcl9 */
	return TCL_ERROR;
    }
    if (c != 4) {
	Tcl_SetResult (interp, "Bad #elements for rectangle", TCL_STATIC);
	return TCL_ERROR;
    }

    int x, y, w, h;
    if (Tcl_GetIntFromObj (interp, v[0], &x) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj (interp, v[1], &y) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj (interp, v[2], &w) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj (interp, v[3], &h) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */

    aktive_rectangle_set (&@A, x, y, w, h);
} aktive_rectangle aktive_rectangle

critcl::resulttype aktive_rectangle {
    Tcl_SetObjResult (interp, aktive_new_rectangle_obj(&rv));
    return TCL_OK;
} aktive_rectangle

# # ## ### ##### ######## #############
## 2d/3d geometry

critcl::argtype aktive_geometry {
    Tcl_Size  c;
    Tcl_Obj** v;

    if (Tcl_ListObjGetElements (interp, @@, &c, (Tcl_Obj***) &v) != TCL_OK) { /* OK tcl9 */
	return TCL_ERROR;
    }
    if (c != 5) {
	Tcl_SetResult (interp, "Bad #elements for geometry", TCL_STATIC);
	return TCL_ERROR;
    }

    int x, y, w, h, d;
    if (Tcl_GetIntFromObj (interp, v[0], &x) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj (interp, v[1], &y) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj (interp, v[2], &w) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj (interp, v[3], &h) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj (interp, v[3], &d) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */

    aktive_geometry_set (&@A, x, y, w, h, d);
} aktive_geometry aktive_geometry

critcl::resulttype aktive_geometry {
    Tcl_SetObjResult (interp, aktive_new_geometry_obj(&rv));
    return TCL_OK;
} aktive_geometry

# # ## ### ##### ######## #############
## range

critcl::argtype aktive_range {
    Tcl_Size  c;
    Tcl_Obj** v;

    if (Tcl_ListObjGetElements (interp, @@, &c, (Tcl_Obj***) &v) != TCL_OK) { /* OK tcl9 */
	return TCL_ERROR;
    }
    if (c != 4) {
	Tcl_SetResult (interp, "Bad #elements for range", TCL_STATIC);
	return TCL_ERROR;
    }

    int xmin, xmax, y;
    double value;
    if (Tcl_GetIntFromObj    (interp, v[0], &y    ) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj    (interp, v[1], &xmin ) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetIntFromObj    (interp, v[2], &xmax ) != TCL_OK) { return TCL_ERROR; } /* OK tcl9 */
    if (Tcl_GetDoubleFromObj (interp, v[3], &value) != TCL_OK) { return TCL_ERROR; }

    aktive_range_set (&@A, xmin, xmax, y, value);
} aktive_range aktive_range

# # ## ### ##### ######## #############
## image types

critcl::resulttype aktive_image_type_ptr {
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult (interp, Tcl_NewStringObj (rv->name, -1)); /* OK tcl9 */
    return TCL_OK;
} aktive_image_type_ptr

# # ## ### ##### ######## #############
## images

critcl::argtype aktive_image {
    if (aktive_image_from_obj (interp, @@, &@A) != TCL_OK) { return TCL_ERROR; }
} aktive_image aktive_image

critcl::resulttype aktive_image {
    // This assumes that the work function has set an error message into the interp
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult (interp, aktive_new_image_obj(rv));
    return TCL_OK;
} aktive_image

# # ## ### ##### ######## #############
## 2d points - fractional variant

critcl::argtype aktive_fpoint {
    Tcl_Size  c;
    Tcl_Obj** v;

    if (Tcl_ListObjGetElements (interp, @@, &c, (Tcl_Obj***) &v) != TCL_OK) { /* OK tcl9 */
	return TCL_ERROR;
    }
    if (c != 2) {
	Tcl_SetResult (interp, "Bad #elements for point", TCL_STATIC);
	return TCL_ERROR;
    }

    double x, y;
    if (Tcl_GetDoubleFromObj (interp, v[0], &x) != TCL_OK) { return TCL_ERROR; }
    if (Tcl_GetDoubleFromObj (interp, v[1], &y) != TCL_OK) { return TCL_ERROR; }

    aktive_fpoint_set (&@A, x, y);
} aktive_fpoint aktive_fpoint

critcl::resulttype aktive_fpoint {
    Tcl_SetObjResult (interp, aktive_new_fpoint_obj(&rv));
    return TCL_OK;
} aktive_fpoint

# # ## ### ##### ######## #############
## 2d rectangle - fractional variant

critcl::argtype aktive_frectangle {
    Tcl_Size  c;
    Tcl_Obj** v;

    if (Tcl_ListObjGetElements (interp, @@, &c, (Tcl_Obj***) &v) != TCL_OK) { /* OK tcl9 */
	return TCL_ERROR;
    }
    if (c != 4) {
	Tcl_SetResult (interp, "Bad #elements for rectangle", TCL_STATIC);
	return TCL_ERROR;
    }

    double x, y, w, h;
    if (Tcl_GetDoubleFromObj (interp, v[0], &x) != TCL_OK) { return TCL_ERROR; }
    if (Tcl_GetDoubleFromObj (interp, v[1], &y) != TCL_OK) { return TCL_ERROR; }
    if (Tcl_GetDoubleFromObj (interp, v[2], &w) != TCL_OK) { return TCL_ERROR; }
    if (Tcl_GetDoubleFromObj (interp, v[3], &h) != TCL_OK) { return TCL_ERROR; }

    aktive_frectangle_set (&@A, x, y, w, h);
} aktive_frectangle aktive_frectangle

critcl::resulttype aktive_frectangle {
    Tcl_SetObjResult (interp, aktive_new_frectangle_obj(&rv));
    return TCL_OK;
} aktive_frectangle

# # ## ### ##### ######## #############
return
