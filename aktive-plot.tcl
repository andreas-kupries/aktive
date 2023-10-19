## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## (c) 2023 Andreas Kupries

# @@ Meta Begin
# Package aktive::plot 0
# Meta author      {Andreas Kupries}
# Meta location    https://core.tcl.tk/akupries/aktive
# Meta platform    tcl
# Meta summary	   Simple XY plot widget
# Meta description Simple XY plot widget.
# Meta description Wrapper around Tklib's plotchart providing a simplified API
# Meta subject	   {XY plot} {plot widget} {plot XY series}
# Meta require     {Tcl 8.6-}
# Meta require     Tk
# Meta require     snit
# Meta require     Plotchart
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.6
package require Tk
package require snit      ; #         Tcllib
package require Plotchart ; # 1.9 ; # Tklib

package provide aktive::plot 0.0

# # ## ### ##### ######## ############# #####################
## Implementation

snit::widget aktive::plot {
    # # ## ### ##### ######## ############# #####################

    constructor {args} {
	canvas $win.c -bg white
	pack   $win.c -side top -expand 1 -fill both
        $self configurelist $args
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## Style options - plot color and title

    option  -color -default blue -configuremethod C-color
    method C-color {o value} {
	set options($o) $value
	catch {
	    $myplot dataconfig series -color $value
	}
	return
    }

    option  -title -default {} -configuremethod C-title
    method C-title {o value} {
	set options($o) $value
	catch {
	    $myplot title $value
	}
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## Fixed versus auto-scaled axes

    option -ylocked -default 1 -configuremethod C-locked
    option -xlocked -default 1 -configuremethod C-locked

    method C-locked {o value} {
	set options($o) $value
	$self Refresh
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## Variable holding series to show.

    option  -variable -configuremethod C-variable

    method C-variable {o value} {
	if {$options($o) ne {}} {
	    trace remove variable $options($o) write [mymethod UpdateData]
	}
	set options($o) $value
	if {$options($o) ne {}} {
	    trace add variable $options($o) write [mymethod Refresh]

	    # Force update now, to handle pre-existing data in the
	    # variable, if any, as such does not invoke the trace.
	    $self Refresh
	}
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## Internal helpers - Track changes to the series and refresh the plot.

    method Refresh {args} {
	catch { after cancel $myupdate }
	set myupdate [after idle [mymethod UpdateData]]
	return
    }

    method UpdateData {} {
	upvar #0 $options(-variable) series
	if {![info exists series]} return

	if {!$options(-ylocked)} {
	    set  yscale [::Plotchart::determineScaleFromList $series]
	    lset yscale 0 0
	} else {
	    set yscale {0 255 64}
	}

	if {!$options(-xlocked)} {
	    set  xscale [::Plotchart::determineScaleFromList [list 0 [llength $series]]]
	    lset xscale 0 0
	} else {
	    set xscale {0 255 64}
	}

	$win.c delete all

	set myplot [Plotchart::createXYPlot $win.c $xscale $yscale]
	$myplot title $options(-title)
	$myplot dataconfig series -color $options(-color)
	$myplot xconfig -format %d

	set x 0
	foreach y $series {
	    $myplot plot series $x $y
	    incr x
	}
	return
    }

    # # ## ### ##### ######## ############# #####################

    variable myplot   {} ; # plotchar xyplot for the series
    variable myupdate {} ; # idle token for defered update

    # # ## ### ##### ######## ############# #####################
}

# # ## ### ##### ######## ############# #####################
## ready
return
