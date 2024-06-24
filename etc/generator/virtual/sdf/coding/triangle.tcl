state -fields {
    aktive_triangle_spec spec;
} -setup {
    aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);

    #define DOTSELF(x,y) ((x)*(x) + (y)*(y))

    // Precompute common values for the SDF calculation
    state->spec.a.x     = param->a.x;
    state->spec.a.y     = param->a.y;
    state->spec.b.x     = param->b.x;
    state->spec.b.y     = param->b.y;
    state->spec.c.x     = param->c.x;
    state->spec.c.y     = param->c.y;
    state->spec.ba.x    = param->b.x - param->a.x;
    state->spec.ba.y    = param->b.y - param->a.y;
    state->spec.cb.x    = param->c.x - param->b.x;
    state->spec.cb.y    = param->c.y - param->b.y;
    state->spec.ac.x    = param->a.x - param->c.x;
    state->spec.ac.y    = param->a.y - param->c.y;
    state->spec.badot   = DOTSELF (state->spec.ba.x, state->spec.ba.y);
    state->spec.cbdot   = DOTSELF (state->spec.cb.x, state->spec.cb.y);
    state->spec.acdot   = DOTSELF (state->spec.ac.x, state->spec.ac.y);
    state->spec.bacsign = aktive_sign (  state->spec.ba.x * state->spec.ac.y
				       - state->spec.ba.y * state->spec.ac.x);
    #undef DOTSELF
}

blit triangle-sdf {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
} {point/2d {
    TRIANGLE (x, y)
}}

pixels {
    TRACE("point A = @%d,%d", param->a.x, param->a.y);
    TRACE("point B = @%d,%d", param->b.x, param->b.y);
    TRACE("point C = @%d,%d", param->c.x, param->c.y);

    #define TRIANGLE(x,y) aktive_sdf_triangle_precoded (x, y, &istate->spec)
    #define SD         (idomain->depth)
    #define SH         (idomain->height)
    #define SW         (idomain->width)
    #define SX         (request->x)
    #define SY         (request->y)

    @@triangle-sdf@@

    #undef TRIANGLE
}
