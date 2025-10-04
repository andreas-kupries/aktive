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

datasource1 = "aktive-read-le-be.csv"
# 1 config
# 2 file
# 3 file/be
# 4 string
# 5 string/be

set output   "aktive-read-le-1.svg"
set title "file reader le, be"
set logscale y
plot datasource1 using 1:2 with lines, \
     datasource1 using 1:3 with lines

set title "file reader, le relative to be"
set output   "aktive-read-le-2.svg"
unset logscale
plot datasource1 using 1:(1)	 with lines title "le", \
     datasource1 using 1:($3/$2) with lines title "be / le"

set output   "aktive-read-le-3.svg"
set title "string reader le, be"
set logscale y
plot datasource1 using 1:4 with lines, \
     datasource1 using 1:5 with lines

set title "string reader, le relative to be"
set output   "aktive-read-le-4.svg"
unset logscale
plot datasource1 using 1:(1)	 with lines title "le", \
     datasource1 using 1:($5/$4) with lines title "be / le"
