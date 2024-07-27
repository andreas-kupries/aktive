## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Getters -- Retrieving image attributes

operator query::id {
    section accessor

    note Returns the input's implementation-specific image identity.

    # Example: makes no sense, would change with each run.
    #
    # This is special. It provides an identification of the image, i.e. a value unique to
    # it. This enables equality comparisons, and nothing else.
    #
    # BEWARE. This is the integerized memory address of the thing, with some whitening to
    # make it not as obvious.

    input

    return wide {
	Tcl_WideInt r = 0x25d94395245495a2 ^ (long int) src ;
	//                0123456789012345
	return r;
    }
}

operator query::type {
    section accessor

    example -text {aktive image zone width 32 height 32} {@1}
    example -text {aktive image gradient width 32 height 32 depth 1 first 0 last 1} {@1}

    note Returns the input's type.

    input
    return image-type {
	aktive_image_type* r = aktive_image_get_type (src);
	return r;
    }
}

operator query::location {
    section accessor geometry

    example -text {aktive image zone width 32 height 32} {@1}
    example -text {aktive image gradient width 32 height 32 depth 1 first 0 last 1} {@1}

    note Returns the input's location, a 2D point.

    input
    return point {
	aktive_point* r = aktive_image_get_location (src);
	return *r;
    }
}

operator query::domain {
    section accessor geometry

    example -text {aktive image zone width 32 height 32} {@1}
    example -text {aktive image gradient width 32 height 32 depth 1 first 0 last 1} {@1}

    note Returns the input's domain, a 2D rectangle. I.e. location, width, and height.

    input
    return rect {
	aktive_rectangle* r = aktive_image_get_domain (src);
	return *r;
    }
}

operator query::geometry {
    section accessor geometry

    example -text {aktive image zone width 32 height 32} {@1}
    example -text {aktive image gradient width 32 height 32 depth 1 first 0 last 1} {@1}

    note Returns the input's full geometry, i.e. domain and depth.

    input
    return geometry {
	aktive_geometry* r = aktive_image_get_geometry (src);
	return *r;
    }
}

operator description {
    query::x    x
    query::xmax {maximum x}
    query::y    y
    query::ymax {maximum y}
} {
    section accessor geometry
    op -> _ attribute

    example -text {aktive image zone width 32 height 32} {@1}
    example -text {aktive image gradient width 32 height 32 depth 1 first 0 last 1} {@1}

    note Returns the input's $description location.

    input

    return int {
	int r = aktive_image_get_@@attribute@@ (src);
	return r;
    }
}

operator description {
    query::width  width
    query::height height
    query::depth  depth
    query::pixels {number of pixels}
    query::pitch  {pitch, the number of values in a row, i.e. width times depth}
    query::size   {size, i.e. the number of pixels times depth}
} {
    section accessor geometry
    op -> _ attribute

    example -text {aktive image zone width 32 height 32} {@1}
    example -text {aktive image gradient width 32 height 32 depth 1 first 0 last 1} {@1}

    note Returns the input's ${description}.

    input

    return uint {
	aktive_uint r = aktive_image_get_@@attribute@@ (src);
	return r;
    }
}

operator query::inputs {
    section accessor

    # Example: makes no sense, changes with each run (it is raw stuff)
    # ... Maybe by transforming to type, or something else stable.

    note Returns a list of the input's inputs.

    note For an image without inputs the result is the empty list.

    input

    return object0 {
	aktive_uint c = aktive_image_get_nsrcs (src);
	Tcl_Obj**   v = NALLOC (Tcl_Obj*, c);

	for (aktive_uint i = 0; i < c; i++) {
	  v [i] = aktive_new_image_obj  (aktive_image_get_src (src, i));
	}
	Tcl_Obj* r = Tcl_NewListObj (c, v);
	ckfree ((char*) v);
	return r;
    }
}

operator query::params {
    section accessor

    example -text {aktive image zone width 32 height 32} {@1}
    example -text {aktive image gradient width 32 height 32 depth 1 first 0 last 1} {@1}

    note Returns a dictionary containing the input's parameters.

    note For an image without parameters the result is the empty dictionary.

    input

    return object0 {
	Tcl_Obj* r = aktive_op_params (ip, src);
	if (!r) { r = Tcl_NewDictObj (); }
	return r;
    }
}

operator query::setup {
    section accessor

    example -text {aktive image zone width 32 height 32} {@1}
    example -text {aktive image gradient width 32 height 32 depth 1 first 0 last 1} {@1}

    note Returns a dictionary containing the input's setup.

    note This includes type, geometry, and parameters, if any. The inputs however are excluded.

    input

    return object0 {
	Tcl_Obj* r = aktive_op_setup (ip, src);
	return r;
    }
}

operator query::meta {
    section accessor metadata

    example -text {aktive read from netpbm path tests/assets/sines.ppm} @1

    note Returns a dictionary containing the input's meta data.

    input

    return object0 {
	Tcl_Obj* r = aktive_image_meta_get (src);
	if (!r) { r = Tcl_NewDictObj (); }
	return r;
    }
}

operator query::values {
    section accessor values

    example -text {aktive image gradient width 2 height 2 depth 1 first 0 last 1} {@1}

    note Returns a list containing the input's pixel values.

    note The values are provided in row-major order.
    note The list has length \"<!xref: aktive query size> \\<src\\>\".

    input

    strict single \
	The image is materialized in memory.

    return object0 {
	Tcl_Obj* r = aktive_op_pixels (ip, src);
	if (r) { return r; }
	if (aktive_error_raised()) { return 0; }
	return Tcl_NewListObj (0, 0);
    }
}

operator query::value::at {
    section accessor values

    example -text {aktive image gradient width 2 height 2 depth 1 first 0 last 1} {@1 x 0 y 1}

    note Returns the input's pixel value(s) at the given 2D point.

    note The result is __not__ an image. It is a list of floating point numbers \
	for a multi-band input, and a single floating point number otherwise.

    note Beware that the coordinate domain is `0..width|height`, \
	regardless of image location.

    strict single \
	The requested pixel is materialized in memory.

    input
    int   x	Physical x-coordinate of the pixel to query
    int   y	Physical y-coordinate of the pixel to query

    body {
	set src [aktive op select y $src from $y to $y]
	set src [aktive op select x $src from $x to $x]
	aktive query values $src
    }
}

operator query::value::around {
    section accessor values

    note Returns the input's pixel values for the region around \
	the specified 2D point, within the manhattan `radius`.

    note The result is __not__ an image.

    note Beware that the coordinate domain is `0..width|height`, \
	regardless of image location.

    strict single \
	The requested pixel region is materialized in memory.

    input

    int     x		Physical x-coordinate of the pixel to query
    int     y		Physical y-coordinate of the pixel to query
    uint? 1 radius	Region radius, defaults to 1, i.e. a 3x3 region.

    body {
	lassign [aktive query domain $src] _ _ w h

	if {(($x - $radius) <   0) ||
	    (($x + $radius) >= $w) ||
	    (($y - $radius) <   0) ||
	    (($y + $radius) >= $h) } {
	    aktive error "Unable to query locations outside of the image domain" }

	set x0 [expr {$x - $radius}]
	set x1 [expr {$x + $radius}]
	set y0 [expr {$y - $radius}]
	set y1 [expr {$y + $radius}]

	set src [aktive op select y $src from $y0 to $y1]
	set src [aktive op select x $src from $x0 to $x1]

	aktive query values $src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
