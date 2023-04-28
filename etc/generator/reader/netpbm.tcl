## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Reading from somewhere

# # ## ### ##### ######## ############# #####################
## PPM, PGM format

operator read::from::netpbm {

    section generator reader

    note Construct image from file content in one of the NetPBM formats.

    # currently supported: PPM, PGM, for byte|short|text|etext
    # not supported yet: PBM (bit format).

    object path \
	Path to file holding the NetPBM image data to read

    state -fields {
	aktive_netpbm_header header;
	aktive_path          path;	// Read-only copy of path.
    } -cleanup {
	aktive_path_free (&state->path);
    } -setup {
	Tcl_Channel src = Tcl_FSOpenFileChannel (NULL, param->path, "r", 0);
	if (!src) aktive_failf ("failed to open path %s", Tcl_GetString (param->path));

	aktive_read_setup_binary (src);
	if (!aktive_netpbm_read_header (src, &state->header)) {
	    aktive_fail ("failed to read netpbm header");
	}
	Tcl_Close (NULL, src);

	aktive_geometry_set (domain, 0, 0,
			     state->header.width,
			     state->header.height,
			     state->header.depth);

	aktive_path_copy (&state->path, param->path);

	const char* cspace = (state->header.depth == 1 ? "gray" : "sRGB");

	Tcl_Obj* netpbm = 0;
	aktive_meta_set_int    (&netpbm, "maxval", state->header.maxval);
	aktive_meta_set        (meta, "netpbm", netpbm);
	aktive_meta_set_string (meta, "colorspace", cspace);
    }

    pixels -state {
	Tcl_Channel           data;
	aktive_netpbm_header* info;	// quick access to netpbm information
	void*                 cache;	// TODO CACHE
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
	state->cache = 0;
	// NOTE: cache init is done by reader function

    } -cleanup {
	if (state->data) Tcl_Close (NULL, state->data);
	if (state->cache) ckfree (state->cache);
	// TODO cache cleanup -- proper -- TODO cache structures and API
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
	    state->info->reader (&state->cache, state->info,
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
