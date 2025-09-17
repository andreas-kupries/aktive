# Benchmark results for the AKTIVE reader

  - Reading from string (image fully in memory) is much faster than
    reading from file, even when using the log scale.

# Takeaways

  - Look into ideas which bring a file into memory

    - Full in-memory cache

    - Memory mapping the underlying file
