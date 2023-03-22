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
	Tcl_Obj*             ppath;	// param reference, to unlink at final unref
	Tcl_Obj*             path;	// param image copy
    } -cleanup {
	// Remove our copy and our hold on the parameter
	Tcl_DecrRefCount (state->path);
	Tcl_DecrRefCount (state->ppath);
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

	// BEWARE :: hold the Tcl_Obj* reference. Required, needed for when querying the params.
	// TODO   :: build this kind of init/finish into the generator ... see handling of vectors.
	state->ppath = param->path;
	Tcl_IncrRefCount (param->path);

	// Create local copy of the object for regions to access, from other threads.
	//
	// With the param->path we cannot guarantuee that there will not be any changes
	// made by the main thread (int rep conversions, etc) breaking us. Even if not
	// done concurrently. The local copy will be ours, and read-only (no shimmering).

	state->path = Tcl_DuplicateObj (param->path); Tcl_IncrRefCount (state->path);
	(void) Tcl_GetString (state->path);
    }

    pixels -state {
	Tcl_Channel           data;
	aktive_netpbm_header* info;	// quick access to netpbm information
	void*                 cache;	// TODO CACHE
    } -setup {
	// Each region has its own channel to the same file. At OS level a separate file handle.
	// Concurrent access in threads without locking
	//
	// WARE Breaks when the file at the path got deleted or moved between header read
	// WARE (see above), and pixel access.

	state->data = Tcl_FSOpenFileChannel (NULL, istate->path, "r", 0);
	if (!state->data) aktive_failf ("failed to open path %s", Tcl_GetString (istate->path));

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
