/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Sinks, types and methods
 *
 * Sinks are active elements computing information about the input images,
 * possibly materializing it.
 *
 * An obvious use is writing the image to a file, socket, memory block, etc.
 * Computing statistical data, histograms, etc. are also uses for sinks.
 */
#ifndef AKTIVE_SINK_H
#define AKTIVE_SINK_H

/*
 * - - -- --- ----- -------- -------------
 *
 * Initialization - Create sink state based on image and user data
 * Processing     - Process pixels, update sink state, and/or user data
 * Finalization   - destroy sink state, final update of user data (sink result)
 */

typedef void* (*aktive_sink_setup)   (aktive_image src, void* userstate);
typedef void  (*aktive_sink_process) (void* state, aktive_block* src);
typedef void  (*aktive_sink_final)   (void* state);

typedef struct aktive_sink {
    char*               name    ; // Identification
    aktive_sink_setup   setup   ; // Sink initialization
    aktive_sink_process process ; // Sink pixel processing
    aktive_sink_final   final   ; // Sink finalization
    void*               state   ; // User state
} aktive_sink;

/*
 * - - -- --- ----- -------- -------------
 */

extern void aktive_sink_run (aktive_sink* sink, aktive_image src);

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_SINK_H */
