/* -*- c -*-
 *
 * -- Direct operator support - formatting image as Tcl structure
 */
#ifndef AKTIVE_ASTCL_H
#define AKTIVE_ASTCL_H

#include <rt.h>

/* - - -- --- ----- -------- -------------
 * Helper functions for the individual operators
 * Shared code, and large blocks
 */

extern Tcl_Obj* aktive_op_astcl    (Tcl_Interp* ip, aktive_image src);
extern Tcl_Obj* aktive_op_params   (Tcl_Interp* ip, aktive_image src);
extern Tcl_Obj* aktive_op_pixels   (Tcl_Interp* ip, aktive_image src);
extern Tcl_Obj* aktive_op_geometry (Tcl_Interp* ip, aktive_image src);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_ASTCL_H */
