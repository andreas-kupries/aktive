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

# Zoom: 1.Press   - start
#       1.Motion  - track
#       1.Release - end - configure to show spanned box
#       3         - unzoom a level

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.6
package require Tk
package require snit      ; #         Tcllib
package require Plotchart ; # 1.9 ; # Tklib
package require xyplot    ; #       # Tklib - Interactive resizing

package provide aktive::plot 0.0

# # ## ### ##### ######## ############# #####################
## Implementation

snit::widget aktive::plot {
    # # ## ### ##### ######## ############# #####################

    #typevariable ouroptions {-color -title -xscale -yscale}
    typevariable ouroptions {-color -title}

    variable mycolors {red green blue orange}
    variable mycindex 2 ;# start with blue

    method NextColor {} {
	set next [lindex $mycolors $mycindex]
	incr mycindex
	if {$mycindex >= [llength $mycolors]} { set mycindex 0 }
	return $next
    }

    proc Scale {series} {
	::Plotchart::determineScaleFromList $series
    }

    proc Default {o args} {
	upvar 1 options options
	if {[dict exists $options $o]} return
	dict set options $o [uplevel 1 $args]
	return
    }

    method Options {words} {
	upvar 1 options options

	# apply options
	set options $words

	# ensure that only legal options are used
	foreach o [dict keys $options] {
	    if {$o ni $ouroptions} {
		return -code error "illegal option $o, expected one of $ouroptions"
	    }
	}

	# Apply defaults to all missing parts
	Default -color  $self NextColor
	#Default -yscale Scale $series
	#Default -xscale Scale [list 0 [llength $series]]
	Default -title  string cat ""
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## Add plots to the canvas

    method vertical {x lowy highy args} {
	$self Options $args
	# make options are available as scalar variables
	dict with options {}

	$self Setup ${-title}

	set points [list $x $lowy $x $highy]
	incr myseries
	$myplot add_data series$myseries $points -color ${-color}
	return
    }

    method horizontal {y lowx highx args} {
	$self Options $args
	# make options are available as scalar variables
	dict with options {}

	$self Setup ${-title}

	set points [list $lowx $y $highx $y]
	incr myseries
	$myplot add_data series$myseries $points -color ${-color}
	return
    }

    method add {series args} {
	$self Options $args
	# make options are available as scalar variables
	dict with options {}

	$self Setup ${-title}

	# convert to coordinates taken by xyplot
	lassign {0 {}} x points ; foreach y $series { lappend points $x $y ; incr x }

	incr myseries
	$myplot add_data series$myseries $points -color ${-color}
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## Internal helpers - Track changes to the series and refresh the plot.

    method Setup {title} {
	if {$myplot ne {}} return
	set myplot [xyplot $win.xyp -xinteger 1 -xformat %d -title $title]
	pack $myplot -in $win -expand 1 -fill both
return
    }

    # # ## ### ##### ######## ############# #####################

    variable myplot   {}	;# xy plot to hold the series to come
    variable myseries 0		;# counter to generate ids for the series to come

    # # ## ### ##### ######## ############# #####################
}

# # ## ### ##### ######## ############# #####################
## ready
return
