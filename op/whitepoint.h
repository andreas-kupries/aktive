/* -*- c -*-
 *
 * -- Various color white points / standard observers
 */
#ifndef AKTIVE_WHITEPOINT_H
#define AKTIVE_WHITEPOINT_H

/* - - -- --- ----- -------- -------------
 * Known white points.
 * General data found in VIPS
 */

#define AKTIVE_WP_A_X     (109.8503)
#define AKTIVE_WP_A_Y     (100.0)
#define AKTIVE_WP_A_Z     (35.5849)

#define AKTIVE_WP_B_X     (99.0720)
#define AKTIVE_WP_B_Y     (100.0)
#define AKTIVE_WP_B_Z     (85.2230)

#define AKTIVE_WP_C_X     (98.0700)
#define AKTIVE_WP_C_Y     (100.0)
#define AKTIVE_WP_C_Z     (118.2300)

#define AKTIVE_WP_D3250_X (105.6590)
#define AKTIVE_WP_D3250_Y (100.0)
#define AKTIVE_WP_D3250_Z (45.8501)

#define AKTIVE_WP_D50_X   (96.4250)
#define AKTIVE_WP_D50_Y   (100.0)
#define AKTIVE_WP_D50_Z   (82.4680)

#define AKTIVE_WP_D55_X   (95.6831)
#define AKTIVE_WP_D55_Y   (100.0)
#define AKTIVE_WP_D55_Z   (92.0871)

#define AKTIVE_WP_D65_X   (95.0470)
#define AKTIVE_WP_D65_Y   (100.0)
#define AKTIVE_WP_D65_Z   (108.8827)

#define AKTIVE_WP_D75_X   (94.9682)
#define AKTIVE_WP_D75_Y   (100.0)
#define AKTIVE_WP_D75_Z   (122.5710)

#define AKTIVE_WP_D93_X   (89.7400)
#define AKTIVE_WP_D93_Y   (100.0)
#define AKTIVE_WP_D93_Z   (130.7700)

#define AKTIVE_WP_E_X     (100.0)
#define AKTIVE_WP_E_Y     (100.0)
#define AKTIVE_WP_E_Z     (100.0)

/*
 * - - -- --- ----- -------- -------------
 * In memory data base of the above, for exposure to the Tcl level.
 */

typedef enum {
     aktive_wp_a = 0,
     aktive_wp_b,
     aktive_wp_c,
     aktive_wp_d3250,
     aktive_wp_d50,
     aktive_wp_d55,
     aktive_wp_d65,
     aktive_wp_d75,
     aktive_wp_d93,
     aktive_wp_e,
} aktive_whitepoint_id;

typedef struct {
    double x;
    double y;
    double z;
} aktive_whitepoint;

extern aktive_whitepoint* aktive_whitepoint_get (aktive_whitepoint_id w);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_WHITEPOINT_H */
