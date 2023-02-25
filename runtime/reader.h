/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Reader utility functions.
 */
#ifndef AKTIVE_READER_H
#define AKTIVE_READER_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tcl.h>
#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 *
 * All read functions stay at the current location should they fail to read
 * enough bytes for their expected result. This will work only for channels
 * which are seekable. Unseekable channels will be stuck at EOF.
 */

extern int aktive_read_setup_binary (Tcl_Channel src);

extern int aktive_read_string    (Tcl_Channel src, char* buf, aktive_uint n);
extern int aktive_read_match     (Tcl_Channel src, char* buf, aktive_uint n);
extern int aktive_read_uint8     (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint16be  (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint32be  (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint64be  (Tcl_Channel src, Tcl_WideInt* v);
extern int aktive_read_float64be (Tcl_Channel src, double*      v);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_READER_H */
