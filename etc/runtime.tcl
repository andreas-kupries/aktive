# -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Core runtime definitions
## Separately processed.

# # ## ### ##### ######## ############# #####################
## Types for parameters and results

# __ id __________ critcl ___________    C type _______ Conversion ______________________________
type point         aktive_point          -              {aktive_new_point_obj (value)}
type range         aktive_range          -              {aktive_new_range_obj (value)}
type rect          aktive_rectangle      -              {aktive_new_rectangle_obj (value)}
type geometry      aktive_geometry       -              {aktive_new_geometry_obj (value)}
type image-type    aktive_image_type_ptr -              {Tcl_NewStringObj ((*value)->name, -1)}
type image         aktive_image          -              {aktive_new_image_obj (*value)}
type region        aktive_region         -              {0 /* INTERNAL -- No Tcl_Obj* equivalent */}
type uint          aktive_uint           -              {aktive_new_uint_obj (*value)}
type double        -                     -              {Tcl_NewDoubleObj (*value)}
type str           aktive_string         aktive_string  {Tcl_NewStringObj (*value, -1)}

vector region image point range rect uint double str

# # ## ### ##### ######## ############# #####################
## Generally useful blocks of code

##
# # ## ### ##### ######## ############# #####################
::return
