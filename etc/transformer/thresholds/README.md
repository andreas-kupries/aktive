# Thresholding / Binarization

  - [Operator reference](/doc/trunk/doc/ref/transform_threshold.md)

## Overview

The listed methods are all based on adaption to the local environment of a pixel. As such they all
take the radius R of the region to consider as their parameter.

The region is a square tile of size `2*R+1`x`2*R+1` centered on the pixel under consideration.

A value `fooN` is the `foo` statistic computed over the tile.


|Method		|Parameters		|Description							|Defaults			|
|---		|---			|---								|---				|
|`bernsen`	|n/a			|`(minN+maxN)/2`						|				|
|`niblack`	|`k`			|`meanN + (k * stddevN)`					|`k=-0.2`			|
|`sauvola`	|`k`, `R`		|`meanN * (1 + k * ((stddevN/R) - 1))`				|`k=0.5`, `R=128`		|
|`phansalkar`	|`k`, `R`, `p`, `q`	|`meanN * (1 + p * exp(-q * meanN) + k * ((stddevN / R) - 1))`	|`p=3`,`q=10`,`k=0.25`,`R=0.5`	|

## Commands

The package provides four commands per method:

|Command			|Operation										|
|---				|---											|
|`image threshold <method>`	|Computes the threshold image from input and parameters					|
|`image mask <method>`		|Computes and applies the threshold. Result indicates foreground in white		|

Note that the mask methods assume that the input's foreground is darker than the background
(Example: Black print on a white page).