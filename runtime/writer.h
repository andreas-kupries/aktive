/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Low-level API abstracting over write destinations.
 * -- Also basic write utility functions.
 */
#ifndef AKTIVE_WRITER_H
#define AKTIVE_WRITER_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 */

typedef aktive_uint (*aktive_quantizer) (double x);

extern aktive_uint aktive_quantize_uint8  (double x);
extern aktive_uint aktive_quantize_uint16 (double x);
extern aktive_uint aktive_quantize_uint32 (double x);

/*
 * - - -- --- ----- -------- -------------
 */

typedef void (*aktive_writer_write) (void* state, char* buf, Tcl_Size n, Tcl_WideInt pos);
// | pos | buf | n   | action                      | ref |
// |---  |---  |---  |---                          |---  |
// | >=0 | 0   | 0   | goto pos                    | @   |
// | >=0 | !0  | >0  | goto pos, and write buffer  | W   |
// | -1  | 0   | 0   | goto end                    | E   |
// | -1  | !0  | >0  | write buffer at current pos | C   |
// | -2  | 0   | 0   | done                        | D   |

typedef struct aktive_writer {
    void*               state;
    aktive_writer_write writer;
} aktive_writer;

extern void aktive_write_channel   (aktive_writer* writer, Tcl_Channel chan, int binary);
extern void aktive_write_bytearray (aktive_writer* writer, Tcl_Obj* ba);

extern void aktive_write_here /* (C)   */ (aktive_writer* writer, char* buf, Tcl_Size n);
extern void aktive_write_at   /* (W)   */ (aktive_writer* writer, char* buf, Tcl_Size n, Tcl_WideInt pos);
extern void aktive_write_goto /* (@,E) */ (aktive_writer* writer, Tcl_WideInt pos);
extern void aktive_write_done /* (D)   */ (aktive_writer* writer);

extern void aktive_write_here_uint8       (aktive_writer* writer, aktive_uint v);

extern void aktive_write_here_uint16be    (aktive_writer* writer, aktive_uint v);
extern void aktive_write_here_uint32be    (aktive_writer* writer, aktive_uint v);
extern void aktive_write_here_uint64be    (aktive_writer* writer, Tcl_WideInt v);

extern void aktive_write_here_uint16le    (aktive_writer* writer, aktive_uint v);
extern void aktive_write_here_uint32le    (aktive_writer* writer, aktive_uint v);
extern void aktive_write_here_uint64le    (aktive_writer* writer, Tcl_WideInt v);

extern int  aktive_write_here_uint_text   (aktive_writer* writer, aktive_uint v);

extern void aktive_write_here_int8       (aktive_writer* writer, int         v);

extern void aktive_write_here_int16be    (aktive_writer* writer, int         v);
extern void aktive_write_here_int32be    (aktive_writer* writer, int         v);
extern void aktive_write_here_int64be    (aktive_writer* writer, Tcl_WideInt v);

extern void aktive_write_here_int16le    (aktive_writer* writer, int         v);
extern void aktive_write_here_int32le    (aktive_writer* writer, int         v);
extern void aktive_write_here_int64le    (aktive_writer* writer, Tcl_WideInt v);

extern int  aktive_write_here_int_text   (aktive_writer* writer, int         v);

extern void aktive_write_here_float64be   (aktive_writer* writer, double v);

extern void aktive_write_here_float64le   (aktive_writer* writer, double v);

#define AKTIVE_WRITE_DONE ((Tcl_Size) -2)
#define AKTIVE_WRITE_END  ((Tcl_Size) -1)
#define AKTIVE_WRITE_HERE ((Tcl_Size) -1)

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_WRITER_H */
