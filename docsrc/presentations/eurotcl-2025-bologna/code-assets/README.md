# Page Extractor Script.

Syntax: `border.tcl ?-debug|-quad? /path/to/book-directory`

The jpeg pictures to process are expected in `/path/to/book-directory/raw/`.

The results, i.e. the extracted pages, will appear in
`/path/to/book-directory/_show_rect/`.

Except if `-quad` is specified. Then calculation runs only until the
quadrilaterals are computed into `/path/to/book-directory/_quad`.

The script's activity is reported to stdout.

The `STATS` lines at the end show how much time was spent on each
phase, in milliseconds, and as percentage of the total time. This is
sorted from longest phase down to shortest.

# Presentation

Calling the script in `-debug` mode causes it to generate many more
intermediate results and a presentation for each processed image using
them.

This is much slower than just performing the core page extraction.

The generated presentations will appear in
`/path/to/book-directory/_presentation/`.

In this mode the script will look in the directory
`/path/to/book-directory/_notes` for additional html files to
integrate into the presentation.

The note files used to make the presentation you are looking at right
now are found in the sub-directory `notes` of this directory.

