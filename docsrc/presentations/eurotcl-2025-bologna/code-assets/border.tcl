#!/usr/bin/env tclsh
# -*- tcl -*-
## (c) 2025 Andreas Kupries // Page Border Extraction
# # ## ### ##### ######## ############# #####################

# SYNTAX: border ?-debug|-quad? <base-directory>
#
# Expects directory
#   <base>/raw
# to contain the input images (.jpg)
#
# Fills siblings of <base>/raw with calculation results

#
# TODO: presentation - static things
#
# intro - myself
# intro aktive - site, repo, docs, examples
#
# highlight runtime internals (vips, threaded, structures)
# highlight code gen
# highlight simplification rules
#
# - calculate statistics
# - runtime, ops/tests/specs, generated c/tcl/docs

package require Tcl 8.6
package require aktive	;# + image magick for some conversions.

# # ## ### ##### ######## ############# #####################
## configuration - scale factor

proc factor {} { return 4    }

# # ## ### ##### ######## ############# #####################
## configuration - presentation/debug yes/no

#proc debug? {} { return 1 }
proc debug? {} { return 0 }

# # ## ### ##### ######## ############# #####################
## app entry

proc main {} {
    if {![cmdline]} usage
    perf process
    stats
}

# # ## ### ##### ######## ############# #####################
## command line handling

proc cmdline {} {
    global argv quadonly

    set quadonly 0
    switch -exact -- [lindex $argv 0] {
	-debug {
	    set argv [lassign $argv _]
	    puts "debug/presentation mode"
	    proc debug? {} { return 1 }
        }
        -quad {
	    set argv [lassign $argv _]
	    puts "quad-only mode"
	    proc debug? {} { return 0 }
	    set quadonly 1
	}
	default {}
    }

    if {[llength $argv] != 1} { return 0 }
    base [lindex $argv 0]
    return 1
}

proc usage {} {
    global argv0
    puts stderr "Usage: $argv0 ?-debug|-quad? base"
    exit 1
}

# # ## ### ##### ######## ############# #####################
## coordination

proc stats {} {
    global perf
    # perf = list (pair (millis name)...)
    # show stage times, high to low, i.e. slowest stage first, total time, percentages

    foreach entry $perf {
	lassign $entry millis _
	incr total $millis
    }
    foreach entry [lsort -decreasing -dict -index 0 $perf] {
	lassign $entry millis name
	set percent [format %6.2f [expr {($millis*100.0)/$total}]]
	puts \tSTATS\t$millis\t$percent\t$name
    }
    puts \tSTATS\t$total\t100.00\tTOTAL
}

proc perf {args} {
    set start [clock seconds]

    uplevel 1 $args

    set done  [clock seconds]
    set delta [expr {$done - $start}]

    puts [now]\tTIME\ttotal\t${delta}s
}

proc process {} {
    # main blocks
    # - ingest
    #   - convert format (ppm), usable by AKTIVE
    #   - scale down
    #   - to greyscale
    #   - to black/white (binarize (fg/bg segmentation), phansalkar)
    #     - we have regiona
    #   - internal morphological gradient
    #     - we have region borders
    #   - pick region (border) with largest-area bounding box.
    # - estimate straight left page border
    #   - get left profile
    #   - segment near/far parts
    #     - get global threshold (fixed, half)
    #     - apply threshold
    #   - fit a line (ransac)
    # - estimate straight right page border
    #   - see left border, use right instead of left
    # - estimate straight top border
    #   - get top profile
    #   - limit profile to left/right
    #   - fit an outer tangent to the profile, with minimal excess area
    # - estimate straight bottom border
    #   - see top border, use bottom instead of top
    # - find corners at the intersections of the straight borders
    #   - the line-segments form the quad/rilateral
    # - scale quad up
    # - unwarp the quad (applied to unscaled input)
    ##
    # paper / presentation
    # - create html page demonstrating the main series of steps

    # ingest to borders
    # future experiment: color edges?

    iter {raw        .jpg} {_ingest    {.txt .ppm}} do-ingest
    iter {_ingest    .ppm} {_scaled    {.txt .ppm}} do-scale-down
    iter {_scaled    .ppm} {_grey      .pgm}        do-convert-to-grey
    iter {_grey      .pgm} {_binarized .pgm}        do-binarize
    iter {_binarized .pgm} {_borders   .pgm}        do-get-borders

    # select primary border (largest by area), and visualize

    iter {_borders .pgm} {_primary .pgm} do-select

    # visualization - add overlay of border to base image

    debug iter {
	_scaled  .ppm
	_primary .pgm
    } {_show_border .ppm} do-show-border

    # determine the page profiles from all directions as the base for
    # all following.

    iter {_primary .pgm _scaled .txt} { _lt_profile .txt _lt_profile .pgm } do-left-profile
    iter {_primary .pgm _scaled .txt} { _rt_profile .txt _rt_profile .pgm } do-right-profile
    iter {_primary .pgm _scaled .txt} { _tp_profile .txt _tp_profile .pgm } do-top-profile
    iter {_primary .pgm _scaled .txt} { _bt_profile .txt _bt_profile .pgm } do-bottom-profile

    ## estimate straight left/right page borders. interleaved
    ## - outlier removal through thresholding, followed by ransac line fit
    # future experiment: profile from the inside out?

    iter {_lt_profile .txt _scaled .txt} {_lt_threshold {.txt .pgm}} do-find-threshold
    iter {_rt_profile .txt _scaled .txt} {_rt_threshold {.txt .pgm}} do-find-threshold

    iter {_lt_profile .txt _scaled .txt _lt_threshold .txt} {_lt_inlier {.txt .pgm}} do-apply-threshold keep-under
    iter {_rt_profile .txt _scaled .txt _rt_threshold .txt} {_rt_inlier {.txt .pgm}} do-apply-threshold keep-over

    iter {_lt_inlier .txt _scaled .txt} {_lt_limit {.txt .pgm}} do-fit-vertical-line left
    iter {_rt_inlier .txt _scaled .txt} {_rt_limit {.txt .pgm}} do-fit-vertical-line right

    # visualization - show threshold laid over base profile

    debug iter {_lt_profile .pgm _lt_threshold .pgm} {_lt_pt .ppm} do-chart red
    debug iter {_rt_profile .pgm _rt_threshold .pgm} {_rt_pt .ppm} do-chart red

    # visualization - add overlay of the left/right approximation

    debug iter {
	_show_border .ppm
	_lt_limit    .pgm
	_rt_limit    .pgm
    } {_show_lr .ppm} do-show-lr

    ## estimate straight top/bottom page border. interleaved
    ## - limit the profile to the left/right interval
    ## - refine to find the gutter
    ## - update left/right
    ## - fit outer tangent, adding minimal excess area

    iter {_scaled .txt _tp_profile .txt _lt_limit .txt _rt_limit .txt} {_tp_cut {.txt .pgm}} do-cut-horiz top-cliff
    iter {_scaled .txt _bt_profile .txt _lt_limit .txt _rt_limit .txt} {_bt_cut {.txt .pgm}} do-cut-horiz bottom-cliff

    # debug gutter finding process I
    debug iter {_tp_cut {.txt .pgm} _lt_limit .txt _rt_limit .txt} {_tp_base .pgm} do-profile-base max-better
    debug iter {_bt_cut {.txt .pgm} _lt_limit .txt _rt_limit .txt} {_bt_base .pgm} do-profile-base min-better

    # debug gutter finding process II
    debug iter {_tp_cut {.txt .pgm} _lt_limit .txt _rt_limit .txt} {_tp_shear .pgm} do-profile-shear max-better
    debug iter {_bt_cut {.txt .pgm} _lt_limit .txt _rt_limit .txt} {_bt_shear .pgm} do-profile-shear min-better

    # find gutter
    # future experiment: column histogram (page x-ray) for coarse location?
    iter {_scaled .txt _tp_cut .txt _lt_limit .txt _rt_limit .txt} {_tp_refined {.txt .pgm}} do-refine-horiz max-better
    iter {_scaled .txt _bt_cut .txt _lt_limit .txt _rt_limit .txt} {_bt_refined {.txt .pgm}} do-refine-horiz min-better

    iter {_scaled .txt _tp_refined .txt _bt_refined .txt} {_lt_final {.txt .pgm}} do-finalize-vertical left
    iter {_scaled .txt _tp_refined .txt _bt_refined .txt} {_rt_final {.txt .pgm}} do-finalize-vertical right

    # visualization - profile + base, profile + base + shear, profile + base + shear + max

    debug iter {_tp_cut .pgm _tp_base .pgm} {_tp_cutbase .ppm} do-chart blue
    debug iter {_bt_cut .pgm _bt_base .pgm} {_bt_cutbase .ppm} do-chart blue

    debug iter {_tp_cutbase .ppm _tp_shear .pgm} {_tp_cutshear .ppm} do-cchart red
    debug iter {_bt_cutbase .ppm _bt_shear .pgm} {_bt_cutshear .ppm} do-cchart red

    # fit tangents

    iter {_scaled .txt _tp_refined .txt} {_tp_tangents {.txt .pgm}} do-collect-tangents under-profile
    iter {_scaled .txt _bt_refined .txt} {_bt_tangents {.txt .pgm}} do-collect-tangents over-profile

    iter {_scaled .txt _tp_refined .txt _tp_tangents .txt} {_tp_final {.txt .pgm}} do-choose-tangent
    iter {_scaled .txt _bt_refined .txt _bt_tangents .txt} {_bt_final {.txt .pgm}} do-choose-tangent

    # fit a quadrilateral to the straight borders

    iter {
	_scaled   .txt
	_lt_final .txt
	_rt_final .txt
	_tp_final .txt
	_bt_final .txt
    } {
	_quad .txt
	_quad .pgm
    } do-fit-quadrilateral

    # scale back to original size
    
    iter {
	_quad   .txt
	_ingest .txt
    } {
	_quadup .txt
	_quadup .pgm
    } do-scale-up

    # stop after computing the quads. without rectification
    global quadonly
    if {$quadonly} return
    
    # visualization - add overlay of the top/bottom approximation (non-final left/right)

    debug iter {
	_show_lr    .ppm
	_tp_refined .pgm
	_bt_refined .pgm
    } {_show_tb .ppm} do-show-tb

    # visualization - add overlay of the left/right finals

    debug iter {
	_show_border .ppm
	_lt_final    .pgm
	_rt_final    .pgm
    } {_show_lr_final .ppm} do-show-lr

    # visualization - add overlay of the top/bottom approximation (final left/right)

    debug iter {
	_show_lr_final .ppm
	_tp_refined    .pgm
	_bt_refined    .pgm
    } {_show_tb_final .ppm} do-show-tb

    # visualization - primary + candidates + chosen

    debug iter {
	_show_border .ppm
	_tp_tangents .pgm
	_tp_final    .pgm
	_bt_tangents .pgm
	_bt_final    .pgm
    } {_show_tangents .ppm} do-show-tangents

    # visualization - final left/right/bottom border overlaid on primary

    debug iter {
	_show_lr_final .ppm
	_tp_final      .pgm
	_bt_final      .pgm
    } {_show_final .ppm} do-show-tb

    # visualization - primary + page enclosure

    debug iter {_show_border .ppm _quad .pgm} {_show_page .ppm} do-cchart red

    # semi final result + visual - rectify through the quadrilateral
    # - quad is scaled up, tp/bt refined is not, returned residue is scaled

    iter {
	_ingest     .ppm
	_quadup     .txt
	_tp_refined .txt
	_bt_refined .txt
    } {
	_show_rect  .ppm
	_tp_residue {.txt .pgm}
	_bt_residue {.txt .pgm}
    } do-rectify

    # visualization - add overlay of the top/bottom residuals on the rect result

    debug iter {
	_show_rect  .ppm
	_tp_residue .pgm
	_bt_residue .pgm
    } {_show_residue .ppm} do-show-tb
    
    # generate a html presentation for each page
    
    debug iter {
	raw            .jpg
	_scaled        .jpg
	_grey          .jpg
	_binarized     .jpg
	_borders       .jpg
	_primary       .jpg
	_show_border   .jpg
	_lt_profile    .jpg
	_lt_pt         .jpg
	_lt_inlier     .jpg
	_lt_limit      .jpg
	_show_lr       .jpg
	_tp_profile    .jpg
	_tp_cut        .jpg
	_tp_cutbase    .jpg
	_tp_cutshear   .jpg
	_tp_refined    .jpg
	_show_lr_final .jpg
	_show_tb_final .jpg
	_tp_tangents   .jpg
	_show_tangents .jpg
	_show_final    .jpg
	_quad          .jpg
	_show_page     .jpg
	_show_rect     .jpg
	_show_residue  .jpg
    } {
	_presentation .html
    } do-html $::base/_notes

    return
}

