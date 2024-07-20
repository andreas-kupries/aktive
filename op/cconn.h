/* -*- c -*-
 *
 * -- Direct operator support - Connected components
 */
#ifndef AKTIVE_CCONN_H
#define AKTIVE_CCONN_H

/* - - -- --- ----- -------- -------------
 * Data structures describing the set of connected components
 * for an image, or part of it.
 *
 *      /- .... ->\
 * block -> cc ... cc <| (next)
 *   / \
 *  /   row -> run ... run <| (row_next)
 *  .   .
 *  \-> row -> run ... run <| (row_next)
 *      ^
 *      -
 *      (next)
 *
 *  cc -> run ... run <| (cc_next)
 *
 * Not shown above: ownership back-links from run to cc, and cc to block.
 *
 * - The `block` is the main structure.
 *
 * - A block links to a set of `row`s, ordered from smallest to largest index,
 *   without gaps.
 *
 * - Each `row` links to a set of `run`s.
 *
 * - Each `run` describes a component range in the containing `row`.
 *
 * - A block further links to a set of `cc`s, the actual connected components
 *   found in the row-set of the block.
 *
 * - Each `cc` links to the set of `runs` which build it.
 *
 * - The `run`s link back to their owning `cc`.
 *
 * - The `cc`s link back to their owning `block`.
 */

typedef struct aktive_cc*       aktive_cc_ptr;
typedef struct aktive_cc_row*   aktive_cc_row_ptr;
typedef struct aktive_cc_run*   aktive_cc_run_ptr;
typedef struct aktive_cc_block* aktive_cc_block_ptr;

A_STRUCTURE(aktive_cc_run) {
    A_FIELD (aktive_uint,       y)        ; // Run row index
    A_FIELD (aktive_uint,       xmin)     ; // Run start
    A_FIELD (aktive_uint,       xmax)     ; // Run end
    A_FIELD (aktive_cc_ptr,     owner)    ; // CC containing the run
    A_FIELD (aktive_cc_run_ptr, row_next) ; // Next run in same row
    A_FIELD (aktive_cc_run_ptr, cc_next)  ; // Next run in same CC
} A_END (aktive_cc_run);

A_STRUCTURE(aktive_cc_row) {
    A_FIELD (aktive_uint,       y)     ; // Row index
    A_FIELD (aktive_cc_run_ptr, first) ; // First run in this row
    A_FIELD (aktive_cc_run_ptr, last)  ; // Last run in this row
    A_FIELD (aktive_cc_row_ptr, next)  ; // Next row
} A_END (aktive_cc_row);

A_STRUCTURE(aktive_cc) {
    A_FIELD (aktive_uint,         xmin)  ; // Bounding box
    A_FIELD (aktive_uint,         xmax)  ; //   ditto
    A_FIELD (aktive_uint,         ymin)  ; //   ditto
    A_FIELD (aktive_uint,         ymax)  ; //   ditto
    A_FIELD (aktive_uint,         area)  ; // Area in pixels
    A_FIELD (aktive_cc_run_ptr,   first) ; // First run in this CC
    A_FIELD (aktive_cc_run_ptr,   last)  ; // Last run in this CC
    A_FIELD (aktive_cc_ptr,       prev)  ; // Previous CC in block
    A_FIELD (aktive_cc_ptr,       next)  ; // Next CC in block
    A_FIELD (aktive_cc_block_ptr, owner) ; // Block containing the CC
} A_END (aktive_cc);

A_STRUCTURE(aktive_cc_block) {
    A_FIELD (aktive_uint,       ymin)      ; // Bounding row
    A_FIELD (aktive_uint,       ymax)      ; //  ditto
    A_FIELD (aktive_cc_row_ptr, row_first) ; // First row in block
    A_FIELD (aktive_cc_row_ptr, row_last)  ; // Last row in block
    A_FIELD (aktive_cc_ptr,     cc_first)  ; // First CC in block
    A_FIELD (aktive_cc_ptr,     cc_last)   ; // Last CC in block
} A_END (aktive_cc_block);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_cc_block* aktive_cc_find          (aktive_image src);
extern Tcl_Obj*         aktive_cc_as_tcl_dict   (Tcl_Interp* ip, aktive_cc_block* block);
extern void             aktive_cc_release_block (aktive_cc_block* block);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_CCONN_H */
