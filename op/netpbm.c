/* -*- c -*-
 *
 * -- Direct operator support - Netpbm support
 */

#include <netpbm.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#define MAXCOL 70

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
 */

static aktive_netpbm_control* netpbm_header (aktive_image src, aktive_netpbm_control* info);
static void                   netpbm_final  (aktive_netpbm_control* info);

static void netpbm_text  (aktive_netpbm_control* info, aktive_block* src);
static void netpbm_etext (aktive_netpbm_control* info, aktive_block* src);
static void netpbm_byte  (aktive_netpbm_control* info, aktive_block* src);
static void netpbm_short (aktive_netpbm_control* info, aktive_block* src);

/*
 * - - -- --- ----- -------- -------------
 */

/* 2/3 = pgm/ppm text, 5/6 = pgm/ppm binary */
static const char* format[] = {
	"",
	"",
	"pgm::text",
	"ppm::text",
	"",
	"pgm::binary",
	"ppm::binary"
};

static int valid[] = { 0, 0, 1, 1, 0,  1, 1 };

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

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_sink*
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

    sink->name    = (char*) format [vindex];
    sink->setup   = (aktive_sink_setup) netpbm_header;
    sink->final   = (aktive_sink_final) netpbm_final;
    sink->process = process [(vindex << 1) + extended];
    sink->state   = info;
    
    TRACE_RETURN ("(aktive_sink*) %p", sink);
}

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_netpbm_control*
netpbm_header (aktive_image src, aktive_netpbm_control* info)
{
    TRACE_FUNC ("((aktive_image) %p '%s', (aktive_netpbm_control*) %p '%s')",
		src, aktive_image_get_type (src)->name, info, info->sink->name);
    
    char             buf [40];
    aktive_geometry* g = aktive_image_get_geometry (src);
    aktive_uint      n = sprintf (buf, "P%c %d %d %d ",
				  info->variant,
				  g->width,
				  g->height,
				  info->maxvalue);

    ASSERT (n < 40, "header overflowed internal string buffer");
    TRACE ("header to write (%s)", buf);

    aktive_write_append (info->writer, buf, n);

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
	aktive_uint n = aktive_write_append_uint_text (info->writer, aktive_quantize_uint8 (VAL));
	info->col += n;
	int term = 32;
	if (info->col >= MAXCOL) { TRACE ("break %d", info->col); info->col = 0; term = 10; } else { info->col ++; }
	aktive_write_append_uint8 (info->writer, term);
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
	aktive_uint n = aktive_write_append_uint_text (info->writer, aktive_quantize_uint16 (VAL));
	info->col += n;
	int term = 32;
	if (info->col >= MAXCOL) { TRACE ("break %d", info->col); info->col = 0; term = 10; } else { info->col ++; }
	aktive_write_append_uint8 (info->writer, term);
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
	aktive_write_append_uint8 (info->writer, aktive_quantize_uint8 (VAL));
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
	aktive_write_append_uint16be (info->writer, aktive_quantize_uint16 (VAL));
	info->written ++;
    }

    TRACE_RETURN_VOID;
}

#undef ITER
#undef VAL

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