# # ## ### ##### ######## ############# #####################
## actions

proc do-ingest {src geo dst} {
    exec convert $src $dst

    param pnm dst
    lassign [aktive query domain $dst] _ _ w h

    result wtxt geo [list $w $h]
}

proc do-scale-down {src geo dst} {
    param pnm src

    lassign [aktive query domain $src] _ _ w h
    set w   [expr {$w / [factor]}]
    set h   [expr {$h / [factor]}]

    result wtxt geo [list $w $h]
    result ppm  dst [aktive op resize $src width $w height $h]
}

proc do-scale-up {quad geo dstdata dstshow} {
    param rtxt quad
    param rtxt geo

    set qup [sup $quad]
    set polyclose $qup ; lappend polyclose [lindex $qup 0]
    
    result        wtxt dstdata $qup
    debugs {result pgm dstshow [draw-poly {*}$geo $polyclose]}
}

proc do-convert-to-grey {src dst} {
    param  pnm src

    result pgm dst [aktive op color sRGB to gray $src]
}

proc do-binarize {src dst} {
    param  pnm src

    set bw [aktive image mask per phansalkar $src radius 7]

    result pgm dst [aktive op math1 invert $bw]
}

proc do-get-borders {src dst} {
    param  pnm src

    result pgm dst [aktive op morph gradient internal $src]
}

proc do-select {src dst} {
    param pnm src

    set ccs     [aktive op connected-components get $src]
    set ccs     [region-bbox-max $ccs]
    set ranges  [lsort -dict [lmap part [dict get $ccs 1 parts] {
	linsert $part end 1
    }]]
    set domain  [aktive query domain $src]
    result pgm dst [aktive image from sparse ranges geometry $domain ranges {*}$ranges]
}

proc do-left-profile {src geo dstdata dstshow} {
    param pnm  src
    param rtxt geo

    # index of 1st non-zero pixel from the left
    set profile [aktive op row profile $src]
    set profile [aktive query values $profile]
    set poly    [v-path-of $profile]

    result        wtxt dstdata $poly
    placeholder        dstshow
    debugs {result pgm dstshow [draw-poly {*}$geo $poly]}
}

proc do-right-profile {src geo dstdata dstshow} {
    param pnm  src
    param rtxt geo

    # index of last non-zero pixel from the left
    set profile [aktive op row rprofile $src]
    set profile [aktive query values $profile]
    set poly    [v-path-of $profile]

    result        wtxt dstdata $poly
    placeholder        dstshow
    debugs {result pgm dstshow [draw-poly {*}$geo $poly]}
}

proc do-top-profile {src geo dstdata dstshow} {
    param pnm  src
    param rtxt geo

    # index of 1st non-zero pixel from the top
    set profile [aktive op column profile $src]
    set profile [aktive query values $profile]
    set poly    [h-path-of $profile]

    result        wtxt dstdata $poly
    placeholder        dstshow
    debugs {result pgm dstshow [draw-poly {*}$geo $poly]}
}

