/* -*- c -*-
 *
 * -- Direct operator support
 *    -- formatting image as Tcl structure
 *
 * -- Math for the transformers
 */

#include <op.h>

//#include <tcl.h>
//#include <critcl_alloc.h>
//#include <critcl_assert.h>
//#include <critcl_trace.h>
//TRACE_OFF;

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

static double aktive_invert     (double x) { return 1 - x; }
static double aktive_neg        (double x) { return -x; }
static double aktive_reciprocal (double x) { return 1.0/x; }
static double aktive_clamp      (double x) { return (x < 0) ? 0 : (x > 1) ? 1 : x; }
static double aktive_wrap       (double x) { return (x > 1) ? fmod(x, 1) : (x < 0) ? (1 + fmod(x - 1, 1)) : x; }
static double aktive_sign       (double x) { return (x < 0) ? -1 : (x > 0) ? 1 : 0; }
static double aktive_signb      (double x) { return (x < 0) ? -1 : 1; }

// apparently `exp10` is a GNU thing, whereas exp2 is not, nor is log10
static double aktive_exp10      (double x) { return pow (10, x); }

/* sRGB specification
 * - gamma transfer functions
 *   https://en.wikipedia.org/wiki/SRGB#The_sRGB_transfer_function_(%22gamma%22)
 */

#define GAMMA  (2.4)
#define IGAMMA (1.0/GAMMA)
#define IGAIN  (12.92)
#define GAIN   (1.0/IGAIN)
#define GLIMIT (0.4045)
#define ILIMIT (0.0031308)
#define OFFSET (0.055)
#define SCALE  (1.055)

static double
aktive_gamma_compress (double x) {
    /* BEWARE :: Assumes x in [0..1] */
    TRACE_FUNC ("((double) %f)", x);
    double value =
        (x <= ILIMIT)
        ? x * IGAIN
        : SCALE * pow (x, IGAMMA) - OFFSET
        ;
    TRACE_RETURN ("(double) %f", value);
}

static double
aktive_gamma_expand (double x) {
    TRACE_FUNC ("((double) %f)", x);
    double value =
        (x <= GLIMIT)
        ? x * GAIN
        : pow ((x + OFFSET) / SCALE, GAMMA)
        ;
    TRACE_RETURN ("(double) %f", value);
}

/*
 * - - -- --- ----- -------- -------------
 */

static double aktive_shift  (double x, double offset)    { return x + offset; }
static double aktive_nshift (double x, double offset)    { return offset - x; }
static double aktive_scale  (double x, double factor)    { return x * factor; }
static double aktive_rscale (double x, double factor)    { return factor / x; }
static double aktive_fmod   (double x, double numerator) { return fmod (numerator, x); }
static double aktive_pow    (double x, double base)      { return pow (base, x); }
static double aktive_atan   (double x, double y)         { return atan2 (y, x); }
static double aktive_ge     (double x, double threshold) { return (x >= threshold) ? 1 : 0; }
static double aktive_le     (double x, double threshold) { return (x <= threshold) ? 1 : 0; }
static double aktive_gt     (double x, double threshold) { return (x >  threshold) ? 1 : 0; }
static double aktive_lt     (double x, double threshold) { return (x <  threshold) ? 1 : 0; }
static double aktive_sol    (double x, double threshold) { return (x <= threshold) ? x : 1-x; }

/*
 * - - -- --- ----- -------- -------------
 */

static double aktive_inside_oo  (double x, double low, double high) { return (low <  x) && (x <  high) ? 1 : 0; }
static double aktive_inside_oc  (double x, double low, double high) { return (low <  x) && (x <= high) ? 1 : 0; }
static double aktive_inside_co  (double x, double low, double high) { return (low <= x) && (x <  high) ? 1 : 0; }
static double aktive_inside_cc  (double x, double low, double high) { return (low <= x) && (x <= high) ? 1 : 0; }
static double aktive_outside_oo (double x, double low, double high) { return (low <  x) && (x <  high) ? 0 : 1; }
static double aktive_outside_oc (double x, double low, double high) { return (low <  x) && (x <= high) ? 0 : 1; }
static double aktive_outside_co (double x, double low, double high) { return (low <= x) && (x <  high) ? 0 : 1; }
static double aktive_outside_cc (double x, double low, double high) { return (low <= x) && (x <= high) ? 0 : 1; }

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
