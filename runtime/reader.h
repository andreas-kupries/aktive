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

extern void aktive_read_setup_binary (Tcl_Channel src);

extern int aktive_read_string      (Tcl_Channel src, char* buf, aktive_uint n);
extern int aktive_read_match       (Tcl_Channel src, char* buf, aktive_uint n);
extern int aktive_read_uint8       (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint16be    (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint32be    (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint64be    (Tcl_Channel src, Tcl_WideInt* v);
extern int aktive_read_float64be   (Tcl_Channel src, double*      v);
extern int aktive_read_uint_str    (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint_strcom (Tcl_Channel src, aktive_uint* v);

/*
 * - - -- --- ----- -------- -------------
 * Support for transfer and usage of file path information from images to
 * regions I.e. across thread boundaries when batch/sink are involved.
 *
 * `copy` creates a read-only char* copy of the path Tcl_Obj*. Use in image state setup.
 * `free` releases this information. Use in image state cleanup.
 * `open` creates channel for file, using RO access to the path. Use in region setup.
 *
 * We cannot use Tcl_Obj* as this structure is not thread-safe. Even a "RO"
 * copy in the image state can still change (shimmering of the int rep).
 */

typedef struct {
    int   length;
    char* string;
} aktive_path;

extern void        aktive_path_copy (aktive_path* dst, Tcl_Obj* src);
extern void        aktive_path_free (aktive_path* dst);
extern Tcl_Channel aktive_path_open (aktive_path* dst);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_READER_H */
