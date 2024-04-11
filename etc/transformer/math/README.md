# Image math

Unary and binary math on images, for regular and `complex`-valued images.
All functions are applied per-cell.

Basic set of functions in one, two, or three arguments, with scalar and image arguments:

  - abs, acos, acosh, asin, asinh, atan, atan2, atanh, cbrt, ceil, cos, cosh, exp, exp10, exp2,
    expx, floor, hypot, log, log10, log2, max, min, mod, neg, pow, reciprocal, round, sign, sin,
    sinh, sqrt, square, tan, tanh

  - add, sub, mul, div, pow

  - Relations: >=, >, <=, <, !=, ==, inside/outside interval

  - Logical: and, or, nand, nor, xor, not

    Note that these all threshold their inputs at `0.5` to determine their input's logical levels
    before applying the actual logical function.

  - [Gamma compression and expansion](https://en.wikipedia.org/wiki/SRGB#Transfer_function_\(%22gamma%22\))

  - Clamping, wrapping, solarization, scaling, shifting, inversion

  - Linear blending

__Note__ that not all operators are listed here.
