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
 * |32		|metac	|uchar[metac]	|meta	|meta data (1)		|
 * |===		|===	|===		|===	|===			|
 * |32+metac	|8	|uchar[8]	|magic2	|'AKTIVE_D'		|
 * |40+metac	|8*n	|float64_be[n]	|pixel	|n == w*h*d values	|
 * |===		|===	|===		|===	|===			|
 * |40+metac+8*n|	|		|	|			|
 *
 * (1) Format: String representation of a Tcl dictionary value.
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <aktive.h>

#define MAGIC   "AKTIVE"
#define MAGIC2  "AKTIVE_D"
#define VERSION "00"

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_aktive_control {
    // Processing configuration
    aktive_writer* writer;   // Destination for image data
    aktive_sink*   sink;     // Owning/owned sink

    // Processing state
    aktive_uint    size;      // Image size in pixels
    aktive_uint    written;   // Values written == size at end
    aktive_uint    start;     // Byte offset where pixels start in the file
    aktive_uint    rowsize;   // Size of a row in bytes
    aktive_uint    pixsize;   // Size of a single pixel in bytes
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

extern aktive_sink*
aktive_aktive_sink (aktive_writer* writer)
{
    TRACE_FUNC ("((writer*) %p)", writer);

    aktive_aktive_control* info = ALLOC (aktive_aktive_control);
    aktive_sink*           sink = ALLOC (aktive_sink);

    info->writer   = writer;
    info->sink     = sink;
    info->size     = 0;
    info->start    = 0;
    info->written  = 0;

    sink->name       = "aktive";
    sink->setup      = (aktive_sink_setup)   aktive_header;
    sink->final      = (aktive_sink_final)   aktive_final;
    sink->process    = (aktive_sink_process) aktive_pixels;
    sink->sequential = 0;
    sink->state      = info;

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
    Tcl_Obj*         m = aktive_image_meta_get (src);
    int              msize = 0;
    char*            mdata = 0;
    int              start = 0;
    if (m) { mdata = Tcl_GetStringFromObj (m, &msize); start += msize; }

    TRACE ("magic",      0); aktive_write_here          (info->writer, MAGIC,   sizeof (MAGIC)-1);   start += sizeof (MAGIC)-1;
    TRACE ("version",    0); aktive_write_here          (info->writer, VERSION, sizeof (VERSION)-1); start += sizeof (VERSION)-1;
    TRACE ("x location", 0); aktive_write_here_uint32be (info->writer, g->x);                        start += 4;
    TRACE ("y location", 0); aktive_write_here_uint32be (info->writer, g->y);                        start += 4;
    TRACE ("width",      0); aktive_write_here_uint32be (info->writer, g->width);                    start += 4;
    TRACE ("height",     0); aktive_write_here_uint32be (info->writer, g->height);                   start += 4;
    TRACE ("depth",      0); aktive_write_here_uint32be (info->writer, g->depth);                    start += 4;
    TRACE ("meta size",  0); aktive_write_here_uint32be (info->writer, msize);                       start += 4;
    if (msize) {
	TRACE ("meta data", 0); aktive_write_here (info->writer, mdata, msize);
    }
    TRACE ("magic2",        0); aktive_write_here (info->writer, MAGIC2, sizeof (MAGIC2)-1);         start += sizeof (MAGIC2)-1;

    info->size    = aktive_geometry_get_size (g);
    info->written = 0;
    info->start   = start;
    info->pixsize = g->depth * sizeof (double);
    info->rowsize = g->width * info->pixsize;

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

static void
aktive_pixels (aktive_aktive_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_aktive_control*) %p '%s', written %d, getting (%p): %d)",
		info, info->sink->name, info->written, src, src->used);

    TRACE_DO (__aktive_block_dump (info->sink->name, src));

    // start offset of the block in the file
    int offset = info->start
	+ info->rowsize * src->location.y
	+ info->pixsize * src->location.x;

    TRACE ("location offset: %d", offset);

    aktive_uint r, c, j;
    aktive_uint rowvalues = src->domain.width * src->domain.depth;

    // iterate over the rows of the block ...
    for (j = 0, r = 0; r < src->domain.height; r++, offset += info->rowsize) {
	// seek to pixel location in the file, for the current row ...
	aktive_write_goto (info->writer, offset);

	// ... and write the elements of the row into place
	for (c = 0; c < rowvalues; c++, j++) {
	    aktive_write_here_float64be (info->writer, src->pixel [j]);
	    info->written ++;
	}
    }

    TRACE_RETURN_VOID;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