proc do-bottom-profile {src geo dstdata dstshow} {
    param pnm  src
    param rtxt geo

    # index of last non-zero pixel from the top
    set profile [aktive op column rprofile $src]
    set profile [aktive query values $profile]
    set poly    [h-path-of $profile]

    result        wtxt dstdata $poly
    placeholder        dstshow
    debugs {result pgm dstshow [draw-poly {*}$geo $poly]}
}

proc do-find-threshold {profile geo dstdata dstshow} {
    param rtxt profile
    param rtxt geo

    # threshold = fixed midway in the image, easy and quick
    set threshold [expr {[lindex $geo 0]/2}]

    # forego the complex calculation of a dynamic otsu threshold
    if 0 {
	# as image, fit [0..1], map config, calc, unmap
	set xs        [as-image [xs $profile]]
	set xs        [aktive op math1 fit min-max $xs]
	set stretch   [aktive meta get $xs stretch]
	set scale     [dict get $stretch scale]
	set gain      [dict get $stretch gain]
	set threshold [aktive image threshold global otsu $xs]
	set threshold [expr {($threshold - $gain)/double($scale)}]
    }

    result        wtxt dstdata $threshold
    placeholder        dstshow
    debugs {result pgm dstshow [draw-vertical {*}$geo $threshold]}
}

proc do-apply-threshold {selector profile geo threshold dstdata dstshow} {
    #param selector (argument, command prefix)
    param rtxt profile
    param rtxt geo
    param rtxt threshold

    set poly [{*}$selector $threshold $profile]

    result        wtxt dstdata $poly
    placeholder        dstshow
    debugs {result pgm dstshow [draw-poly {*}$geo $poly]}
}

proc do-fit-vertical-line {edge profile geo dstdata dstshow} {
    #param edge (argument, {left, right})
    param rtxt profile
    param rtxt geo

    lassign $geo w h
    lassign [linreg-v $profile] slope intercept
    # note: the line is x = y*scale+intercept

    #puts fit-vertical/$edge\t($slope)\t($intercept)

    set a   [lerp-pv $slope $intercept 0]
    set b   [lerp-pv $slope $intercept [expr {$h-1}]]
    set hug [hugs-image-border $edge $w $a $b]

    result        wtxt dstdata [list $slope $intercept $hug]
    placeholder        dstshow
    debugs {result pgm dstshow [draw-line $w $h $a $b]}
}

proc do-chart {color bg mask dst} {
    # param color (argument)
    param pnm bg
    param pnm mask

    result ppm dst [overlay [2colors $bg] += [inv $mask] $color]
}

proc do-cchart {color bg mask dst} {
    # param color (argument)
    param pnm bg
    param pnm mask

    result ppm dst [overlay $bg += [inv $mask] $color]
}

proc do-cut-horiz {cliffs geo top left right dstdata dstshow} {
    # param cliffs (argument, cmd prefix)
    param rtxt geo
    param rtxt top
    param rtxt left
    param rtxt right

    lassign $left  lslope lintercept lhug
    lassign $right rslope rintercept rhug
    lassign [$cliffs $lhug $rhug $lslope $rslope] lcliff rcliff

    # apply limits
    set top  [limit-left  $lcliff $lslope $lintercept $top]
    set top  [limit-right $rcliff $rslope $rintercept $top]

    result        wtxt dstdata $top
    placeholder        dstshow
    debugs {result pgm dstshow [draw-poly {*}$geo $top]}
}

proc top-cliff {lhug rhug lslope rslope} {
    # determine cliffs (details in the limit-* procs)
    set lcliff [expr {!$lhug && ($lslope < 0)}]
    set rcliff [expr {!$rhug && ($rslope > 0)}]
    list $lcliff $rcliff
}

proc bottom-cliff {lhug rhug lslope rslope} {
    # determine cliffs (details in the limit-* procs)
    set lcliff [expr {!$lhug && ($lslope > 0)}]
    set rcliff [expr {!$rhug && ($rslope < 0)}]
    list $lcliff $rcliff
}

proc do-refine-horiz {isbetter geo profile left right dstdata dstshow} {
    param rtxt geo
    param rtxt profile
    param rtxt left
    param rtxt right

    lassign $left  lslope lintercept lhug
    lassign $right rslope rintercept rhug

    if {[llength $profile] > 10} {
	set profile [dehug $lhug $rhug $isbetter $profile]
    }

    result        wtxt dstdata $profile
    placeholder        dstshow
    debugs {result pgm dstshow [draw-poly {*}$geo $profile]}
}

# debug only
proc do-profile-base {isbetter data show left right dst} {
    # param isbetter (argument {max-better, min-better})
    param rtxt data
    param pnm  show
    param rtxt left
    param rtxt right

    lassign [aktive query domain $show] _ _ w h

    lassign $left  _ _ lhug
    lassign $right _ _ rhug

    if {$lhug} {
	lassign [profile-base $isbetter $data] a b _
    } elseif {$rhug} {
	lassign [profile-base $isbetter [lreverse $data]] b a _
    } else {
	set a [lindex $data 0]
	set b [lindex $data end]
    }

    result pgm dst [draw-line $w $h $a $b]
}

# debug only
proc do-profile-shear {isbetter data show left right dst} {
    # param isbetter (argument {max-better, min-better})
    param rtxt data
    param pnm  show
    param rtxt left
    param rtxt right

    lassign [aktive query domain $show] _ _ w h

    lassign $left  _ _ lhug
    lassign $right _ _ rhug

    if {$lhug} {
	lassign [profile-base $isbetter $data] a b cps
    } elseif {$rhug} {
	lassign [profile-base $isbetter [lreverse $data]] b a cps
	set cps [lreverse $cps]
    } else {
	set a [lindex $data 0]
	set b [lindex $data end]
	set cps $data
    }

    # model for the base line
    lassign [h-line-model $a $b] slope intercept
    lassign $a ax ay

    # interpolate into a full path - gradient
    set shear [lmap p $cps {
	lassign $p px py
	set ly [lerp $slope $ay [expr {$px - $ax}]]
	switch -exact -- $isbetter {
	    max-better { set dy [expr {$py - $ly}] }
	    min-better { set dy [expr {$py - $ly + $h - 1}] }
	}
	list $px $dy
    }]

    result pgm dst [draw-poly $w $h $shear]
}

proc do-finalize-vertical {edge geo tprofile bprofile dstdata dstshow} {
    #param edge (argument, {left, right})
    param rtxt geo
    param rtxt tprofile
    param rtxt bprofile

    switch -exact -- $edge {
	left {
	    set a [lindex $tprofile 0]
	    set b [lindex $bprofile 0]
	}
	right {
	    set a [lindex $tprofile end]
	    set b [lindex $bprofile end]
	}
	default { error "Bad edge `$edge`" }
    }

    if {[llength $tprofile] > 10 &&
	[llength $bprofile] > 10} {
	lassign [v-line-model $a $b] slope intercept
	if {abs($slope) < 1e6 && abs($intercept) < 1e6} {
	    lassign $geo w h

	    set a [lerp-pv $slope $intercept 0]
	    set b [lerp-pv $slope $intercept [expr {$h-1}]]
	}
    }

    result        wtxt dstdata [list $a $b]
    placeholder        dstshow
    debugs {result pgm dstshow [draw-line $w $h $a $b]}
}

proc do-show-border {src border dst} {
    param pnm src
    param pnm border

    result ppm dst [overlay $src += $border yellow]
}

proc do-show-lr {src left right dst} {
    param pnm src
    param pnm left
    param pnm right

    result ppm dst [overlay [overlay $src \
				 += [inv $left] cyan] \
			+= [inv $right] green]
}

proc do-show-tb {src top bottom dst} {
    param pnm src
    param pnm top
    param pnm bottom

    result ppm dst [overlay [overlay $src \
				 += [inv $top] blue] \
			+= [inv $bottom] red]
}

