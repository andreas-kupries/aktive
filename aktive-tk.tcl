## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## (c) 2023-2025 Andreas Kupries

# @@ Meta Begin
# Package aktive::tk 0
# Meta author      {Andreas Kupries}
# Meta location    https://core.tcl.tk/akupries/aktive
# Meta platform    tcl
# Meta summary	   AKTIVE / Tk conversions
# Meta description Converting between Tk photos and AKTIVE images.
# Meta subject	   {tk photo} {photo from AKTIVE} {photo to AKTIVE}
# Meta subject	   {AKTIVE to photo} {AKTIVE from photo}
# Meta require     {Tcl 8.6-}
# Meta require     Tk
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.6
package require Tk

package provide aktive::tk 0.0

# # ## ### ##### ######## ############# #####################
## Implementation

namespace eval ::aktive {
    namespace export tk
    namespace ensemble create
}
namespace eval ::aktive::tk {
    namespace export image photo photo=
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## BEWARE - As Tk photos are wholly in-memory so will be all of the data from
##          the images they are created from.
#
## To view very large images with not a lot of memory it is not just necessary
## to have a scrolled canvas with an image item. The image item also has to be
## sized exactly to the needs of the visible region and then fed just that part
## of the input as image to show.
#
## Then the internals of AKTIVE ensure that only the necessary part of the input
## is in memory. Plus caches. In case of expensive operations this will of
## course cause lagging. And require more caches.
##
## For such cases consider precomputing the result in full, into a file on disk,
## from which any region can then be shown quickly. A full-image cache,
## essentially.
#
## NOTE: Instead of connecting to AKTIVE on the C level in some way
##       the image is passed through a memory buffer (i.e. a byte
##       array), using a format Tk understands. These are the NETPBM
##       ppm and pgm formats.
#
## TODO: Consider using PNG to have an alpha channel as well. Note however that
##       AKTIVE has to be extended to support writing PNG. Tk already supports
##       reading PNG.

proc ::aktive::tk::image {photo} {
    return [aktive read from netpbm string value [$photo data -format ppm]
}

proc ::aktive::tk::photo {image} {
    return [::image create photo -data [String $image]
}

proc ::aktive::tk::photo= {photo image} {
    $photo data [String $image]
    return
}

proc ::aktive::tk::String {image} {
    set bands [aktive query depth $image]
    set convert {
	1 {pgm byte}
	3 {ppm byte}
    }
    if {![dict exists $convert $bands]} {
	return -code error -errorcode UNKNOWN \
	    "Unable to convert/show image with $bands bands"
    }
    set format [dict get $convert $bands]
    return [aktive format as {*}$format 2string $image]
}

# # ## ### ##### ######## ############# #####################
## ready
return
