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
# 3 fileold
# 4 string
# 5 stringold

set logscale y
plot datasource1 using 1:2 with lines, \
     datasource1 using 1:3 with lines, \
     datasource1 using 1:4 with lines, \
     datasource1 using 1:5 with lines

unset logscale
plot datasource1 using 1:(1)	with lines, \
     datasource1 using 1:($2/$3) with lines title "file/fileold"

plot datasource1 using 1:(1)	with lines, \
     datasource1 using 1:($4/$5) with lines title "string/stringold"

plot datasource1 using 1:(1)	with lines, \
     datasource1 using 1:($2/$4) with lines title "file/string"

plot datasource1 using 1:(1)	with lines, \
     datasource1 using 1:($3/$5) with lines title "fileold/stringold"
