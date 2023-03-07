/* -*- c -*-
 *
 * -- Color conversion support
 */
#ifndef AKTIVE_COLOR_H
#define AKTIVE_COLOR_H

#include <math.h>

/*
 * - - -- --- ----- -------- ------------ ----------------------
 * CIE Lab / CIE XYZ conversion constants.
 */

#define CIE_T  (0.00885645167903563081) /* = (6/29)^3 */
#define CIE_Ti (0.20689655172413793103) /* = (6/29) = sqrt (T) */
#define CIE_A  (7.78703703703703703702) /* = (1/3)(29/6)^2 */
#define CIE_B  (0.13793103448275862068) /* = 4/29 */

#define XYZ_TO_LAB(t) (((t) > CIE_T ) ? cbrt (t)      : (CIE_A * (t) + CIE_B))
#define LAB_TO_XYZ(t) (((t) > CIE_Ti) ? ((t)*(t)*(t)) : (((t) - CIE_B) / CIE_A));

/*
 * - - -- --- ----- -------- ------------ ----------------------
 * CIE Lab / CIE LCh
 * https://en.wikipedia.org/wiki/CIELAB_color_space#CIEHLC_cylindrical_model
 */

#define LAB_TO_LCH_H(L,a,b) atan2(b,a)
#define LAB_TO_LCH_C(L,a,b) hypot(b,a)

#define LCH_TO_LAB_A(L,c,h) ((c) * cos (h))
#define	LCH_TO_LAB_B(L,c,h) ((c) * sin (h))

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_COLOR_H */
