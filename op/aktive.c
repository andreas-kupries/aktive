/* -*- c -*-
 *
 * -- Direct operator support - AKTIVE format support
 *
 * AKTIVE image files - Bare bones format, VIPS insprired
 *
 * |Offset	|Size	|Type		|Id	|Content		|
 * |---:	|---:	|---		|---	|---			|
 * |0		|6	|uchar[6]	|magic	|'AKTIVE'		|
 * |6		|2	|uchar[2]	|version|'00'			|
 * |8		|4	|uint32_be	|x	|x location		|
 * |12		|4	|uint32_be	|y	|y location		|
 * |16		|4	|uint32_be	|width	|#columns		|
 * |20		|4	|uint32_be	|height	|#rows			|
 * |24		|4	|uint32_be	|depth	|#bands			|
 * |28		|4	|uint32_be	|metac	|#bytes meta data	|
 * |===		|===	|===		|===	|===			|
 * |32		|metac	|uchar[metac]	|meta	|meta data (?format?)	|
 * |===		|===	|===		|===	|===			|
 * |32+metac	|8	|uchar[8]	|magic2	|'AKTIVE_D'		|
 * |40+metac	|8*n	|float64_be[n]	|pixel	|n == w*h*d values	|
 * |===		|===	|===		|===	|===			|
 * |40+metac+8*n|	|		|	|			|
 */

#include <aktive.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#define MAGIC   "AKTIVE"
#define MAGIC2  "AKTIVE_D"
#define VERSION "00"

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_aktive_control {
    // Processing configuration
    aktive_writer* writer;   // Destination for image data
    aktive_sink*   sink;     // Owning/owned sink

    // Processing state
    aktive_uint    size;       // Image size
    aktive_uint    written;    // Values written == size at end    
} aktive_aktive_control;

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_aktive_control* aktive_header (aktive_aktive_control* info, aktive_image src);
static void                   aktive_pixels (aktive_aktive_control* info, aktive_block* src);
static void                   aktive_final  (aktive_aktive_control* info);

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_sink*
aktive_aktive_sink (aktive_writer* writer)
{
    TRACE_FUNC ("((writer*) %p)", writer);
  
    aktive_aktive_control* info = ALLOC (aktive_aktive_control);
    aktive_sink*           sink = ALLOC (aktive_sink);

    info->writer   = writer;
    info->sink     = sink;
    info->size     = 0;
    info->written  = 0;

    sink->name    = "aktive";
    sink->setup   = (aktive_sink_setup)   aktive_header;
    sink->final   = (aktive_sink_final)   aktive_final;
    sink->process = (aktive_sink_process) aktive_pixels;
    sink->state   = info;
    
    TRACE_RETURN ("(aktive_sink*) %p", sink);
}

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_aktive_control*
aktive_header (aktive_aktive_control* info, aktive_image src)
{
    TRACE_FUNC ("((aktive_aktive_control*) %p '%s', (aktive_image) %p '%s')",
		info, info->sink->name, src, aktive_image_get_type (src)->name);

    aktive_geometry* g = aktive_image_get_geometry (src);

    TRACE ("magic",      0); aktive_write_append          (info->writer, MAGIC,   sizeof (MAGIC)-1);
    TRACE ("version",    0); aktive_write_append          (info->writer, VERSION, sizeof (VERSION)-1);
    TRACE ("x location", 0); aktive_write_append_uint32be (info->writer, g->x);
    TRACE ("y location", 0); aktive_write_append_uint32be (info->writer, g->y);
    TRACE ("width",      0); aktive_write_append_uint32be (info->writer, g->width);
    TRACE ("height",     0); aktive_write_append_uint32be (info->writer, g->height);
    TRACE ("depth",      0); aktive_write_append_uint32be (info->writer, g->depth);
    TRACE ("meta size",  0); aktive_write_append_uint32be (info->writer, 0);	// # meta data, none, so far
    TRACE ("magic2",     0); aktive_write_append          (info->writer, MAGIC2, sizeof (MAGIC2)-1);

    info->size    = aktive_geometry_get_size (g);
    info->written = 0;

    TRACE_RETURN ("(aktive_aktive_control*) %p", info);
}

static void
aktive_final (aktive_aktive_control* info) {
    TRACE_FUNC ("((aktive_aktive_control*) %p '%s', written %d)",
		info, info->sink->name, info->written);

    ASSERT_VA (info->written == info->size, "write mismatch",
	       "AKTIVE wrote %d != required %d", info->written, info->size);
    
    aktive_write_done (info->writer);
    
    ckfree (info->sink);
    ckfree (info);

    TRACE_RETURN_VOID;
}

#define ITER  for (aktive_uint j = 0; j < src->used; j++)
#define VAL   src->pixel [j]

static void
aktive_pixels (aktive_aktive_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_aktive_control*) %p '%s', written %d, getting (%p): %d)",
		info, info->sink->name, info->written, src, src->used);

    ITER {
	aktive_write_append_float64be (info->writer, VAL);
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
