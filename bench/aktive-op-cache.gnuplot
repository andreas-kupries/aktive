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

datasource1 = "aktive-netpbm-cached.csv"
datasource2 = "aktive-file-cached.csv"
datasource3 = "netpbm-file-cached.csv"
# 1 config
# 2 file
# 3 string

set title    "aktive, netpbm, readers"
set output   "aktive-op-cache-1.svg"
set logscale y
plot datasource1 using 1:2 with lines, \
     datasource1 using 1:3 with lines

set title    "cached, aktive"
set output   "aktive-op-cache-3.svg"
plot datasource2 using 1:2 with lines, \
     datasource2 using 1:3 with lines

set title    "cached, netpbm"
set output   "aktive-op-cache-5.svg"
plot datasource3 using 1:2 with lines, \
     datasource3 using 1:3 with lines

set title    "aktive relative to netpbm, readers"
set output   "aktive-op-cache-2.svg"
set ylabel   "Factor"
unset logscale
plot datasource1 using 1:(1)	 with lines title "netpbm", \
     datasource1 using 1:($2/$3) with lines title "aktive / netpbm"

set title    "cached relative to aktive reader"
set output   "aktive-op-cache-4.svg"
unset logscale
plot datasource2 using 1:(1)	 with lines title "aktive", \
     datasource2 using 1:($2/$3) with lines title "cached / aktive"

set title    "cached relative netpbm reader"
set output   "aktive-op-cache-6.svg"
unset logscale
plot datasource3 using 1:(1)	 with lines title "netpbm", \
     datasource3 using 1:($2/$3) with lines title "cached / netpbm"
