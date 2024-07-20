## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- File Reader - AKTIVE format

# # ## ### ##### ######## ############# #####################
## PPM, PGM format

operator read::from::aktive {

    example -post {times 8} {path tests/assets/results/format-colorbox.aktive}
    example -post {times 8} {path tests/assets/results/format-graybox.aktive}

    section generator reader

    note Construct image from file content in the native AKTIVE format.

    object path \
	Path to file holding the AKTIVE image data to read

    state -fields {
	int         x;
	int         y;
	aktive_uint pix;	// offset to first pixel value
	aktive_path path;	// Read-only copy of path.
    } -cleanup {
	aktive_path_free (&state->path);
    } -setup {
	Tcl_Channel src = Tcl_FSOpenFileChannel (NULL, param->path, "r", 0);
	if (!src) aktive_failf ("failed to open path %s", Tcl_GetString (param->path));

	// Determine file size
	Tcl_Seek (src, 0, SEEK_END);
	Tcl_WideInt fsize = Tcl_Tell (src);
	Tcl_Seek (src, 0, SEEK_SET);

	// Read header
	aktive_read_setup_binary (src);

	#define MAGIC   "AKTIVE"
	#define MAGIC2  "AKTIVE_D"
	#define VERSION "00"

	#define TRY(m, cmd) if (!(cmd)) aktive_fail ("failed to read header: " m);
	int x, y;
	aktive_uint w, h, d, metac, pix;
	TRY ("magic",   aktive_read_match    (src, MAGIC, sizeof (MAGIC)-1));
	TRY ("version", aktive_read_match    (src, VERSION, sizeof (VERSION)-1));
	TRY ("x",       aktive_read_int32be  (src, &x));
	TRY ("y",       aktive_read_int32be  (src, &y));
	TRY ("w",       aktive_read_uint32be (src, &w));
	TRY ("h",       aktive_read_uint32be (src, &h));
	TRY ("d",       aktive_read_uint32be (src, &d));
	TRY ("metac",   aktive_read_uint32be (src, &metac));
	if (metac) {
	    char* buf = NALLOC (char, metac);
	    if (!aktive_read_string (src, buf, metac)) {
		ckfree (buf);
		aktive_fail ("failed to read header: metad");
	    }
	    *meta = Tcl_NewStringObj (buf, metac);
	    ckfree (buf);
	}
	TRY ("magic2",  aktive_read_match    (src, MAGIC2, sizeof (MAGIC2)-1));
	pix = Tcl_Tell (src);
	#undef TRY

	Tcl_Close (NULL, src);

	// Check found versus expected file size
	Tcl_WideInt esize = (sizeof (MAGIC)-1)         // 1st magic
	                  + (sizeof (VERSION)-1)       // version
			  + 6 * 4                      // x, y, w, h, d, meta size
			  + metac                      // meta data
	                  + (sizeof (MAGIC2)-1)        // 2nd magic
                          + w * h * d * sizeof(double) // pixels
                          ;
        if (esize != fsize) aktive_failf ("bad size, expected %lld, got %lld", esize, fsize);

	state->pix  = pix;
	state->x    = x;
	state->y    = y;

	aktive_meta_set  (meta, "path",   param->path);

	aktive_path_copy (&state->path, param->path);

	aktive_geometry_set (domain, x, y, w, h, d);
    }

    pixels -state {
	Tcl_Channel data;
	int         x;
	int         y;
	aktive_uint pix;
    } -setup {
	// Each region has its own channel to the same file.
	// At OS level a separate file handle.
	// Concurrent access in threads without locking,
	//
	// WARE Breaks when the file at the path is deleted or moved between header read
	// WARE (see above), and first pixel access.

	state->data = aktive_path_open (&istate->path);
	if (!state->data) aktive_failf ("failed to open path %s", istate->path.string);

	aktive_read_setup_binary (state->data);

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

	// Translate logical request location to physical 0-based location into the pixel block
	aktive_uint sy = request->y - state->y;
	aktive_uint sx = request->x - state->x;

	// Unoptimized loop nest to read pixel data and write to storage
	TRACE ("dy  dx  dz  | out | @@@ | val", 0);

	#define ITER_ROW  for (srcy = sy, dsty = dst->y, row  = 0; row  < request->height; srcy ++, dsty ++, row ++)
	#define ITER_COL  for (srcx = sx, dstx = dst->x, col  = 0; col  < request->width;  srcx ++, dstx ++, col ++)
	#define ITER_BAND for (           dstz = 0,      band = 0; band < idomain->depth;           dstz ++, band ++)

	ITER_ROW {
	    Tcl_WideInt rowat = state->pix + sizeof(double) * (srcy * pitch + sx * stride);
	    TRACE ("%3d %3d     |     | %3lld | off %d %d %d", srcy, sx, rowat, state->pix, pitch, stride);
	    ASSERT (rowat >= state->pix, "read before pixel data");

	    Tcl_Seek (state->data, rowat, SEEK_SET);
	    ITER_COL {
		ITER_BAND {
		    dstpos = dsty * pitch + dstx * stride + dstz;

		    Tcl_WideInt at = Tcl_Tell (state->data);
		    ASSERT (at >= 0, "read before channel");

		    double value = 0.0;
		    (void) aktive_read_float64be (state->data, &value);

		    TRACE ("%3d %3d %3d | %3d | %3lld | %.2f", dsty, dstx, dstz, dstpos, at, value);
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
