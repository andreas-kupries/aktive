# single element without center, angling, scaling

note The triangle connects the points A, B, and C, in this order.

point    a          Triangle point A
point    b          Triangle point B
point    c          Triangle point C

if {$mode eq "sdf"} {
    example {
	width 128 height 128 a {10 10} b {30 80} c {80 30} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
}
