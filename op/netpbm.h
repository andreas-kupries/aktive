/* -*- c -*-
 *
 * -- Direct operator support - NETPBM support
 */
#ifndef AKTIVE_NETPBM_H
#define AKTIVE_NETPBM_H

#include <writer.h>
#include <sink.h>

/* - - -- --- ----- -------- -------------
 * Provision of a NETPBM sink
 *
 * Currently supports the PPM and PGM formats in text and binary sub types,
 * and byte/short scaling in each sub type, for a total of 8 related formats.
 *
 * | variant | maxval | format | coding | scaling |
 * |---      |---     |---     |---     |---      |
 * | 2       | <= 255 | PGM    | text   | byte    |
 * | 2       | > 255  | PGM    | text   | short   |
 * | 5       | <= 255 | PGM    | binary | byte    |
 * | 5       | > 255  | PGM    | binary | short   |
 * |---      |---     |---     |---     |---      |
 * | 3       | <= 255 | PPM    | text   | byte    |
 * | 3       | > 255  | PPM    | text   | short   |
 * | 6       | <= 255 | PPM    | binary | byte    |
 * | 6       | > 255  | PPM    | binary | short   |
 *
 * Note: maxval has to be less than 65536.
 */

extern aktive_sink*
aktive_netpbm_sink (aktive_writer* writer,
		    unsigned char  variant,
		    aktive_uint    maxvalue);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Base header structure holding the image information
 */

typedef struct aktive_netpbm_header {
    aktive_uint width;  // image width,  #columns
    aktive_uint height; // image height, #rows
    aktive_uint depth;  // image depth,  #bands
    aktive_uint maxval; // max allowed pixel value (< 256 => 8 bit, else 16 bit)
    aktive_uint base;   // offset to pixel data
    double      scale;  // 1/maxval, scaling to internal [0..1] range
    aktive_uint binary; // bool flag. set for the binary formats
} aktive_netpbm_header;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures and types for reading from a channel
 */

typedef void (*aktive_netpbm_reader) (void**                cache, // row cache, reader dependent
				      aktive_netpbm_header* info,  // offset of first pixel
				      aktive_uint           x,     // first requested column in row
				      aktive_uint           y,     // requested row
				      aktive_uint           w,     // number of columns to read
				      Tcl_Channel           chan,  // channel to read from
				      double*               v);    // destination, space for W columns

// Note the use of `columns` as the type for counting and space in the above.
// The PPM formats provide 3 values per column.

typedef struct aktive_netpbm_read_header {
    aktive_netpbm_header base;   // image information
    aktive_netpbm_reader reader; // pixel reader function
} aktive_netpbm_read_header;

extern int aktive_netpbm_header_read (Tcl_Channel src, aktive_netpbm_read_header* info);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures and types for getting from a byte array
 */

typedef void (*aktive_netpbm_getter) (void**                cache,   // row cache, reader dependent
				      aktive_netpbm_header* info,    // offset of first pixel
				      aktive_uint           x,       // first requested column in row
				      aktive_uint           y,       // requested row
				      aktive_uint           w,       // number of columns to read
				      char*                 inbytes, // byte array to get from,
				      Tcl_Size              inmax,   // and its length, in bytes
				      double*               v);      // destination, space for W columns

// Note the use of `columns` as the type for counting and space in the above.
// The PPM formats provide 3 values per column.

typedef struct aktive_netpbm_get_header {
    aktive_netpbm_header base;   // image information
    aktive_netpbm_getter getter; // pixel getter function
} aktive_netpbm_get_header;

extern int aktive_netpbm_header_get (char* inbytes, Tcl_Size inmax, aktive_netpbm_get_header* info);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_NETPBM_H */
