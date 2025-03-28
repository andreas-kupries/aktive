# single element without center, angling, scaling

note The line connects the two specified locations.

fpoint   from  Starting location
fpoint   to    End location

if {$mode eq "sdf"} {
    # core sdf
    example {
	width 128 height 128 from {10.1 10.9} to {30.3 80.6} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 from {10.1 10.9} to {30.3 80.6} color {1 0 0} strokewidth 1.1
    }
} else {
    # just draw
    example {
	width 128 height 128 from {10.1 10.9} to {30.3 80.6}
    }
    example {
	width 128 height 128 from {10.1 10.9} to {30.3 80.6} strokewidth 1.1
    }
    example {
	width 128 height 128 from {10.1 10.9} to {30.3 80.6} antialiased 0
    }
}
