/* -*- c -*-
 *
 * -- Direct operator support - NETPBM support
 *
 * PGM - Portable Grey Map      1-band grey image
 * PPM - Portable Pixel Map     3-band RGB  image
 *
 * References:
 *
 *  - http://en.wikipedia.org/wiki/Netpbm_format
 *
 *  - http://wiki.tcl.tk/4530
 *
 * Format Description/Specification Recap
 *
 *  - PPM data represents a byte- or short-quantized RGB image (i.e. it has 3 bands). It
 *    consists of a minimal header followed by a list of integer triples. The integer
 *    values can be coded in binary (uint8 or uint16), or as ASCII decimal numbers
 *    (unsigned, >= 0 always). The header indicates the coding in use.
 *
 *  - PGM data represents a byte- or short-quantized gray image (i.e. it has 1 band). The
 *    header is identical to PPM, except in the type indicator up front. The possible
 *    encodings for the integer values are the same.
 *
 *  - The header is always plain text. It consists of type indicator, image width and
 *    height, and the possible maximal integer value, in this order. The `maximal value` is
 *    a scaling factor in the range 1 to 65535. Values <= 255 indicate uint8 for binary
 *    coding, otherwise uint16.
 *
 *  - All formats allow `#`-based single-line comments in the header H which may start
 *    __anywhere__ in H. IOW even in the middle of a number.
 *
 *    This writer does not generate any comments - TODO FUTURE :: use for meta data
 *
 *    The formats encoding the pixel values as text further allow #-based single-line
 *    comments in the pixel data section as well.
 *
 *  - Parsing the header can and is done using a state machine supporting a single level
 *    of stack/context.
 *
 *  - Whitespace (Space, TAB, VT, CR, LF) is used to terminate all values in the header.
 *    Whitespace is also used to terminate text encoded pixel values. Binary coded pixel
 *    values on the other hand are __not__ terminated at all.
 *
 *  - Binary coded data is written in __big endian__ order (relevant only to uint16).
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <netpbm.h>
#include <swap.h>
#include <veccache.h>

#define MAXCOL 70

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_netpbm_control {
    // Processing configuration
    aktive_writer* writer;   // Destination for image data
    unsigned char  variant;  // Format variant, primary (PGM/PPM) and secondary (text/binary)
    aktive_uint    maxvalue; // Size/scaling.
    aktive_sink*   sink;     // Owning/owned sink

    // Processing state
    aktive_uint    size;       // Image size
    aktive_uint    written;    // Values written == size at end
    aktive_uint    col;        // Line breaker control for text modes

} aktive_netpbm_control;

/*
 * - - -- --- ----- -------- -------------
 * Writer internals
 */

static aktive_netpbm_control* netpbm_header (aktive_netpbm_control* info, aktive_image src);
static void                   netpbm_final  (aktive_netpbm_control* info);

static void netpbm_text  (aktive_netpbm_control* info, aktive_block* src);
static void netpbm_etext (aktive_netpbm_control* info, aktive_block* src);
static void netpbm_byte  (aktive_netpbm_control* info, aktive_block* src);
static void netpbm_short (aktive_netpbm_control* info, aktive_block* src);

/*
 * - - -- --- ----- -------- -------------
 * Reader internals
 */

#define D(name)						\
    static void						\
    netpbm_read_ ## name (void**                cache,	\
			  aktive_netpbm_header* info,	\
			  aktive_uint           x,	\
			  aktive_uint           y,	\
			  aktive_uint           w,	\
			  Tcl_Channel           chan,	\
			  double*               v)

D (pgm_byte);
D (pgm_short);
D (pgm_text);
D (pgm_etext);
D (ppm_byte);
D (ppm_short);
D (ppm_text);
D (ppm_etext);

/*
 * - - -- --- ----- -------- -------------
 */

/* 2/3 = pgm/ppm text, 5/6 = pgm/ppm binary */
static const char* format[] = {
	/* 0 */	"",
	/* 1 */	"",
	/* 2 */	"pgm::text",
	/* 3 */	"ppm::text",
	/* 4 */	"",
	/* 5 */	"pgm::binary",
	/* 6 */	"ppm::binary"
};

