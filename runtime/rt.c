/* -*- c -*-
 */

#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include <tclpre9compat.h>

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <rt.h>
#include <internals.h>

#include <rtgen/vector-funcs.c>
#include <rtgen/type-funcs.c>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct ThreadSpecificData {
    Tcl_Obj* error;
} ThreadSpecificData;

/* copied from tclInt.h */
#define TCL_TSD_INIT(keyPtr) \
    (ThreadSpecificData *)Tcl_GetThreadData((keyPtr), sizeof(ThreadSpecificData)) /* OK tcl9 */

static Tcl_ThreadDataKey rtDataKey;

/*
 * - - -- --- ----- -------- -------------
 * Error management
 */

extern int
aktive_error_raised (void) {
    TRACE_FUNC("()", 0);

    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&rtDataKey);

    TRACE_RETURN ("raised (%d)", !!tsdPtr->error);
}

extern void
aktive_error_set (Tcl_Interp* interp) {
    TRACE_FUNC("((Tcl_Interp*) %p)", interp);

    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&rtDataKey);

    if (!tsdPtr->error) TRACE_RETURN_VOID;

    TRACE ("report '%s'", Tcl_GetString (tsdPtr->error));

    Tcl_SetErrorCode (interp, "AKTIVE", "ERROR", NULL);
    Tcl_SetObjResult (interp, tsdPtr->error);
    Tcl_DecrRefCount (tsdPtr->error);
    tsdPtr->error = 0;

    TRACE_RETURN_VOID;
}

extern void
aktive_error_add (const char* message) {
    TRACE_FUNC("(char*) '%s'", message);

    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&rtDataKey);

    // %% Consider the collection of multiple errors, instead of keeping just
    // %% the last

    if (tsdPtr->error) { Tcl_DecrRefCount (tsdPtr->error); }

    tsdPtr->error = Tcl_NewStringObj (message, TCL_AUTO_LENGTH); /* OK tcl9 */
    Tcl_IncrRefCount (tsdPtr->error);

    TRACE_RETURN_VOID;
}

extern void
aktive_error_addf (const char* format, ...) {
    TRACE_FUNC("(%s ...)", format);

    /*
     * 128K output-buffer is hopefully large enough.
     */
#define MSGMAX (128*1024)
    static char msg [MSGMAX];

    va_list args;
    va_start(args, format);
    int len = vsnprintf(msg, MSGMAX, format, args);
    va_end(args);

    aktive_error_add (msg);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * Type support
 */

extern Tcl_Obj*
aktive_new_uint_obj (aktive_uint x) {
    Tcl_WideInt w = x;
    return Tcl_NewWideIntObj (w);
}

/*
 * - - -- --- ----- -------- -------------
 */

#include <sys/time.h>

extern aktive_uint
aktive_now(void)
{
    struct timeval tv;
    gettimeofday (&tv,NULL);
    return tv.tv_sec*1000000 + tv.tv_usec;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
