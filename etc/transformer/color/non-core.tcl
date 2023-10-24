## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################
## Force a colorspace on an image (essentially a kind of type cast)

operator op::color::set {
    external!
    section transform color

    note Forcibly sets the colorspace attribute of the input image to the specified value

    image src		Input to modify
    str   colorspace	New colorspace to assume
}

# # ## ### ##### ######## ############# #####################
## Convert chains of color conversions into proper operators
## implementing said chains.

foreach chain {
    {HSL sRGB HSV}
    {HSL sRGB scRGB}
    {HSL sRGB scRGB Grey}
    {HSL sRGB scRGB XYZ}
    {HSL sRGB scRGB XYZ Lab}
    {HSL sRGB scRGB XYZ Lab LCh}
    {HSL sRGB scRGB XYZ Yxy}

    {HSV sRGB scRGB}
    {HSV sRGB scRGB Grey}
    {HSV sRGB scRGB XYZ}
    {HSV sRGB scRGB XYZ Lab}
    {HSV sRGB scRGB XYZ Lab LCh}
    {HSV sRGB scRGB XYZ Yxy}

    {sRGB scRGB Grey}

    {sRGB scRGB XYZ}
    {sRGB scRGB XYZ Lab}
    {sRGB scRGB XYZ Lab LCh}
    {sRGB scRGB XYZ Yxy}

    {scRGB XYZ Lab}
    {scRGB XYZ Lab LCh}
    {scRGB XYZ Yxy}

    {XYZ Lab LCh}

    {Yxy XYZ Lab}
    {Yxy XYZ Lab LCh}

    {LCh Lab Grey}
} {
    set a [lindex $chain 0]
    set b [lindex $chain end]

    unset -nocomplain map

    lappend map %%a%%      $a
    lappend map %%b%%      $b

    # generate conversion code, Tcl
    set ab [lmap from [lrange $chain 0 end-1] to [lrange $chain 1 end] {
	set __ "set src \[aktive op color $from to $to \$src\]"
    }]

    lappend map %%chain%%  [join $ab \n]

    # ______________________________________________________________ a -> b conversion
    operator op::color::${a}::to::${b} [string map $map {
	section transform color

	note Returns image in %%b%% colorspace, from input in %%a%% colorspace.

	input

	body {
	    %%chain%%
	    return $src
	}
    }]
    # ______________________________________________________________

    # Grey cannot be converted back to color.
    if {$b eq "Grey"} continue

    # generate reverse conversion code, Tcl commands
    set ba [lreverse [lmap from [lrange $chain 0 end-1] to [lrange $chain 1 end] {
	set __ "set src \[aktive op color $to to $from \$src\]"
    }]] ;#                                ^------^- reversed also!
    lappend map %%rchain%% [join $ba \n]

    # ______________________________________________________________ b -> a conversion
    operator op::color::${b}::to::${a} [string map $map {
	section transform color

	note Returns image in %%a%% colorspace, from input in %%b%% colorspace.

	input

	body {
	    %%rchain%%
	    return $src
	}
    }]
    # ______________________________________________________________

    unset a b ab map
}

unset chain

##
# # ## ### ##### ######## ############# #####################
::return