static int         valid [] = { 0, 0, 1, 1, 0, 1, 1 };
static aktive_uint bands [] = { 0, 0, 1, 3, 0, 1, 3 };
static aktive_uint binary[] = { 0, 0, 0, 0, 0, 1, 1 };

static aktive_sink_process process[] = {
	/*  0 0          */ 0,
	/*  1 0/extended */ 0,
	/*  2 1          */ 0,
	/*  3 1/extended */ 0,
	/*  4 2          */ (aktive_sink_process) netpbm_text,
	/*  5 2/extended */ (aktive_sink_process) netpbm_etext,
	/*  6 3          */ (aktive_sink_process) netpbm_text,
	/*  7 3/extended */ (aktive_sink_process) netpbm_etext,
	/*  8 4          */ 0,
	/*  9 4/extended */ 0,
	/* 10 5          */ (aktive_sink_process) netpbm_byte,
	/* 11 5/extended */ (aktive_sink_process) netpbm_short,
	/* 12 6          */ (aktive_sink_process) netpbm_byte,
	/* 13 6/extended */ (aktive_sink_process) netpbm_short,
};

static aktive_netpbm_reader reader[] = {
	/*  0 0          */ 0,
	/*  1 0/extended */ 0,
	/*  2 1          */ 0,
	/*  3 1/extended */ 0,
	/*  4 2          */ (aktive_netpbm_reader) netpbm_read_pgm_text,
	/*  5 2/extended */ (aktive_netpbm_reader) netpbm_read_pgm_etext,
	/*  6 3          */ (aktive_netpbm_reader) netpbm_read_ppm_text,
	/*  7 3/extended */ (aktive_netpbm_reader) netpbm_read_ppm_etext,
	/*  8 4          */ 0,
	/*  9 4/extended */ 0,
	/* 10 5          */ (aktive_netpbm_reader) netpbm_read_pgm_byte,
	/* 11 5/extended */ (aktive_netpbm_reader) netpbm_read_pgm_short,
	/* 12 6          */ (aktive_netpbm_reader) netpbm_read_ppm_byte,
	/* 13 6/extended */ (aktive_netpbm_reader) netpbm_read_ppm_short,
};

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_sink*
aktive_netpbm_sink (aktive_writer* writer,
		    unsigned char  variant,
		    aktive_uint    maxvalue)
{
    TRACE_FUNC ("((writer*) %p, (variant) %c, (maxvalue) %d)", writer, variant, maxvalue);

    aktive_uint vindex = variant - '0'; // Translate from char down to array index

    ASSERT (maxvalue < 65536, "scaling too large");
    ASSERT ((vindex < 7) && valid [vindex], "band variant");

    aktive_netpbm_control* info = ALLOC (aktive_netpbm_control);
    aktive_sink*           sink = ALLOC (aktive_sink);

    info->writer   = writer;
    info->variant  = variant;
    info->maxvalue = maxvalue;
    info->sink     = sink;
    info->size     = 0;
    info->written  = 0;
    info->col      = 0;

    int extended = (maxvalue > 255);

    sink->name       = (char*) format [vindex];
    sink->setup      = (aktive_sink_setup) netpbm_header;
    sink->final      = (aktive_sink_final) netpbm_final;
    sink->process    = process [(vindex << 1) + extended];
    sink->sequential = 1; // TODO :: see if we can avoid this for the binary formats
    sink->state      = info;

    TRACE_RETURN ("(aktive_sink*) %p", sink);
}

/*
 * - - -- --- ----- -------- -------------
 ** Sink support. Writing netpbm header, pixels, completion
 */

static aktive_netpbm_control*
netpbm_header (aktive_netpbm_control* info, aktive_image src)
{
    TRACE_FUNC ("((aktive_netpbm_control*) %p '%s', (aktive_image) %p '%s')",
		info, info->sink->name, src, aktive_image_get_type (src)->name);

    char             buf [40];
    aktive_geometry* g = aktive_image_get_geometry (src);
    aktive_uint      n = sprintf (buf, "P%c %d %d %d ",
				  info->variant,
				  g->width,
				  g->height,
				  info->maxvalue);

    ASSERT (n < 40, "header overflowed internal string buffer");
    TRACE ("header to write (%s)", buf);

    aktive_write_here (info->writer, buf, n);

    info->size    = aktive_geometry_get_size (g);
    info->written = 0;
    info->col     = n; // Header on first line

    TRACE_RETURN ("(aktive_netpbm_control*) %p", info);
}

