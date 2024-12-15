/* -*- c -*-
 *
 ** (c) 2024 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *
 * -- Signed distance functions
 */
#ifndef AKTIVE_SDF_H
#define AKTIVE_SDF_H

#include <math.h>
#include <rt.h>

/*
 * - - -- --- ----- -------- ------------ ----------------------
 * See
 *	https://iquilezles.org/articles/distfunctions2d
 *
 * and at shadertoys, youtube, ...
 *	https://www.youtube.com/@InigoQuilez
 *
 * If no position is specified the element is centered in the origin.
 *
 * For a different center      translate the P
 * For a different orientation rotate    the P
 * For a different size        scale     the P
 *
 * Notes:
 *  - in case of both, rotate first, then translate ?!
 *  - not all modifications make sense for all fields.
 *
 * Examples:
 *  - A circle is rotation invariant.             Rotation makes no sense.
 *  - A circle's size is specified by its radius. Scaling is not necessary.
 */

#define AP  aktive_point*
#define APD aktive_point_d*

typedef struct aktive_point_d {
    double x;
    double y;
} aktive_point_d;

typedef struct aktive_segment_spec {
    aktive_point_d from;
    aktive_point_d delta;
    double         ddot;
} aktive_segment_spec;

typedef struct aktive_triangle_spec {
    aktive_point_d a;
    aktive_point_d b;
    aktive_point_d c;
    aktive_point_d ba;
    aktive_point_d cb;
    aktive_point_d ac;
    double         badot;
    double         cbdot;
    double         acdot;
    double         bacsign;
} aktive_triangle_spec;

#define aktive_sdf_hard(f) (fabs(f) < 0.5)
#define aktive_sdf_soft(f) (1 - fmax (0, fmin (1, fabs (f))))
/* soft has inlined aktive_clamp */

#define aktive_sdf_translate(x,y,cx,cy) (x)-(cx), (y)-(cy)
#define aktive_sdf_rotate(x,y,c,s)      ((x)*(c)-(y)*(s)), ((x)*(s)+(y)*(c))

#define aktive_sdf_annular(th,f) (fabs (f) - (th))
#define aktive_sdf_widen(th,f)   (fmax (0, aktive_sdf_annular (th, f)))

// R = /c -s\  | /x'\ = /c -s\ * /x\  | x' =  x*c - y*s
//     \s  c/  | \y'/   \s  c/   \y/  | y' =  x*s + y*c

double aktive_sdf_box               (double x, double y, double w, double h);
double aktive_sdf_box_rounded       (double x, double y, double w, double h, double r[4]);
double aktive_sdf_circle            (double x, double y, double radius);
double aktive_sdf_parallelogram     (double x, double y, double w, double h, double skew);
double aktive_sdf_rhombus           (double x, double y, double w, double h);
double aktive_sdf_segment           (double x, double y, AP from, AP to);
double aktive_sdf_segment_precoded  (double x, double y, aktive_segment_spec* seg);
double aktive_sdf_triangle_precoded (double x, double y, aktive_triangle_spec* tri);

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#if 0
double aktive_sdf_arc            (double x, double y, AP sc, double ra, double rb );		// https://www.shadertoy.com/view/wl23RK
double aktive_sdf_bezier         (double x, double y, AP a, AP b, AP c);			// https://www.shadertoy.com/view/MlKcDD

double aktive_sdf_box_oriented   (double x, double y, AP from, AP to, double thickness);	// https://www.shadertoy.com/view/stcfzn
double aktive_sdf_box_rounded    (double x, double y, double w, double h, double r);		// https://www.shadertoy.com/view/4llXD7
double aktive_sdf_cross          (double x, double y, AP b, double r);				// https://www.shadertoy.com/view/XtGfzw
double aktive_sdf_cross_blobby   (double x, double y, double he);				// https://www.shadertoy.com/view/NssXWM
double aktive_sdf_cross_rounded  (double x, double y, double h);				// https://www.shadertoy.com/view/NslXDM
double aktive_sdf_cut_disk       (double x, double y, double r, double h	);		// https://www.shadertoy.com/view/ftVXRc
double aktive_sdf_ellipse        (double x, double y, AP ab);					// https://www.shadertoy.com/view/4sS3zz
double aktive_sdf_hexagon        (double x, double y, double r);       				//
double aktive_sdf_hexagram       (double x, double y, double r);				// https://www.shadertoy.com/view/tt23RR
double aktive_sdf_octogon        (double x, double y, double r);				// https://www.shadertoy.com/view/llGfDG

