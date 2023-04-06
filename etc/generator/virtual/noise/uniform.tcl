## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Uniform noise

operator image::noise::uniform {
    section generator virtual

    note Returns image where pixels are set to random values drawn \
	from a uniform distribution over {[0..1]}

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    uint      depth   Depth of the returned image

    uint? {[expr {int(4294967296*rand())}]}  seed    \
	Randomizer seed. Needed only to force fixed \
	results, or external random numbers.

    state -fields {
	aktive_uint seed;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, param->depth);

	state->seed = param->seed;
	// Merge w, h, d into seed ? No. Does not make things more random.
    }

    blit uniformsampling {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {point {
	SCALE (STEP (MERGE3 (istate->seed, x, y, z)))
    }}

    pixels {
	#undef SCALE
	#define STEP  aktive_fnv_step
	#define MERGE aktive_fnv_merge_uint32
	#define MERGE3(s,a,b,c) MERGE (MERGE (MERGE (s, a), b), c)
	#define SCALE(x) (((double) (x)) / 4294967296.0)
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@uniformsampling@@
	#undef STEP
	#undef MERGE
	#undef MERGE3
	#undef SCALE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
