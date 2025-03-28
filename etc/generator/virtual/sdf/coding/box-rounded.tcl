
state -setup {
    if (param->ewidth          <= 0) aktive_fail("expected element width > 0");
    if (param->eheight         <= 0) aktive_fail("expected element height > 0");
    if (param->downrightradius  < 0) aktive_fail("expected down right radius >= 0");
    if (param->uprightradius    < 0) aktive_fail("expected up right radius >= 0");
    if (param->downleftradius   < 0) aktive_fail("expected down left radius >= 0");
    if (param->upleftradius     < 0) aktive_fail("expected up left radius >= 0");

    aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
}

blit box-rounded-sdf {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
} {point/2d {
    BOX (x, y)
}}

pixels {
    double w  = param->ewidth;	//    [3]...[1] - r: corner radii mapping
    double h  = param->eheight;	//     .     .
    double cx = param->center.x;	//     .     .
    double cy = param->center.y;	//    [2]...[0]
    double r[4];                    // <-/

    r[0] = param->downrightradius;
    r[1] = param->uprightradius;
    r[2] = param->downleftradius;
    r[3] = param->upleftradius;

    TRACE("center            = @%f,%f", param->center.x, param->center.y);
    TRACE("box width         =  %f", param->ewidth);
    TRACE("box height        =  %f", param->eheight);
    TRACE("up   left  radius =  %f", param->upleftradius);
    TRACE("up   right radius =  %f", param->uprightradius);
    TRACE("down left  radius =  %f", param->downleftradius);
    TRACE("down right radius =  %f", param->downrightradius);

    #define BOX(x,y) aktive_sdf_box_rounded (aktive_sdf_translate (x, y, cx, cy), w, h, r)
    #define SD         (idomain->depth)
    #define SH         (idomain->height)
    #define SW         (idomain->width)
    #define SX         (request->x)
    #define SY         (request->y)

    @@box-rounded-sdf@@

    #undef BOX
}
