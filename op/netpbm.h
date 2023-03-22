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
 * Currently support PPM and PGM formats in text and binary sub types, and
 * byte/short scaling in each sub type, for a total of 8 related formats.
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
 */

typedef struct aktive_netpbm_header *aktive_netpbm_header_ptr;

typedef void (*aktive_netpbm_reader) (void**                   cache, // row cache, reader dependent
				      aktive_netpbm_header_ptr info,  // Offset of first pixel.
				      aktive_uint              x,     // First requested column in row.
				      aktive_uint              y,     // Requested row.
				      aktive_uint              w,     // Number ofcolumns to read.
				      Tcl_Channel              chan,  // Channel to read from.
				      double*                  v);    // Destination, space for W columns.

// Note the use of `columns` for counting and space in the above.
// The PPM formats provide 3 values per column.

typedef struct aktive_netpbm_header {
    aktive_uint          width;
    aktive_uint          height;
    aktive_uint          depth;
    aktive_uint          maxval;
    aktive_uint          base;
    aktive_netpbm_reader reader;
    double               scale;
} aktive_netpbm_header;

extern int aktive_netpbm_read_header (Tcl_Channel src, aktive_netpbm_header* info);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_NETPBM_H */