proc do-collect-tangents {where geo profile dstdata dstshow} {
    param rtxt geo
    param rtxt profile

    # reduce profile to convex hull
    if {[llength $profile] > 100 } {
	set hullspec [join [list 2 [llength $profile] {*}$profile] \n]
	set result   [exec qconvex Fx << $hullspec]
	set indices  [lassign [split [string trim $result] \n] n]
	set profile  [lmap i [lreverse $indices] { lindex $profile $i }]
    }

    # now collect tangents of a much smaller problem
    set pairs    [pairs $profile]
    set tangents [filter $pairs $where $profile]
    set tangents [unique-tangents $tangents]

    result    wtxt dstdata $tangents
    placeholder    dstshow
    debugs {
	lassign $geo w h
	result pgm dstshow [draw-lines $w $h [t-lines $w $tangents]]
    }
}

proc do-choose-tangent {geo profile tangents dstdata dstshow} {
    param rtxt geo
    param rtxt profile
    param rtxt tangents

    if {![llength $tangents]} return
    # without tangents no result here, and no quad later
    
    set tareas [map $tangents line-area-delta $profile]
    set best   [fold {{} {} {} {} Inf} $tareas min-area]
    # best = (i j a b slope intercept area)
    lassign $geo w h
    lassign [h-expand $w $best] a b

    result        wtxt dstdata [list $a $b]
    placeholder        dstshow
    debugs {result pgm dstshow [draw-line $w $h $a $b]}
}

proc do-show-tangents {src ttangents tfinal btangents bfinal dst} {
    param pnm src
    param pnm ttangents
    param pnm tfinal
    param pnm btangents
    param pnm bfinal

    set tangents [inv [aktive op sdf or $ttangents $btangents]]
    set chosen   [inv [aktive op sdf or $tfinal $bfinal]]

    result ppm dst [overlay [overlay $src += $tangents blue] + $chosen red]
}

proc do-fit-quadrilateral {geo left right top bottom dstdata dstshow} {
    param rtxt geo
    param rtxt left
    param rtxt right
    param rtxt top
    param rtxt bottom

    lassign $left   a d		;# A B   E--F   I--J
    lassign $right  b c		;# | | x      = |  |
    lassign $top    e f		;# D C   H--G   L--K
    lassign $bottom h g		;#
    if {[catch {
        set i [intersect $a $d $e $f]
	set j [intersect $b $c $e $f]
	set k [intersect $b $c $g $h]
	set l [intersect $a $d $g $h]
    }]} return ;# cannot assemble quad

    set poly      [list $i $j $k $l]
    set polyclose $poly ; lappend polyclose $i

    result        wtxt dstdata $poly
    placeholder        dstshow
    debugs {result pgm dstshow [draw-poly {*}$geo $polyclose]}
}

proc do-rectify {src quad top bottom dst tresidue tshow bresidue bshow} {
    param pnm  src
    param rtxt quad
    param rtxt top	; set top    [sup $top]
    param rtxt bottom	; set bottom [sup $bottom]

    lassign [aktive query domain $src] _ _ w h
    lassign $quad i j k l

    set quad      [aktive transform quad unit2 a $i b $j c $k d $l]
    set iquad     [aktive transform invert $quad]
    set scale     [aktive transform scale x $w y $h]
    set transform [aktive transform compose $scale $iquad]
    set rect      [aktive op transform by  $transform $src]
    set top       [aktive transform points $transform series {*}$top]
    set bottom    [aktive transform points $transform series {*}$bottom]
    
    result         ppm  dst      [aktive op view $rect port [list 0 0 $w $h]]
    result         wtxt tresidue $top
    result         wtxt bresidue $bottom
    debugs {result pgm  tshow [draw-poly $w $h $top]}
    debugs {result pgm  bshow [draw-poly $w $h $bottom]}
}

proc do-html {
	      notedir
	      raw scaled grey binarized borders primary interludea
	      ltprofile threshold inlier limit interludeb
	      tpprofile tpcut tpbase tpshear tprefined interludec interluded
	      tangents chosen qlines quad interludee
	      rectified residue
	      dst
} {
    foreach p {
	raw scaled grey binarized borders primary interludea
        ltprofile threshold inlier limit interludeb
	tpprofile tpcut tpbase tpshear tprefined interludec interluded
	tangents chosen qlines quad interludee
	rectified residue
    } { param pathof $p }

    # rewrite dst file into a dst directory for the presentation and its assets
    set dst [file rootname $dst]/index.html
    
    titles {
	raw        {Input 3456 x 4608}
	scaled     {Scaled 864 x 1152}
	grey       Grey
	binarized  Binarized
	borders    Borders
	primary    Primary
	interludea {Scaled + Primary}
	ltprofile  {Left Profile}
	threshold  {Fixed Threshold}
	inlier     {Profile Inlier}
	limit      {Left Border}
	interludeb {Scaled + Primary + Left Border}
	tpprofile  {Top Profile}
	tpcut      {Top Profile L/R Limited}
	tpbase     {Top Profile + Base Line}
	tpshear    {Top Profile + Base + Sheared}
	tprefined  {Top Profile Refined}
	interludec {Refined Left/Right Borders}
	interluded {Left/Right/Top/Bottom Borders}
	tangents   {Top Profile Tangents}
	chosen     {Border + Tangents + Best}
	qlines     {Left/Right Top/Bottom Box}
	quad       {Enclosing Quadrilateral}
	interludee {Border + Box}
	rectified  {Rectified Page 3456 x 4608}
	residue    {Rectified + Residuals}
    }

    code raw        ;# NOTES
    code scaled     do-scale-down "aktive::op::resize"
    code grey       do-convert-to-grey
    code binarized  do-binarize	  "aktive::image::threshold::phansalkar"   ;# NOTES
    code borders    do-get-borders "aktive::op::morph::gradient::internal" ;# NOTES
    code primary    do-select
    code interludea do-show-border overlay yellow color "aktive::image::from::color"
    code ltprofile  do-left-profile draw-poly ;# NOTES
    code threshold  do-find-threshold ;# draw-vertical draw-line
    code inlier     do-apply-threshold
    code limit	    do-fit-vertical-line
    code interludeb
    code tpprofile  do-top-profile
    code tpcut      do-cut-horiz top-cliff
    code tpbase     ;# do-profile-base ;# profile-base smooth-end
    code tpshear    ;# do-profile-shear
    code tprefined  do-refine-horiz
    code interludec
    code interluded
    code tangents   do-collect-tangents ;# draw-lines
    code chosen     do-choose-tangent
    code qlines
    code quad       do-fit-quadrilateral
    code interludee
    code rectified  do-rectify ;# NOTES
    code residue
    
    ordered {
	raw scaled grey binarized borders primary interludea
	ltprofile threshold inlier limit interludeb
	tpprofile tpcut tpbase tpshear tprefined interludec interluded
	tangents chosen qlines quad interludee
	rectified residue
    }

    result wtxt dst [collect]
}

# # ## ### ##### ######## ############# #####################
## action helpers

proc region-bbox-max {ccs} {
    #here
    # locate the region with the largest bounding box and remove all
    # other regions.
    ##
    # phase 1: compute region bb areas, and track the maximal
    set bba {}
    set maxarea -1
    dict for {id spec} $ccs {
	lassign [dict get $spec box] xmin ymin xmax ymax
	set w [expr {$xmax - $xmin}]
	set h [expr {$ymax - $ymin}]
	set a [expr {$w * $h}]
	dict set bba $id $a
	if {$a < $maxarea} continue
	set maxarea $a
    }
    # phase 2: get the data of the maximal
    set single {}
    dict for {id spec} $ccs {
	if {[dict get $bba $id] < $maxarea} continue
	set single $id
	dict set new $id $spec
    }
    # construct result dictionary
    if {([dict size $new] == 1) && ($single != 1)} {
	dict set new 1 [dict get $new $single]
	dict unset new $single
    }
    # done
    return $new
}

proc blue    {w h} { color $w $h blue }
proc green   {w h} { color $w $h green }
proc cyan    {w h} { color $w $h cyan }
proc red     {w h} { color $w $h red }
proc magenta {w h} { color $w $h magenta }
proc yellow  {w h} { color $w $h yellow }

