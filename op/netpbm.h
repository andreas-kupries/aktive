/* -*- c -*-
 *
 * -- Direct operator support - NETPBM support
 */
#ifndef AKTIVE_NETPBM_H
#define AKTIVE_NETPBM_H

#include <writer.h>
#include <sink.h>

/* - - -- --- ----- -------- -------------
 * Provision of a NETPBM sink
 *
 * Currently support PPM and PGM formats in text and binary sub types, and
 * byte/short scaling in each sub type, for a total of 8 related formats.
 *
 * | variant | maxval | format | coding | scaling |
 * |---      |---     |---     |---     |---      |
 * | 2       | <= 255 | PGM    | text   | byte    |
 * | 2       | > 255  | PGM    | text   | short   |
 * | 5       | <= 255 | PGM    | binary | byte    |
 * | 5       | > 255  | PGM    | binary | short   |
 * |---      |---     |---     |---     |---      |
 * | 3       | <= 255 | PPM    | text   | byte    |
 * | 3       | > 255  | PPM    | text   | short   |
 * | 6       | <= 255 | PPM    | binary | byte    |
 * | 6       | > 255  | PPM    | binary | short   |
 *
 * Note: maxval has to be less than 65536.
 */

extern aktive_sink*
aktive_netpbm_sink (aktive_writer* writer,
		    unsigned char  variant,
		    aktive_uint    maxvalue);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_NETPBM_H */
