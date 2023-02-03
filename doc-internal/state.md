Post 2023 Hackweek 22

- Using code generation looks to have turned out a good idea in the main.

- Not fully happy yet with parts of the runtime API

  - Signature / Interface between runtime and fetch hook for example not quite happy with yet

    - Too many arguments ... Consider a structure to aggregate the operator specific data

    - Note: Do not want to expose the region structure. However maybe part of it can, as a
      `Fetch Configuration Block`.

    - Should also have defines/makros for easy access to the FCB fields.

  - Points, Rects, Geometries are not feeling quite right yet. Too many conversions and data
    shuffling IMHO.
