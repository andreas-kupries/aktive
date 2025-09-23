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

set xlabel "Id"
set ylabel  "Microseconds"

datasource1 = "warp-rotate.csv"
# 2 cache access
# 3 near-neighbour
# 4 bilinear
# 5 bicubic
# 6 lanczos

set title    "raw warp times, cache access"
set output   "warp-rotate-1.svg"
set logscale y
plot datasource1 using 1:3 with lines, \
     datasource1 using 1:4 with lines, \
     datasource1 using 1:5 with lines, \
     datasource1 using 1:6 with lines, \
     datasource1 using 1:2 with lines

set title    "warp without cache access"
set output   "warp-rotate-2.svg"
set logscale y
plot datasource1 using 1:($3-$2) with lines, \
     datasource1 using 1:($4-$2) with lines, \
     datasource1 using 1:($5-$2) with lines, \
     datasource1 using 1:($6-$2) with lines

# -- warp, and compensated for cache access, per interpolation

set title    "near neighbour - warp / warp without cache access"
set output   "warp-rotate-3-near.svg"
set logscale y
plot datasource1 using 1:($3-$2) with lines title "without cache", \
     datasource1 using 1:3 	 with lines title "raw"

set title    "bilinear - warp / warp without cache access"
set output   "warp-rotate-3-bilinear.svg"
set logscale y
plot datasource1 using 1:($4-$2) with lines title "without cache", \
     datasource1 using 1:4	 with lines title "raw"

set title    "bicubic - warp / warp without cache access"
set output   "warp-rotate-3-bicubic.svg"
set logscale y
plot datasource1 using 1:($5-$2) with lines title "without cache", \
     datasource1 using 1:5 	 with lines title "raw"

set title    "lanczos - warp / warp without cache access"
set output   "warp-rotate-3-lanczos.svg"
set logscale y
plot datasource1 using 1:($6-$2) with lines title "without cache", \
     datasource1 using 1:6 	 with lines title "raw"




