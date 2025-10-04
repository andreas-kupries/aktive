/* -*- c -*-
 *
 * -- Direct operator support - AKTIVE format support
 *
 * AKTIVE image files - Bare bones format, VIPS inspired
 *
 * |Offset	|Size	|Type		|Id	|Content		|
 * |---:	|---:	|---		|---	|---			|
 * |0		|6/8	|uchar[8]	|magic	|'AKTIVE'/'AKTIVELE'	|
 * |6		|2	|uchar[2]	|version|'00'			|
 * |8		|4	|int32_be	|x	|x location		|
 * |12		|4	|int32_be	|y	|y location		|
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
 * |42+metac+8*n|	|		|	|			|
 *
 * (1) Format: String representation of a Tcl dictionary value.
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <aktive.h>

#define MAGICBE "AKTIVE"
#define MAGICLE "AKTIVELE"
#define MAGIC2  "AKTIVE_D"
#define VERSION "00"

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 ** Reader support
 */

static int         header_esize (aktive_aktive_header* info, Tcl_Size inmax, Tcl_Size magicsize);
static Tcl_WideInt slice_offset (aktive_aktive_header* info, aktive_uint x, aktive_uint y, aktive_uint n);

#define TRY(m, cmd) \
    if (!(cmd)) { aktive_fail ("failed to read header: " m); goto fail; }

/*
 *
 */

