## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Salt and pepper noise

# # ## ### ##### ######## ############# #####################

operator image::noise::salt {
    section generator virtual

    # fixed seed to keep the examples identical across runs
    example {width 256 height 256 depth 1 seed 703011174 threshold 0.02}
    example {width 256 height 256 depth 3 seed 703011174 threshold 0.02}

    note Returns image containing salt and pepper noise.

    note Pixels are set where the uniformly distributed random value is under the threshold.
    note For a given desired percentage P of noise pixels set the threshold to P/100.
    note The value of set pixels is fixed at 1.0

    uint      width      Width of the returned image
    uint      height     Height of the returned image
    uint      depth      Depth of the returned image

    double? 0.01 threshold  Noise threshold within {[0..1].}

    uint? {[expr {int(4294967296*rand())}]}  seed    \
	Randomizer seed. Needed only to force fixed results.

    state -fields {
	aktive_uint seed;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, param->depth);

	state->seed = param->seed;
	// Merge w, h, d into seed ? No. Does not make things more random.
    }

    blit saltsampling {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {point {
	(SCALE (STEP (MERGE3 (istate->seed, x, y, z)))) <= param->threshold ? 1 : 0
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
