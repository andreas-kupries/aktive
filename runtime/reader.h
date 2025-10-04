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

#include <tclpre9compat.h>
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

extern int aktive_read_uint8         (Tcl_Channel src, aktive_uint* v);

extern int aktive_read_uint16le      (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint32le      (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint64le      (Tcl_Channel src, Tcl_WideInt* v);

extern int aktive_read_uint16be      (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint32be      (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint64be      (Tcl_Channel src, Tcl_WideInt* v);

extern int aktive_read_uint_str      (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint_strsharp (Tcl_Channel src, aktive_uint* v);
extern int aktive_read_uint_strcom   (Tcl_Channel src, aktive_uint* v);

extern int aktive_read_int8        (Tcl_Channel src, int*         v);

extern int aktive_read_int16le     (Tcl_Channel src, int*         v);
extern int aktive_read_int32le     (Tcl_Channel src, int*         v);
extern int aktive_read_int64le     (Tcl_Channel src, Tcl_WideInt* v);

extern int aktive_read_int16be     (Tcl_Channel src, int*         v);
extern int aktive_read_int32be     (Tcl_Channel src, int*         v);
extern int aktive_read_int64be     (Tcl_Channel src, Tcl_WideInt* v);

extern int aktive_read_int_str     (Tcl_Channel src, int*         v);
extern int aktive_read_int_strcom  (Tcl_Channel src, int*         v);

extern int aktive_read_float64be   (Tcl_Channel src, double*      v);
extern int aktive_read_float64be_n (Tcl_Channel src, aktive_uint n, double* v);

extern int aktive_read_float64le   (Tcl_Channel src, double*      v);
extern int aktive_read_float64le_n (Tcl_Channel src, aktive_uint n, double* v);

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
    Tcl_Size length;
    char*    string;
} aktive_path;

extern void        aktive_path_copy (aktive_path* dst, Tcl_Obj* src);
extern void        aktive_path_free (aktive_path* dst);
extern Tcl_Channel aktive_path_open (aktive_path* dst);

/*
 * - - -- --- ----- -------- -------------
 *
 * All get functions (*) stay at the current location should they fail to read
 * enough bytes for their expected result.
 *
 * (*) The getters are `read from byte array`, i.e. in memory.
 *     Position information is tracked outside.
 */

extern int aktive_get_string        (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, char* buf, aktive_uint n);
extern int aktive_get_match         (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, char* buf, aktive_uint n);

extern int aktive_get_uint8         (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v);

extern int aktive_get_uint16le      (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v);
extern int aktive_get_uint32le      (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v);
extern int aktive_get_uint64le      (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, Tcl_WideInt* v);

extern int aktive_get_uint16be      (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v);
extern int aktive_get_uint32be      (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v);
extern int aktive_get_uint64be      (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, Tcl_WideInt* v);

extern int aktive_get_uint_str      (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v);
extern int aktive_get_uint_strsharp (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v);
extern int aktive_get_uint_strcom   (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v);

extern int aktive_get_int8          (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int*         v);

extern int aktive_get_int16be       (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int*         v);
extern int aktive_get_int32be       (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int*         v);
extern int aktive_get_int64be       (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, Tcl_WideInt* v);

extern int aktive_get_int16le       (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int*         v);
extern int aktive_get_int32le       (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int*         v);
extern int aktive_get_int64le       (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, Tcl_WideInt* v);

extern int aktive_get_int_str       (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int*         v);
extern int aktive_get_int_strcom    (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int*         v);

extern int aktive_get_float64be     (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, double*      v);
extern int aktive_get_float64be_n   (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint n, double* v);

extern int aktive_get_float64le     (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, double*      v);
extern int aktive_get_float64le_n   (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint n, double* v);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_READER_H */
