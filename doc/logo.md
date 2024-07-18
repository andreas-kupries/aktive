
||||
|---|---|---|
|[Project ↗](../README.md)|[Documentation ↗](doc/index.md)|[Developer Index ↗](doc/dev/index.md)|

<img src='assets/aktive-logo-128.png' style='float:right;'>

# Logo

The logo consists of the Tcl feather super-imposed over a gridded color palette.

It was created using [AKTIVE](../README.md) itself, the image containing the Tcl feather was the
only external resource.

The (slightly modified, reduced) script to create it is

```tcl
#!/usr/bin/env tclsh
package require aktive

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
    aktive format as ppm byte 2file $logo into doc/assets/aktive-logo-128.ppm
    return
}

emit [logo]
exit
```