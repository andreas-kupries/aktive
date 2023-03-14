## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################
## Convert chains of color conversions into proper operators
## implementing said chains.

foreach chain {
    {HSL sRGB scRGB}
    {HSL sRGB scRGB XYZ}
    {HSL sRGB scRGB XYZ Lab}
    {HSL sRGB scRGB XYZ Lab LCh}
    {HSL sRGB scRGB XYZ Yxy}

    {HSV sRGB scRGB}
    {HSV sRGB scRGB XYZ}
    {HSV sRGB scRGB XYZ Lab}
    {HSV sRGB scRGB XYZ Lab LCh}
    {HSV sRGB scRGB XYZ Yxy}

    {sRGB scRGB XYZ}
    {sRGB scRGB XYZ Lab}
    {sRGB scRGB XYZ Lab LCh}
    {sRGB scRGB XYZ Yxy}

    {scRGB XYZ Lab}
    {scRGB XYZ Lab LCh}
    {scRGB XYZ Yxy}

    {XYZ Lab LCh}
} {
    set a [lindex $chain 0]
    set b [lindex $chain end]

    # generate conversion code, Tcl
    set ab [lmap from [lrange $chain 0 end-1] to [lrange $chain 1 end] {
	set __ "set src \[aktive op color $from to $to \$src\]"
    }]
    set ba [lreverse [lmap from [lrange $chain 0 end-1] to [lrange $chain 1 end] {
	set __ "set src \[aktive op color $to to $from \$src\]"
    }]] ;#                                ^------^- reversed also!

    lappend map %%chain%%  [join $ab \n]
    lappend map %%rchain%% [join $ba \n]
    lappend map %%a%%      $a
    lappend map %%b%%      $b

    tcl-operator op::color::${a}::to::${b} [string map $map {
	section transform color

	note Returns image in %%a%% colorspace, from input in %%b%% colorspace.

	arguments src
	body {
	    %%chain%%
	    return $src
	}
    }]

    tcl-operator op::color::${b}::to::${a} [string map $map {
	section transform color

	note Returns image in %%b%% colorspace, from input in %%a%% colorspace.

	arguments src
	body {
	    %%rchain%%
	    return $src
	}
    }]

    unset a b ab map
}

unset chain

##
# # ## ### ##### ######## ############# #####################
::return
