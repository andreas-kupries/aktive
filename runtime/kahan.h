#ifndef AKTIVE_INTERNAL_KAHAN_H
#define AKTIVE_INTERNAL_KAHAN_H

#ifndef KAHAN_TEST
#define KAHAN_TEST 0
#endif

/*
 * = = == === ===== ======== ============= =====================
 * Structures and methods to encapsulate Kahan (aka compensated) summation.
 *
 * Ref: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
 */

typedef struct kahan {
    double sum;
    double correction;
    /*
     * Testing: Uncorrected sum.
     */
#if KAHAN_TEST
    double ucsum;
#endif
} kahan;

extern void aktive_kahan_init (kahan* k);
extern void aktive_kahan_add  (kahan* k, double v);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_INTERNAL_KAHAN_H */
