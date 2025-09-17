# _ _ __ ___ _____ ________ _____________ _____________________
#

set datafile   separator ','
set key        autotitle columnhead				# use the first line as title
set terminal   postscript enhanced color landscape 'Arial' 12

set size ratio 0.71 # for the A4 ratio
set boxwidth   0.9
set style      fill solid

set output   "aktive-read.ps"

# _ _ __ ___ _____ ________ _____________ _____________________

set xlabel "Id"
set ylabel  "Microseconds"

datasource1 = "aktive-file-vs-string.csv"
# 1 config
# 2 file
# 3 string

set logscale y
plot datasource1 using 1:2 with lines, \
     datasource1 using 1:3 with lines

unset logscale
plot datasource1 using 1:(1)	with lines, \
     datasource1 using 1:($2/$3) with lines title "file/string"
