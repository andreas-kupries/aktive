# Virtual images

  - [Operator reference](/doc/trunk/doc/ref/generator_virtual.md)

Are generated whole cloth from a small number of parameters without access to anything external. In
contrast to Readers which pull the image data from a file.

Currently provided are

 - Constant values (cell, pixels, per row, band, column, explicit matrix)

 - Gradient (arbitrary linear over cells, fade black to white)

 - Indexes (where pixels encode their own x/y position in the image)

 - Noise

 - Useful patterns

 - Sparse constants (defined through coordinate sets, either as explicit points, or deltas)

