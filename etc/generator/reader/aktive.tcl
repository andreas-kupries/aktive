## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Reader -- AKTIVE format -- Files and memory buffers (string)

# # ## ### ##### ######## ############# #####################
## AKTIVE format

operator {endian dendian} {
    read::from::aktive::string    le /LE
    read::from::aktive-be::string be /BE
} {
    section generator reader

    note Construct image from a Tcl byte array value in the native AKTIVE$dendian format.

    object value \
	Tcl value holding the AKTIVE${dendian} image data to read

    state -fields {
	aktive_aktive_header info;	// image header
	char*                bytes;	// memory buffer holding the image
    } -setup {
	// Determine "file" size
	Tcl_Size fsize;
	char* bytes  = Tcl_GetBytesFromObj (interp, param->value, &fsize);
	state->bytes = bytes;

	// Read header
	int ok = aktive_aktive_@@endian@@_header_get (bytes, fsize, &state->info);
	if (!ok) { __afdone; }

	*meta = Tcl_NewStringObj (state->info.meta, state->info.metac);

	aktive_geometry_copy (domain, &state->info.domain);
    }

    pixels -state {
	aktive_aktive_header* info;  // image header
	char*                 bytes; //
    } -setup {
	state->info  = &istate->info;
	state->bytes = istate->bytes;
    } {
        // custom blit, position to row start on each row
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

	aktive_uint row, dsty;
	aktive_uint           n      = request->width * stride;
	char*                 bytes  = state->bytes;
	aktive_aktive_header* header = state->info;
	aktive_uint           rx     = request->x;
	aktive_uint           ry     = request->y;
	aktive_uint           dbase  = dst->x * stride;

	#define ITER for (dsty = dst->y, row = 0; row < request->height; dsty ++, row ++, ry ++)
	ITER {
	    aktive_uint dstpos = dbase + dsty * pitch;
	    (void) aktive_aktive_@@endian@@_slice_get (bytes, header, rx, ry, n, block->pixel + dstpos);
	}
	#undef ITER
    }
}

operator {endian dendian suffix} {
    read::from::aktive::file    le /LE {}
    read::from::aktive-be::file be /BE -be
} {
    example "path tests/assets/results/format-colorbox.aktive$suffix | times 8"
    example "path tests/assets/results/format-graybox.aktive$suffix  | times 8"

    section generator reader

    note Construct image from file content in the native AKTIVE$dendian format.

    object path \
	Path to file holding the AKTIVE$dendian image data to read

    state -fields {
	aktive_aktive_header info;	// image header
	aktive_path          path;	// Read-only copy of path.
    } -cleanup {
	aktive_path_free (&state->path);
	if (state->info.meta) ckfree (state->info.meta); // TODO hide in a header release function
    } -setup {
	Tcl_Channel src = Tcl_FSOpenFileChannel (NULL, param->path, "r", 0);
	if (!src) aktive_failf ("failed to open path %s", Tcl_GetString (param->path));

	// Determine file size
	Tcl_Seek (src, 0, SEEK_END);
	Tcl_WideInt fsize = Tcl_Tell (src);
	Tcl_Seek (src, 0, SEEK_SET);

	// Read header
	aktive_read_setup_binary (src);

	int ok = aktive_aktive_@@endian@@_header_read (src, fsize, &state->info);
	Tcl_Close (NULL, src);
	if (!ok) { __afdone; }

	*meta = Tcl_NewStringObj (state->info.meta, state->info.metac);

	aktive_meta_set  (meta, "path", param->path);
	aktive_path_copy (&state->path, param->path);

	aktive_geometry_copy (domain, &state->info.domain);
    }

    pixels -state {
	Tcl_Channel           data;
	aktive_aktive_header* info; // image header
    } -setup {
	// Each region has its own channel to the same file.
	// At the OS level this is a separate file handle.
	// With a separate seek location.
	// Enables concurrent access by multiple threads without locking
	//
	// WARE Breaks when the file at the path is deleted or moved between header read
	// WARE (see above), and first pixel access.
	//
	// Look into memory mapping

	state->data = aktive_path_open (&istate->path);
	if (!state->data) aktive_failf ("failed to open path %s", istate->path.string);

	aktive_read_setup_binary (state->data);
	state->info = &istate->info;
    } -cleanup {
	if (state->data) Tcl_Close (NULL, state->data);
    } {
	// custom blit, seek to row start on each row
	// failure to read results in zeroes

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

	aktive_uint row, dsty;
	aktive_uint           n      = request->width * stride;
	aktive_aktive_header* header = state->info;
	aktive_uint           rx     = request->x;
	aktive_uint           ry     = request->y;
	Tcl_Channel           src    = state->data;
	aktive_uint           dbase  = dst->x * stride;

	#define ITER for (dsty = dst->y, row = 0; row < request->height; dsty ++, row ++, ry ++)
	ITER {
	    aktive_uint dstpos = dbase + dsty * pitch;
	    (void) aktive_aktive_@@endian@@_slice_read (src, header, rx, ry, n, block->pixel + dstpos);
	}
	#undef ITER
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
