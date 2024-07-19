# multi-element, no common center, angling, scaling

note The lines form a polyline through the specified points.

point... points    Points of the poly-line

if {$mode eq "sdf"} {
    example \
	-transform sdf-fit       \
	-transform sdf-smooth    \
	-transform sdf-pixelated \
	{width 128 height 128 points {10 10} {30 80} {80 30}}
}
