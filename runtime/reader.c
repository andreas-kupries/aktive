/* -*- c -*-
 */

#include <math.h>
#include <string.h>
#include <reader.h>
#include <swap.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_read_setup_binary (Tcl_Channel src) {
    Tcl_SetChannelOption (NULL, src, "-encoding",    "binary");
    Tcl_SetChannelOption (NULL, src, "-translation", "binary");
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_read_string (Tcl_Channel src, char* buf, aktive_uint n)
{
    Tcl_WideInt mark = Tcl_Tell (src);
    int         got  = Tcl_Read (src, buf, n);
    if (got < n) {
	if (mark >= 0) { (void) Tcl_Seek (src, mark, SEEK_SET); }
	return 0;
    }
    return 1;
}

extern int
aktive_read_match (Tcl_Channel src, char* pattern, aktive_uint n)
{
    Tcl_WideInt mark = Tcl_Tell (src);
    char* buf = NALLOC(char, n);
    int ok = aktive_read_string (src, buf, n);
    if (ok) {
	ok = 0 == strncmp (pattern, buf, n);
	if (!ok && (mark >= 0)) {
	    (void) Tcl_Seek (src, mark, SEEK_SET);
	}
    }
    ckfree (buf);
    return ok;
}

extern int
aktive_read_uint8 (Tcl_Channel src, aktive_uint* v)
{
    char buf [1];
    int ok = aktive_read_string (src, buf, 1);
    if (ok) {
	*v = buf[0];
    }
    return ok;
}

extern int
aktive_read_uint16be (Tcl_Channel src, aktive_uint* v)
{
    char buf [2];
    int ok = aktive_read_string (src, buf, 2);
    if (ok) {
	*v =  (buf [0] << 8)
	    | (buf [1]     );
    }
    return ok;
}

extern int
aktive_read_uint32be (Tcl_Channel src, aktive_uint* v)
{
    char buf [4];
    int ok = aktive_read_string (src, buf, 4);
    if (ok) {
	*v =  (buf [0] << 24)
	    | (buf [1] << 16)
	    | (buf [2] <<  8)
	    | (buf [3]      );
    }
    return ok;
}

extern int
aktive_read_uint64be (Tcl_Channel src, Tcl_WideInt* v)
{
    char buf [8];
    int ok = aktive_read_string (src, buf, 8);
    if (ok) {
	*v =  (((Tcl_WideInt) buf [0]) << 56)
	    | (((Tcl_WideInt) buf [1]) << 48)
	    | (((Tcl_WideInt) buf [2]) << 40)
	    | (((Tcl_WideInt) buf [3]) << 32)
	    | (((Tcl_WideInt) buf [4]) << 24)
	    | (((Tcl_WideInt) buf [5]) << 16)
	    | (((Tcl_WideInt) buf [6]) <<  8)
	    | (((Tcl_WideInt) buf [7])      );
    }
    return ok;
}

extern int
aktive_read_float64be (Tcl_Channel src, double* v)
{
    union {
	double        v;
	unsigned char buf [sizeof(double)];
    } cast;

    int ok = aktive_read_string (src, cast.buf, sizeof(double));
    if (ok) {
	SWAP64 (cast.v);
	*v = cast.v;
    }
    return ok;
}


/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