proc color {w h name} { aktive image from color width $w height $h color $name }

proc 2colors {src} { aktive op montage z-rep $src by 3 }

proc inv {mask} { aktive op math1 invert $mask }

proc overlay {bg __ mask color} {
    lassign [aktive query domain $bg] _ _ w h

    # widen the mask for better visibility
    set mask [aktive op morph dilate $mask radius 2]

    # merge everything
    return [aktive op if-then-else $mask [{*}$color $w $h] $bg]
}

proc as-image {values} { aktive image from row height 1 values {*}$values }

proc draw-vertical {w h x}        { draw-line $w $h [list $x 0] [list $x $h] }
proc draw-line     {w h a b}      { fat [aktive image sdf line width $w height $h from $a to $b] }
proc draw-poly     {w h poly}     { fat [aktive image sdf polyline width $w height $h points {*}$poly] }
proc draw-lines    {w h segments} { fat [aktive image sdf lines width $w height $h segments {*}$segments] }

proc fat {i {radius 1}} { aktive op sdf round $i radius $radius }

proc xs  {path} { lmap p $path { lindex $p 0 } }
proc ys  {path} { lmap p $path { lindex $p 1 } }
proc sup {path} { lmap p $path {
    lassign $p x y
    list [expr {$x * [factor]}] [expr {$y * [factor]}]
} }

# treat the profile as a horizontal/vertical path, values are y/x-coordinates.
proc h-path-of {profile} { set x -1 ; lmap y $profile { incr x ; list $x [expr {int($y)}] } }
proc v-path-of {profile} { set y -1 ; lmap x $profile { incr y ; list [expr {int($x)}] $y } }

proc keep-under {th points} { lmap p $points { if {[lindex $p 0] > $th} continue ; set p } }
proc keep-over  {th points} { lmap p $points { if {[lindex $p 0] < $th} continue ; set p } }

proc h-line-model {a b} {
    lassign $a ax ay
    lassign $b bx by

    set dx        [expr {$bx - $ax}]
    set dy        [expr {$by - $ay}]
    set slope     [expr {double($dy)/$dx}]
    set intercept [expr {$by - $bx*$slope}]

    list $slope $intercept
}

proc v-line-model {a b} {
    lassign $a ax ay
    lassign $b bx by

    set dx [expr {$bx - $ax}]
    set dy [expr {$by - $ay}]

    if {$dy == 0} {
	return {0 Inf}
    }
    
    set slope     [expr {double($dx)/$dy}]
    set intercept [expr {$bx - $by*$slope}]

    list $slope $intercept
}

proc lerp-pv {slope intercept y} { list [lerp $slope $intercept $y] $y }
proc lerp-ph {slope intercept x} { list $x [lerp $slope $intercept $x] }
proc lerp    {slope intercept x} { expr {$x * $slope + $intercept} }

proc intersect {a b c d} {
    lassign $a ax ay
    lassign $b bx by
    lassign $c cx cy
    lassign $d dx dy
    set d [expr {($ax-$bx)*($cy-$dy) - ($ay-$by)*($cx-$dx)}]
    if {$d == 0} { error None }
    set xi [expr {int (round ((($cx - $dx) * ($ax * $by - $ay * $bx) - ($ax - $bx) * ($cx * $dy - $cy * $dx)) / $d))}]
    set yi [expr {int (round ((($cy - $dy) * ($ax * $by - $ay * $bx) - ($ay - $by) * ($cx * $dy - $cy * $dx)) / $d))}]
    return [list $xi $yi]
}

proc limit-left {cliff slope intercept border} {
    #puts \t[lreplace [info level 0] end end]

    # intercept, slope -> left border
    # first cut ... (and record left border xmax)
    set xmax -Inf
    set border [lmap p $border {
	# get point
	lassign $p x y
	# find left page border at the y-location of the border point
	#set lx [lerp $slope $intercept $y]
	set lx [expr {$intercept + $slope * $y}]
	# keep right-most edge of the left border
	# (might have to handle a cliff)
	if {$lx >= $xmax} { set xmax $lx }
	# reject points to the left of the border
	if {$x < $lx} continue
	# keep inside points
	set p
    }]

    #puts \t\t([llength $border])

    if {$cliff} {
	#puts \t\txmax=$xmax

	# The caller determined that this border has a cliff at the
	# left side. this is a part of the border which shadows (IOW
	# follows) the left border. this happens for the side not
	# touching the image border as such a free-standing left
	# border is never truly vertical. depending on the slope this
	# cliff is visible to either the top or the bottom border, not
	# both.
	#
	# the cliff is dealt with by additionally rejecting all the
	# points to the left of the right-most point of the left
	# border.
	set border [lmap p $border {
	    # get point
	    lassign $p x y
	    # reject points before the right-most left border
	    if {$x < $xmax} continue
	    # keep inside points
	    set p
	}]
	# forcibly place the border into contact with the right border
	set p [list [expr {int(ceil($xmax))-1}] [lindex $border 0 1]]
	set border [linsert $border 0 $p]
    }

    #puts \t\t([llength $border])

    return $border
}

proc limit-right {cliff slope intercept border} {
    #puts \t[lreplace [info level 0] end end]

    # intercept, slope -> right border
    # first cut ... (and record right border xmin)
    set xmin Inf
    set border [lmap p $border {
	# get point
	lassign $p x y
	# find right page border at the y-location of the border point
	#set rx [lerp $slope $intercept $y]
	set rx [expr {$intercept + $slope * $y}]
	# keep left-most edge of the right border
	# (might have to handle a cliff)
	if {$rx <= $xmin} { set xmin $rx }
	# reject points to the right of the border
	if {$x > $rx} continue
	# keep inside points
	set p
    }]

    #puts \t\t([llength $border])

    if {$cliff} {
	#puts \t\txmin=$xmin

	# The caller determined that this border has a cliff at the
	# right side. this is a part of the border which shadows (IOW
	# follows) the right border. this happens for the side not
	# touching the image border as such a free-standing right
	# border is never truly vertical. depending on the slope this
	# cliff is visible to either the top or the bottom border, not
	# both.
	#
	# the cliff is dealt with by additionally rejecting all the
	# points to the right of the left-most point of the right
	# border.
	set border [lmap p $border {
	    # get point
	    lassign $p x y
	    # reject points beyond the left-most right border
	    if {$x > $xmin} continue
	    # keep inside points
	    set p
	}]
	# forcibly place the border into contact with the right border
	set p [list [expr {int(ceil($xmin))+1}] [lindex $border end 1]]
	lappend border $p
    }

    #puts \t\t([llength $border])

    return $border
}

proc hugs-image-border {edge w a b} {
    lassign $a ax ay
    lassign $b bx by
    switch -exact -- $edge {
	left  { return [expr {min($ax,$bx) < 5}]        }
	right { return [expr {max($ax,$bx) > ($w - 6)}] }
	default { error "Bad edge `$edge`" }
    }
}

proc dehug {left right better ps} {
    # do nothing if no side hugs its image border
    if {!$left && !$right} { return $ps }
    # look inward on the indicated side
    # assumes that at most one side hugs its image border
    if {$left}  {
	set ps [dehug-left  $ps $better]
    } elseif {$right} {
	set ps [dehug-right $ps $better]
    }
    return $ps
}

proc dehug-left {ps isbetter} {
    dehug-core $ps $isbetter
}

proc dehug-right {ps isbetter} {
    lreverse [dehug-core [lreverse $ps] $isbetter]
}

