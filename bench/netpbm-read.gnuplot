# _ _ __ ___ _____ ________ _____________ _____________________
#

set datafile   separator ','
set key        autotitle columnhead				# use the first line as title
set terminal   postscript enhanced color landscape 'Arial' 12

set size ratio 0.71 # for the A4 ratio
set boxwidth   0.9
set style      fill solid

set output   "netpbm-read.ps"

# _ _ __ ___ _____ ________ _____________ _____________________

set xlabel "Id"
set ylabel  "Microseconds"

datasource1 = "ppm-iter-binary-unordered-vs-sequential.csv"
datasource2 = "ppm-iter-text-unordered-vs-sequential.csv"
datasource3 = "ppm-shot-binary-unordered-vs-sequential.csv"
datasource4 = "ppm-shot-text-unordered-vs-sequential.csv"

# iter vs shot (2:3)
datasource5 = "ppm-iter-shot-text-unordered.csv"
datasource6 = "ppm-iter-shot-text-sequential.csv"
datasource7 = "ppm-iter-shot-binary-unordered.csv"
datasource8 = "ppm-iter-shot-binary-sequential.csv"

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter binary, unordered and sequential
## unordered beats sequential

plot datasource1 using 1:2 with lines, \
     datasource1 using 1:3 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter text, unordered and sequential
## unordered beats sequential

plot datasource2 using 1:2 with lines, \
     datasource2 using 1:3 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter unordered, text vs binary
## text beats binary

plot datasource1 using 1:2 with lines, \
     datasource2 using 1:2 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter sequential, text vs binary
## text beats binary

plot datasource1 using 1:3 with lines, \
     datasource2 using 1:3 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter binary and text, unordered and sequential

plot datasource1 using 1:2 with lines, \
     datasource1 using 1:3 with lines, \
     datasource2 using 1:2 with lines, \
     datasource2 using 1:3 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /shot binary, unordered and sequential

plot datasource3 using 1:2 with lines, \
     datasource3 using 1:3 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /shot text, unordered and sequential

plot datasource4 using 1:2 with lines, \
     datasource4 using 1:3 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /shot sequential, text vs binary

plot datasource3 using 1:2 with lines, \
     datasource4 using 1:2 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /shot unordered, text vs binary

plot datasource3 using 1:3 with lines, \
     datasource4 using 1:3 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /shot binary and text, unordered and sequential

plot datasource3 using 1:2 with lines, \
     datasource3 using 1:3 with lines, \
     datasource4 using 1:2 with lines, \
     datasource4 using 1:3 with lines

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter /shot text unordered, absolute, delta

plot datasource5 using 1:2 with lines, \
     datasource5 using 1:3 with lines

plot datasource5 using 1:($3 - $2) with lines title "shot - iter"

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter /shot text sequential, absolute, delta

plot datasource6 using 1:2 with lines, \
     datasource6 using 1:3 with lines

plot datasource6 using 1:($3 - $2) with lines title "shot - iter"

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter /shot binary unordered, absolute, delta
## near to no difference

set title "binary unordered"

plot datasource7 using 1:2 with lines, \
     datasource7 using 1:3 with lines

set title "binary unordered / shot - iter"

plot datasource7 using 1:($3 - $2) with lines title "shot - iter"

# _ _ __ ___ _____ ________ _____________ _____________________
## /iter /shot binary sequential, absolute, delta
## near to no difference

set title "binary sequential"

plot datasource8 using 1:2 with lines, \
     datasource8 using 1:3 with lines

set title "binary sequential / shot - iter"

plot datasource8 using 1:($3 - $2) with lines title "shot - iter"
