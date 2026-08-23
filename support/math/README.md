
# Image math operations

Pixelwise operations, unary, binary, with no, one, or two parameters.

As bands and pixels are handled separately, i.e. there is no communication
between any, it is possible to treat each input image as one large vector which
can be processed in a single run through.
