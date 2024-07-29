# multi-element, no common center, angling, scaling

note The circles all have the same `radius`, and are placed at the specified centers.

uint? 1  radius     Circle radius
point... centers    Circle centers

if {$mode eq "sdf"} {
    example {
	width 128 height 128 radius 8 centers {10 10} {30 80} {80 30} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
}
