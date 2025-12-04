#ifndef AKTIVE_KAHAN_H
#define AKTIVE_KAHAN_H

#include <math.h>

#ifndef KAHAN_TEST
#define KAHAN_TEST 0
#endif

/*
 * = = == === ===== ======== ============= =====================
 * Structures and methods to encapsulate Kahan's compensated summation.
 * The implemented algorithm uses Neumaier's enhancement.
 *
 * Ref:
 *  - https://en.wikipedia.org/wiki/Kahan_summation_algorithm#Further_enhancements
 *  - https://www.mat.univie.ac.at/~neum/scan/01.pdf
 *    (local copy: doc-internal/references/neumaier.pdf)
 */

typedef struct kahan {
    double sum;
    double correction;
#if KAHAN_TEST
    /*
     * Testing: Uncorrected sum.
     */
    double ucsum;
#endif
} kahan;

#ifdef KAHAN_FUNC

#define aktive_kahan_init(k)        aktive_kahan_init_c     (&(k))
#define aktive_kahan_add(k,v)       aktive_kahan_add_c      (&(k))
#define aktive_kahan_add_kahan(k,v) aktive_kahan_add_kahan_c(&(k), &(v))
#define aktive_kahan_final(k)       ((k).sum + (k).correction)

extern void aktive_kahan_init_c      (kahan* k);
extern void aktive_kahan_add_c       (kahan* k, double v);
extern void aktive_kahan_add_kahan_c (kahan* k, kahan* v);
#define     aktive_kahan_final_c(k)  ((k)->sum + (k)->correction)

#else // !KAHAN_FUNC - inlined kahan functionality

#define aktive_kahan_init(k)        { (k).sum = (k).correction = 0; }
#define aktive_kahan_add_kahan(k,v) { aktive_kahan_add (k, (v).correction); aktive_kahan_add (k, (v).sum); }
#define aktive_kahan_final(k)       ((k).sum + (k).correction)
#define aktive_kahan_add(k,v)       {		\
	double t = (k).sum + (v);		\
	int vlost = fabs ((k).sum) > fabs (v);	\
	(k).correction += vlost			\
	    ? (((k).sum - t) + (v))		\
	    : (((v) - t) + (k).sum);		\
	(k).sum = t;				\
    }


// k is a kahan*
#define aktive_kahan_init_c(k)        { (k)->sum = (k)->correction = 0; }
#define aktive_kahan_add_kahan_c(k,v) { aktive_kahan_add (k, (v)->correction); aktive_kahan_add (k, (v)->sum); }
#define aktive_kahan_final_c(k)       ((k)->sum + (k)->correction)
#define aktive_kahan_add_c(k,v)       {		\
	double t = (k)->sum + (v);		\
	int vlost = fabs ((k)->sum) > fabs (v);	\
	(k)->correction += vlost		\
	    ? (((k)->sum - t) + (v))		\
	    : (((v) - t) + (k)->sum);		\
	(k)->sum = t;				\
    }

#endif // KAHAN_FUNC

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_KAHAN_H */
