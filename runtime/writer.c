/* -*- c -*-
 */

#include <math.h>
#include <string.h>
#include <writer.h>
#include <swap.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

#define MSB(x) (((x) >> 8) & 0xFF)
#define LSB(x) (( x      ) & 0xFF)

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct __ba_writer {
    Tcl_Obj* ba;
    int      pos;
} __ba_writer;

// replicated from op.h -- move to runtime
static double aktive_clamp (double x) { return (x < 0) ? 0 : (x > 1) ? 1 : x; }

static void aktive_writer_to_channel   (Tcl_Channel  chan, char* buf, int n, int pos);
static void aktive_writer_to_bytearray (__ba_writer* ba,   char* buf, int n, int pos);

/*
 * - - -- --- ----- -------- -------------
 */

#define Q(scale) return (aktive_uint) floor (aktive_clamp (x) * scale)

extern aktive_uint aktive_quantize_uint8  (double x) { Q (255); }
extern aktive_uint aktive_quantize_uint16 (double x) { Q (65535); }
extern aktive_uint aktive_quantize_uint32 (double x) { Q (4294967295); }

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_write_channel (aktive_writer* writer, Tcl_Channel chan, int binary)
{
    TRACE_FUNC ("((writer*) %p, (Tcl_Channel) %p, (binary) %d)", writer, chan, binary);

    writer->state  = chan;
    writer->writer = (aktive_writer_write) aktive_writer_to_channel;

    if (!binary) return;

    Tcl_SetChannelOption (NULL, chan, "-encoding",    "binary");
    Tcl_SetChannelOption (NULL, chan, "-translation", "binary");

    TRACE_RETURN_VOID;
}

