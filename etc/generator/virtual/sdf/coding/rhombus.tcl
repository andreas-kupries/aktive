state -setup {
    if (param->ewidth  <= 0) aktive_fail("expected element width > 0");
    if (param->eheight <= 0) aktive_fail("expected element height > 0");
    aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
}

blit rhombus-sdf {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
} {point/2d {
    RHOMBUS (x, y)
}}

pixels {
    double w  = param->ewidth;
    double h  = param->eheight;
    double cx = param->center.x;
    double cy = param->center.y;

    TRACE("center         = @%f,%f", param->center.x, param->center.y);
    TRACE("rhombus width  =  %f", param->ewidth);
    TRACE("rhombus height =  %f", param->eheight);

    #define RHOMBUS(x,y) aktive_sdf_rhombus (aktive_sdf_translate (x, y, cx, cy), w, h)
    #define SD         (idomain->depth)
    #define SH         (idomain->height)
    #define SW         (idomain->width)
    #define SX         (request->x)
    #define SY         (request->y)

    @@rhombus-sdf@@

    #undef RHOMBUS
}