double aktive_sdf_pentagon       (double x, double y, double r);				// https://www.shadertoy.com/view/llVyWW
double aktive_sdf_pie            (double x, double y, AP c, double r);				// https://www.shadertoy.com/view/3l23RK
double aktive_sdf_polygon        (double x, double y, AP* v, int n);				// https://www.shadertoy.com/view/wdBXRW
double aktive_sdf_quad_circle    (double x, double y);						// https://www.shadertoy.com/view/Nd3cW8

double aktive_sdf_ring           (double x, double y, AP n, double r, double th);		// https://www.shadertoy.com/view/DsccDH
double aktive_sdf_star           (double x, double y, double r, double n, double m);		// https://www.shadertoy.com/view/3tSGDy
double aktive_sdf_star5          (double x, double y, double r, double rf);			// https://www.shadertoy.com/view/3tSGDy
double aktive_sdf_trapezoid      (double x, double y, double r1, double r2, double h);		// https://www.shadertoy.com/view/MlycD3
double aktive_sdf_vesica_oriented(double x, double y, AP a, AP b, double  w);			// https://www.shadertoy.com/view/cs2yzG
double aktive_sdf_xcross_rounded (double x, double y, double w, double  r);			// https://www.shadertoy.com/view/3dKSDc
#endif

#if 0
double aktive_sdf_circle_wave    (double x, double y, double tb, double ra);			// https://www.shadertoy.com/view/stGyzt
double aktive_sdf_cool_s         (double x, double y);						// https://www.shadertoy.com/view/clVXWc
double aktive_sdf_egg            (double x, double y, double ra, double  rb);			// https://www.shadertoy.com/view/Wdjfz3
double aktive_sdf_heart          (double x, double y);						// https://www.shadertoy.com/view/3tyBzV
double aktive_sdf_horseshoe      (double x, double y, AP c, double r, AP w);			// https://www.shadertoy.com/view/WlSGW1
double aktive_sdf_hyperbola      (double x, double y, double k, double  he );	// 0 <= k <= inf   https://www.shadertoy.com/view/DtjXDG
double aktive_sdf_moon           (double x, double y, double d, double ra, double  rb);		// https://www.shadertoy.com/view/WtdBRS
double aktive_sdf_parabola       (double x, double y, double k);				// https://www.shadertoy.com/view/ws3GD7
double aktive_sdf_parabola_seg   (double x, double y, double wi, double  he);			// https://www.shadertoy.com/view/3lSczz
double aktive_sdf_stairs         (double x, double y, double w, double  h, double  n);		// https://www.shadertoy.com/view/7tKSWt
double aktive_sdf_triangle_equi  (double x, double y, double r);				// https://www.shadertoy.com/view/Xl2yDW
double aktive_sdf_triangle_isosc (double x, double y, AP q);					// https://www.shadertoy.com/view/MldcD7
double aktive_sdf_tunnel         (double x, double y, double w, double h  );			// https://www.shadertoy.com/view/flSSDy
double aktive_sdf_uneven_capsule (double x, double y, double r1, double r2, double h);		// https://www.shadertoy.com/view/4lcBWn
double aktive_sdf_vesica         (double x, double y, double r, double  d);			// https://www.shadertoy.com/view/XtVfRW
#endif

//double aktive_sdf_ (double x, double y  );
//double aktive_sdf_ (double x, double y  );
//double aktive_sdf_ (double x, double y  );
//double aktive_sdf_ (double x, double y  );

// width/thickness - subtract value
//double aktive_sdf_ (double x, double y, );

// annular - abs(), then subtract
// smooth min - connection
// domain repeat
// range distort
// booleans

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_SDF_H */
