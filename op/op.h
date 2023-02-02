/* -*- c -*-
 */
#ifndef AKTIVE_OP_H
#define AKTIVE_OP_H

/* - - -- --- ----- -------- -------------
 * Helper functions for the individual operators
 * Shared code, and large blocks
 */

static Tcl_Obj* aktive_op_astcl    (Tcl_Interp* ip, aktive_image src);
static Tcl_Obj* aktive_op_params   (Tcl_Interp* ip, aktive_image src);
static Tcl_Obj* aktive_op_pixels   (Tcl_Interp* ip, aktive_image src);
static Tcl_Obj* aktive_op_location (Tcl_Interp* ip, aktive_image src);
static Tcl_Obj* aktive_op_geometry (Tcl_Interp* ip, aktive_image src);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_OP_H */