int
aktive_aktive_be_header_read (Tcl_Channel src, Tcl_Size inmax, aktive_aktive_header* info)
{
#define TRYF(field,cmd) \
    if (!(cmd (src, &info->field))) { aktive_fail ("failed to read header: " #field); goto fail; } \
    TRACE ("HEADER (" #field ") = %d", info->field)

    TRACE_FUNC("((Channel) %p, (aktive_header*) %p)", src, info);

    TRY  ("magic",       aktive_read_match   (src, MAGICBE, sizeof (MAGICBE)  -1));
    TRY  ("version",     aktive_read_match   (src, VERSION, sizeof (VERSION)-1));
    TRYF (domain.x,      aktive_read_int32be );
    TRYF (domain.y,      aktive_read_int32be );
    TRYF (domain.width,  aktive_read_uint32be);
    TRYF (domain.height, aktive_read_uint32be);
    TRYF (domain.depth,  aktive_read_uint32be);
    TRYF (metac,         aktive_read_uint32be);
    if (info->metac) {
	info->meta = NALLOC (char, info->metac);
	if (!aktive_read_string (src, info->meta, info->metac)) { aktive_fail ("failed to read header: metad"); goto fail; }
    }
    TRY ("magic2", aktive_read_match (src, MAGIC2, sizeof (MAGIC2)-1));
    info->pix = Tcl_Tell (src);

    if (!header_esize (info, inmax, sizeof (MAGICBE))) goto fail;

    TRACE_RETURN ("(ok) %d", 1);
 fail:
    if (info->meta) ckfree (info->meta);
    TRACE_RETURN ("(fail) %d", 0);

#undef TRYF
}

int
aktive_aktive_be_header_get (char* inbytes, Tcl_Size inmax, aktive_aktive_header* info)
{
#define TRYF(field,cmd)							\
    if (!(cmd (inbytes, inmax, &pos, &info->field))) { aktive_fail ("failed to read header: " #field); goto fail; } \
    TRACE ("HEADER (" #field ") = %d", info->field)

    TRACE_FUNC("((byte*) %p [%d], (aktive_header*) %p)", inbytes, inmax, info);

    Tcl_Size pos = 0;

    TRY  ("magic",       aktive_get_match   (inbytes, inmax, &pos, MAGICBE, sizeof (MAGICBE)-1));
    TRY  ("version",     aktive_get_match   (inbytes, inmax, &pos, VERSION, sizeof (VERSION)-1));
    TRYF (domain.x,      aktive_get_int32be );
    TRYF (domain.y,      aktive_get_int32be );
    TRYF (domain.width,  aktive_get_uint32be);
    TRYF (domain.height, aktive_get_uint32be);
    TRYF (domain.depth,  aktive_get_uint32be);
    TRYF (metac,         aktive_get_uint32be);
    if (info->metac) {
	info->meta = NALLOC (char, info->metac);
	if (!aktive_get_string (inbytes, inmax, &pos, info->meta, info->metac)) {
	    aktive_fail ("failed to read header: metadata");
	    goto fail;
	}
    }
    TRY ("magic2", aktive_get_match (inbytes, inmax, &pos, MAGIC2, sizeof (MAGIC2)-1));
    info->pix = pos;

    if (!header_esize (info, inmax, sizeof (MAGICBE))) goto fail;

    TRACE_RETURN ("(ok) %d", 1);
 fail:
    if (info->meta) ckfree (info->meta);
    TRACE_RETURN ("(fail) %d", 0);

#undef TRYF
}

int
aktive_aktive_be_slice_read (Tcl_Channel src, aktive_aktive_header* info, aktive_uint x, aktive_uint y, aktive_uint n, double* rowbuf)
{
    TRACE_FUNC ("((Channel) %p, (header*) %p, x=%d, y=%d, double[%d] %p)",
		src, info, x, y, n, rowbuf);

    Tcl_Seek (src, slice_offset (info, x, y, n), SEEK_SET);
    int ok = aktive_read_float64be_n (src, n, rowbuf);

    TRACE_RETURN ("(ok?) %d", ok);
}

int
aktive_aktive_be_slice_get  (char* inbytes, aktive_aktive_header* info, aktive_uint x, aktive_uint y, aktive_uint n, double* rowbuf)
{
    TRACE_FUNC ("((byte*) %p, (header*) %p, x=%d, y=%d, double[%d] %p)",
		inbytes, info, x, y, n, rowbuf);

    Tcl_Size pos = slice_offset (info, x, y, n);
    int ok = aktive_get_float64be_n (inbytes, info->esize, &pos, n, rowbuf);

    TRACE_RETURN ("(ok?) %d", ok);
}

/*
 * little endian
 */

int
aktive_aktive_le_header_read (Tcl_Channel src, Tcl_Size inmax, aktive_aktive_header* info)
{
#define TRYF(field,cmd) \
    if (!(cmd (src, &info->field))) { aktive_fail ("failed to read header: " #field); goto fail; } \
    TRACE ("HEADER (" #field ") = %d", info->field)

    TRACE_FUNC("((Channel) %p, (aktive_header*) %p)", src, info);

    TRY  ("magic",       aktive_read_match   (src, MAGICLE, sizeof (MAGICLE)  -1));
    TRY  ("version",     aktive_read_match   (src, VERSION, sizeof (VERSION)-1));
    TRYF (domain.x,      aktive_read_int32le );
    TRYF (domain.y,      aktive_read_int32le );
    TRYF (domain.width,  aktive_read_uint32le);
    TRYF (domain.height, aktive_read_uint32le);
    TRYF (domain.depth,  aktive_read_uint32le);
    TRYF (metac,         aktive_read_uint32le);
    if (info->metac) {
	info->meta = NALLOC (char, info->metac);
	if (!aktive_read_string (src, info->meta, info->metac)) { aktive_fail ("failed to read header: metad"); goto fail; }
    }
    TRY ("magic2", aktive_read_match (src, MAGIC2, sizeof (MAGIC2)-1));
    info->pix = Tcl_Tell (src);

    if (!header_esize (info, inmax, sizeof (MAGICLE))) goto fail;

    TRACE_RETURN ("(ok) %d", 1);
 fail:
    if (info->meta) ckfree (info->meta);
    TRACE_RETURN ("(fail) %d", 0);

#undef TRYF
}

int
aktive_aktive_le_header_get (char* inbytes, Tcl_Size inmax, aktive_aktive_header* info)
{
#define TRYF(field,cmd)							\
    if (!(cmd (inbytes, inmax, &pos, &info->field))) { aktive_fail ("failed to read header: " #field); goto fail; } \
    TRACE ("HEADER (" #field ") = %d", info->field)

    TRACE_FUNC("((byte*) %p [%d], (aktive_header*) %p)", inbytes, inmax, info);

    Tcl_Size pos = 0;

    TRY  ("magic",       aktive_get_match   (inbytes, inmax, &pos, MAGICLE, sizeof (MAGICLE)-1));
    TRY  ("version",     aktive_get_match   (inbytes, inmax, &pos, VERSION, sizeof (VERSION)-1));
    TRYF (domain.x,      aktive_get_int32le );
    TRYF (domain.y,      aktive_get_int32le );
    TRYF (domain.width,  aktive_get_uint32le);
    TRYF (domain.height, aktive_get_uint32le);
    TRYF (domain.depth,  aktive_get_uint32le);
    TRYF (metac,         aktive_get_uint32le);
    if (info->metac) {
	info->meta = NALLOC (char, info->metac);
	if (!aktive_get_string (inbytes, inmax, &pos, info->meta, info->metac)) {
	    aktive_fail ("failed to read header: metadata");
	    goto fail;
	}
    }
    TRY ("magic2", aktive_get_match (inbytes, inmax, &pos, MAGIC2, sizeof (MAGIC2)-1));
    info->pix = pos;

    if (!header_esize (info, inmax, sizeof (MAGICLE))) goto fail;

    TRACE_RETURN ("(ok) %d", 1);
 fail:
    if (info->meta) ckfree (info->meta);
    TRACE_RETURN ("(fail) %d", 0);

#undef TRYF
}

int
aktive_aktive_le_slice_read (Tcl_Channel src, aktive_aktive_header* info, aktive_uint x, aktive_uint y, aktive_uint n, double* rowbuf)
{
    TRACE_FUNC ("((Channel) %p, (header*) %p, x=%d, y=%d, double[%d] %p)",
		src, info, x, y, n, rowbuf);

    Tcl_Seek (src, slice_offset (info, x, y, n), SEEK_SET);
    int ok = aktive_read_float64le_n (src, n, rowbuf);

    TRACE_RETURN ("(ok?) %d", ok);
}

int
aktive_aktive_le_slice_get  (char* inbytes, aktive_aktive_header* info, aktive_uint x, aktive_uint y, aktive_uint n, double* rowbuf)
{
    TRACE_FUNC ("((byte*) %p, (header*) %p, x=%d, y=%d, double[%d] %p)",
		inbytes, info, x, y, n, rowbuf);

    Tcl_Size pos = slice_offset (info, x, y, n);
    int ok = aktive_get_float64le_n (inbytes, info->esize, &pos, n, rowbuf);

    TRACE_RETURN ("(ok?) %d", ok);
}

static int
header_esize (aktive_aktive_header* info, Tcl_Size inmax, Tcl_Size magicsize)
{
    TRACE_FUNC("((aktive_header*) %p)", info);

    TRACE_GEOMETRY (&info->domain);

    info->pitch = aktive_geometry_get_pitch (&info->domain);
    info->esize
	= (magicsize-1)                                             // 1st magic, BE or LE
	+ (sizeof (VERSION)-1)                                      // version
	+ 6 * sizeof(aktive_uint)                                   // x, y, w, h, d, meta size
	+ info->metac                                               // meta data
	+ (sizeof (MAGIC2)-1)                                       // 2nd magic
	+ aktive_geometry_get_size (&info->domain) * sizeof(double) // pixels
	;

    int ok = inmax == info->esize;

    TRACE ("pitch = %d (values)", info->pitch);
    TRACE ("size  = %d (bytes)", info->esize);

    if (!ok) aktive_failf ("bad size, expected %lld, got %lld", info->esize, inmax);

    TRACE_RETURN ("(size ok?) %d", ok);
}

static Tcl_WideInt
slice_offset (aktive_aktive_header* info, aktive_uint x, aktive_uint y, aktive_uint n)
{
    TRACE_FUNC("((header*) %p, x=%d, y=%d)", info, x, y);

    Tcl_WideInt offset = info->pix
	+ sizeof(double) * (  (y - info->domain.y) * info->pitch
			    + (x - info->domain.x) * info->domain.depth);

    ASSERT (offset                      >= info->pix,   "read before pixel data");
    ASSERT (offset + n * sizeof(double) <= info->esize, "read after end of data");

    TRACE_RETURN ("(offset) %d", offset);
}

/*
 * - - -- --- ----- -------- -------------
 ** Sink / Writer
 */

typedef struct aktive_aktive_control {
    // Processing configuration
    aktive_writer* writer;   // Destination for image data
    aktive_sink*   sink;     // Owning/owned sink

    // Processing state
    int x;
    int y;
    aktive_uint    size;      // Image size in pixels
    aktive_uint    written;   // #values written == size at end (in values, not bytes)
    aktive_uint    start;     // Byte offset where pixels start in the file
    aktive_uint    rowsize;   // Size of a row in bytes
    aktive_uint    pixsize;   // Size of a single pixel in bytes
} aktive_aktive_control;

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_aktive_control* aktive_be_header (aktive_aktive_control* info, aktive_image src);
static void                   aktive_be_pixels (aktive_aktive_control* info, aktive_block* src);
static aktive_aktive_control* aktive_le_header (aktive_aktive_control* info, aktive_image src);
static void                   aktive_le_pixels (aktive_aktive_control* info, aktive_block* src);
static void                   aktive_final     (aktive_aktive_control* info);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_sink*
aktive_aktive_be_sink (aktive_writer* writer)
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
    sink->setup      = (aktive_sink_setup)   aktive_be_header;
    sink->final      = (aktive_sink_final)   aktive_final;
    sink->process    = (aktive_sink_process) aktive_be_pixels;
    sink->sequential = 0;
    sink->state      = info;

    TRACE_RETURN ("(aktive_sink*) %p", sink);
}

extern aktive_sink*
aktive_aktive_le_sink (aktive_writer* writer)
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
    sink->setup      = (aktive_sink_setup)   aktive_le_header;
    sink->final      = (aktive_sink_final)   aktive_final;
    sink->process    = (aktive_sink_process) aktive_le_pixels;
    sink->sequential = 0;
    sink->state      = info;

    TRACE_RETURN ("(aktive_sink*) %p", sink);
}

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_aktive_control*
aktive_be_header (aktive_aktive_control* info, aktive_image src)
{
    TRACE_FUNC ("((aktive_aktive_control*) %p '%s', (aktive_image) %p '%s')",
		info, info->sink->name, src, aktive_image_get_type (src)->name);

    aktive_geometry* g = aktive_image_get_geometry (src);
    Tcl_Obj*         m = aktive_image_meta_get (src);
    Tcl_Size         msize = 0;
    char*            mdata = 0;
    int              start = 0;
    if (m) { mdata = Tcl_GetStringFromObj (m, &msize); start += msize; }	 /* OK tcl9 */

    TRACE ("magic",      0); aktive_write_here          (info->writer, MAGICBE, sizeof (MAGICBE)-1); start += sizeof (MAGICBE)-1;
    TRACE ("version",    0); aktive_write_here          (info->writer, VERSION, sizeof (VERSION)-1); start += sizeof (VERSION)-1;
    TRACE ("x location", 0); aktive_write_here_int32be  (info->writer, g->x);                        start += 4;
    TRACE ("y location", 0); aktive_write_here_int32be  (info->writer, g->y);                        start += 4;
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

    info->x = g->x;
    info->y = g->y;

    TRACE_RETURN ("(aktive_aktive_control*) %p", info);
}

static void
aktive_be_pixels (aktive_aktive_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_aktive_control*) %p '%s', written %d, getting (%p): %d)",
		info, info->sink->name, info->written, src, src->used);

    TRACE_DO (__aktive_block_dump (info->sink->name, src));

    TRACE ("pixel offset: %d", info->start);
    TRACE_POINT_M   ("src loc", &src->location);
    TRACE_GEOMETRY_M("src dom", &src->domain);

    // start offset of the block in the file
    // - note that we translate the logical location into a physical 0-based location first, before computing an offset.
    // - using explicit casts to the destination type ensures avoiding of overflows in intermediate values.
    Tcl_WideInt offset = ((Tcl_WideInt) info->start)
	+ ((Tcl_WideInt) info->rowsize) * ((Tcl_WideInt) (src->location.y - info->y))
	+ ((Tcl_WideInt) info->pixsize) * ((Tcl_WideInt) (src->location.x - info->x));

    TRACE ("location offset: %lld", offset);
    ASSERT (offset >= info->start, "Header smash");

    aktive_uint r, c, j;
    aktive_uint rowvalues = src->domain.width * src->domain.depth;

    // iterate over the rows of the block ...
    for (j = 0, r = 0; r < src->domain.height; r++, offset += ((Tcl_WideInt) info->rowsize)) {
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

static aktive_aktive_control*
aktive_le_header (aktive_aktive_control* info, aktive_image src)
{
    TRACE_FUNC ("((aktive_aktive_control*) %p '%s', (aktive_image) %p '%s')",
		info, info->sink->name, src, aktive_image_get_type (src)->name);

    aktive_geometry* g = aktive_image_get_geometry (src);
    Tcl_Obj*         m = aktive_image_meta_get (src);
    Tcl_Size         msize = 0;
    char*            mdata = 0;
    int              start = 0;
    if (m) { mdata = Tcl_GetStringFromObj (m, &msize); start += msize; }	 /* OK tcl9 */

    TRACE ("magic",      0); aktive_write_here          (info->writer, MAGICLE, sizeof (MAGICLE)-1); start += sizeof (MAGICLE)-1;
    TRACE ("version",    0); aktive_write_here          (info->writer, VERSION, sizeof (VERSION)-1); start += sizeof (VERSION)-1;
    TRACE ("x location", 0); aktive_write_here_int32le  (info->writer, g->x);                        start += 4;
    TRACE ("y location", 0); aktive_write_here_int32le  (info->writer, g->y);                        start += 4;
    TRACE ("width",      0); aktive_write_here_uint32le (info->writer, g->width);                    start += 4;
    TRACE ("height",     0); aktive_write_here_uint32le (info->writer, g->height);                   start += 4;
    TRACE ("depth",      0); aktive_write_here_uint32le (info->writer, g->depth);                    start += 4;
    TRACE ("meta size",  0); aktive_write_here_uint32le (info->writer, msize);                       start += 4;
    if (msize) {
	TRACE ("meta data", 0); aktive_write_here (info->writer, mdata, msize);
    }
    TRACE ("magic2",        0); aktive_write_here (info->writer, MAGIC2, sizeof (MAGIC2)-1);         start += sizeof (MAGIC2)-1;

    info->size    = aktive_geometry_get_size (g);
    info->written = 0;
    info->start   = start;
    info->pixsize = g->depth * sizeof (double);
    info->rowsize = g->width * info->pixsize;

    info->x = g->x;
    info->y = g->y;

    TRACE_RETURN ("(aktive_aktive_control*) %p", info);
}

static void
aktive_le_pixels (aktive_aktive_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_aktive_control*) %p '%s', written %d, getting (%p): %d)",
		info, info->sink->name, info->written, src, src->used);

    TRACE_DO (__aktive_block_dump (info->sink->name, src));

    TRACE ("pixel offset: %d", info->start);
    TRACE_POINT_M   ("src loc", &src->location);
    TRACE_GEOMETRY_M("src dom", &src->domain);

    // start offset of the block in the file
    // - note that we translate the logical location into a physical 0-based location first, before computing an offset.
    // - using explicit casts to the destination type ensures avoiding of overflows in intermediate values.
    Tcl_WideInt offset = ((Tcl_WideInt) info->start)
	+ ((Tcl_WideInt) info->rowsize) * ((Tcl_WideInt) (src->location.y - info->y))
	+ ((Tcl_WideInt) info->pixsize) * ((Tcl_WideInt) (src->location.x - info->x));

    TRACE ("location offset: %lld", offset);
    ASSERT (offset >= info->start, "Header smash");

    aktive_uint r, c, j;
    aktive_uint rowvalues = src->domain.width * src->domain.depth;

    // iterate over the rows of the block ...
    for (j = 0, r = 0; r < src->domain.height; r++, offset += ((Tcl_WideInt) info->rowsize)) {
	// seek to pixel location in the file, for the current row ...
	aktive_write_goto (info->writer, offset);

	// ... and write the elements of the row into place
	for (c = 0; c < rowvalues; c++, j++) {
	    aktive_write_here_float64le (info->writer, src->pixel [j]);
	    info->written ++;
	}
    }

    TRACE_RETURN_VOID;
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

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
