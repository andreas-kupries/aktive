## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Wiener filtering, Spatial
#
## References
#

# # ## ### ##### ######## ############# #####################

operator op::wiener {
    section transform wiener

    input

    uint? 2 radius	Filter radius. Actual window size is `2*k-1`. \
	The default value is 2. This is also the minimum allowed value.

    str? mirror embed	Embedding to use for the internal local \
	mean/variance information. The default, mirror, is chosen to not \
	affect the result as much as possible.

    note Returns input with a Wiener reconstruction  filter applied to it.
    note The location of the input is ignored.

    note The filter is applied to each band of the input separately.

    body {
	if {$radius < 2} { aktive error "Invalid radius $radius, expected a value >= 2" }

	# Multi-band ? Split, process each, and re-join.
	if {[aktive query depth $src] > 1} {
	    set cs    [aktive op query colorspace $src]
	    set src   [aktive op montage z {*}[lmap b [aktive op split z $src] { aktive op wiener $b k $k }]]
	    set src   [aktive op color set $src $cs]
	    return $src
	}

	# Single-band. Core wiener-filter.

	set src [aktive op embed $embed $src left $radius right $radius top $radius bottom $radius]

	set localmean [aktive op tile mean     $src radius $radius]	;# per-pixel means
	set localvar  [aktive op tile variance $src radius $radius]	;# per-pixel variances

	# beware: this semi-materializes the localvar at DAG construction time
	set noise     [aktive op image mean    $localvar]		;# global mean of variances

	set icenter [aktive op math  sub   $src $localmean]			;# center input, local means
	set vcenter [aktive op math1 shift $localvar offset [expr {-$noise}]]	;# center variance, global mean
	set vcpos   [aktive op math1 max   $vcenter  min 0]			;# cut negative centered variances
	set vpos    [aktive op math1 max   $localvar min $noise]		;# cut variances below center

	# combine the pieces into the final result

	set a [aktive op math div $icenter $vpos]
	set b [aktive op math mul $a $vcpos]
	set f [aktive op math add $b $localmean]

	return $f
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
