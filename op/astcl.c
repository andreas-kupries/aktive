/* -*- c -*-
 *
 * -- Direct operator support
 *    -- formatting image as Tcl structure
 *
 * -- Math for the transformers
 */

#include <astcl.h>

#include <tclpre9compat.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

#define K(s) Tcl_NewStringObj((s), TCL_AUTO_LENGTH) /* TODO :: Use enum */ /* OK tcl9 */

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj*
aktive_op_astcl (Tcl_Interp* ip, aktive_image src) {
    TRACE_FUNC ("((interp*) %p, (aktive_image*) %p)", ip, src);

    Tcl_Obj* r = Tcl_NewDictObj();

    Tcl_DictObjPut (ip, r, K ("type"),   K (aktive_image_get_type(src)->name));
    Tcl_DictObjPut (ip, r, K ("domain"), aktive_op_geometry (ip, src));


    Tcl_Obj* meta = aktive_image_meta_get (src);
    if (meta) {
	Tcl_DictObjPut (ip, r, K("meta"),meta);
    }

    Tcl_Obj* params = aktive_op_params (ip, src);
    if (params) {
	Tcl_DictObjPut (ip, r, K("config"), params);
    }

    Tcl_Obj* pixels = aktive_op_pixels (ip, src);
    if (pixels) {
	Tcl_DictObjPut (ip, r, K("pixels"), pixels);
    } else if (aktive_error_raised()) {
	Tcl_DecrRefCount (r);
	TRACE_RETURN ("(Tcl_Obj*) %p", 0);
    }

    TRACE_RETURN ("(Tcl_Obj*) %p", r);
}

extern Tcl_Obj*
aktive_op_params (Tcl_Interp* ip, aktive_image src) {
    TRACE_FUNC ("((interp*) %p, (aktive_image*) %p)", ip, src);

    aktive_uint c = aktive_image_get_nparams (src);

    if (!c) {
	TRACE_RETURN ("(Tcl_Obj*) %p", 0);
    }

    Tcl_Obj* p = Tcl_NewDictObj();

    for (aktive_uint i = 0; i < c; i++) {
	const char* n = aktive_image_get_param_name  (src, i);
	Tcl_Obj*    v = aktive_image_get_param_value (src, i, ip);
	Tcl_DictObjPut (ip, p, K (n), v);
    }

    TRACE_RETURN ("(Tcl_Obj*) %p", p);
}

extern Tcl_Obj*
aktive_op_pixels (Tcl_Interp* ip, aktive_image src) {
    TRACE_FUNC ("((interp*) %p, (aktive_image*) %p)", ip, src);

    aktive_uint sz = aktive_image_get_size (src);

    if (!sz) { TRACE_RETURN ("(Tcl_Obj*) %p", 0); }

    Tcl_Obj* p = Tcl_NewListObj (sz, 0); // OK tcl9, 0 => Space is allocated for `sz` elements.

    aktive_rectangle* domain = aktive_image_get_domain (src);
    aktive_context    c      = aktive_context_new ();
    aktive_region     rg     = aktive_region_new (src, c);

    if (!rg) { TRACE_RETURN ("(Tcl_Obj*) %p", 0); }

    // Scan image by rows, add the pixels of each retrieved row to the result list.

    aktive_rectangle_def_as (scan, domain);
    aktive_uint height = scan.height;
    scan.height = 1;

    aktive_uint k, i, j;

    for (k = 0, i=0; k < height; k ++) {
	TRACE ("row %d", k);
	TRACE_RECTANGLE(&scan);

	aktive_block* pixels = aktive_region_fetch_area_head (rg, &scan);

	for (j = 0; j < pixels->used; j++, i++) {
	    ASSERT_VA (i < sz, "too many pixel values", "%d >= %d", i, sz);

	    Tcl_Obj* v = Tcl_NewDoubleObj (pixels->pixel [j]);
	    Tcl_ListObjReplace(ip, p, i, 1, 1, &v);	 /* OK tcl9 */
	}

	aktive_rectangle_move (&scan, 0, 1);
    }

    aktive_region_destroy (rg); // Note that this invalidates `pixels` too.
    aktive_context_destroy (c);

    TRACE_RETURN ("(Tcl_Obj*) %p", p);
}

extern Tcl_Obj*
aktive_op_geometry (Tcl_Interp* ip, aktive_image src) {
    TRACE_FUNC ("((interp*) %p, (aktive_image*) %p)", ip, src);

    Tcl_Obj* geo = Tcl_NewDictObj();

    Tcl_DictObjPut (ip, geo, K ("x"),      Tcl_NewIntObj       (aktive_image_get_x      (src))); /* OK tcl9 */
    Tcl_DictObjPut (ip, geo, K ("y"),      Tcl_NewIntObj       (aktive_image_get_y      (src))); /* OK tcl9 */
    Tcl_DictObjPut (ip, geo, K ("width"),  aktive_new_uint_obj (aktive_image_get_width  (src)));
    Tcl_DictObjPut (ip, geo, K ("height"), aktive_new_uint_obj (aktive_image_get_height (src)));
    Tcl_DictObjPut (ip, geo, K ("depth"),  aktive_new_uint_obj (aktive_image_get_depth  (src)));

    TRACE_RETURN ("(Tcl_Obj*) %p", geo);
}

extern Tcl_Obj*
aktive_op_setup (Tcl_Interp* ip, aktive_image src) {
    TRACE_FUNC ("((interp*) %p, (aktive_image*) %p)", ip, src);

    Tcl_Obj* r = Tcl_NewDictObj();

    // setup of inputs ? just count ? id ?

    Tcl_DictObjPut (ip, r, K ("type"),   K (aktive_image_get_type(src)->name));
    Tcl_DictObjPut (ip, r, K ("domain"), aktive_op_geometry (ip, src));

    Tcl_Obj* params = aktive_op_params (ip, src);
    if (params) {
	Tcl_DictObjPut (ip, r, K("config"), params);
    }

    TRACE_RETURN ("(Tcl_Obj*) %p", r);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
