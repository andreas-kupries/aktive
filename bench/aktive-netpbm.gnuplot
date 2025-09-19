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

datasource1 = "aktive-netpbm.csv"
# 1 config
# 2 file
# 3 string

set output   "aktive-netpbm-1.svg"
set logscale y
plot datasource1 using 1:2 with lines, \
     datasource1 using 1:3 with lines

set output   "aktive-netpbm-2.svg"
unset logscale
plot datasource1 using 1:(1)	 with lines, \
     datasource1 using 1:($2/$3) with lines title "aktive/netpbm"
