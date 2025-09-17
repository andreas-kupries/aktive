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
 * _str functions, state space.
 *
 */

static char* hmode[3] = {"leader","digits","trails"};

#define LEADER (0)
#define DIGITS (1)
#define TRAILS (2)

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_read_setup_binary (Tcl_Channel src) {
    TRACE_FUNC ("((Channel) %p)", src);

    Tcl_SetChannelOption (NULL, src, "-encoding",    "binary");
    Tcl_SetChannelOption (NULL, src, "-translation", "binary");

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_read_string (Tcl_Channel src, char* buf, aktive_uint n)
{
    TRACE_FUNC ("((Channel) %p, (char*) %p [%d])", src, buf, n);

    Tcl_WideInt mark = Tcl_Tell (src);
    Tcl_Size    got  = Tcl_Read (src, buf, n);	 /* OK tcl9 */

    TRACE ("got " TCL_SIZE_FMT ", mark %d", got, mark);
    if (got < n) {
	if (mark >= 0) { (void) Tcl_Seek (src, mark, SEEK_SET); }
	TRACE_RETURN ("(Fail) %d", 0);
    }

    TRACE_HEADER(1);TRACE_ADD ("read = {", 0);
    for (int k=0;k<n;k++) { TRACE_ADD(" %u", ((aktive_uint) buf[k]) & 0xFF); }
    TRACE_ADD (" }", 0);TRACE_CLOSER;

    TRACE_HEADER(1);TRACE_ADD ("read = {", 0);
    for (int k=0;k<n;k++) { TRACE_ADD(" '%c'", (char) buf[k]); }
    TRACE_ADD (" }", 0);TRACE_CLOSER;

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

    aktive_uint vl   = 0;		// Number buffer
    aktive_uint mode = LEADER;		// DFA state
    aktive_uint run  = 1;		// Flag: Continue
    char        buf [2] = { 0, 0 };	// Character buffer

    // Deterministic finite automaton
    // State  Input  To     Action           Notes
    // -----  -----  --     ------           -----------------------
    // LEADER space  LEADER -                Skip leading whitespace
    //        !digit FAIL                    Begin number accumulation
    //        digit  DIGITS accumulate digit
    // DIGITS space  TRAILS -                Accumulate Number
    //        !digit FAIL
    //        digit  DIGITS accumulate digit
    // TRAILS space  TRAILS -                Skip trailing whitespace
    //        !space STOP   rewind, return

    while (run) {
	if (!aktive_read_string (src, buf, 1)) {
	    // EOF reached
	    if (mode > LEADER) {
		// Managed to read at least one digit. This is the number
		*v = vl;
		TRACE ("read number = %d", vl);
		TRACE_RETURN ("(OK) %d", 1);
	    }
	    TRACE_RETURN ("(FAIL eof) %d", 0);
	}
	TRACE ("read/%s = (%d) = '%c' ws=%d", hmode[mode], (int) *buf, *buf, isspace (*buf));

	switch (mode) {
	case LEADER:	// skip leading whitespace, if any
	    if (isspace (*buf)) continue;
	    // not whitespace, possible number start
	    mode = DIGITS;
	    goto digit;
	case DIGITS:	// process digits
	    // post number whitespace - back skipping
	    if (isspace (*buf)) { mode = TRAILS ; continue; }
	digit:
	    // non-digit - syntax error - fail
	    if ((*buf < '0') || (*buf > '9')) { TRACE_RETURN ("(FAIL not digit) %d", 0); }
	    // accumulate digit
	    vl = 10*vl + (*buf - '0');
	    TRACE ("number = %d", vl);
	    continue;
	case TRAILS: // skip trailing whitespace
	    if (isspace (*buf)) continue;
	    // end of whitespace, rewind for next call
	    Tcl_Seek(src, -1, SEEK_CUR);
	    run = 0;
	    break;
	}
    }

    *v = vl;
    TRACE ("read number = %d", vl);
    TRACE_RETURN ("(OK) %d", 1);
}

extern int
aktive_read_uint_strsharp (Tcl_Channel src, aktive_uint* v)
{
    // This uint string reader differs from uint_str in that it stops at the
    // first trailing whitespace it sees. This is necessary for the NetPBM
    // binary formats. The maxval value ending their header ends in \n
    // immediately followed by the pixel data. This cannot be treated as more
    // white space.

    TRACE_FUNC ("((Channel) %p, (aktive_uint*) %p)", src, v);

    aktive_uint vl   = 0;		// Number buffer
    aktive_uint mode = LEADER;		// DFA state
    aktive_uint run  = 1;		// Flag: Continue
    char        buf [2] = { 0, 0 };	// Character buffer

    // Deterministic finite automaton
    // State  Input  To     Action           Notes
    // -----  -----  --     ------           -----------------------
    // LEADER space  LEADER -                Skip leading whitespace
    //        !digit FAIL                    Begin number accumulation
    //        digit  DIGITS accumulate digit
    // DIGITS space  STOP   -                Cannot have general trailing whitespace
    //        !digit FAIL
    //        digit  DIGITS accumulate digit

    while (run) {
	TRACE ("read next", 0);
	if (!aktive_read_string (src, buf, 1)) {
	    // EOF reached
	    if (mode > LEADER) {
		// Managed to read at least one digit. This is the number
		*v = vl;
		TRACE ("read number = %d", vl);
		TRACE_RETURN ("(OK) %d", 1);
	    }
	    TRACE_RETURN ("(FAIL eof) %d", 0);
	}
	TRACE ("read/%s = (%d) = '%c' ws=%d", hmode[mode], (int) *buf, *buf, isspace (*buf));

	switch (mode) {
	case LEADER:	// skip leading whitespace, if any
	    if (isspace (*buf)) continue;
	    // not whitespace, possible number start
	    mode = DIGITS;
	    goto digit;
	case DIGITS:	// process digits
	    // post number whitespace - stop now
	    if (isspace (*buf)) {
		TRACE ("stop on whitespace", 0);
		run = 0; break;
	    }
	    TRACE ("possible digit", 0);
	digit:
	    // non-digit - syntax error - fail
	    if ((*buf < '0') || (*buf > '9')) { TRACE_RETURN ("(FAIL not digit) %d", 0); }
	    // accumulate digit
	    vl = 10*vl + (*buf - '0');
	    TRACE ("number = %d", vl);
	    continue;
	case TRAILS: // at first trailing whitespace stop, immediately.
	    ASSERT (0, "not reachable");
	    break;
	}
    }
    TRACE ("after loop", 0);

    *v = vl;
    TRACE ("read number = %d", vl);
    TRACE_RETURN ("(OK) %d", 1);
}

extern int
aktive_read_uint_strcom (Tcl_Channel src, aktive_uint* v)
{
    TRACE_FUNC ("((Channel) %p, (aktive_uint*) %p)", src, v);

    aktive_uint vl   = 0;		// Number buffer
    aktive_uint mode = LEADER;		// DFA state
    aktive_uint skip = 0;		// Flag: In-comment
    aktive_uint run  = 1;		// Flag: Continue
    char        buf [2] = { 0, 0 };	// Character buffer

    // Deterministic finite automaton
    // See `aktive_read_uint_str` for the core.
    //
    // Here seeing a `#` suspends the current state until a '\n' is seen.
    // This handles `#`-based line comments embedded anywhere in the input
    // without having to change the automaton itself.
    // See (comment handling) below.

    // Deterministic finite automaton
    // State  Input  To     Action           Notes
    // -----  -----  --     ------           -----------------------
    // LEADER space  LEADER -                Skip leading whitespace
    //        !digit FAIL                    Begin number accumulation
    //        digit  DIGITS accumulate digit
    // DIGITS space  TRAILS -                Accumulate Number
    //        !digit FAIL
    //        digit  DIGITS accumulate digit
    // TRAILS space  TRAILS -                Skip trailing whitespace
    //        !space STOP   rewind, return

    while (run) {
	if (!aktive_read_string (src, buf, 1)) {
	    // EOF reached
	    if (mode > LEADER) {
		// Managed to read at least one digit. This is the number
		*v = vl;
		TRACE ("read number = %d", vl);
		TRACE_RETURN ("(OK) %d", 1);
	    }
	    TRACE_RETURN ("(FAIL eof) %d", 0);
	}
	TRACE ("read/%s%s = (%d) = '%c' ws=%d", hmode[mode], skip ? "/skip" : "",
	       (int) *buf, *buf, isspace (*buf));

	// (comment handling)
	if (skip) {
	    // In comment. Skip all characters until EOL, including the EOL
	    if (*buf == '\n') {
		// EOL seen. Leave skip mode and process next character normally.
		// Note, this may re-enter skip mode.
		skip = 0;
	    }
	    continue;
	} else if (*buf == '#') {
	    // Start of comment seen. Enter skip mode.
	    skip = 1;
	    continue;
	}

	switch (mode) {
	case LEADER:	// skip leading whitespace, if any
	    if (isspace (*buf)) continue;
	    // not whitespace, possible number start
	    mode = DIGITS;
	    goto digit;
	case DIGITS:	// process digits
	    // post number whitespace - skip trailing whitespace
	    if (isspace (*buf)) { mode = TRAILS ; continue; }
	digit:
	    // non-digit - syntax error - fail
	    if ((*buf < '0') || (*buf > '9')) { TRACE_RETURN ("(FAIL not digit) %d", 0); }
	    // accumulate digit
	    vl = 10*vl + (*buf - '0');
	    TRACE ("number = %d", vl);
	    continue;
	case TRAILS: // skip trailing whitespace
	    if (isspace (*buf)) continue;
	    // end of whitespace, rewind for next call
	    Tcl_Seek(src, -1, SEEK_CUR);
	    run = 0;
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
    TRACE_FUNC ("((Tcl_Channel) %p, *value %p)", src, v);

    unsigned char buf [1];
    int           ok = aktive_read_string (src, (char*) buf, 1);
    if (ok) {
	*v = buf[0];
	TRACE ("got %u", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_read_uint16be (Tcl_Channel src, aktive_uint* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, *value %p)", src, v);

    uint16_t vin;
    int      ok = aktive_read_string (src, (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP16 (vin);
	*v = vin;
	TRACE ("got %u", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_read_uint32be (Tcl_Channel src, aktive_uint* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, *value %p)", src, v);

    uint32_t vin;
    int      ok = aktive_read_string (src, (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP32 (vin);
	*v = vin;
	TRACE ("got %u", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_read_uint64be (Tcl_Channel src, Tcl_WideInt* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, *value %p)", src, v);

    uint64_t vin;
    int      ok = aktive_read_string (src, (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP64 (vin);
	*v = vin;
	TRACE ("got %llu", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_read_int8 (Tcl_Channel src, int* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, *value %p)", src, v);

    char buf [1];
    int  ok = aktive_read_string (src, buf, 1);
    if (ok) {
	*v = buf[0];
	TRACE ("got %d", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_read_int16be (Tcl_Channel src, int* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, *value %p)", src, v);

    int16_t vin;
    int     ok = aktive_read_string (src, (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP16 (vin);
	*v = vin;
	TRACE ("got %d", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_read_int32be (Tcl_Channel src, int* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, *value %p)", src, v);

    int32_t vin;
    int     ok = aktive_read_string (src, (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP32 (vin);
	*v = vin;
	TRACE ("got %d", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_read_int64be (Tcl_Channel src, Tcl_WideInt* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, (int64_t*) %p)", src, v);

    int64_t vin;
    int     ok = aktive_read_string (src, (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP64 (vin);
	*v = vin;
	TRACE ("got %lld", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_read_float64be (Tcl_Channel src, double* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, (double*) %p)", src, v);

    int ok = aktive_read_string (src, (char*) v, sizeof(*v));
    if (ok) {
	uint64_t* vin = (uint64_t*) v;
	SWAP64 (*vin);
	TRACE ("got %f", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_read_float64be_n (Tcl_Channel src, aktive_uint n, double* v)
{
    TRACE_FUNC ("((Tcl_Channel) %p, (double*) %p [%d])", src, v, n);

    // read directly into the buffer
    int ok = aktive_read_string (src, (char*) v, n * sizeof(*v));

    // if needed perform endian conversion - vectorize-able ?!
#ifdef BE_SWAP
    if (ok) {
	uint64_t* vi = (uint64_t*) v;
	aktive_uint i; for (i = 0; i < n; i++, vi++) { SWAP64 (*vi); }
    }
#endif

    TRACE_RETURN ("(OK) %d", ok);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_get_string (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, char* buf, aktive_uint n)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, (char*) %p [%d])", inbytes, inmax, *pos, buf, n);

    Tcl_Size mark = *pos;
    Tcl_Size stop = mark + n;

    TRACE ("from " TCL_SIZE_FMT ", to " TCL_SIZE_FMT, mark, stop);
    if (stop > inmax) {
	if (mark >= 0) { *pos = mark; }
	TRACE_RETURN ("(Fail) %d", 0);
    }

    memcpy (buf, inbytes + mark, n);
    *pos = stop;

    TRACE_HEADER(1);TRACE_ADD ("read = {", 0);
    for (int k=0;k<n;k++) { TRACE_ADD(" %u", ((aktive_uint) buf[k]) & 0xFF); }
    TRACE_ADD (" }", 0);TRACE_CLOSER;

    TRACE_HEADER(1);TRACE_ADD ("read = {", 0);
    for (int k=0;k<n;k++) { TRACE_ADD(" '%c'", (char) buf[k]); }
    TRACE_ADD (" }", 0);TRACE_CLOSER;

    TRACE_RETURN ("(OK) %d", 1);
}

extern int
aktive_get_match (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, char* pattern, aktive_uint n)
{
    Tcl_Size mark = *pos;
    char*    buf  = NALLOC(char, n);
    int      ok   = aktive_get_string (inbytes, inmax, pos, buf, n);
    if (ok) {
	ok = 0 == strncmp (pattern, buf, n);
	if (!ok && (mark >= 0)) { *pos = mark; }
    }
    ckfree (buf);
    return ok;
}

extern int
aktive_get_uint_str (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, (aktive_uint*) %p)", inbytes, inmax, *pos, v);

    aktive_uint vl   = 0;		// Number buffer
    aktive_uint mode = LEADER;		// DFA state
    aktive_uint run  = 1;		// Flag: Continue
    char        buf [2] = { 0, 0 };	// Character buffer

    // Deterministic finite automaton
    // State  Input  To     Action           Notes
    // -----  -----  --     ------           -----------------------
    // LEADER space  LEADER -                Skip leading whitespace
    //        !digit FAIL                    Begin number accumulation
    //        digit  DIGITS accumulate digit
    // DIGITS space  TRAILS -                Accumulate Number
    //        !digit FAIL
    //        digit  DIGITS accumulate digit
    // TRAILS space  TRAILS -                Skip trailing whitespace
    //        !space STOP   rewind, return

    while (run) {
	if (!aktive_get_string (inbytes, inmax, pos, buf, 1)) {
	    // EOF reached
	    if (mode > LEADER) {
		// Managed to read at least one digit. This is the number
		*v = vl;
		TRACE ("read number = %d", vl);
		TRACE_RETURN ("(OK) %d", 1);
	    }
	    TRACE_RETURN ("(FAIL eof) %d", 0);
	}
	TRACE ("read/%s = (%d) = '%c' ws=%d", hmode[mode], (int) *buf, *buf, isspace (*buf));

	switch (mode) {
	case LEADER:	// skip leading whitespace, if any
	    if (isspace (*buf)) continue;
	    // not whitespace, possible number start
	    mode = DIGITS;
	    goto digit;
	case DIGITS:	// process digits
	    // post number whitespace - back skipping
	    if (isspace (*buf)) { mode = TRAILS ; continue; }
	digit:
	    // non-digit - syntax error - fail
	    if ((*buf < '0') || (*buf > '9')) { TRACE_RETURN ("(FAIL not digit) %d", 0); }
	    // accumulate digit
	    vl = 10*vl + (*buf - '0');
	    TRACE ("number = %d", vl);
	    continue;
	case TRAILS: // skip trailing whitespace
	    if (isspace (*buf)) continue;
	    // end of whitespace, rewind for next call
	    *pos = *pos - 1;
	    run = 0;
	    break;
	}
    }

    *v = vl;
    TRACE ("read number = %d", vl);
    TRACE_RETURN ("(OK) %d", 1);
}

extern int
aktive_get_uint_strsharp (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v)
{
    // This uint string reader differs from uint_str in that it stops at the
    // first trailing whitespace it sees. This is necessary for the NetPBM
    // binary formats. The maxval value ending their header ends in \n
    // immediately followed by the pixel data. This cannot be treated as more
    // white space.

    TRACE_FUNC ("((char*) %p [%d] @ %d, (aktive_uint*) %p)", inbytes, inmax, *pos, v);

    aktive_uint vl   = 0;		// Number buffer
    aktive_uint mode = LEADER;		// DFA state
    aktive_uint run  = 1;		// Flag: Continue
    char        buf [2] = { 0, 0 };	// Character buffer

    // Deterministic finite automaton
    // State  Input  To     Action           Notes
    // -----  -----  --     ------           -----------------------
    // LEADER space  LEADER -                Skip leading whitespace
    //        !digit FAIL                    Begin number accumulation
    //        digit  DIGITS accumulate digit
    // DIGITS space  STOP   -                Cannot have general trailing whitespace
    //        !digit FAIL
    //        digit  DIGITS accumulate digit

    while (run) {
	TRACE ("read next", 0);
	if (!aktive_get_string (inbytes, inmax, pos, buf, 1)) {
	    // EOF reached
	    if (mode > LEADER) {
		// Managed to read at least one digit. This is the number
		*v = vl;
		TRACE ("read number = %d", vl);
		TRACE_RETURN ("(OK) %d", 1);
	    }
	    TRACE_RETURN ("(FAIL eof) %d", 0);
	}
	TRACE ("read/%s = (%d) = '%c' ws=%d", hmode[mode], (int) *buf, *buf, isspace (*buf));

	switch (mode) {
	case LEADER:	// skip leading whitespace, if any
	    if (isspace (*buf)) continue;
	    // not whitespace, possible number start
	    mode = DIGITS;
	    goto digit;
	case DIGITS:	// process digits
	    // post number whitespace - stop now
	    if (isspace (*buf)) {
		TRACE ("stop on whitespace", 0);
		run = 0; break;
	    }
	    TRACE ("possible digit", 0);
	digit:
	    // non-digit - syntax error - fail
	    if ((*buf < '0') || (*buf > '9')) { TRACE_RETURN ("(FAIL not digit) %d", 0); }
	    // accumulate digit
	    vl = 10*vl + (*buf - '0');
	    TRACE ("number = %d", vl);
	    continue;
	case TRAILS: // at first trailing whitespace stop, immediately.
	    ASSERT (0, "not reachable");
	    break;
	}
    }
    TRACE ("after loop", 0);

    *v = vl;
    TRACE ("read number = %d", vl);
    TRACE_RETURN ("(OK) %d", 1);
}

extern int
aktive_get_uint_strcom (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, (aktive_uint*) %p)", inbytes, inmax, *pos, v);

    aktive_uint vl   = 0;		// Number buffer
    aktive_uint mode = LEADER;		// DFA state
    aktive_uint skip = 0;		// Flag: In-comment
    aktive_uint run  = 1;		// Flag: Continue
    char        buf [2] = { 0, 0 };	// Character buffer

    // Deterministic finite automaton
    // See `aktive_get_uint_str` for the core.
    //
    // Here seeing a `#` suspends the current state until a '\n' is seen.
    // This handles `#`-based line comments embedded anywhere in the input
    // without having to change the automaton itself.
    // See (comment handling) below.

    // Deterministic finite automaton
    // State  Input  To     Action           Notes
    // -----  -----  --     ------           -----------------------
    // LEADER space  LEADER -                Skip leading whitespace
    //        !digit FAIL                    Begin number accumulation
    //        digit  DIGITS accumulate digit
    // DIGITS space  TRAILS -                Accumulate Number
    //        !digit FAIL
    //        digit  DIGITS accumulate digit
    // TRAILS space  TRAILS -                Skip trailing whitespace
    //        !space STOP   rewind, return

    while (run) {
	if (!aktive_get_string (inbytes, inmax, pos, buf, 1)) {
	    // EOF reached
	    if (mode > LEADER) {
		// Managed to read at least one digit. This is the number
		*v = vl;
		TRACE ("read number = %d", vl);
		TRACE_RETURN ("(OK) %d", 1);
	    }
	    TRACE_RETURN ("(FAIL eof) %d", 0);
	}
	TRACE ("read/%s%s = (%d) = '%c' ws=%d", hmode[mode], skip ? "/skip" : "",
	       (int) *buf, *buf, isspace (*buf));

	// (comment handling)
	if (skip) {
	    // In comment. Skip all characters until EOL, including the EOL
	    if (*buf == '\n') {
		// EOL seen. Leave skip mode and process next character normally.
		// Note, this may re-enter skip mode.
		skip = 0;
	    }
	    continue;
	} else if (*buf == '#') {
	    // Start of comment seen. Enter skip mode.
	    skip = 1;
	    continue;
	}

	switch (mode) {
	case LEADER:	// skip leading whitespace, if any
	    if (isspace (*buf)) continue;
	    // not whitespace, possible number start
	    mode = DIGITS;
	    goto digit;
	case DIGITS:	// process digits
	    // post number whitespace - skip trailing whitespace
	    if (isspace (*buf)) { mode = TRAILS ; continue; }
	digit:
	    // non-digit - syntax error - fail
	    if ((*buf < '0') || (*buf > '9')) { TRACE_RETURN ("(FAIL not digit) %d", 0); }
	    // accumulate digit
	    vl = 10*vl + (*buf - '0');
	    TRACE ("number = %d", vl);
	    continue;
	case TRAILS: // skip trailing whitespace
	    if (isspace (*buf)) continue;
	    // end of whitespace, rewind for next call
	    *pos = *pos - 1;
	    run = 0;
	    break;
	}
    }

    *v = vl;
    TRACE ("read number = %d", vl);
    TRACE_RETURN ("(OK) %d", 1);
}

extern int
aktive_get_uint8 (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    unsigned char buf [1];
    int           ok = aktive_get_string (inbytes, inmax, pos, (char*) buf, 1);
    if (ok) {
	*v = buf[0];
	TRACE ("got %u", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_get_uint16be (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    uint16_t vin;
    int      ok = aktive_get_string (inbytes, inmax, pos,
				     (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP16 (vin);
	*v = vin;
	TRACE ("got %u", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_get_uint32be (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    uint32_t vin;
    int      ok = aktive_get_string (inbytes, inmax, pos,
				     (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP32 (vin);
	*v = vin;
	TRACE ("got %u", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_get_uint64be (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, Tcl_WideInt* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    uint64_t vin;
    int      ok = aktive_get_string (inbytes, inmax, pos,
				     (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP64 (vin);
	*v = vin;
	TRACE ("got %llu", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_get_int8 (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    char buf [1];
    int  ok = aktive_get_string (inbytes, inmax, pos, buf, 1);
    if (ok) {
	*v = buf[0];
	TRACE ("got %d", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_get_int16be (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    int16_t vin;
    int     ok = aktive_get_string (inbytes, inmax, pos,
				    (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP16 (vin);
	*v = vin;
	TRACE ("got %d", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_get_int32be (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, int* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    int32_t vin;
    int     ok = aktive_get_string (inbytes, inmax, pos,
				    (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP32 (vin);
	*v = vin;
	TRACE ("got %d", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_get_int64be (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, Tcl_WideInt* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    int64_t vin;
    int     ok = aktive_get_string (inbytes, inmax, pos,
				    (char*) &vin, sizeof(vin));
    if (ok) {
	SWAP64 (vin);
	*v = vin;
	TRACE ("got %lld", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_get_float64be (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, double* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, *value %p)", inbytes, inmax, *pos, v);

    int ok = aktive_get_string (inbytes, inmax, pos, (char*) v, sizeof(*v));
    if (ok) {
	uint64_t* vin = (uint64_t*) v;
	SWAP64 (*vin);
	TRACE ("got %f", *v);
    }

    TRACE_RETURN ("(OK) %d", ok);
}

extern int
aktive_get_float64be_n (char* inbytes, Tcl_Size inmax, Tcl_Size* pos, aktive_uint n, double* v)
{
    TRACE_FUNC ("((char*) %p [%d] @ %d, (double*) %p [%d])", inbytes, inmax, *pos, v, n);

    // read directly into the buffer
    int ok = aktive_get_string (inbytes, inmax, pos, (char*) v, n * sizeof(*v));

    // if needed perform endian conversion - vectorize-able ?!
#ifdef BE_SWAP
    if (ok) {
	uint64_t* vi = (uint64_t*) v;
	aktive_uint i; for (i = 0; i < n; i++, vi++) { SWAP64 (*vi); }
    }
#endif

    TRACE_RETURN ("(OK) %d", ok);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_path_copy (aktive_path* dst, Tcl_Obj* src)
{
    TRACE_FUNC("((path*) %p, (Tcl_Obj*) %p)", dst, src);

    Tcl_Size len;
    char*    path = Tcl_GetStringFromObj (src, &len);	 /* OK tcl9 */

    dst->length = len;
    STRDUP (dst->string, path);

    TRACE("(=> (path*) %p = (" TCL_SIZE_FMT ", '%s'))", dst, len, dst->string);
    TRACE_RETURN_VOID;
}

extern void
aktive_path_free (aktive_path* dst)
{
    TRACE_FUNC("((path*) %p = (" TCL_SIZE_FMT ", '%s'))", dst, dst->length, dst->string);

    ckfree (dst->string);
    dst->string = 0;
    dst->length = 0;

    TRACE_RETURN_VOID;
}

extern Tcl_Channel
aktive_path_open (aktive_path* dst)
{
    TRACE_FUNC("((path*) %p = (%d, '%s'))", dst, dst->length, dst->string);

    Tcl_Obj*    path = Tcl_NewStringObj (dst->string, dst->length);	 /* OK tcl9 */
    Tcl_IncrRefCount (path);
    Tcl_Channel src  = Tcl_FSOpenFileChannel (NULL, path, "r", 0);
    Tcl_DecrRefCount (path);

    TRACE_RETURN ("(Channel) %p", src);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
