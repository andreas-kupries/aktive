## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers - Complex math
#
## Pairs of bands are treated as one complex numbered band
## Inputs have to have at least 2 bands, and an even number of bands

nyi operator {
    op::cmath::conjugate
    op::cmath::cos
    op::cmath::div
    op::cmath::exp
    op::cmath::log
    op::cmath::log10
    op::cmath::magnitude
    op::cmath::mul
    op::cmath::sin
    op::cmath::sqmagnitude
    op::cmath::sqrt
    op::cmath::tan
    op::cmath::tocartesian
    op::cmath::topolar

    op::integrate
} {
    input keep

    # %% TODO %% specify implementation
}

##
# # ## ### ##### ######## ############# #####################
::return
