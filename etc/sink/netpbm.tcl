## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Sinks -- Netpbm PPM, PGM formats
#
## Portable Grey Map	1-band grey values
## Portable Pixel Map	3-band RGB values
#
# References:
# - http://en.wikipedia.org/wiki/Netpbm_format
# - http://wiki.tcl.tk/4530
#
# Format Description/Specification Recap
#
#  - PPM data represents a byte- or short-quantized RGB image (i.e. it has 3 bands). It
#    consists of a minimal header followed by a list of integer triples. The integer
#    values can be coded in binary (bytes or shorts), or as ASCII decimal numbers
#    (unsigned, >= 0 always). The header indicates the coding in use.
#
#  - PGM data represents a byte- or short-quantized gray image (i.e. it has 1 band). The
#    header is identical to PPM, except in the type indicator up front. The possible
#    encodings for the integer values is the same.
#
#  - The header is always plain text. It consists of type indicator, image width and
#    height, and the possible maximal integer value, in this order. The `maximal value` is
#    a scaling factor in the range 1 to 65535. Values <= 255 indicate bytes for binary
#    coding, otherwise shorts.
#
#  - The format supports #-based single-line comments in the header H which may start
#    __anywhere__ in H. IOW even in the middle of a number.
#
#    This writer does not generate any comments - TODO FUTURE :: use for meta data
#
#    The formats writing encoding the pixel values as text support #-based single-line
#    comments in the pixel data section as well.
#
#  - With this parsing the header can be done in a state machine supporting a single level
#    of stack/context.
#
#  - Whitespace (Space, TAB, VT, CR, LF) is used to terminate all values in the header.
#    Whitespace is also used to terminate text encoded pixel values. Binary coded pixel
#    values on the other hand are __not__ terminated at all.
#
#  - Binary coded data is written in __big endian__ order.
#

operator {bands type maxval} {
    format::as::pgm::text::2chan    1 2	  255
    format::as::pgm::etext::2chan   1 2 65535
    format::as::pgm::byte::2chan    1 5	  255
    format::as::pgm::short::2chan   1 5 65535

    format::as::ppm::text::2chan    3 3	  255
    format::as::ppm::etext::2chan   3 3 65535
    format::as::ppm::byte::2chan    3 6	  255
    format::as::ppm::short::2chan   3 6 65535

    format::as::pgm::text::2string  1 2	  255
    format::as::pgm::etext::2string 1 2 65535
    format::as::pgm::byte::2string  1 5	  255
    format::as::pgm::short::2string 1 5 65535

    format::as::ppm::text::2string  3 3	  255
    format::as::ppm::etext::2string 3 3 65535
    format::as::ppm::byte::2string  3 6	  255
    format::as::ppm::short::2string 3 6 65535
} {
    def thing	[set thing   [lindex [split $__op :] 4]]
    def variant [set variant [lindex [split $__op :] 6]]
    def dst	[set dst     [dict get {
	2chan channel
	2string string
    } [lindex [split $__op :] 8]]]

    note Sink. \
	Serializes image into the $dst, using [string toupper $thing]'s $variant format.

    input

    if {$dst eq "channel"} {
	channel dst	Channel the $thing $variant image data is written to
    }

    def write-result-setup [dict get {
	channel { aktive_write_channel (&dst, param->dst, 1); }
	string	{
	    Tcl_Obj* ba = Tcl_NewByteArrayObj (0,0);
	    aktive_write_bytearray (&dst, ba);
	}
    } $dst]

    def write-result-return [dict get {
	channel {}
	string	{ TRACE_RETURN ("(Tcl_Obj*) %p", ba); }
    } $dst]

    def write-begin {
	TRACE ("@@thing@@ starting", 0);

	aktive_geometry* g  = aktive_image_get_geometry (src);
	aktive_uint	 sz = aktive_geometry_get_size (g);

	if (g->depth != @@bands@@) {
	    TRACE ("band mismatch, have %d, wanted %d", g->depth, @@bands@@);
	    aktive_failf ("@@thing@@ does not support images with %d bands, expects @@bands@@",
			  g->depth);
	}

	aktive_writer dst;
	@@write-result-setup@@

	char   buf [40];
	aktive_uint n = sprintf (buf, "P@@type@@ %d %d @@maxval@@ ", g->width, g->height);
	ASSERT (n < 40, "header overflowed internal string buffer");
	TRACE ("header to write (%s)", buf);

	aktive_write_to (&dst, buf, n);

	aktive_uint wr = 0;
	aktive_uint lc = n;	// text, etext only - TODO conditional
	#define MAXCOL 70	//
    }

    def write-row [dict get {
	text {
	    ITER {
		aktive_uint n = aktive_write_uint_text (&dst, aktive_quantize_uint8 (VAL));
		lc += n;
		int term = 32;
		if (lc >= MAXCOL) { lc = 0; term = 10; } else { lc ++; }
		aktive_write_uint8 (&dst, term);
		wr ++;
	    }
	}
	etext {
	    ITER {
		aktive_uint n = aktive_write_uint_text (&dst, aktive_quantize_uint16 (VAL));
		lc += n;
		int term = 32;
		if (lc >= MAXCOL) { lc = 0; term = 10; } else { lc ++; }
		aktive_write_uint8 (&dst, term);
		wr ++;
	    }
	}
	byte {
	    ITER {
		aktive_write_uint8 (&dst, aktive_quantize_uint8 (VAL));
		wr ++;
	    }
	}
	short {
	    ITER {
		aktive_write_uint16be (&dst, aktive_quantize_uint16 (VAL));
		wr ++;
	    }
	}
    } $variant]

    def write-complete {
	ASSERT_VA (wr == sz, "@@thing@@ @@variant@@ write mismatch",
		   "wrote %d != required %d",
		   wr, sz);
	TRACE ("flush", 0);
	aktive_write_done (&dst);
	@@write-result-return@@
    }

    {*}[dict get {
	channel void
	string	{return object0}
    } $dst] {
	@@write-begin@@

	TRACE ("scan prep", 0);

	aktive_rectangle* domain = aktive_image_get_domain (src);
	aktive_region	  rg	 = aktive_region_new (src);

	// Scan image by rows, add the pixels of each retrieved row to the result list.

	TRACE_RECTANGLE (domain);

	aktive_rectangle_def_as (scan, domain);
	aktive_uint height = scan.height;
	scan.height = 1;

	for (aktive_uint k = 0, i=0; k < height; k ++) {
	    TRACE ("row %d", k);
	    TRACE_RECTANGLE(&scan);

	    aktive_block* pixels = aktive_region_fetch_area (rg, &scan);

	    #define ITER  for (aktive_uint j = 0; j < pixels->used; j++)
	    #define VAL	  pixels->pixel [j]
	    @@write-row@@
	    #undef ITER
	    #undef VAL

	    aktive_rectangle_move (&scan, 0, 1);
	}

	aktive_region_destroy (rg); // Note that this invalidates `pixels` too.

	@@write-complete@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
