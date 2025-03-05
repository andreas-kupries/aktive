
// = = == === ===== ======== ============= =====================

#ifndef BANDS
#error No bands set
#endif
#ifndef BANDCODE
# error No band code set
#endif

#if BANDCODE == 1
#define BANDTYPE uint8_t
#else
#define BANDTYPE uint16_t
#endif


#define BANDSZ sizeof(BANDTYPE)	// bytes needed for a single cell
#define BYTES (BANDS * BANDSZ)	// bytes needed for a single column

#ifndef PROCESS
#define PROCESS(v) TRACE("no processing", 0)
#endif

#define XS(s) X(s)
#define X(s) #s

// = = == === ===== ======== ============= =====================

TRACE_FUNC ("((void**) %p, (info*) %p, (%u x %u), (Chan) %p, (double*) %p [3*%u]) [%u %f]",
	    cache, info, x, y, chan, v, w, info->width, info->scale);
TRACE("Bands %d x %s [%d]", BANDS, XS(BANDTYPE), BYTES);

// Create cache able to hold a full row of raw shorts

if (!*cache) {
    *cache = NALLOC (char, info->width * BYTES);
}
TRACE ("Cache %p [%d]", *cache, info->width * BYTES);

BANDTYPE* raw   = (BANDTYPE*) *cache;
double    scale = info->scale;

TRACE ("Scale %f", scale);

// Determine where to read in the file.

aktive_uint offset = info->base + BYTES * (y * info->width + x);
TRACE ("Goto %d+%d*(%d*%d+%d) = %u", info->base, BYTES, y, info->width, x, offset);
Tcl_Seek (chan, offset, SEEK_SET);

// Read the (partial) row, then convert to destination

int i, got = Tcl_Read (chan, (char*) raw, w * BYTES);

TRACE ("request %8d, got %8d [bytes]", w*BYTES, got);

got /= BYTES;
ASSERT_VA (got <= w          , "got over request", "%d > %d", got, w);
ASSERT_VA (got <= info->width, "got over storage", "%d > %d", got, info->width);

TRACE ("request %8d, got %8d [columns]", w, got);

got *= BANDS;
w   *= BANDS;

TRACE ("request %8d, got %8d [values]", w, got);

double* vbase = v;

#if BYTE_ORDER == LITTLE_ENDIAN
#define ENDIAN "le"
#else
#define ENDIAN "be"
#endif

for (i = 0; i < got; i++, v++, raw++) {
    BANDTYPE vr = *raw;
#if BANDCODE == 1
    TRACE ("ingest [%8d] %5u /raw ...... [%02x]", i, vr, (int)((char*)&vr)[0]);

    *v = vr * scale;

    TRACE ("ingest [%8d] %5u -> %f [%02x]", i, vr, *v, (int)((char*)&vr)[0]);
#else
    TRACE ("ingest [%8d] %5u /raw ...... (be) [%02x %02x]", i, vr, (int)((char*)&vr)[0], (int)((char*)&vr)[1]);

    PROCESS (vr);
    *v = vr * scale;

    TRACE ("ingest [%8d] %5u -> %f (%s) [%02x %02x]", i, vr, *v, ENDIAN, (int)((char*)&vr)[0], (int)((char*)&vr)[1]);
#endif
}
for (     ; i < w;   i++, v++) { *v = 0.0; }

ASSERT_VA ((v - vbase) <= w,                   "over request", "written %ld max %d", v - vbase, w);
ASSERT_VA ((v - vbase) <= BANDS * info->width, "over storage", "written %ld max %d", v - vbase, info->width);

TRACE_RETURN_VOID;

// = = == === ===== ======== ============= =====================

#undef E
#undef BANDS
#undef BANDCODE
#undef BANDTYPE
#undef BANDSZ
#undef BYTES
#undef PROCESS

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
