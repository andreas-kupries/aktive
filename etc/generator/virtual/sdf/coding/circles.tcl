
if 0 {
    # binary tree of circles. heavy overhead due to the number of operators in play.
    body {
        aktive op sdf or {*}[lmap c $centers {
	    aktive image sdf circle x $x y $y width $width height $height \
	        radius $radius center $c
	}]
    }
}

state -setup {
    if (param->radius <= 0) aktive_fail("expected radius > 0");
    aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
}

blit circle-sdf {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
} {point/2d {
    CIRCLE (x, y)
}}

pixels {
    #define CIRCLE(x,y) aktive_sdf_polycircle (x, y, param->radius, &param->centers)
    #define SD         (idomain->depth)
    #define SH         (idomain->height)
    #define SW         (idomain->width)
    #define SX         (request->x)
    #define SY         (request->y)

    @@circle-sdf@@

    #undef CIRCLE
}