proc dehug-core {ps isbetter} {
    lassign [profile-base $isbetter $ps] a b cps

    # line from start of smoothed profile to end of same
    set half [expr {[llength $ps] / 2}]

    # ... and model for the line
    lassign $a ax ay
    lassign $b bx by
    set dx   [expr {$bx - $ax}]
    set dy   [expr {$by - $ay}]
    set step [expr {double($dy)/$dx}]

    # find border point with isbetter/best delta from line (knee point)
    set k 0
    set best {}
    set at   -1
    foreach p $cps {
	lassign $p px py
	set ly [lerp $step $ay [expr {$px - $ax}]]
	set dy                 [expr {$py - $ly}]
	if {[$isbetter $dy $best]} { set at $k ; set best $dy }
	incr k
    }

    # accept cut point if and only if in the first half of the profile
    if {($at > 0) && ($at < $half)} {
	set ps [lrange $ps $at end]
    }

    return $ps
}

proc smooth-end {merge ps {e 200} {r 100}} {
    # take the last E (200) points of the path,
    # fit a linear model M to this set, and then
    # replace the last R (100) points according to M.

    # fit model to end segment of the border
    lassign [linreg-h [lrange $ps end-$e end]] slope intercept
    set n [llength $ps]

    # replace shorter end segment per the model
    set ax [lindex $ps end-$e 0]
    set new $ps
    for {set k [expr {$n - $r}]} {$k < $n} {incr k} {
	lassign [lindex $ps $k] kx ky
	set ly [lerp $slope $intercept $kx]
	# top/bottom - min/max
	lset new $k [list $kx [$merge $ly $ky]]
    }

    return $new
}

proc profile-base {isbetter ps} {
    # smooth the border curvature at the end of the profile
    # prevent left-over cliffs, i.e. de-spike
    set merge [dict get {
	max-better min-merge
	min-better max-merge
    } $isbetter]
    set cps [smooth-end $merge $ps]

    # line from start of smoothed profile to end of same
    set a [lindex $cps 0]
    set b [lindex $cps end]

    list $a $b $cps
}

proc min-merge {a b} { expr {int     (min ($a, $b))  }}
proc max-merge {a b} { expr {int(ceil(max ($a, $b))) }}

proc min-better {dy best} {
    if {$best eq {}} { return 1 }
    expr {$dy < $best}
}

proc max-better {dy best} {
    if {$best eq {}} { return 1 }
    expr {$dy > $best}
}

proc unique-tangents {tangents} {
    set mx {}
    lmap pair $tangents {
	lassign $pair i j a b
	set model [h-line-model $a $b]
	# discard duplicate models
	if {[dict exists $mx $model]} continue
	dict set mx $model .
	# keep unique
	list $i $j $a $b {*}$model
    }
}

proc t-lines {w tangents} {
    lmap pair $tangents {
	h-expand $w $pair
    }
}

proc h-expand {w pair} {
    lassign $pair i j a b slope intercept area
    set a [lerp-ph $slope $intercept 0]
    set b [lerp-ph $slope $intercept [expr {$w-1}]]
    return [list $a $b]
}

proc min-area {linea lineb} {
    set aa [lindex $linea end]
    set ab [lindex $lineb end]
    if {$aa < $ab} { return $linea }
    return $lineb
}

proc line-area-delta {ps line} {
    lassign $line _ _ a b _ _
    lassign $a ax ay
    lassign $b bx by

    # assume dx != 0 for the line.

    set dx    [expr {$bx - $ax}]
    set dy    [expr {$by - $ay}]
    set slope [expr {double($dy)/$dx}]

    set area  0
    set first 1
    set lasty {}
    set lastx {}
    foreach p $ps {
	lassign $p px py
	set ly [expr {$py - ($ay + ($px-$ax)*$slope)}]
	if {$first} {
	    set first 0
	    set lastx $px
	    set lasty $ly
	    continue
	}

	set dx   [expr {$px - $lastx}]
	set area [expr {$area + [trapezium-area $dx $lasty $ly]}]

	# prep next step
	set lastx $px
	set lasty $ly
    }

    set area [expr {abs ($area)}]

    #puts \t[list {*}$line // $area]
    return [list {*}$line $area]
}

proc under-profile {ps line} {
    lassign $line _ _ a b
    lassign $a ax ay
    lassign $b bx by

    set dx [expr {$bx - $ax}]

    # a vertical cannot be under
    if {$dx == 0} { return 0 }

    set dy    [expr {$by - $ay}]
    set slope [expr {double($dy)/$dx}]

    foreach p $ps {
	lassign $p x y
	set ly [expr {$ay + ($x-$ax)*$slope}]
	# stop if line is not under path. on (==) is ok.
	if {$ly > $y} { return 0 }
    }
    return 1
}

proc over-profile {ps line} {
    lassign $line _ _ a b
    lassign $a ax ay
    lassign $b bx by

    set dx [expr {$bx - $ax}]

    # a vertical cannot be over
    if {$dx == 0} { return 0 }

    set dy    [expr {$by - $ay}]
    set slope [expr {double($dy)/$dx}]

    foreach p $ps {
	lassign $p x y
	set ly [expr {$ay + ($x-$ax)*$slope}]
	# stop if line is not over path. on (==) is ok.
	if {$ly < $y} { return 0 }
    }
    return 1
}

proc trapezium-area {dx dyl dyr} {
    # Trapezium area calculation
    #
    #   -*.   -
    # dyl|\.  |dyl-dyr
    #    | \. |
    #    |  \.-
    #    |   *-
    #    |   |dyr
    #    *---*
    #    |dx-|
    #
    # area = dx *  dyr + 1/2 * dx * (dyl - dyr)
    #      = dx * (dyr + 1/2 * (dyl - dyr))
    #      = dx * (dyr + 1/2 * dyl - 1/2 * dyr)
    #      = dx * (dyr - 1/2 * dyr + 1/2 * dyl)
    #      = dx * (1/2 * dyr + 1/2 * dyl)
    #      = dx * 1/2 * (dyr + dyl)
    #
    return [expr {$dx*0.5*($dyl+$dyr)}]
}

proc fold {initial alist args} {
    # apply the command prefix ARGS to each element of the list and an
    # accumulator and place the result into the accumulator again. The
    # initial value of the accumulator is given as command
    # argument. The final accumulator is returned as the result.

    set a $initial
    foreach e $alist {
	set a [uplevel 1 [list {*}$args $a $e]]
    }
    return $a
}

proc map {alist args} {
    # apply the command prefix ARGS to each element of the list and
    # return the collected results as a list.

    return [lmap e $alist {
	uplevel 1 [list {*}$args $e]
    }]
}

proc filter {alist args} {
    # filter the list based on the acceptance command prefix in
    # ARGS. The prefix is called with each element of the list, and
    # has to return a boolean value. On true the element is accepted
    # and returned as part of the result. On false the element is
    # discarded and does appear in the result,

    return [lmap e $alist {
	if {![uplevel 1 [list {*}$args $e]]} continue
	set e
    }]
}

proc pairs {ps} {
    # compute a list of all pairs of points in ps.  the elements of
    # the resulting list are 4-tuples containing the point indices and
    # points, in the order (i j pi pj) where i < j

    set n [llength $ps]
    set result {}
    for {set i 0} {$i < $n} {incr i} {
	set a [lindex $ps $i]
	for {set j [expr {$i+1}]} {$j < $n} {incr j} {
	    set b [lindex $ps $j]
	    lappend result [list $i $j $a $b]
	}
    }
    return $result
}

proc linreg-v {path} {
    package require math::statistics

    if {![llength $path]} {
	return [list 0 0]
    }
    if {[llength $path] == 1} {
	return [list 0 0]
    }

    # Note: the incoming path is expected to be (near-)vertical. This
    # means a very large slope, nearing, or even reaching +/-Inf. This
    # is very bad. To avoid this the x- and y-coordiates are swapped,
    # making the path worked on internally near-horizontal instead,
    # with slops near zero. Much better.
    
    set xs [xs $path]
    set ys [ys $path]

    # avoid issue in linear-model running into "out of domain" for a
    # pure horizontal path.

    set xss  [lsort -real $xs]
    set xmin [lindex $xss 0]
    set xmax [lindex $xss end]
    
    if {$xmin == $xmax} {
	# exactly vertical
	set slope     0
	set intercept $xmin
    } else {
	# ignore the statistics after the parameters of the line
	lassign [::math::statistics::ransac-linear-model $ys $xs] intercept slope
	if {$intercept eq {} || $slope eq {}} {
	    # on ransac failure fall back to a plain linear model
	    puts \transac\tFAIL\tplain
	    lassign [::math::statistics::linear-model $ys $xs] intercept slope
	} else {
	    #puts \transac\tOK
	}
	# lassign [... $ys $xs] intercept slope
	#         swap -^---^
	# due to the coordinate swap the line is X = slope*Y + intercept
    }

    list $slope $intercept
}

