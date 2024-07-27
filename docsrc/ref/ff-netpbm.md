!include ../parts/topnav-quadrant-ref.inc

# File formats: NetPBM

  - [Operators](../ref/sink_writer.md#format_as_pgm_byte_2chan)

[NetPBM](http://en.wikipedia.org/wiki/Netpbm_format) stands for a series of
related image file formats capable of representing bit-, gray-, and (color)
pix(el) maps, in both pure text and mixed text and binary.

Of these __bitmaps are not supported__ by AKTIVE.
Neither is the semi-related `PAM` format.

## Overview

Generally all the formats start with a text header describing image geometry and
chosen pixel storage format, followed by the pixels in either text or binary
form. Pixel quantization is done to either byte or uint16, i.e. 256 or 65536
different values. The multi-byte forms use __network byte order__, i.e. __big
endian__, i.e. most significant byte first.

## Header

|Field	|Content		|Notes			|
|---	|---	     		|---			|
|type	|Format indicator	|Format: "[Pn](#find)"	|
|width	|Number of columns	|	 		|
|height	|Number of rows		|			|
|maxval	|Max pixel value	| (1)			|

where all fields are separated by one or more white space characters.
These are space, tab, vertical tab, carriage return, and linefeed, i.e.
ASCII 0x20, 0x09, 0x0B, 0x0D, and 0x0A.

  1. For the binary pixel formats the value also indicates the type of each
     pixel value, i.e. `byte` (`maxval` < 256) vs. `uint16` (`maxval < 65536`).

__Note__ that the image header may contain line comments starting with a `#`
character (ASCII 0x23) and ending at the next carriage return or line feed
(ASCII 0x0D, 0x0A).  __Beware__, such comments are allowed to __start at any
location__ within the header. Even within a number or the type indicator, etc.

__Note__ further that the formats using text to encode pixel data allow for
comments in the pixel area as well, again at any location.

Image depth is implied in the format itself and not stored. Graymaps are single
band, whereas pixmaps have three bands, for the red, green, and blue channels.

## <a name='find'></a> Format indicator

|Code	|Map	|Subformat	|
|---	|---	|---		|
|`P2`	|gray	|text		|
|`P5`	|gray	|binary		|
|	|	|		|
|`P3`	|pix	|text		|
|`P6`	|pix	|binary		|
