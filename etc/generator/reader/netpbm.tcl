## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Reader -- NetPBM formats -- Files and memory buffers (string)

# # ## ### ##### ######## ############# #####################
## PPM, PGM format

lappend supported netpbm

operator read::from::netpbm::string {

    section generator reader

    note Construct image from Tcl byte array value in one of the supported NetPBM formats.

    note Currently supported are PPM and PGM formats, in the binary byte and short \
	variants, as well as the text and extended text variants.

    note The PBM format is not supported.

    object value \
	Tcl value holding the NetPBM image data to read

    state -fields {
	aktive_netpbm_get_header header;
	aktive_veccache          rows;  // Row cache. Text formats only.
	char*                    bytes; // memory buffer holding the image
	Tcl_Size                 size;  // length of the above buffer, in bytes
    } -cleanup {
	// For the text modes the cache is at image-level. Release here as well.
	if (!state->header.base.binary) {
	    aktive_veccache_release (state->rows);
	}
    } -setup {
	// Read header

	Tcl_Size fsize;
	char* bytes  = Tcl_GetBytesFromObj (interp, param->value, &fsize);
	state->bytes = bytes;
	state->size  = fsize;

	if (!aktive_netpbm_header_get (bytes, fsize, &state->header)) {
	    aktive_fail ("failed to read netpbm header");
	}

	aktive_geometry_set (domain, 0, 0,
			     state->header.base.width,
			     state->header.base.height,
			     state->header.base.depth);

	const char* cspace = (state->header.base.depth == 1 ? "gray" : "sRGB");

	Tcl_Obj* netpbm = 0;
	aktive_meta_set_int    (&netpbm, "maxval", state->header.base.maxval);
	aktive_meta_set        (meta, "netpbm",     netpbm);
	aktive_meta_set_string (meta, "colorspace", cspace);

	if (!state->header.base.binary) {
	    state->rows = aktive_veccache_new (state->header.base.height,
					       state->header.base.width * state->header.base.depth,
					       state->header.base.base);
	}
    }

    pixels -state {
        char*                     pixels; // in-memory pixel buffer ATTENTION: access is READ-ONLY, thread shared
        Tcl_Size                  size;   // length of the pixel buffer, in bytes
	aktive_netpbm_get_header* info;   // quick access to netpbm information
	void*                     cache;  // TODO CACHE
    } -setup {
        state->pixels = istate->bytes;
        state->size   = istate->size;
	state->info   = &istate->header;

	// Cache management. For the binary modes the cache holds the raw data for a
	// single row, and is allocated by the reader function on first call.
	// For the text modes the image-level row cache is passed in instead.

	if (state->info->base.binary) {
	    state->cache = 0;
	} else {
	    state->cache = istate->rows;
	}
    } -cleanup {
	// For the binary modes the cache was allocated at pixel-level. Release here as well.
	if (state->info->base.binary && state->cache) { ckfree (state->cache); }
    } {
	aktive_uint stride = block->domain.depth;
	aktive_uint pitch  = block->domain.width * stride;

	aktive_uint srcy, dsty, row;
	aktive_uint sx   = request->x;
	aktive_uint dstx = dst->x * stride;
	aktive_uint dstpos;

	#define ITER_ROW \
	    for (srcy = request->y, dsty = dst->y, row = 0; \
	         row  < request->height; \
	         srcy ++, dsty ++, row ++)

	ITER_ROW {
	    dstpos = dsty * pitch + dstx;
	    state->info->getter (&state->cache, &state->info->base,
				 sx, srcy, request->width,
				 state->pixels, state->size,
				 block->pixel + dstpos);
	}
	#undef ITER_ROW
    }
}

operator read::from::netpbm::file {

    example {path tests/assets/sines.ppm}
    example {path tests/assets/crop.pgm}

    section generator reader

    note Construct image from file content in one of the NetPBM formats.

    note Currently supported are PPM and PGM formats, in the binary byte and short \
	variants, as well as the text and extended text variants.

    note The PBM format is not supported.

    object path \
	Path to file holding the NetPBM image data to read

    state -fields {
	aktive_netpbm_read_header header;
	aktive_path               path;	// Read-only copy of path.
	aktive_veccache           rows;	// Row cache. Text formats only.
    } -cleanup {
	aktive_path_free (&state->path);
	// For the text modes the cache is at image-level. Release here as well.
	if (!state->header.base.binary) {
	    aktive_veccache_release (state->rows);
	}
    } -setup {
	Tcl_Channel src = Tcl_FSOpenFileChannel (NULL, param->path, "r", 0);
	if (!src) aktive_failf ("failed to open path %s", Tcl_GetString (param->path));

	aktive_read_setup_binary (src);
	if (!aktive_netpbm_header_read (src, &state->header)) {
	    aktive_fail ("failed to read netpbm header");
	}
	Tcl_Close (NULL, src);

	aktive_geometry_set (domain, 0, 0,
			     state->header.base.width,
			     state->header.base.height,
			     state->header.base.depth);

	aktive_path_copy (&state->path, param->path);

	const char* cspace = (state->header.base.depth == 1 ? "gray" : "sRGB");

	Tcl_Obj* netpbm = 0;
	aktive_meta_set_int    (&netpbm, "maxval", state->header.base.maxval);
	aktive_meta_set        (meta, "netpbm",     netpbm);
	aktive_meta_set        (meta, "path",       param->path);
	aktive_meta_set_string (meta, "colorspace", cspace);

	if (!state->header.base.binary) {
	    state->rows = aktive_veccache_new (state->header.base.height,
					       state->header.base.width * state->header.base.depth,
					       state->header.base.base);
	}
    }

    pixels -state {
	Tcl_Channel                data;
	aktive_netpbm_read_header* info;	// quick access to netpbm information
	void*                      cache;	// TODO CACHE
    } -setup {
	// Each region has its own channel to the same file.
	// At OS level a separate file handle.
	// Concurrent access in threads without locking.
	//
	// WARE Breaks when the file at the path is deleted or moved between header read
	// WARE (see above), and first pixel access.

	state->data = aktive_path_open (&istate->path);
	if (!state->data) aktive_failf ("failed to open path %s", istate->path.string);
	aktive_read_setup_binary (state->data);

	state->info  = &istate->header;

	// Cache management. For the binary modes the cache holds the raw data for a
	// single row, and is allocated by the reader function on first call.
	// For the text modes the image-level row cache is passed in instead.

	if (state->info->base.binary) {
	    state->cache = 0;
	} else {
	    state->cache = istate->rows;
	}
    } -cleanup {
	if (state->data) Tcl_Close (NULL, state->data);
	// For the binary modes the cache was allocated at pixel-level. Release here as well.
	if (state->info->base.binary && state->cache) { ckfree (state->cache); }
    } {
	aktive_uint stride = block->domain.depth;
	aktive_uint pitch  = block->domain.width * stride;

	aktive_uint srcy, dsty, row;
	aktive_uint sx   = request->x;
	aktive_uint dstx = dst->x * stride;
	aktive_uint dstpos;

	#define ITER_ROW \
	    for (srcy = request->y, dsty = dst->y, row = 0; \
	         row  < request->height; \
	         srcy ++, dsty ++, row ++)

	ITER_ROW {
	    dstpos = dsty * pitch + dstx;
	    state->info->reader (&state->cache, &state->info->base,
				 sx, srcy, request->width,
				 state->data,
				 block->pixel + dstpos);
	}
	#undef ITER_ROW
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
