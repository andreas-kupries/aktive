/* -*- c -*-
 */

static void FreeImage     (Tcl_Obj* obj);
static void DupImage      (Tcl_Obj* obj, Tcl_Obj* dst);
static int  ImageFromAny  (Tcl_Interp* interp, Tcl_Obj* obj);

static Tcl_ObjType aktive_image_objtype = {
    "aktive::image",
    FreeImage,
    DupImage,
    0,			/* Images have NO string representation */
    ImageFromAny	/* Ditto: Always reports an error       */
};

/*
 * - - -- --- ----- -------- -------------
 */

static Tcl_Obj*
aktive_new_image_obj (aktive_image src) {
    TRACE_FUNC ("((aktive_image) %p '%s' ~ rc %d)", src, src->opspec->name, src->refcount);

    Tcl_Obj* obj = Tcl_NewObj ();

    Tcl_InvalidateStringRep (obj);

    obj->internalRep.twoPtrValue.ptr1 = src;

    aktive_image_ref (src);

    obj->typePtr = &aktive_image_objtype;

    TRACE_RETURN ("(Tcl_Obj*) %p", obj);
}

static int
aktive_image_from_obj (Tcl_Interp* interp, Tcl_Obj* obj, aktive_image* dst) {
    TRACE_FUNC ("((Tcl_Interp*) %p, (Tcl_Obj*) %p, (aktive_image*) %p)", interp, obj, dst);

    if (obj->typePtr != &aktive_image_objtype) {
	if (interp) {
	    Tcl_SetObjResult (interp, Tcl_NewStringObj ("not an image", -1));
	}
	TRACE_RETURN ("(error) %d", TCL_ERROR);
    }

    *dst = (aktive_image) obj->internalRep.twoPtrValue.ptr1;

    TRACE_RETURN ("(ok) %d", TCL_OK);
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
FreeImage (Tcl_Obj* obj)
{
    aktive_image a = (aktive_image) obj->internalRep.twoPtrValue.ptr1;

    TRACE_FUNC ("((Tcl_Obj*) %p obj ~ %d image/rc)", obj, a->refcount);

    aktive_image_unref (a);

    TRACE_RETURN_VOID;
}

static void
DupImage (Tcl_Obj* obj, Tcl_Obj* dst)
{
    TRACE_FUNC ("((Tcl_Obj*) %p obj, (Tcl_Obj*) %p dst)", obj, dst);

    aktive_image src = (aktive_image) obj->internalRep.twoPtrValue.ptr1;

    dst->internalRep.twoPtrValue.ptr1 = src;

    aktive_image_ref (src);

    dst->typePtr = &aktive_image_objtype;

    TRACE_RETURN_VOID;
}

static int
ImageFromAny (Tcl_Interp* interp, Tcl_Obj* obj)
{
    TRACE_FUNC ("((Tcl_Interp*) %p, (Tcl_Obj*) %p)", interp, obj);
    TRACE_RETURN ("(error) %d", TCL_ERROR);
}

/*
 * - - -- --- ----- -------- -------------
 */
