## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - Binary math (pixel wise)

# # ## ### ##### ######## ############# #####################
## Binary without parameters

nyi operator {
    op::math::atan2
    op::math::div
    op::math::ge
    op::math::gt
    op::math::hypot
    op::math::le
    op::math::lt
    op::math::mod
    op::math::pow
    op::math::sub
    op::math::add
    op::math::max
    op::math::min
    op::math::mul
} {
    input keep-pass-ignore
    input keep-pass-ignore

    # %% TODO %% specify implementation
}

##
# # ## ### ##### ######## ############# #####################
::return
