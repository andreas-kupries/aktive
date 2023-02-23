/* -*- c -*-
 */

#include <math.h>
#include <string.h>
#include <writer.h>
#include <critcl_assert.h>

// replicated from op.h -- move to runtime
static double aktive_clamp (double x) { return (x < 0) ? 0 : (x > 1) ? 1 : x; }

/*
 * - - -- --- ----- -------- -------------
 */

#define Q(scale) return (aktive_uint) round (aktive_clamp (x) * scale)

extern aktive_uint aktive_quantize_uint8  (double x) { Q (255); }
extern aktive_uint aktive_quantize_uint16 (double x) { Q (65535); }
extern aktive_uint aktive_quantize_uint32 (double x) { Q (4294967295); }

/*
 * - - -- --- ----- -------- -------------
 */

static void aktive_writer_to_channel   (Tcl_Channel chan, char* buf, int n);
static void aktive_writer_to_bytearray (Tcl_Obj*    ba,   char* buf, int n);

extern void
aktive_write_channel (aktive_writer* writer, Tcl_Channel chan, int binary)
{
    writer->state  = chan;
    writer->writer = (aktive_writer_write) aktive_writer_to_channel;

    if (!binary) return;
    
    Tcl_SetChannelOption (NULL, chan, "-encoding",    "binary");
    Tcl_SetChannelOption (NULL, chan, "-translation", "binary");
}

extern void
aktive_write_bytearray (aktive_writer* writer, Tcl_Obj* ba)
{
    writer->state  = ba;
    writer->writer = (aktive_writer_write) aktive_writer_to_bytearray;
}

extern void
aktive_write_to (aktive_writer* writer, char* buf, int n)
{
    ASSERT (buf,   "buffer missing");
    ASSERT (n > 0, "empty buffer");
    writer->writer (writer->state, buf, n);
}

extern void
aktive_write_done (aktive_writer* writer)
{
    writer->writer (writer->state, 0, 0);
}

extern void
aktive_write_uint8 (aktive_writer* writer, int v)
{
    char buf [1];
    buf [0] = v & 0xFF;
    aktive_write_to (writer, buf, 1);
}

extern void
aktive_write_uint16be (aktive_writer* writer, int v)
{
    char buf [2];
    buf [0] = MSB (v);
    buf [1] = LSB (v);
    aktive_write_to (writer, buf, 2);
}

extern int
aktive_write_uint_text (aktive_writer* writer, int v)
{
    char buf [20];
    aktive_uint n = sprintf (buf, "%d", v);

    ASSERT (n < 20, "value overflowed internal string buffer");
    aktive_write_to (writer, buf, n);
    return n;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
aktive_writer_to_channel (Tcl_Channel chan, char* buf, int n)
{
    if (!buf || !n) { Tcl_Flush (chan); return; }
    Tcl_Write (chan, buf, n);
}

static void
aktive_writer_to_bytearray (Tcl_Obj* ba, char* buf, int n)
{
    if (!buf || !n) return;
    
    int            length;
    unsigned char* bytes;

    (void)  Tcl_GetByteArrayFromObj (ba, &length);
    bytes = Tcl_SetByteArrayLength  (ba, length + n);
    memcpy (bytes + length, buf, n);    
}

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
