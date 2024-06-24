state -setup {
    aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
}

blit circle-sdf {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
} {point/2d {
    CIRCLE (x, y)
}}

pixels {
    double r  = param->radius;	// early cast to the type need during blit
    double cx = param->center.x;	// ditto
    double cy = param->center.y;	// ditto

    TRACE("center = @%d,%d", param->center.x, param->center.y);
    TRACE("radius = %d",     param->radius);

    #define CIRCLE(x,y) aktive_sdf_circle (aktive_sdf_translate (x, y, cx, cy), r)
    #define SD         (idomain->depth)
    #define SH         (idomain->height)
    #define SW         (idomain->width)
    #define SX         (request->x)
    #define SY         (request->y)

    @@circle-sdf@@

    #undef CIRCLE
}