extern void
aktive_write_bytearray (aktive_writer* writer, Tcl_Obj* ba)
{
    TRACE_FUNC ("(writer*) %p, (Tcl_Obj*) %p)", writer, ba);

    __ba_writer* baw = ALLOC (__ba_writer);
    baw->ba  = ba;
    baw->pos = 0;

    writer->state  = baw;
    writer->writer = (aktive_writer_write) aktive_writer_to_bytearray;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_write_here (aktive_writer* writer, char* buf, int n)
{
    TRACE_FUNC ("((writer*) %p, write %d at end)", writer, n);

    ASSERT (buf,   "buffer missing");
    ASSERT (n > 0, "empty buffer");

    writer->writer (writer->state, buf, n, -1); // (C) write at current location

    TRACE_RETURN_VOID;
}

extern void
aktive_write_at (aktive_writer* writer, char* buf, int n, int pos)
{
    TRACE_FUNC ("((writer*) %p, write %d at %d)", writer, n, pos);

    ASSERT (buf,      "buffer missing");
    ASSERT (n > 0,    "empty buffer");
    ASSERT (pos >= 0, "bad location");

    writer->writer (writer->state, buf, n, pos); // (W) goto pos, then write

    TRACE_RETURN_VOID;
}

extern void
aktive_write_goto (aktive_writer* writer, int pos)
{
    TRACE_FUNC ("((writer*) %p, goto %d)", writer, pos);

    ASSERT (pos >= -1, "bad location");

    writer->writer (writer->state, 0, 0, pos); // (@, E) goto pos, maybe end

    TRACE_RETURN_VOID;
}

extern void
aktive_write_done (aktive_writer* writer)
{
    TRACE_FUNC ("((writer*) %p)", writer);

    writer->writer (writer->state, 0, 0, -2); // (D) finalize

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_write_here_uint8 (aktive_writer* writer, aktive_uint v)
{
    TRACE_FUNC ("((writer*) %p, value %d)", writer, v);

    char buf [1];
    buf [0] = v & 0xFF;
    aktive_write_here (writer, buf, 1);

    TRACE_RETURN_VOID;
}

extern void
aktive_write_here_uint16be (aktive_writer* writer, aktive_uint v)
{
    TRACE_FUNC ("((writer*) %p, value %d)", writer, v);

    char buf [2];
    buf [0] = MSB (v);
    buf [1] = LSB (v);

    TRACE ("BE %02x %02x", (int)buf[0], (int)buf[1]);

    aktive_write_here (writer, buf, 2);

    TRACE_RETURN_VOID;
}

extern void
aktive_write_here_uint32be (aktive_writer* writer, aktive_uint v)
{
    TRACE_FUNC ("((writer*) %p, value %d)", writer, v);

    char buf [4];
    buf [0] = (v >> 24) & 0xFF;
    buf [1] = (v >> 16) & 0xFF;
    buf [2] = (v >>  8) & 0xFF;
    buf [3] = (v      ) & 0xFF;
    aktive_write_here (writer, buf, 4);

    TRACE_RETURN_VOID;
}

extern void
aktive_write_here_uint64be (aktive_writer* writer, Tcl_WideInt v)
{
    TRACE_FUNC ("((writer*) %p, value %ld)", writer, v);

    char buf [8];
    buf [0] = (v >> 56) & 0xFF;
    buf [1] = (v >> 48) & 0xFF;
    buf [2] = (v >> 40) & 0xFF;
    buf [3] = (v >> 32) & 0xFF;
    buf [4] = (v >> 24) & 0xFF;
    buf [5] = (v >> 16) & 0xFF;
    buf [6] = (v >>  8) & 0xFF;
    buf [7] = (v      ) & 0xFF;
    aktive_write_here (writer, buf, 8);

    TRACE_RETURN_VOID;
}

extern int
aktive_write_here_uint_text (aktive_writer* writer, aktive_uint v)
{
    TRACE_FUNC ("((writer*) %p, value %d)", writer, v);

    char buf [20];
    aktive_uint n = sprintf (buf, "%d", v);

    ASSERT (n < 20, "value overflowed internal string buffer");
    aktive_write_here (writer, buf, n);

    TRACE_RETURN ("(written) %d", n);
}

extern void
aktive_write_here_float64be (aktive_writer* writer, double v)
{
    TRACE_FUNC ("((writer*) %p, value %f)", writer, v);

    union {
	double        v;
	uint64_t      vi;
	unsigned char buf [sizeof(double)];
    } cast;

    cast.v = v;
    cast.vi = SWAP64 (cast.vi);
    aktive_write_here (writer, cast.buf, sizeof(double));

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
aktive_writer_to_channel (Tcl_Channel chan, char* buf, int n, int pos)
{
    TRACE_FUNC ("((chan*) %p, values %p[%d] @ %d)", chan, buf, n, pos);

    if ((pos == -2) && (n == 0) && !buf) {
	// (D)
	Tcl_Flush (chan);
	TRACE_RETURN_VOID;
    }

    if (pos >= 0) {
	// (@, W)
	Tcl_Flush (chan);
	Tcl_Seek(chan, pos, SEEK_SET);
	TRACE ("location @ %d", Tcl_Tell (chan));

	if (buf && (n > 0)) {
	    // (W)
	    Tcl_Write (chan, buf, n);
	} // else (@)

	TRACE_RETURN_VOID;
    }

    // (E, C)

    if ((n == 0) && !buf) {
	// (E)
	Tcl_Flush (chan);
	Tcl_Seek(chan, 0, SEEK_END);

	TRACE_RETURN_VOID;
    }

    // (C)
    Tcl_Write (chan, buf, n);
    TRACE_RETURN_VOID;
}

static void
aktive_writer_to_bytearray (__ba_writer* baw, char* buf, int n, int pos)
{
    if ((pos == -2) && (n == 0) && !buf) {
	// (D)
	return;
    }

    int            length;
    unsigned char* bytes;
    Tcl_Obj*       ba  = baw->ba;

    bytes = Tcl_GetByteArrayFromObj (ba, &length);

    if (pos >= 0) {
	// (@, W)
	baw->pos = pos;

	if (buf && (n > 0)) {
	    // (W)
	    goto write;
	} // else (@)
	return;
    }

    // (E, C)

    if ((n == 0) && !buf) {
	// (E)
	baw->pos = length;
	return;
    }

    // (C)
 write:
    if ((baw->pos + n) > length) {
	bytes = Tcl_SetByteArrayLength (ba, baw->pos + n);
    }

    memcpy (bytes + baw->pos, buf, n);
    baw->pos += n;
    return;
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
