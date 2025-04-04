
if 0 {
    # binary tree of line-segments. heavy overhead due to the number of operators in play.
    body {
	aktive op sdf or {*}[lmap a [lrange $points 0 end-1] b [lrange $points 1 end] {
	    aktive image sdf line x $x y $y width $width height $height \
		from $a to $b
	}]
    }
}

state -fields {
  aktive_segment_spec* spec; // pre-coded segment data
  aktive_uint          n;    // number of segments
} -cleanup {
  ckfree (state->spec);
} -setup {
      if (param->points.c < 2) aktive_fail ("not enough points, at least 2 are required");

      aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);

      // Precompute common values for the SDF calculation
      // Done for each line segment specified by the points

      state->n    = param->points.c - 1;
      state->spec = NALLOC (aktive_segment_spec, state->n);
      aktive_uint k;
      for (k=0; k < state->n; k++) {
	  double dx   = param->points.v[k+1].x - param->points.v[k].x;
	  double dy   = param->points.v[k+1].y - param->points.v[k].y;
	  double ddot = dx*dx + dy*dy;

	  state->spec[k].from.x  = param->points.v[k].x;
	  state->spec[k].from.y  = param->points.v[k].y;
	  state->spec[k].delta.x = dx;
	  state->spec[k].delta.y = dy;
	  state->spec[k].ddot    = ddot;
      }
}

blit segment-sdf {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
} {point/2d {
    SEGMENT (x, y)
}}

pixels {
    #define SEGMENT(x,y) aktive_sdf_polysegment_precoded (x, y, istate->n, istate->spec)
    #define SD         (idomain->depth)
    #define SH         (idomain->height)
    #define SW         (idomain->width)
    #define SX         (request->x)
    #define SY         (request->y)

    @@segment-sdf@@

    #undef SEGMENT
}
