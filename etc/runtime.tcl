# -*- mode: tcl ; fill-column: 90 -*-

## # # ## ### ##### ######## ############# #####################
## Types for parameters and results required by the runtime.
## Separately processed.

# __ id __________ critcl ___________    C type __ Conversion ______________________________
type point         aktive_point          -         {aktive_new_point_obj (value)}
type rect          aktive_rectangle      -         {aktive_new_rectangle_obj (value)}
type geometry      aktive_geometry       -         {aktive_new_geometry_obj (value)}
type image-type    aktive_image_type_ptr -         {Tcl_NewStringObj ((*value)->name, -1)}
type image         aktive_image          -         {aktive_new_image_obj (*value)}
type region        aktive_region         -         {0 /* INTERNAL -- No Tcl_Obj* equivalent */}
type uint          aktive_uint           -         {aktive_new_uint_obj (*value)}
type double        -                     -         {Tcl_NewDoubleObj (*value)}

vector region image point rect uint double

## # # ## ### ##### ######## ############# #####################
::return
