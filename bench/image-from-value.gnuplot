# _ _ __ ___ _____ ________ _____________ _____________________
#

set datafile   separator ','
set key        autotitle columnhead				# use the first line as title
set terminal   svg enhanced dynamic font 'Arial,12'
# BEWARE. Each plot requires a separate outputfile.

set size ratio 0.71 # for the A4 ratio
set boxwidth   0.9
set style      fill solid

# _ _ __ ___ _____ ________ _____________ _____________________
##
# the timings of `image from value`, a constant virtual image, should
# be strongly dominated by the overheads of the batch processor and
# its thread coordinators. this will hopefully later enable the
# teasing out of the actual operation times, for complex operators

set xlabel "Id"
set ylabel  "Microseconds"

# _ _ __ ___ _____ ________ _____________ _____________________
## overall comparison of unordered vs sequential operation
#
# The 17 visible groups of the diagram are the thread counts, i.e.
# -1 (no threading), then 1 to 16.

# At 8 threads, the number of cores of the AMD Ryzen 5 3400G processor
# the benchmark was run on, sequential falls strongly behind
# unordered, while in absolute terms both actually look to be faster
# in general than then not all cores are in use.

datasource = "unordered-vs-sequential.csv"

# direct comparison of sequential vs unordered. a log scale is used to
# get a visualization, due to the large spread of values from near
# zero to the million range

set output   "image-from-value-1.svg"
set logscale y
plot datasource using 1:2 with lines, \
     datasource using 1:3 with lines

# now treating unordered as a fixed base line, i.e. 1, and showing the
# sequential timings relative to that. sequential < 1 is faster than
# unordered, and > 1 slower by that factor.

set output   "image-from-value-2.svg"
unset logscale
plot datasource using 1:(1)	with lines title "unordered", \
     datasource using 1:($3/$2) with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## tall (narrow high) images per height (x) and threads (multiple y)
##
# These kind of images are a bad match to the current system. While
# the row-based operation nicely dispatches tasks to all the worker
# threads, each task is very small. Here, processing a single pixel.

datasource = "unordered-single-column-threads.csv"

set output   "image-from-value-3.svg"
set logscale y
plot datasource using  1:2 with lines, \
     datasource using  1:3 with lines, \
     datasource using  1:4 with lines, \
     datasource using  1:5 with lines, \
     datasource using  1:6 with lines, \
     datasource using  1:7 with lines, \
     datasource using  1:8 with lines, \
     datasource using  1:9 with lines, \
     datasource using 1:10 with lines, \
     datasource using 1:11 with lines, \
     datasource using 1:12 with lines, \
     datasource using 1:13 with lines, \
     datasource using 1:14 with lines, \
     datasource using 1:15 with lines, \
     datasource using 1:16 with lines, \
     datasource using 1:17 with lines, \
     datasource using 1:18 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## wide (broad shallow) images per width (x) and threads (multiple y)
##
# These kind of images are a also bad match to the current system,
# although for a different reason than the tall ones. Here, while each
# task has quite a bit of work to perform, per the width of the image,
# there is only a single row, thus task. Therefore the majority of the
# workers is not used at all.

# In both the tall and wide cases the non-threaded case is the best
# possible case. Even so, in the range 10**4 to 10**5, i.e. where
# normal images are about the threaded ops are not too bad.

datasource2 = "unordered-single-row-threads.csv"

set output   "image-from-value-4.svg"
set logscale y
plot datasource2 using  1:2 with lines, \
     datasource2 using  1:3 with lines, \
     datasource2 using  1:4 with lines, \
     datasource2 using  1:5 with lines, \
     datasource2 using  1:6 with lines, \
     datasource2 using  1:7 with lines, \
     datasource2 using  1:8 with lines, \
     datasource2 using  1:9 with lines, \
     datasource2 using 1:10 with lines, \
     datasource2 using 1:11 with lines, \
     datasource2 using 1:12 with lines, \
     datasource2 using 1:13 with lines, \
     datasource2 using 1:14 with lines, \
     datasource2 using 1:15 with lines, \
     datasource2 using 1:16 with lines, \
     datasource2 using 1:17 with lines, \
     datasource2 using 1:18 with lines

# Both tall and wide together

