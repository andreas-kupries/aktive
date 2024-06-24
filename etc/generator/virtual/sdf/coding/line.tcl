state -fields {
    aktive_segment_spec spec;
} -setup {
    aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);

    // Precompute common values for the SDF calculation

    double dx   = param->to.x - param->from.x;
    double dy   = param->to.y - param->from.y;
    double ddot = dx*dx + dy*dy;

    state->spec.from.x  = (double) param->from.x;
    state->spec.from.y  = (double) param->from.y;
    state->spec.delta.x = dx;
    state->spec.delta.y = dy;
    state->spec.ddot    = ddot;
}

blit segment-sdf {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
} {point/2d {
    SEGMENT (x, y)
}}

pixels {
    TRACE("from      = @%d,%d", param->from.x, param->from.y);
    TRACE("to        = @%d,%d", param->to.x,   param->to.y);
    TRACE("delta     = %f, %f", istate->spec.delta.x, istate->spec.delta.y);
    TRACE("dot.delta = %f",     istate->spec.ddot);

    #define SEGMENT(x,y) aktive_sdf_segment_precoded (x, y, &istate->spec)
    #define SD         (idomain->depth)
    #define SH         (idomain->height)
    #define SW         (idomain->width)
    #define SX         (request->x)
    #define SY         (request->y)

    @@segment-sdf@@

    #undef SEGMENT
}
