## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - convolution kernels
#
## - blur::gauss (x, y, xy)
## - emboss
## - kirsch  (x, y, md, sd)
## - laplace (5, 9, X)
## - prewitt (x, y, md, sd)
## - roberts (x, y)
## - scharr  (x, y)
## - sobel   (x, y, md, sd)
#
## References
#
## - http://www.holoborodko.com/pavel/image-processing/edge-detection/
## - https://wiki.tcl-lang.org/page/TkPhotoLab
## - https://en.wikipedia.org/wiki/Prewitt_operator
## - https://en.wikipedia.org/wiki/Roberts_cross
## - https://en.wikipedia.org/wiki/Sobel_operator
## - https://en.wikipedia.org/wiki/Scharr_operator
## -
## -

# # ## ### ##### ######## ############# #####################
## md = main diagonal
## sd = secondary diagonal
##
## gauss x/y -  1/4*[1 2 1]
## gauss xy  - 1/16*[1 2 1  2 4 2  1 2 1]

operator {w h effect kernel} {
    image::kernel::emboss  3 3 {emboss effect} { 2  0  0   0 -1  0   0  0 -1}

    image::kernel::laplace::4  3 3 {sharpening effect} {  0 -1  0  -1  4 -1   0 -1  0 }
    image::kernel::laplace::8  3 3 {sharpening effect} { -1 -1 -1  -1  8 -1  -1 -1 -1 }
    image::kernel::laplace::X  3 3 {sharpening effect} {  1 -2  1  -2  4 -2   1 -2  1 }

    image::kernel::gauss::x  3 1 {gaussian blur effect} { 0.25 0.5 0.25 }
    image::kernel::gauss::y  1 3 {gaussian blur effect} { 0.25 0.5 0.25 }
    image::kernel::gauss::xy 3 3 {gaussian blur effect} { 0.0625 0.125 0.0625 0.125 0.25 0.125 0.0625 0.125 0.0625 }

    image::kernel::kirsch::md  3 3 {kirsch edge detection}         { -3   5  5   -3 0  5  -3 -3 -3 }
    image::kernel::kirsch::sd  3 3 {kirsch edge detection}         {  5   5 -3    5 0 -3  -3 -3 -3 }
    image::kernel::kirsch::x   3 3 {kirsch edge detection}         {  5  -3 -3    5 0 -3   5 -3 -3 }
    image::kernel::kirsch::y   3 3 {kirsch edge detection}         {  5   5  5   -3 0 -3  -3 -3 -3 }
    image::kernel::prewitt::md 3 3 {prewitt edge detection}        {  0   1  1   -1 0  1  -1 -1  0 }
    image::kernel::prewitt::sd 3 3 {prewitt edge detection}        { -1  -1  0   -1 0  1   0  1  1 }
    image::kernel::prewitt::x  3 3 {prewitt edge detection}        { -1   0  1   -1 0  1  -1  0  1 }
    image::kernel::prewitt::y  3 3 {prewitt edge detection}        { -1  -1 -1    0 0  0   1  1  1 }
    image::kernel::roberts::x  3 3 {robert's cross edge detection} {  0  -1  0    1 0  0   0  0  0 }
    image::kernel::roberts::y  3 3 {robert's cross edge detection} { -1   0  0    0 1  0   0  0  0 }
    image::kernel::scharr::x   3 3 {scharr edge detection}         { -3   0  3  -10 0 10  -3  0  3 }
    image::kernel::scharr::y   3 3 {scharr edge detection}         { -3 -10 -3    0 0  0   3 10  3 }
    image::kernel::sobel::md   3 3 {sobel edge detection}          {  0  -1 -1    2 0 -2   1  1  0 }
    image::kernel::sobel::sd   3 3 {sobel edge detection}          {  1   1  0    2 0 -2   0 -1 -1 }
    image::kernel::sobel::x    3 3 {sobel edge detection}          {  1   0 -1    2 0 -2   1  0 -1 }
    image::kernel::sobel::y    3 3 {sobel edge detection}          {  1   2  1    0 0  0  -1 -2 -1 }

} {
    section generator virtual

    note Returns convolution kernel for $effect

    body {
        aktive image from matrix width @@w@@ height @@h@@ values @@kernel@@
    }
}

# # ## ### ##### ######## ############# #####################

##
# # ## ### ##### ######## ############# #####################
::return
