# -*- tcl -*-
# # ## ### ##### ######## #############
## Project specific Critcl argument/result types

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
    int       c;
    Tcl_Obj** v;

    if (Tcl_ListObjGetElements (interp, @@, &c, (Tcl_Obj***) &v) != TCL_OK) {
	return TCL_ERROR;
    }
    if (c != 2) {
	Tcl_SetResult (interp, "Bad #elements for point", TCL_STATIC);
	return TCL_ERROR;
    }

    int x, y;
    if (Tcl_GetIntFromObj (interp, v[0], &x) != TCL_OK) { return TCL_ERROR; }
    if (Tcl_GetIntFromObj (interp, v[1], &y) != TCL_OK) { return TCL_ERROR; }

    (@A).x = x;
    (@A).y = y;
} aktive_point aktive_point

critcl::resulttype aktive_point {
    Tcl_SetObjResult (interp, aktive_new_point_obj(&rv));
    return TCL_OK;
} aktive_point

# # ## ### ##### ######## #############
## 2d rectangle

critcl::argtype aktive_rectangle {
    int       c;
    Tcl_Obj** v;

    if (Tcl_ListObjGetElements (interp, @@, &c, (Tcl_Obj***) &v) != TCL_OK) {
	return TCL_ERROR;
    }
    if (c != 4) {
	Tcl_SetResult (interp, "Bad #elements for rectangle", TCL_STATIC);
	return TCL_ERROR;
    }

    int x, y, w, h;
    if (Tcl_GetIntFromObj (interp, v[0], &x) != TCL_OK) { return TCL_ERROR; }
    if (Tcl_GetIntFromObj (interp, v[1], &y) != TCL_OK) { return TCL_ERROR; }
    if (Tcl_GetIntFromObj (interp, v[2], &w) != TCL_OK) { return TCL_ERROR; }
    if (Tcl_GetIntFromObj (interp, v[3], &h) != TCL_OK) { return TCL_ERROR; }

    (@A).x      = x;
    (@A).y      = y;
    (@A).width  = w;
    (@A).height = h;
} aktive_rectangle aktive_rectangle

critcl::resulttype aktive_rectangle {
    Tcl_SetObjResult (interp, aktive_new_rectangle_obj(&rv));
    return TCL_OK;
} aktive_rectangle

# # ## ### ##### ######## #############
## image types

critcl::resulttype aktive_image_type* {
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult (interp, Tcl_NewStringObj (rv->name, -1));
    return TCL_OK;
} {const aktive_image_type*}

# # ## ### ##### ######## #############
## images

critcl::argtype aktive_image {
    if (aktive_image_from_obj (interp, @@, &@A) != TCL_OK) { return TCL_ERROR; }
} aktive_image aktive_image

critcl::resulttype aktive_image {
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult (interp, aktive_new_image_obj(rv));
    return TCL_OK;
} aktive_image

# # ## ### ##### ######## #############
return
