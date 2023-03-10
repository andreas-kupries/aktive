#ifndef AKTIVE_KAHAN_H
#define AKTIVE_KAHAN_H

#ifndef KAHAN_TEST
#define KAHAN_TEST 0
#endif

/*
 * = = == === ===== ======== ============= =====================
 * Structures and methods to encapsulate Kahan (aka compensated) summation.
 * The implemented algorithm uses the Neumaier enhancement.
 *
 * Ref:
 *  - https://en.wikipedia.org/wiki/Kahan_summation_algorithm#Further_enhancements
 *  - https://www.mat.univie.ac.at/~neum/scan/01.pdf
 *    (local copy: doc-internal/references/neumaier.pdf)
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

extern void aktive_kahan_init      (kahan* k);
extern void aktive_kahan_add       (kahan* k, double v);
extern void aktive_kahan_add_kahan (kahan* k, kahan* v);

#define aktive_kahan_final(k) ((k)->sum + (k)->correction)

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_KAHAN_H */
