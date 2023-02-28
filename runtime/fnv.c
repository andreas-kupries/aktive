/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API
 * -- Fowler, Noll and Vo - FNV - Hashing
 *
 * References:
 *
 *  - http://isthe.com/chongo/tech/comp/fnv/
 *  - https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
 *
 * This code implements the FNV 1a variant
 */

#include <fnv.h>
#include <stdlib.h>
#include <math.h>

/*
 * - - -- --- ----- -------- -------------
 */

#define PRIME  0x01000193 /* 16777619 */

#define ROUND(hash,byte) (((hash) ^ (byte)) * PRIME)

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_uint
aktive_fnv_step (aktive_uint hash)
{
    return aktive_fnv_merge_uint32 (aktive_fnv_base, hash);
}
    
extern aktive_uint
aktive_fnv_merge_bytes (aktive_uint hash, aktive_uint c, unsigned char* v)
{
    while (c--) hash = ROUND (hash, *v++);
    return hash;
}

extern aktive_uint
aktive_fnv_merge_uint8  (aktive_uint hash, unsigned char x)
{
    hash = ROUND (hash, x);
    return hash;
}

extern aktive_uint
aktive_fnv_merge_uint32 (aktive_uint hash, aktive_uint x)
{
    unsigned char* v = (unsigned char*) &x;
    hash = ROUND (hash, v[0]);
    hash = ROUND (hash, v[1]);
    hash = ROUND (hash, v[2]);
    hash = ROUND (hash, v[3]);
    return hash;
}

extern aktive_uint
aktive_fnv_merge_uint64 (aktive_uint hash, Tcl_WideInt x)
{
    unsigned char* v = (unsigned char*) &x;
    hash = ROUND (hash, v[0]);
    hash = ROUND (hash, v[1]);
    hash = ROUND (hash, v[2]);
    hash = ROUND (hash, v[3]);
    hash = ROUND (hash, v[4]);
    hash = ROUND (hash, v[5]);
    hash = ROUND (hash, v[6]);
    hash = ROUND (hash, v[7]);
    return hash;
}

extern aktive_uint
aktive_fnv_merge_float64 (aktive_uint hash, double x) {
    unsigned char* v = (unsigned char*) &x;
    hash = ROUND (hash, v[0]);
    hash = ROUND (hash, v[1]);
    hash = ROUND (hash, v[2]);
    hash = ROUND (hash, v[3]);
    hash = ROUND (hash, v[4]);
    hash = ROUND (hash, v[5]);
    hash = ROUND (hash, v[6]);
    hash = ROUND (hash, v[7]);
    return hash;
}

extern double
aktive_fnv_gauss (aktive_uint hash)
{
    /*
     * Uses `aktive_fnv_step` as a source of uniformly distributed random
     * values and generates a gaussian in the range [-1,1] from pairs via
     * Marsaglia's Polar Method. The gaussian has mean 0 and sigma 1.
     *
     * Transforms
     * - https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
     * - https://en.wikipedia.org/wiki/Marsaglia_polar_method
     *
     * Future: See how complex the implementation is.
     * - https://en.wikipedia.org/wiki/Ziggurat_algorithm
     */

#define REJECT ((s == 0) || (s >= 1))

    double s, u, v;
    do {
	hash = aktive_fnv_step (hash); u = 2.0*hash/RAND_MAX - 1; /* (**) */
	hash = aktive_fnv_step (hash); v = 2.0*hash/RAND_MAX - 1; /* (**) */
	s = u*u+v*v;
	// TRACE (" (%f, %f) --> %f %s", u, v, s, (REJECT ? "R" : "+"));
    } while (REJECT);

    double gain = sqrt (-2*log(s)/s);
    double z0 = u * gain;
    // Note, we can compute a second gaussian here, derived from v.
    
    /* (**) hash                in [0,RAND_MAX]
     *      hash/RAND_MAX       in [0,1]
     *      2*hash/RAND_MAX     in [0,2]
     *      2*hash/RAND_MAX - 1 in [-1,+1]
     *
     * ATTENTION: Using `2.0` in the code above. This forces the evaluation of
     *            the expression as type `double`.  hash and RAND_MAX are of
     *            type `int`. Using `2` would keep the type as `int`,
     *            resulting in `hash/RAND_MAX == 0`, always.
     */
    return z0;

#undef REJECT
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