static void
netpbm_final (aktive_netpbm_control* info) {
    TRACE_FUNC ("((aktive_netpbm_control*) %p '%s', written %d, at col %d)",
		info, info->sink->name, info->written, info->col);

    ASSERT_VA (info->written == info->size, "write mismatch",
	       "%s wrote %d != required %d",
	       format[info->variant - '0'], info->written, info->size);

    aktive_write_done (info->writer);

    ckfree (info->sink);
    ckfree (info);

    TRACE_RETURN_VOID;
}

#define ITER  for (aktive_uint j = 0; j < src->used; j++)
#define VAL   src->pixel [j]

static void
netpbm_text (aktive_netpbm_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_netpbm_control*) %p '%s', written %d, at col %d, getting (%p): %d)",
		info, info->sink->name, info->written, info->col, src, src->used);

    ITER {
	aktive_uint n = aktive_write_here_uint_text (info->writer, aktive_quantize_uint8 (VAL));
	info->col += n;
	int term = 32;
	if (info->col >= MAXCOL) { TRACE ("break %d", info->col); info->col = 0; term = 10; } else { info->col ++; }
	aktive_write_here_uint8 (info->writer, term);
	info->written ++;
    }

    TRACE_RETURN_VOID;
}

static void
netpbm_etext (aktive_netpbm_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_netpbm_control*) %p '%s', written %d, at col %d, getting (%p): %d)",
		info, info->sink->name, info->written, info->col, src, src->used);

    ITER {
	aktive_uint n = aktive_write_here_uint_text (info->writer, aktive_quantize_uint16 (VAL));
	info->col += n;
	int term = 32;
	if (info->col >= MAXCOL) { TRACE ("break %d", info->col); info->col = 0; term = 10; } else { info->col ++; }
	aktive_write_here_uint8 (info->writer, term);
	info->written ++;
    }

    TRACE_RETURN_VOID;
}

static void
netpbm_byte (aktive_netpbm_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_netpbm_control*) %p '%s', written %d, at col %d, getting (%p): %d)",
		info, info->sink->name, info->written, info->col, src, src->used);

    ITER {
	aktive_uint val = aktive_quantize_uint8 (VAL);
	TRACE ("write [%8d] %f -> %5u", j, VAL, val);

	aktive_write_here_uint8 (info->writer, val);
	info->written ++;
    }

    TRACE_RETURN_VOID;
}

static void
netpbm_short (aktive_netpbm_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_netpbm_control*) %p '%s', written %d, at col %d, getting (%p): %d)",
		info, info->sink->name, info->written, info->col, src, src->used);

    ITER {
	aktive_uint val = aktive_quantize_uint16 (VAL);
	TRACE ("write [%8d] %f -> %5u", j, VAL, val);

	aktive_write_here_uint16be (info->writer, val);
	info->written ++;
    }

    TRACE_RETURN_VOID;
}

#undef ITER
#undef VAL

/*
 * - - -- --- ----- -------- -------------
 ** Reader support. Header, pixels
 */

extern int
aktive_netpbm_read_header (Tcl_Channel src, aktive_netpbm_header* info)
{
    TRACE_FUNC ("((Channel) %p, (header*) %p)", src, info);

#define TRY(m, cmd) if (!(cmd)) { TRACE_RETURN ("(Fail) %d: " m, 0); }
#define MAGIC "P"

    TRY ("magic1", aktive_read_match (src, MAGIC, sizeof (MAGIC)-1));

    aktive_uint vcode;
    TRY ("magic2", aktive_read_uint8 (src, &vcode));
    vcode -= '0';
    if ((vcode > 7) || !valid [vcode]) { TRACE_RETURN ("(Fail) %d: type", 0); }

    //*** WARE - In byte data the first pixel byte may be a `#`. That is not a comment.
    TRY ("width",  aktive_read_uint_strcom (src, &info->width));
    TRY ("height", aktive_read_uint_strcom (src, &info->height));
    TRY ("maxval", aktive_read_uint_str/*com*/ (src, &info->maxval));

    aktive_uint extended = (info->maxval > 255);

    info->base   = Tcl_Tell (src);
    info->depth  = bands [vcode];
    info->reader = reader [(vcode << 1) + extended];
    info->scale  = 1.0 / info->maxval;
    info->binary = binary [vcode];

    TRACE ("width  %u", info->width);
    TRACE ("height %u", info->height);
    TRACE ("depth  %u", info->depth);
    TRACE ("maxv   %u", info->maxval);
    TRACE ("data@  %u", info->base);
    TRACE ("scale  %f", info->scale);
    TRACE ("binary %u", info->binary);

#undef TRY
    TRACE_RETURN ("(OK) %d", 1);
}

