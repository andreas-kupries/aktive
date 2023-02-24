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

#include <tcl.h>
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

#define MSB(x) (((x) >> 8) & 0xFF)
#define LSB(x) (( x      ) & 0xFF)

/*
 * - - -- --- ----- -------- -------------
 */

typedef void (*aktive_writer_write) (void* state, char* buf, int n);

typedef struct aktive_writer {
    void*               state;
    aktive_writer_write writer;
} aktive_writer;

extern void aktive_write_channel   (aktive_writer* writer, Tcl_Channel chan, int binary);
extern void aktive_write_bytearray (aktive_writer* writer, Tcl_Obj* ba);

extern void aktive_write_append      (aktive_writer* writer, char* buf, int n);
extern void aktive_write_done        (aktive_writer* writer);

extern void aktive_write_append_uint8       (aktive_writer* writer, aktive_uint   v);
extern void aktive_write_append_uint16be    (aktive_writer* writer, aktive_uint   v);
extern void aktive_write_append_uint32be    (aktive_writer* writer, aktive_uint   v);
extern void aktive_write_append_uint64be    (aktive_writer* writer, unsigned long v);
extern int  aktive_write_append_uint_text   (aktive_writer* writer, int v);

extern void aktive_write_append_float64be   (aktive_writer* writer, double v);

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
