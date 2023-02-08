## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Images created only from parameters
#
## Random fields - Noise of various forms
## A kind of virtual image

# # ## ### ##### ######## ############# #####################

nyi operator image::noise::seed {
    note Set the seed of the random number generator used by the noise-based image generators

    int seed  Seed to set
    void {
	// %% TODO %% specify implementation
    }
}

# # ## ### ##### ######## ############# #####################

nyi operator image::noise::salt {
    note Salt and pepper noise.
    note Pixels are set where the random value passes the threshold
    note The value of set pixels is fixed at 1.0

    uint      width      Width of the returned image
    uint      height     Height of the returned image
    uint      depth      Depth of the returned image
    double    threshold  Noise threshold within low..high
    double? 0 low        Lowest  possible random value
    double? 1 high       Highest possible random value

    # %% TODO %% specify implementation
}

nyi operator image::noise::uniform {
    note Pixels are set to a random value drawn from a uniform distribution

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    uint      depth   Depth of the returned image
    double? 0 low     Lowest  possible noise value
    double? 1 high    Highest possible noise value

    # %% TODO %% specify implementation
}

nyi operator image::noise::gauss {
    note Pixels are set to a random value drawn from a gaussian distribution

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    uint      depth   Depth of the returned image
    double? 0 mean    Noise center value
    double? 1 sigma   Noise spread (sqrt of desired variance)

    # %% TODO %% specify implementation
}

##
# # ## ### ##### ######## ############# #####################
::return