/*
 * - - -- --- ----- -------- -------------
 ** Reader support. Text format. Vector cache context and fill function.
 */

typedef struct rowfill {
    Tcl_Channel chan;	// Channel to read pixels from
    aktive_uint count;	// Number of pixels to read
    double      scale;	// Scaling factor to apply
} rowfill;

static aktive_uint
rowfiller (rowfill* param, aktive_uint start, double* v)
{
    TRACE_FUNC("(chan %p, count %u, scale %f, start %u, dst %p)",
	       param->chan, param->count, param->scale, start, v);

    Tcl_Seek (param->chan, start, SEEK_SET);

    aktive_uint k;
    for (k = 0; k < param->count; k++) {
	aktive_uint value;
	int ok = aktive_read_uint_strcom (param->chan, &value);
	if (!ok) break;
	// NOTE: This not only leaves the requested row short.
	// NOTE: It also forces all rows after to the same place,
	// NOTE: shorting them further (empty).
	v[k] = ((double) value) * param->scale;
    }

    TRACE_RETURN ("next %d", Tcl_Tell(param->chan));
}

/*
 * - - -- --- ----- -------- -------------
 ** Reader support. Header, pixels
 */

D (pgm_byte)	// single band, binary, byte
{
#define BANDS    1
#define BANDCODE 1
#include <netpbm_binread.h>
}

D (pgm_short)	// single band, binary, short
{
#define BANDS      1
#define BANDCODE   2
#define PROCESS(x) x = SWAP16 (x)
#include <netpbm_binread.h>
}

D (pgm_text) // single band, text
{
    TRACE_FUNC ("((void**) %p, (info*) %p, (%u x %u), (Chan) %p, (double*) %p [%u]) [%u %f]",
	    cache, info, x, y, chan, v, w, info->width, info->scale);

    rowfill param = { chan, w, info->scale };

    double* src = aktive_veccache_get (*cache, y,
				       (aktive_veccache_fill) rowfiller,
					&param);

    // src is owned by the cache. read-only!
    memcpy (v, src + x, w * sizeof(double));

    TRACE_RETURN_VOID;
}

D (pgm_etext) // single band, extended text - handle as text
{
    netpbm_read_pgm_text (cache, info, x, y, w, chan, v);
}

D (ppm_byte)	// 3 band, binary, byte
{
#define BANDS      3
#define BANDCODE   1
#include <netpbm_binread.h>
}

D (ppm_short)	// 3 band, binary, short
{
#define BANDS      3
#define BANDCODE   2
#define PROCESS(x) x = SWAP16 (x)
#include <netpbm_binread.h>
}

D (ppm_text) // 3 band, text
{
    TRACE_FUNC ("((void**) %p, (info*) %p, (%u x %u), (Chan) %p, (double*) %p [%u]) [%u %f]",
	    cache, info, x, y, chan, v, w, info->width, info->scale);

    // *cache, info, x, y, w, chan, v [3*w]

    rowfill param = { chan, 3*w, info->scale };
    double* src = aktive_veccache_get (*cache, y,
				       (aktive_veccache_fill) rowfiller,
				       &param);

    // src is owned by the cache. read-only!
    memcpy (v, src + x, 3*w * sizeof(double));

    TRACE_RETURN_VOID;
}

D (ppm_etext) // 3 band, extended text - handle as text
{
    netpbm_read_ppm_text (cache, info, x, y, w, chan, v);
}

#undef D

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
