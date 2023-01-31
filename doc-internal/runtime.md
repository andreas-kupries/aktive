# Runtime

## Supporting - Kahan summation

Structure type and functions to perform Kahan type summation of doubles, for higher precision.

## Supporting - Geometry

  - `aktive_point` :: 2D location

## Image Generics

|Kind    |Name          |Description                                    |
|---     |---           |---                                            |
|opaque  |aktive_image  |Generic image                                  |
|opaque  |aktive_region |Generic image region, processing thread        |

The image holds information about the instance of the operator it was created for, i.e.:

  - Operator descriptor (shared among instances)
  - Vector of input images
  - Parameter descriptor
  - Geometry (width, height, bands, location in the plane)
  - User-specified meta data describing the image outside of processing

%% TODO %% The descriptor contains only a region fill hook so far.
%% TODO %% It needs hooks for region setup and release also for state outside of srcs
%% TODO %% NOTE HOWEVER - No operator with such state is known yet -> DEFER

%% TODO %% Descriptor has to provide hook to generate a geometry from parameter and inputs
%% TODO %% Ditto for meta data
%% TODO %% And a hook to create operator state, for the above hooks to share

The generic structures cannot be accessed directly, only through the API functions provided by the
runtime.

|Name                   |Purpose                                                        |
|---                    |---                                                            |
|aktive_image_new       |Generic constructor from specification, parameters, and inputs |
|aktive_image_unused    |Test reference count, true if <= 0 (<=> no users)              |
|aktive_image_unref     |Release a reference. May release the image                     |
|aktive_image_ref       |Aquire a reference.                                            |
|aktive_image_check     |Test for NULL, record error if so                              |
|aktive_image_from_obj  |Unbox image from Tcl_Obj*                                      |
|aktive_new_image_obj   |Box image into Tcl_Obj*                                        |
|                       |                                                               |
|aktive_image_destroy   |Internal: Release image and its resources                      |
|                       |                                                               |
|aktive_new_uint_obj    |Box aktive_uint                                                |
|aktive_new_point_obj   |Box aktive_point (2d location)                                 |


## Types relevant to the code generator

|Kind    |Name                          |Description                                    |
|---     |---                           |---                                            |
|struct  |aktive_type_spec              |(User) type descriptor                         |
|struct  |active_image_parameter        |Parameter descriptor                           |
|struct  |active_image_type             |Operator descriptor                            |
|        |                              |                                               |
|func*   |aktive_param_value            |Generic conversion of value to Tcl_Obj*        |
|func*   |aktive_image_param_init       |Variadic support, parameters, heapify          |
|func*   |aktive_image_param_finish     |Variadic support, parametres, release          |
|        |                              |                                               |
|fun type|aktive_image_region_fill      |Operation implementation, pixel calc           |