proc linreg-h {path} {
    package require math::statistics
    
    if {![llength $path]} {
	return [list 0 0]
    }
    if {[llength $path] == 1} {
	return [list 0 0]
    }

    # Note: the incoming path is expected to be (near-)horizontal.

    set xs [xs $path]
    set ys [ys $path]

    # avoid issue in linear-model running into out of domain issue for a pure horizontal path at 0.

    set yss  [lsort -real $ys]
    set ymin [lindex $yss 0]
    set ymax [lindex $yss end]

    if {$ymin == $ymax} {
	# exactly horizontal
	set slope     0
	set intercept $ymin
    } else {
	# ignore the statistics after the parameters of the line
	lassign [::math::statistics::ransac-linear-model $xs $ys] intercept slope
	if {$intercept eq {} || $slope eq {}} {
	    # on ransac failure fall back to a plain linear model
	    puts \transac\tFAIL\tplain
	    lassign [::math::statistics::linear-model $xs $ys] intercept slope
	} else {
	    #puts \transac\tOK
	}

	# the line is Y = slope*X + intercept
    }

    list $slope $intercept
}

# # ## ### ##### ######## ############# #####################

proc titles {dict} {
    foreach {section title} $dict { title $section $title }
}

proc title {section title} {
    global stitle
    dict set stitle $section $title
}

proc code  {section args}  {
    global scode
    #if {![llength $args]} { lappend args nop }
    dict set scode $section [lmap name $args { list $name [body $name] }]
}

