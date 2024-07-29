## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Gaussian noise

operator image::noise::gauss {
    section generator virtual

    # fixed seed to keep the examples identical across runs
    example {width 256 height 256 depth 1 seed 703011174}
    example {width 256 height 256 depth 3 seed 703011174}

    note Returns image where pixels are set to random values \
	drawn from a gaussian distribution with mean and \
	sigma over +/-sigma. The defaults are 0 and 1.

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    uint      depth   Depth of the returned image

    double? 0 mean    Mean of the desired gauss distribution.
    double? 1 sigma   Sigma of the desired gauss distribution.

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

    blit gausssampling {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {point {
	mean + (sigma * GAUSS (MERGE3 (istate->seed, x, y, z)))
    }}

    pixels {
	double mean  = param->mean;
	double sigma = param->sigma;

	#define GAUSS  aktive_fnv_gauss
	#define MERGE aktive_fnv_merge_uint32
	#define MERGE3(s,a,b,c) MERGE (MERGE (MERGE (s, a), b), c)
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@gausssampling@@
	#undef STEP
	#undef MERGE3
	#undef MERGE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
