# multi-element, no common center, angling, scaling

note The lines form a polyline through the specified points.

fpoint... points   Points of the poly-line

if {$mode eq "sdf"} {
    # core sdf
    example {
	width 128 height 128 points {10.25 10.75} {30.3 80.6} {80.1 30.9} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 color {1 0 0} strokewidth 1.1 points {10.25 10.75} {30.3 80.6} {80.1 30.9}
    }
} else {
    # just draw
    example {
	width 128 height 128 points {10.25 10.75} {30.3 80.6} {80.1 30.9}
    }
    example {
	width 128 height 128 strokewidth 1.1 points {10.25 10.75} {30.3 80.6} {80.1 30.9}
    }
    example {
	width 128 height 128 antialiased 0 points {10.25 10.75} {30.3 80.6} {80.1 30.9}
    }
}
