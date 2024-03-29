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
#define SWAP16(x) bswap_16 (x)
#define SWAP32(x) bswap_32 (x)
#define SWAP64(x) bswap_64 (x)
#else
#define SWAP16(x)
#define SWAP32(x)
#define SWAP64(x)
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
