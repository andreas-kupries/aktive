## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Mirror the image along one of the coordinate axes

operator {coordinate dimension} {
    op::flip::x  x width
    op::flip::y  y height
    op::flip::z  z depth
} {
    section transform structure

    if {$coordinate in {x y}} {
	example {
	    aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	    @1
	}
    }

    note Returns image which mirrors the input along the ${coordinate}-axis.

    input

    # flips are self-complementary
    simplify for   src/type @self   returns src/child

    blit flipper [dict get {
	y {
	    {DH {y 0 1 down} {y 0 1 up}}
	    {DW {x 0 1 up  } {x 0 1 up}}
	    {DD {z 0 1 up  } {z 0 1 up}}
	}
	x {
	    {DH {y 0 1 up  } {y 0 1 up}}
	    {DW {x 0 1 down} {x 0 1 up}}
	    {DD {z 0 1 up  } {z 0 1 up}}
	}
	z {
	    {DH {y 0 1 up  } {y 0 1 up}}
	    {DW {x 0 1 up  } {x 0 1 up}}
	    {DD {z 0 1 down} {z 0 1 up}}
	}
    } $coordinate] copy

    #            min                                                           v-max
    # domain:    |------------------------------.------------------------------|
    # request:                               |--.-----------------|        n-1^
    # rewritten:              |-----------------.--|              ^rmax .......|
    #
    #            min' = min + (max (domain) - max(request))
    #
    # max (domain)  = min  + n - 1
    # max (request) = rmin + rn -1
    #
    #                 = min + min + n - 1 - rmin -rn + 1
    #                 = 2min - rmin + n - rn
    #

    def flip-rewrite-core {
	// Flip the request before passing it on.
	int new = idomain->@@coordinate@@ + \
	    (aktive_rectangle_get_@@coordinate@@max (idomain) - \
	     aktive_rectangle_get_@@coordinate@@max (request));
	TRACE ("flip @@coordinate@@ %d --> %d = (%d+(%d-%d))",
	       request->@@coordinate@@, new,
	       idomain->@@coordinate@@,
	       aktive_rectangle_get_@@coordinate@@max (idomain),
	       aktive_rectangle_get_@@coordinate@@max (request));
	subrequest.@@coordinate@@ = new;
    }

    def rewrite [dict get {
	x { @@flip-rewrite-core@@ }
	y { @@flip-rewrite-core@@ }
	z { // Nothing to flip, depth requests are never partial }
    } $coordinate]

    state -setup {
	// The geometry and location are unchanged. Only the internal arrangement of the
	// pixels in memory changes.
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_rectangle_def_as (subrequest, request);
	@@rewrite@@
	TRACE_RECTANGLE_M("querych", &subrequest);
	aktive_block* src = aktive_region_fetch_area (0, &subrequest);

	// The @@coordinate@@ axis is scanned in reverse order.
	@@flipper@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
