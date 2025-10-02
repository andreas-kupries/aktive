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

datasource1 = "blit-fill-new-old.csv"
# 1 config
# 2 file
# 3 string

set title    "new, old"
set output   "blit-fill-new-old-1.svg"
set logscale y
plot datasource1 using 1:2 with lines, \
     datasource1 using 1:3 with lines

set title    "new relative to old"
set output   "blit-fill-new-old-2.svg"
set ylabel   "Factor"
unset logscale
plot datasource1 using 1:(1)	 with lines title "old", \
     datasource1 using 1:($2/$3) with lines title "new / old"

set title    "old relative to new"
set output   "blit-fill-new-old-3.svg"
set ylabel   "Factor"
unset logscale
plot datasource1 using 1:(1)	 with lines title "new", \
     datasource1 using 1:($3/$2) with lines title "old / new"
