/* -*- c -*-
 *
 * -- Direct operator support - AKTIVE format support
 */
#ifndef AKTIVE_AKTIVE_H
#define AKTIVE_AKTIVE_H

#include <writer.h>
#include <geometry.h>
#include <sink.h>

/* - - -- --- ----- -------- -------------
 * Provision of an AKTIVE sink
 */

extern aktive_sink*
aktive_aktive_sink (aktive_writer* writer);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Header structure holding the image metadata, plus read/get functions
 */

typedef struct aktive_aktive_header {
    aktive_geometry domain; // position and dimensions
    aktive_uint     pitch;  // pitch = width * depth = values in a row, stride between rows
    aktive_uint     metac;  // size of the meta data string
    char*           meta;   // image meta data, Tcl dictionary as string
    Tcl_WideInt     pix;    // offset to pixel buffer
    Tcl_WideInt     esize;  // expected size of the image data, header and pixels
    //                      // this is also the max offset
} aktive_aktive_header;

extern int aktive_aktive_header_read (Tcl_Channel src, Tcl_Size inmax, aktive_aktive_header* info);
extern int aktive_aktive_header_get  (char* inbytes,   Tcl_Size inmax, aktive_aktive_header* info);

extern int aktive_aktive_slice_read (Tcl_Channel src, aktive_aktive_header* info, aktive_uint x, aktive_uint y, aktive_uint n, double* rowbuf);
extern int aktive_aktive_slice_get  (char* inbytes,   aktive_aktive_header* info, aktive_uint x, aktive_uint y, aktive_uint n, double* rowbuf);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_AKTIVE_H */
