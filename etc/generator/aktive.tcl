## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Reading from somewhere

# # ## ### ##### ######## ############# #####################
## PPM, PGM format

operator read::from::aktive {

    object path \
	Path to file holding the AKTIVE image data to read

    state -fields {
	int         x;
	int         y;
	aktive_uint pix; // offset to first pixel value
	Tcl_Obj*    path;
    } -setup {
	Tcl_Channel src = Tcl_FSOpenFileChannel (NULL, param->path, "r", 0);
	if (!src) aktive_failf ("failed to open path %s", Tcl_GetString (param->path));

	// Read header
	aktive_read_setup_binary (src);

	#define MAGIC   "AKTIVE"
	#define MAGIC2  "AKTIVE_D"
	#define VERSION "00"

	#define SRC src
	#define TRY(m, cmd) if (!(cmd)) aktive_fail ("failed to read header:" m);
	int x, y;
	aktive_uint w, h, d, metac, pix;
	TRY ("magic",   aktive_read_match    (SRC, MAGIC, sizeof (MAGIC)-1));
	TRY ("version", aktive_read_match    (SRC, VERSION, sizeof (VERSION)-1));
	TRY ("x",       aktive_read_uint32be (SRC, &x));
	TRY ("y",       aktive_read_uint32be (SRC, &y));
	TRY ("w",       aktive_read_uint32be (SRC, &w));
	TRY ("h",       aktive_read_uint32be (SRC, &h));
	TRY ("d",       aktive_read_uint32be (SRC, &d));
	TRY ("metac",   aktive_read_uint32be (SRC, &metac));
	if (metac) Tcl_Seek (SRC, metac, SEEK_CUR);
	TRY ("magic2",  aktive_read_match    (SRC, MAGIC2, sizeof (MAGIC2)-1));
	pix = Tcl_Tell (SRC);

	Tcl_Close (NULL, src);

	state->pix  = pix;
	state->x    = x;
	state->y    = y;
	state->path = param->path; Tcl_IncrRefCount (state->path);

	#undef SRC
	#undef TRY

	aktive_geometry_set (domain, x, y, w, h, d);
    } -cleanup {
	Tcl_IncrRefCount (state->path);
    }

    pixels -state {
	Tcl_Channel data;
	int         x;
	int         y;
	aktive_uint pix;
    } -setup {
	// Each region has its own channel to the same file. At OS level a separate file handle.
	// Concurrent access in threads without locking
	//
	// WARE Breaks when the file at the path got deleted or moved between header read
	// WARE (see above), and pixel access.

	state->data = Tcl_FSOpenFileChannel (NULL, istate->path, "r", 0);
	if (!state->data) aktive_failf ("failed to open path %s", Tcl_GetString (istate->path));

	state->pix  = istate->pix;
	state->x    = istate->x;
	state->y    = istate->y;
    } -cleanup {
	if (state->data) Tcl_Close (NULL, state->data);
    } {
	// custom blit, seek to row start on each row
	// failure to read results in 0.0

	// idomain	image geometry
	// request	image area to get the pixels of
	// block.domain storage geometry (ignoring location)
	// dst		storage area to write the pixels to
	//
	// r.width      == dst.width  <= idomain.width  (Note: < possible)
	// r.height     == dst.height <= idomain.height (Note: < possible)
	// domain.depth == idomain.depth

	aktive_uint stride = block->domain.depth;
	aktive_uint pitch  = block->domain.width * stride;

	aktive_uint dstpos, dsty, dstx, dstz;
	aktive_uint srcpos, srcy, srcx;
	aktive_uint row, col, band;

	// Unoptimized loop nest to read pixel data and write to storage
	TRACE ("dy  dx  dz  | out | @@@ | val", 0);

	#define ITER_ROW  for (srcy = request->y - state->y, dsty = dst->y, row  = 0; row  < request->height; srcy ++, dsty ++, row ++)
	#define ITER_COL  for (srcx = request->x - state->x, dstx = dst->x, col  = 0; col  < request->width;  srcx ++, dstx ++, col ++)
	#define ITER_BAND for (                              dstz = 0,      band = 0; band < idomain->depth;           dstz ++, band ++)

	ITER_ROW {
	    Tcl_Seek (state->data, state->pix + sizeof(double) * (srcy * pitch + srcx * stride), SEEK_SET);
	    ITER_COL {
		ITER_BAND {
		    dstpos = dsty * pitch + dstx * stride + dstz;

		    Tcl_WideInt at = Tcl_Tell (state->data);

		    double value = 0.0;
		    (void) aktive_read_float64be (state->data, &value);

		    TRACE ("%3d %3d %3d | %3d | %3d | %.2f", dsty, dstx, dstz, dstpos, at, value);
		    ASSERT (dstpos < block->used, "read/write out of bounds");

		    block->pixel [dstpos] = value;
		}
	    }
	}

	#undef ITER_ROW
	#undef ITER_COL
	#undef ITER_BAND
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
