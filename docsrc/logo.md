!include parts/topnav.inc

# Logo

The logo consists of the Tcl feather super-imposed over a gridded color palette.

It was created using [AKTIVE](../README.md) itself, the image containing the Tcl feather was the
only external resource.

The (slightly modified, reduced) script to create it is

```tcl
#!/usr/bin/env tclsh
package require aktive
package require fileUtil	;# tcllib

puts "aktive v[aktive version], [aktive processors] threads"

proc logo {} {
    set feather [aktive read from netpbm path doc/assets/tcl-feather-on-white-128.ppm]
    set feather [aktive op embed copy $feather left 24 right 24]

    lassign [aktive op split z $feather] r g b
    set mask      [aktive op math mul $r $g $b]
    set mask      [aktive op morph erode $mask embed copy radius 1]

    set colors    [aktive image palette color]

    set gridlines [aktive image checkers width 128 height 128 black 2 white 14 offset 1]
    set gridlines [aktive op math1 invert $gridlines]
    set gridlines [aktive op sample replicate z $gridlines by 3]

    set palette   [aktive op math mul $colors $gridlines]

    set logo      [aktive op if-then-else $mask $palette $feather]
    return $logo
}

proc emit {logo} {
    aktive format as ppm byte 2file $logo into \
	doc/assets/aktive-logo-128.ppm

    exec >@ stdout 2>@ stderr  convert  \
	doc/assets/aktive-logo-128.ppm \
	doc/assets/aktive-logo-128.png

    fileutil::writeFile \
	doc/assets/aktive-logo-128-pipeline.d2 \
	\
	[aktive format as d2 $logo]

    exec >@ stdout 2>@ stderr  d2 \
	doc/assets/aktive-logo-128-pipeline.d2 \
	doc/assets/aktive-logo-128-pipeline.svg

    return
}

emit [logo]
exit
```

The code around `format as d2` and after emits the constructed processing pipeline as a D2 diagram
and SVG for display, demonstrating AKTIVE's ability to inspect itself.

While the pipeline is simplifiable, especially around the various splits/joins of the color bands
hidden in some of the operators, doing so, on the other hand, will result in a script which will not
be as readable anymore. And the image is not truly large enough to bother getting rid of the data
shuffles.

Click on the image for full-size:

<a href='assets/aktive-logo-128-pipeline.svg'>
<img alt='pipeline' src='assets/aktive-logo-128-pipeline.svg'>
</a>