proc body {name} {
    string trimleft [join [lmap line [split [info body $name] \n] {
	# remove comment lines, except for glue markers and trailing
	if { [string match {*#*}  $line] &&     
	     (![string match *glue* $line] ||
	      ![string match "*;#*" $line])} continue
	dehead $line
    }] \n]
}

proc dehead {line} {
    regsub {^    } $line {} line
    regsub {^	} $line {    } line
    return $line
}

proc ordered {sections} {
    upvar 1 lines lines notedir notedir
    global stitle

    # a b c
    #
    # . a b
    # a b c
    # b c .

    set prev [list {} {*}[lrange $sections 0 end-1]]
    set next [list {*}[lrange $sections 1 end] {}]

    top
    foreach p $prev c $sections n $next {
	#header $p $c $n
	show      $c
	#footer
    }
    done
}

proc collect {} {
    upvar 1 lines lines    
    join $lines \n
}

proc top {} {
    upvar 1 notedir notedir
    set start [file join $notedir start.html]
    rtxt start
    + $start
}

proc done {} {
    upvar 1 notedir notedir
    set final [file join $notedir final.html]
    rtxt final
    + $final
}

proc header {prev now next} {
    global stitle ; set title [dict get $stitle $now]

    #    append nav "<a href='#top'>Start</a>"
    #    append nav " <a href='#done'>End</a>"
    #    if {$prev ne {}} { append nav " <a href='#$prev'>Previous</a>" }
    #    if {$next ne {}} { append nav " <a href='#$next'>Next</a>" }
    #   + <a name='$now'><hr></a>
    #   + <p>$nav</p>

    return
}

proc footer {} {
    # + </section>
}

proc show {section} {
    global scode  ; set code  [dict get $scode  $section]
    global stitle ; set title [dict get $stitle $section]
    #
    upvar 2 $section sipath notedir notedir dst dst

    set notes [file join $notedir ${section}.html]
    if {[catch { rtxt notes } msg]} { set notes {} }

    set highlight [highlight]
    
    if {[llength $code]} {
	append notes [join [lmap block $code {
	    lassign $block name body
	    set body [string map $highlight $body]
	    set name [string map {:: { }} $name]
	    #set _ "<table><tr><td valign='top'><b>${name}</b></td></tr><tr><td valign='top'><pre>$body<pre></td></tr></table>"
	    #set _ "<p>${name}</p>\n<p><pre>$body<pre></p>"
	    set _ "<section><h4 align='left'>${name}</h4><p><pre>${body}</pre></p></section>"
	}] \n]\n
    }

    set footnotes [file join $notedir ${section}_footnotes.html]
    if {[catch { rtxt footnotes } msg]} { set footnotes {} }
    append notes $footnotes

    #if {$notes eq {}} { set notes "&nbsp;" }

    file mkdir [file dirname $dst]/assets
    file copy $sipath [file dirname $dst]/assets/$section.jpg

    if {$notes ne {}} {
	+ {}
	+ <section id='$section' data-background='white'>
	+ "<h3>AK Tcl Image Vector Extension</h3>"
	+ $notes
	+ </section>
    }
    
    + <section id='$section' data-background='white'>
    + "<h3>AK Tcl Image Vector Extension</h3>"
    + "<h4 align='left'>$title</h4>"
    + <img src='assets/$section.jpg' height=500 style='border:4px solid gold'>
    + </section>

    return
}

proc + {args} {
    upvar 2 lines lines
    lappend lines [join $args { }]
}

proc nop {args} {}

proc highlight {} {
    foreach pattern {
	{aktive color css}
	{aktive image from band}
	{aktive image from color}
	{aktive image from sparse ranges}
	{aktive image mask per phansalkar}
	{aktive image sdf lines}
	{aktive image sdf line}
	{aktive image sdf polyline}
	{aktive image threshold global otsu}
	{aktive meta get}
	{aktive op color sRGB to gray}
	{aktive op column profile}
	{aktive op column rprofile}
	{aktive op connected-components get}
	{aktive op embed mirror}
	{aktive op if-then-else}
	{aktive op math add}
	{aktive op math mul}
	{aktive op math sub}
	{aktive op math1 exp}
	{aktive op math1 fit min-max}
	{aktive op math1 invert}
	{aktive op math1 linear}
	{aktive op math1 scale}
	{aktive op morph dilate}
	{aktive op morph erode}
	{aktive op morph gradient internal}
	{aktive op resize}
	{aktive op row profile}
	{aktive op row rprofile}
	{aktive op sdf round}
	{aktive op sdf or}
	{aktive op tile mean}
	{aktive op tile stddev}
	{aktive op transform by}
	{aktive op view}
	{aktive query domain}
	{aktive query geometry}
	{aktive query values}
	{aktive transform compose}
	{aktive transform invert}
	{aktive transform quad unit2}
	{aktive transform scale}
	{aktive transform points}
	{aktive}
	band
	dehug
    } {
	lappend map $pattern <b>${pattern}</b>
    }
    return $map
}

# # ## ### ##### ######## ############# #####################
## coordinator support

proc iter {inspec outspec args} {
    global base perf
    set paths [lsort -dict [glob -tails -directory $base/raw *.jpg]]
    set n     [llength $paths]
    set fmt   %[string length $n]s
    set n     [f $fmt $n]

    puts ""
    set done 0
    set start [clock milliseconds]
    foreach path $paths {
	# figure out the involved locations
	set stem [file rootname $path]
	set srcs [paths $inspec]
	set dsts [paths $outspec]

	# command & messaging
	set cmd     [list {*}$args {*}$srcs {*}$dsts]
	set message "[now]\t\[[f $fmt [incr k]]/$n\]\t[js $args] [js [tails $srcs]] [js [tails $dsts]]"
	# do nothing when inputs missing
	if {![inputs-ok $srcs]} continue

	# do nothing when results exist and are not out of date
	if {[results-ok $srcs $dsts]} continue

	# results missing, or out of date, recompute
	
	foreach d $dsts { file mkdir [file dirname $d] }
	puts $message
	uplevel #0 $cmd
	incr done
    }
    set end [clock milliseconds]

    if {!$done} { incr done }	;# avoid division by zero
    set delta     [expr {$end - $start}]
    set millisper [expr {$delta/double($done)}]

    puts [now]\tTIME\t[lindex $args 0]\t${done}x\t${millisper}ms\t=\t${delta}ms
    # save time data for sorted statistics at the end

    lappend perf [list $delta [lindex $args 0]]
}

proc now {} { clock format [clock seconds] }

proc js {words} { join $words { } }

proc inputs-ok {srcs} {
    foreach s $srcs {
	if {[file exists $s]} continue
	return 0
    }
    return 1
}

proc results-ok {srcs dsts} {
    set srctime 0
    foreach s $srcs {
	if {[file exists $s]} {
	    set srctime [expr {max ($srctime, [file mtime $s])}]
	    continue
	}
	error "Expected source missing: $s"
    }
    foreach d $dsts {
	if {![file exists $d]}          { return 0 }
	if {[file mtime $d] < $srctime} { return 0 }
    }
    return 1
}

proc f {f x} { format $f $x }

proc paths {spec} {
    upvar 1 stem stem
    set res {}
    foreach {dir exts} $spec {
	foreach ext $exts {
	    lappend res [path $dir $ext]
	}
    }
    return $res
}

proc tails {paths} {
    lmap path $paths { tail $path }
}

proc tail {path} {
    file join {*}[lrange [file split $path] end-1 end]
}

proc base {path}    { global base ; set base $path }
proc path {dir ext} { global base ; upvar 1 stem stem ; file join $base $dir $stem$ext }

proc mtimeo {paths} {
    set mt Inf
    foreach p $paths {
	#if {![file exists $path]} { return -Inf }
	set mt [expr {min (mt,[file mtime $path])}]
    }
    return $mt
}

proc placeholder {var} { upvar 1 $var x ; result wtxt x "" }

# marker commands, mainly no function, except for the debug controller
proc debug  {args}   { if {![debug?]} return ; uplevel 1 $args }
proc debugs {script} { if {![debug?]} return ; uplevel 1 $script }
proc result {args}   { uplevel 1 $args }
proc param  {args}   { uplevel 1 $args }

# format-specific data readers
proc pathof {var} {}

proc pnm {var} {
    upvar 1 $var v
    set v [aktive read from netpbm file path $v]
}

proc rtxt {var} {
    upvar 1 $var v
    set chan [open $v r]
    set v    [string trim [read $chan]]
    close $chan
    return
}

# format-specific result writers
proc ppm {var i}  {
    upvar 1 $var path
    aktive format as ppm byte 2file $i into $path
    exec convert $path [file rootname $path].jpg
}

proc pgm {var i} {
    upvar 1 $var path ;#puts [info level 0]\t($path)
    aktive format as pgm byte 2file $i into $path
    exec convert $path [file rootname $path].jpg
}

proc wtxt {var str} {
    upvar 1 $var path    
    set    chan [open $path w]
    puts  $chan $str
    close $chan
}

# # ## ### ##### ######## ############# #####################
# # ## ### ##### ######## ############# #####################

# ransac.tcl --
#     Implementation of the RANSAC algorithm (Random Sample Consensus)
#
#     Assumptions/limitations of the current implementation:
#     - The data allow for a linear model
#     - We have "enough" data and there is a discernable subset that lies close to a straight line
#     - The measure for error is the linear residue
#

package require math::statistics ;# base code, add ransac
namespace eval ::math::statistics {}

# split-random --
#     Split an index set into two separate sets in a random fashion
#
# Arguments:
#     number           Number of indices in the first set
#     totalNumber      Total number (N) of indices to chose from
#
# Result:
#     List of two sublists - the indices 0 ... N-1 are distributed uniquely over the two sublists
#
proc ::math::statistics::split-random {number totalNumber} {
    set training {}	;# set of indices to train/fit the linear model with
    set checking {}	;# set of indices to check the linear model against

    for {set i 0} {$i < $totalNumber} {incr i} {
        lappend checking $i
    }
    # llength checking == totalNumber

    for {set i 0} {$i < $number} {incr i} {
	# note: rand() returns a value in     (0,1), i.e. both 0 and 1 excluded.
	# times totalNumber makes this        (0,totalNumber)
	# converting to int() then makes this [0,totalNumber-1]

	set chosen [expr { int($totalNumber * rand()) }]

        lappend training [lindex $checking $chosen]
        set checking [lreplace $checking $chosen $chosen]
	incr totalNumber -1 ;# reduce selection range as checking gets smaller
    }

    return [list $training $checking]
}

# select-from --
#     Select data from a list of indices
#
# Arguments:
#     data             List of data to select from
#     idx              Indices for the selection
#
# Result:
#     Subset of the data
#
proc ::math::statistics::select-from {data idx} {
    return [lmap i $idx {
	lindex $data $i
    }]
}

# ransac-linear-model --
#     Estimate the "best" line through the data points
#
# Arguments:
#     xdata            The x-coordinates of the data points
#     ydata            The x-coordinates of the data points
#     args             Set of zero or more key-value pairs
#                      -initial-number        Initial number of data points to be selected (default: sqrt(N))
#                      -minimum-number        Minimum number of data points to accept the model (default: 0.5*N)
#                      -include-threshold     Threshold for including data points (default: 0.1 of ydata range)
#                      -iterations            Number of iterations (default: 100 - quite arbitrary)
#                      (more should be possible)
#
proc ::math::statistics::ransac-linear-model {xdata ydata args} {
    #
    # Determine the options
    #
    set n          [llength $xdata]
    set initNumber [expr {int(sqrt($n))}]
    set minNumber  [expr {int(0.6*$n)}]
    set iterations 100
    set threshold  [expr {0.1 * ([max $ydata] - [min $ydata])}]

    foreach {key value} $args {
        switch -- $key {
            "-initial-number"    { set initNumber $value }
            "-minimum-number"    { set minNumber  $value }
            "-include-threshold" { set threshold  $value }
            "-iterations"        { set iterations $value }
            default {
                return -code error "Unknown key word: $key"
            }
        }
    }

    #
    # Iteration:
    # - Randomly select the points to which the linear model is to be fitted
    # - See which of the other points fall within the criterium
    # - Accept the new model if it is better than the best on record
    #
    set currentModel       {}
    set currentCorrelation 0.0   ;# Use the correlation coefficient as the goodness of fit

    for {set iteration 0} {$iteration < $iterations} {incr iteration} {
	#
	# Select a training set and fit a model to it
	#
        lassign [split-random $initNumber $n] training checking
        set xsubset [select-from $xdata $training]
        set ysubset [select-from $ydata $training]

        set linearModel [linear-model $xsubset $ysubset]

        #
        # Which points in the non-training set are within the acceptable range?
	# Add these to the training.
        #
        set a [lindex $linearModel 0]
        set b [lindex $linearModel 1]

        foreach i $checking {
            set error [expr {abs( [lindex $ydata $i] - $b * [lindex $xdata $i] - $a )}]
            if { $error < $threshold } {
                lappend training $i
                lappend xsubset [lindex $xdata $i]
                lappend ysubset [lindex $ydata $i]
            }
        }

        #
        # Re-fit the model with the extended training set if the number of points in the set is
        # large enough.
        #
        if { [llength $training] > $minNumber } {
            set linearModel [linear-model $xsubset $ysubset]
            set correlation [lindex $linearModel 3]
            if { $correlation > $currentCorrelation } {
                set currentCorrelation $correlation
                set currentModel       $linearModel
	    }
        } else {
	    #ping \ttoo-small=[llength $training]/$minNumber
	}
    }

    return $currentModel
}

# # ## ### ##### ######## ############# #####################
# # ## ### ##### ######## ############# #####################

# # ## ### ##### ######## ############# #####################
## go

main
exit

# # ## ### ##### ######## ############# #####################
