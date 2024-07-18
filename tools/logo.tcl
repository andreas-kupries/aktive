#!/home/aku/opt/ActiveTcl/bin/tclsh
# ------------------------------------------------------------------------------

package require aktive
package require fileutil

puts "aktive v[aktive version], [aktive processors] threads"

proc logo {} {
    puts feather...
    set feather   [aktive op embed copy \
		       [aktive read from netpbm path doc/assets/tcl-feather-on-white-128.ppm] \
		       left 24 right 24]

    puts mask...
    lassign [aktive op split z $feather] r g b
    set mask      [aktive op morph erode \
		       [aktive op math mul $r $g $b] \
		       embed copy radius 1]
    puts colors...
    set colors    [aktive image palette color]

    puts gridlines...
    set gridlines [aktive op sample replicate z \
		       [aktive op math1 invert \
			    [aktive image checkers width 128 height 128 black 2 white 14 offset 1]] \
		       by 3]

    puts palette...
    set palette   [aktive op math mul $colors $gridlines]

    puts logo...
    set logo      [aktive op if-then-else $mask $palette $feather]

    return $logo
}

proc emit {logo} {
    puts writing...
    puts \tppm...
    aktive format as ppm byte 2file $logo into doc/assets/aktive-logo-128.ppm

    puts \t2png...
    exec >@ stdout 2>@ stderr convert  \
	doc/assets/aktive-logo-128.ppm \
	doc/assets/aktive-logo-128.png

    puts \t2ico
    exec >@ stdout 2>@ stderr convert \
	doc/assets/aktive-logo-128.ppm \
	-geometry 32x32 \
	doc/assets/aktive-logo-32.ico

    puts pipeline...
    puts \td2...
    fileutil::writeFile   \
	doc/assets/aktive-logo-128-pipeline.d2 \
	[aktive format as d2 $logo]

    puts \t2svg...
    exec >@ stdout 2>@ stderr d2 \
	doc/assets/aktive-logo-128-pipeline.d2 \
	doc/assets/aktive-logo-128-pipeline.svg

    puts \t2png...
    exec >@ stdout 2>@ stderr rsvg-convert \
	-o doc/assets/aktive-logo-128-pipeline.png \
	doc/assets/aktive-logo-128-pipeline.svg

    return
}

emit [logo]
exit
