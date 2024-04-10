# Sinks

Operations taking images and returning nothing.

  - Saving images using the `AKTIVE` format, or a host of the NetPBM formats.

  - Converting images into a Tcl representation.

  - A `null` sink to simply trigger an image pipeline. Main use is performance debugging and
    benchmarking.

  - Global image statistics. These could be placed under `accessor` as well, and it would likely be
    the better place.
