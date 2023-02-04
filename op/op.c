/* -*- c -*-
 *
 * -- Direct operator support - formatting image as Tcl structure
 */

#include <op.h>

#define K(s) Tcl_NewStringObj((s), -1) /* TODO :: Use enum */

/*
 * - - -- --- ----- -------- -------------
 */

static Tcl_Obj*
aktive_op_astcl (Tcl_Interp* ip, aktive_image src) {
    Tcl_Obj* r = Tcl_NewDictObj();

    Tcl_DictObjPut (ip, r, K ("type"),   K (aktive_image_get_type(src)->name));
    Tcl_DictObjPut (ip, r, K ("domain"), aktive_op_geometry (ip, src));

    Tcl_Obj* params = aktive_op_params (ip, src);
    if (params) {
	Tcl_DictObjPut (ip, r, K("config"), params);
    }

    Tcl_Obj* pixels = aktive_op_pixels (ip, src);
    if (pixels) {
	Tcl_DictObjPut (ip, r, K("pixels"), pixels);
    }

    return r;
}

static Tcl_Obj*
aktive_op_params (Tcl_Interp* ip, aktive_image src) {

    aktive_uint c = aktive_image_get_nparams (src);

    if (!c) { return 0; }
	
    Tcl_Obj* p = Tcl_NewDictObj();

    for (aktive_uint i = 0; i < c; i++) {
	const char* n = aktive_image_get_param_name  (src, i);
	Tcl_Obj*    v = aktive_image_get_param_value (src, i, ip);
	Tcl_DictObjPut (ip, p, K (n), v);
    }

    return p;
}

static Tcl_Obj*
aktive_op_pixels (Tcl_Interp* ip, aktive_image src) {

    aktive_uint sz = aktive_image_get_size (src);

    if (!sz) { return 0; }

    Tcl_Obj* p = Tcl_NewListObj (sz, 0); // 0 => Space is allocated for `sz` elements.

    // This code asks for the entire image in one call.  That is generally bad
    // for a large image. It also does not allow for concurrent execution.
    //
    // %% TODO %% create and use a worker system to for concurrency
    
    aktive_rectangle* domain = aktive_image_get_domain (src);
    aktive_region     rg     = aktive_region_new (src);
    aktive_block*     pixels = aktive_region_fetch_area (rg, domain);

    for (aktive_uint i = 0; i < sz; i++) {
	Tcl_Obj* v = Tcl_NewDoubleObj (pixels->pixel [i]);
	Tcl_ListObjReplace(ip, p, i, 1, 1, &v);
    }

    aktive_region_destroy (rg); // Note that this invalidates `pixels` too.

    return p;
}

static Tcl_Obj*
aktive_op_geometry (Tcl_Interp* ip, aktive_image src) {
    Tcl_Obj* geo = Tcl_NewDictObj();

    Tcl_DictObjPut (ip, geo, K ("x"),      Tcl_NewIntObj       (aktive_image_get_x      (src)));
    Tcl_DictObjPut (ip, geo, K ("y"),      Tcl_NewIntObj       (aktive_image_get_y      (src)));
    Tcl_DictObjPut (ip, geo, K ("width"),  aktive_new_uint_obj (aktive_image_get_width  (src)));
    Tcl_DictObjPut (ip, geo, K ("height"), aktive_new_uint_obj (aktive_image_get_height (src)));
    Tcl_DictObjPut (ip, geo, K ("depth"),  aktive_new_uint_obj (aktive_image_get_depth  (src)));

    return geo;
}

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */