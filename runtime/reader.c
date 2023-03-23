/* -*- c -*-
 */

#include <math.h>
#include <ctype.h>
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
    TRACE_FUNC ("((Channel) %p, (char*) %p [%d])", src, buf, n);

    Tcl_WideInt mark = Tcl_Tell (src);
    int         got  = Tcl_Read (src, buf, n);

    TRACE ("got %d, mark %d", got, mark);
    if (got < n) {
	if (mark >= 0) { (void) Tcl_Seek (src, mark, SEEK_SET); }
	TRACE_RETURN ("(Fail) %d", 0);
    }
    TRACE_RETURN ("(OK) %d", 1);
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
aktive_read_uint_str (Tcl_Channel src, aktive_uint* v)
{
    TRACE_FUNC ("((Channel) %p, (aktive_uint*) %p)", src, v);

    aktive_uint vl = 0;
    aktive_uint mode = 0;
    char buf [2] = { 0, 0 };
    aktive_uint run = 1;

    while (run) {
	if (!aktive_read_string (src, buf, 1)) { TRACE_RETURN ("(FAIL eof) %d", 0); }
	TRACE ("read/%d = (%d) = '%c' ws=%d", mode, (int) *buf, *buf, isspace (*buf));

	switch (mode) {
	case 0:	// skip leading whitespace, if any
	    if (isspace (*buf)) continue;
	    // not whitespace, number start
	    mode ++;
	    goto digit;
	case 1:	// process digits
	    // post number whitespace - back skipping
	    if (isspace (*buf)) { mode ++ ; continue; }
	    // non-digit - syntax error - fail
	    if ((*buf < '0') || (*buf > '9')) { TRACE_RETURN ("(FAIL not digit) %d", 0); }
	digit:
	    // accumulate digit
	    vl = 10*vl + (*buf - '0');
	    TRACE ("number = %d", vl);
	    continue;
	case 2: // skip trailing whitespace
	    if (isspace (*buf)) continue;
	    // end of whitespace, rewind for next call
	    Tcl_Seek(src, -1, SEEK_CUR);
	    run --;
	    break;
	}
    }

    *v = vl;
    TRACE ("read number = %d", vl);
    TRACE_RETURN ("(OK) %d", 1);
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
	uint64_t      vi;
	unsigned char buf [sizeof(double)];
    } cast;

    int ok = aktive_read_string (src, cast.buf, sizeof(double));
    if (ok) {
	cast.vi = SWAP64 (cast.vi);
	*v = cast.v;
    }
    return ok;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_path_copy (aktive_path* dst, Tcl_Obj* src)
{
    int len;
    char* path = Tcl_GetStringFromObj (src, &len);

    dst->length = len;
    STRDUP (dst->string, path);
}

extern void
aktive_path_free (aktive_path* dst)
{
    ckfree (dst->string);
    dst->string = 0;
    dst->length = 0;
}

extern Tcl_Channel
aktive_path_open (aktive_path* dst)
{
    Tcl_Obj*    path = Tcl_NewStringObj (dst->string, dst->length);
    Tcl_IncrRefCount (path);
    Tcl_Channel src  = Tcl_FSOpenFileChannel (NULL, path, "r", 0);
    Tcl_DecrRefCount (path);
    return src;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
