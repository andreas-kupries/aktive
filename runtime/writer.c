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
    Tcl_Obj*       ba;    // output, filled from buffer
    Tcl_Size       pos;   // write position in buffer
    unsigned char* bytes; // internal byte buffer
    Tcl_Size       used;  // buffer usage
    Tcl_Size       n;     // buffer capacity
} __ba_writer;

// replicated from op.h -- move to runtime
static double aktive_clamp (double x) { return (x < 0) ? 0 : (x > 1) ? 1 : x; }

static void aktive_writer_to_channel   (Tcl_Channel  chan, char* buf, Tcl_Size n, Tcl_WideInt pos);
static void aktive_writer_to_bytearray (__ba_writer* ba,   char* buf, Tcl_Size n, Tcl_WideInt pos);

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

    baw->ba    = ba;
    baw->pos   = 0;
    baw->bytes = 0;
    baw->n     = 0;
    baw->used  = 0;

    writer->state  = baw;
    writer->writer = (aktive_writer_write) aktive_writer_to_bytearray;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_write_here (aktive_writer* writer, char* buf, Tcl_Size n)
{
    TRACE_FUNC ("((writer*) %p, write " TCL_SIZE_FMT " at end)", writer, n);

    ASSERT (buf,   "buffer missing");
    ASSERT (n > 0, "empty buffer");

    TRACE_HEADER(1);TRACE_ADD ("written = {", 0);
    for (int k=0;k<n;k++) { TRACE_ADD(" %u", ((aktive_uint) buf[k]) & 0xFF); }
    TRACE_ADD (" }", 0);TRACE_CLOSER;

    TRACE_HEADER(1);TRACE_ADD ("written = {", 0);
    for (int k=0;k<n;k++) { TRACE_ADD(" '%c'", (char) buf[k]); }
    TRACE_ADD (" }", 0);TRACE_CLOSER;

    writer->writer (writer->state, buf, n, AKTIVE_WRITE_HERE); // (C) write at current location

    TRACE_RETURN_VOID;
}

extern void
aktive_write_at (aktive_writer* writer, char* buf, Tcl_Size n, Tcl_WideInt pos)
{
    TRACE_FUNC ("((writer*) %p, write " TCL_SIZE_FMT " at %lld)", writer, n, pos);

    ASSERT (buf,                     "buffer missing");
    ASSERT (n > 0,                   "empty buffer");
    ASSERT (pos != AKTIVE_WRITE_END, "bad location");

    writer->writer (writer->state, buf, n, pos); // (W) goto pos, then write

    TRACE_RETURN_VOID;
}

extern void
aktive_write_goto (aktive_writer* writer, Tcl_WideInt pos)
{
    TRACE_FUNC ("((writer*) %p, goto %lld)", writer, pos);

    ASSERT (pos != AKTIVE_WRITE_END, "bad location");

    writer->writer (writer->state, 0, 0, pos); // (@, E) goto pos, maybe end

    TRACE_RETURN_VOID;
}

extern void
aktive_write_done (aktive_writer* writer)
{
    TRACE_FUNC ("((writer*) %p)", writer);

    writer->writer (writer->state, 0, 0, AKTIVE_WRITE_DONE); // (D) finalize

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

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_write_here_int8 (aktive_writer* writer, int v)
{
    TRACE_FUNC ("((writer*) %p, value %d)", writer, v);

    char buf [1];
    buf [0] = v & 0xFF;
    aktive_write_here (writer, buf, 1);

    TRACE_RETURN_VOID;
}

extern void
aktive_write_here_int16be (aktive_writer* writer, int v)
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
aktive_write_here_int32be (aktive_writer* writer, int v)
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
aktive_write_here_int64be (aktive_writer* writer, Tcl_WideInt v)
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
aktive_write_here_int_text (aktive_writer* writer, int v)
{
    TRACE_FUNC ("((writer*) %p, value %d)", writer, v);

    char buf [20];
    int n = sprintf (buf, "%d", v);

    ASSERT (n < 20, "value overflowed internal string buffer");
    aktive_write_here (writer, buf, n);

    TRACE_RETURN ("(written) %d", n);
}

/*
 * - - -- --- ----- -------- -------------
 */

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
aktive_writer_to_channel (Tcl_Channel chan, char* buf, Tcl_Size n, Tcl_WideInt pos)
{
    TRACE_FUNC ("((chan*) %p, values %p[" TCL_SIZE_FMT "] @ %lld)", chan, buf, n, pos);

    if ((pos == AKTIVE_WRITE_DONE) && (n == 0) && !buf) {
	// (D)
	TRACE ("flush", 0);
	Tcl_Flush (chan);

	TRACE ("location @ %lld", Tcl_Tell (chan));
	TRACE_RETURN_VOID;
    }

    if (pos != AKTIVE_WRITE_END) {
	// (@, W)
	Tcl_Flush (chan);

	TRACE ("goto %lld", pos);
	Tcl_Seek(chan, pos, SEEK_SET);

	TRACE ("location / %lld", Tcl_Tell (chan));

	if (buf && (n > 0)) {
	    // (W)
	    Tcl_Write (chan, buf, n);	 /* OK tcl9 */
	} // else (@)

	TRACE_RETURN_VOID;
    }

    // (E, C)

    if ((n == 0) && !buf) {
	// (E)
	TRACE ("goto end", 0);

	Tcl_Flush (chan);
	Tcl_Seek(chan, 0, SEEK_END);

	TRACE ("location = %lld", Tcl_Tell (chan));
	TRACE_RETURN_VOID;
    }

    // (C)
    TRACE ("location ! %lld", Tcl_Tell (chan));
    Tcl_Write (chan, buf, n);	 /* OK tcl9 */

    TRACE_RETURN_VOID;
}

static void
aktive_writer_to_bytearray (__ba_writer* baw, char* buf, Tcl_Size n, Tcl_WideInt pos)
{
    TRACE_FUNC ("((baw*) %p, values %p[" TCL_SIZE_FMT "] @ %lld)", baw, buf, n, pos);

    if ((pos == AKTIVE_WRITE_DONE) && (n == 0) && !buf) {
	// (D) done, flush to output Tcl_Obj*, and release
	if (baw->bytes) {
	    Tcl_SetByteArrayObj (baw->ba, baw->bytes, baw->used);	 /* OK tcl9 */
	    ckfree (baw->bytes);
	}
	TRACE_RETURN_VOID;
    }

    if (pos != AKTIVE_WRITE_END) {
	// (@, W)
	baw->pos = pos;

	if (buf && (n > 0)) {
	    // (W)
	    goto write;
	} // else (@)
	TRACE_RETURN_VOID;
    }

    // (E, C) - end, or here

    if ((n == 0) && !buf) {
	// (E)
	baw->pos = baw->n;
	TRACE_RETURN_VOID;
    }

    // (C)
 write:
    // manipulate the internal buffer

    if ((baw->pos + n) > baw->n) {
	// not enough space, extend it - doubling to amortize
	TRACE ("have " TCL_SIZE_FMT ", need " TCL_SIZE_FMT, baw->n, baw->pos + n);
	baw->n = 2*(baw->pos + n);
	TRACE ("now  " TCL_SIZE_FMT ", need " TCL_SIZE_FMT, baw->n, baw->pos + n);

	baw->bytes = REALLOC (baw->bytes, unsigned char, baw->n);
    }

    memcpy (baw->bytes + baw->pos, buf, n);
    baw->pos += n;

    if (baw->pos > baw->used) {
	baw->used = baw->pos;
    }

    TRACE_RETURN_VOID;
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
