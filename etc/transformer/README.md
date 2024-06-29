# Transformers

Operations taking one or more images and returning a changed image.

  - [Operator reference](/doc/trunk/doc/ref/transform.md)

Such operations may affect the `structure` of the images or their values.

The latter are likely some kind of `filter`, `math`, `statistics`, or `color` conversions.

The rest is about:

  - A no-op identity transform which has no simplification rules, and can be used to prevent
    application of other simplification rules. This is for debugging and testing, especially
    round tripping between complementary operation which would be elided otherwise.

  - Changing the location of the image in the infinite image plane.

  - Editing and querying the image meta data dictionary.

  - Changing (translating) the viewport into the image plane.
