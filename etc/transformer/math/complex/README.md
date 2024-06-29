## Math on complex images

  - [Operator reference](/doc/trunk/doc/ref/transform_math_complex.md)

`Complex` images are 2-band images, where band `0` holds the real part of the complex value, and
band `1` the imanginary part.

They have most of the math functions for regular images, as they are defined for complex values.

Instead of per-cell the functions are per-pixel.

Beyond that we get

 - Construction from parts (one or two images)
 
 - Extraction of parts
    - Cartesian: real, imaginary
    - Polar: magnitude, (phase-)angle

 - Coordinate conversions
    - Cartesion representation is standard, convert into and out of polar representation.
