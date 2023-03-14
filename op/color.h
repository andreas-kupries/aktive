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
 *
 * http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_Lab.html
 * http://www.brucelindbloom.com/index.html?Eqn_Lab_to_XYZ.html
 */

#define CIE_E  (216./24389.) // == CIE_Ei ** 3
#define CIE_Ei (6./29.)      // == cbrt (CIE_E))
#define CIE_K  (24389./27.)

#define XYZ_TO_LAB(t) (((t) > CIE_E ) ? cbrt (t)      : ((CIE_K * (t) + 16.)/116.))
#define LAB_TO_XYZ(t) (((t) > CIE_Ei) ? ((t)*(t)*(t)) : ((116.*(t) - 16.)/CIE_K))

/*
 * - - -- --- ----- -------- ------------ ----------------------
 * CIE Lab / CIE LCh
 * https://en.wikipedia.org/wiki/CIELAB_color_space#CIEHLC_cylindrical_model
 */

#define LAB_TO_LCH_C(L,a,b) hypot (b,a)
#define LAB_TO_LCH_H(L,a,b) atan2 (b,a)

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
