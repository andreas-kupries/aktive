# Structural transformations of various kinds

  - [Operator reference](/doc/trunk/doc/transform_structure.md)

---

  - Use `embeddings` to `align` an image along one or more border.
    For example justify left, right, or center.
 
  - Change the band geometry, i.e. fold/unfold bands into/from columns.
 
  - `Cropping` images, i.e. removing left/right/top/bottom/front/back borders.
    The opposite of `embedding`.
 
  - `Flip`/mirror images along one of their axes.
 
  - `Rotate` images (only quarter turns)
 
  - `Scroll` images, i.e. shift their pixels along one of the axes, with wrap around.
 
  - `Select` a continuous subset of image rows, columns, or bands.
    Which is a different interface to cropping.
 
  - `Split` images into their separate rows, columns, and bands, each their own image.
 
  - Exchange, i.e. `swap` any two axes of an images. For example rows to columns and vice versa.
    Specific swaps and combinations of swaps and flip are `transpose` and `transverse`, i.e. flipping
    an image along the main and secondary diagonals.
 
  - `Take` parts of an image under the control of some other (index) image.
    The per-row/... `arg...` statistics are good to compute the controlling index.
 
  - Last, not least change image sizes by `resampling` the pixels.
