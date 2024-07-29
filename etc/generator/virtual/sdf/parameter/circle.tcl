note The circle has the `radius`, and is placed at the specified center.


if {$mode eq "sdf"} {
    example {
	center {64 64} width 128 height 128 radius 32 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
}

uint? 1  radius     Circle radius
sdf-centered
