# single element without center, angling, scaling

note The line connects the two specified locations.

point    from  Starting location
point    to    End location

if {$mode eq "sdf"} {
    example {
	width 128 height 128 from {10 10} to {30 80} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
}

