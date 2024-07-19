# single element without center, angling, scaling

note The line connects the two specified locations.

point    from  Starting location
point    to    End location

if {$mode eq "sdf"} {
    example \
	-transform sdf-fit       \
	-transform sdf-smooth    \
	-transform sdf-pixelated \
	{width 128 height 128 from {10 10} to {30 80}}
}

