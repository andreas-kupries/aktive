/* -*- c -*-
 *
 * -- Direct operator support - Netpbm support
 */
#ifndef AKTIVE_NETPBM_H
#define AKTIVE_NETPBM_H

#include <writer.h>
#include <sink.h>

/* - - -- --- ----- -------- -------------
 * Provision of a netpbm sink
 *
 * (Ad *) The `variant` information encodes primary and secondary format information,
 *        i.e. PPM vs PGM, and text vs binary encoding. The `maxvalue` then further
 *        differentiates by providing scaling/size information.
 */

static aktive_sink*
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
