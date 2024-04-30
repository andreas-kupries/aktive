# Sinks

Operations taking images and returning nothing.

  - Saving images using the `AKTIVE` format, or a host of the NetPBM formats.

  - Converting images into a Tcl dictionary representation. This is a materialization.

  - Converting image DAGs to other representations, notably Tcl script, D2, and Markdown.
    These do not materialize anything. Could be considered accessors too.

  - A `null` sink to simply trigger an image pipeline. Main use is performance debugging and
    benchmarking.

  - Global image statistics. These could be placed under `accessor` as well, and it would likely be
    the better place.