set output   "image-from-value-5.svg"
plot datasource using  1:2 with lines, \
     datasource using  1:3 with lines, \
     datasource using  1:4 with lines, \
     datasource using  1:5 with lines, \
     datasource using  1:6 with lines, \
     datasource using  1:7 with lines, \
     datasource using  1:8 with lines, \
     datasource using  1:9 with lines, \
     datasource using 1:10 with lines, \
     datasource using 1:11 with lines, \
     datasource using 1:12 with lines, \
     datasource using 1:13 with lines, \
     datasource using 1:14 with lines, \
     datasource using 1:15 with lines, \
     datasource using 1:16 with lines, \
     datasource using 1:17 with lines, \
     datasource using 1:18 with lines, \
     \
     datasource2 using  1:2 with lines, \
     datasource2 using  1:3 with lines, \
     datasource2 using  1:4 with lines, \
     datasource2 using  1:5 with lines, \
     datasource2 using  1:6 with lines, \
     datasource2 using  1:7 with lines, \
     datasource2 using  1:8 with lines, \
     datasource2 using  1:9 with lines, \
     datasource2 using 1:10 with lines, \
     datasource2 using 1:11 with lines, \
     datasource2 using 1:12 with lines, \
     datasource2 using 1:13 with lines, \
     datasource2 using 1:14 with lines, \
     datasource2 using 1:15 with lines, \
     datasource2 using 1:16 with lines, \
     datasource2 using 1:17 with lines, \
     datasource2 using 1:18 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## square images per size (x) and threads (multiple y)
##
# For balanced width and height execuition times are generally in the
# low millis

datasource3 = "unordered-square-threads.csv"

set output   "image-from-value-6.svg"
set logscale y
plot datasource3 using  1:2 with lines, \
     datasource3 using  1:3 with lines, \
     datasource3 using  1:4 with lines, \
     datasource3 using  1:5 with lines, \
     datasource3 using  1:6 with lines, \
     datasource3 using  1:7 with lines, \
     datasource3 using  1:8 with lines, \
     datasource3 using  1:9 with lines, \
     datasource3 using 1:10 with lines, \
     datasource3 using 1:11 with lines, \
     datasource3 using 1:12 with lines, \
     datasource3 using 1:13 with lines, \
     datasource3 using 1:14 with lines, \
     datasource3 using 1:15 with lines, \
     datasource3 using 1:16 with lines, \
     datasource3 using 1:17 with lines, \
     datasource3 using 1:18 with lines

# all together
set output   "image-from-value-7.svg"
plot datasource using  1:2 with lines, \
     datasource using  1:3 with lines, \
     datasource using  1:4 with lines, \
     datasource using  1:5 with lines, \
     datasource using  1:6 with lines, \
     datasource using  1:7 with lines, \
     datasource using  1:8 with lines, \
     datasource using  1:9 with lines, \
     datasource using 1:10 with lines, \
     datasource using 1:11 with lines, \
     datasource using 1:12 with lines, \
     datasource using 1:13 with lines, \
     datasource using 1:14 with lines, \
     datasource using 1:15 with lines, \
     datasource using 1:16 with lines, \
     datasource using 1:17 with lines, \
     datasource using 1:18 with lines, \
     \
     datasource2 using  1:2 with lines, \
     datasource2 using  1:3 with lines, \
     datasource2 using  1:4 with lines, \
     datasource2 using  1:5 with lines, \
     datasource2 using  1:6 with lines, \
     datasource2 using  1:7 with lines, \
     datasource2 using  1:8 with lines, \
     datasource2 using  1:9 with lines, \
     datasource2 using 1:10 with lines, \
     datasource2 using 1:11 with lines, \
     datasource2 using 1:12 with lines, \
     datasource2 using 1:13 with lines, \
     datasource2 using 1:14 with lines, \
     datasource2 using 1:15 with lines, \
     datasource2 using 1:16 with lines, \
     datasource2 using 1:17 with lines, \
     datasource2 using 1:18 with lines, \
     \
     datasource3 using  1:2 with lines, \
     datasource3 using  1:3 with lines, \
     datasource3 using  1:4 with lines, \
     datasource3 using  1:5 with lines, \
     datasource3 using  1:6 with lines, \
     datasource3 using  1:7 with lines, \
     datasource3 using  1:8 with lines, \
     datasource3 using  1:9 with lines, \
     datasource3 using 1:10 with lines, \
     datasource3 using 1:11 with lines, \
     datasource3 using 1:12 with lines, \
     datasource3 using 1:13 with lines, \
     datasource3 using 1:14 with lines, \
     datasource3 using 1:15 with lines, \
     datasource3 using 1:16 with lines, \
     datasource3 using 1:17 with lines, \
     datasource3 using 1:18 with lines
