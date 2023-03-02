## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Salt and pepper noise

# # ## ### ##### ######## ############# #####################

operator image::noise::salt {
    section generator virtual

    note Returns image containing salt and pepper noise.

    note Pixels are set where the uniformly distributed random value passes the threshold
    note The value of set pixels is fixed at 1.0

    uint      width      Width of the returned image
    uint      height     Height of the returned image
    uint      depth      Depth of the returned image

    double    threshold  Noise threshold within 0..1

    state -fields {
	aktive_uint seed;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, param->depth);

	state->seed = rand();
	// Merge w, h, d into seed ? No. Does not make things more random.
    }

    blit saltsampling {
	{RH {y DY 1 up} {y SY 1 up}}
	{RW {x DX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {point {
	(SCALE (STEP (MERGE3 (istate->seed, x, y, z)))) >= param->threshold ? 1 : 0
    }}

    pixels {
	#undef SCALE
	#define STEP  aktive_fnv_step
	#define MERGE aktive_fnv_merge_uint32
	#define MERGE3(s,a,b,c) MERGE (MERGE (MERGE (s, a), b), c)
	#define SCALE(x) (((double) (x)) / ((double) RAND_MAX))
	#define DX (dst->x)
	#define DY (dst->y)
	#define RH (request->height)
	#define RW (request->width)
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@saltsampling@@
	#undef STEP
	#undef MERGE
	#undef MERGE3
	#undef SCALE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
