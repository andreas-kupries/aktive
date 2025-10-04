/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Swap utility functions.
 */
#ifndef AKTIVE_SWAP_H
#define AKTIVE_SWAP_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <sys/types.h>
#include <sys/param.h>
#include <byteswap.h>
#include <stdint.h>

/*
 * - - -- --- ----- -------- -------------
 */

#if BYTE_ORDER == LITTLE_ENDIAN
// little endian machine. swapping is required for big endian data

#  define SWAP16_BE(x) x = bswap_16 (x)
#  define SWAP32_BE(x) x = bswap_32 (x)
#  define SWAP64_BE(x) x = bswap_64 (x)

#  define SWAP16_LE(x)
#  define SWAP32_LE(x)
#  define SWAP64_LE(x)

#  define BE_SWAP
#  define ENDIAN "le"

#else
// big endian machine. swapping is required for little endian data

#  define SWAP16_BE(x)
#  define SWAP32_BE(x)
#  define SWAP64_BE(x)

#  define SWAP16_LE(x) x = bswap_16 (x)
#  define SWAP32_LE(x) x = bswap_32 (x)
#  define SWAP64_LE(x) x = bswap_64 (x)

#  define LE_SWAP
#  define ENDIAN "be"

#endif

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_SWAP_H */
