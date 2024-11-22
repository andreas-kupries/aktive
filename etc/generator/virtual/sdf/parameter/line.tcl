# single element without center, angling, scaling

note The line connects the two specified locations.

point    from  Starting location
point    to    End location

if {$mode eq "sdf"} {
    # core sdf
    example {
	width 128 height 128 from {10 10} to {30 80} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 from {10 10} to {30 80} color {1 0 0} strokewidth 1
    }
} else {
    # just draw
    example {
	width 128 height 128 from {10 10} to {30 80}
    }
    example {
	width 128 height 128 from {10 10} to {30 80} strokewidth 1
    }
    example {
	width 128 height 128 from {10 10} to {30 80} antialiased 0
    }
}
