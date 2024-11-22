# multi-element, no common center, angling, scaling

note The lines form a polyline through the specified points.

point... points    Points of the poly-line

if {$mode eq "sdf"} {
    # core sdf
    example {
	width 128 height 128 points {10 10} {30 80} {80 30} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 color {1 0 0} strokewidth 1 points {10 10} {30 80} {80 30}
    }
} else {
    # just draw
    example {
	width 128 height 128 points {10 10} {30 80} {80 30}
    }
    example {
	width 128 height 128 strokewidth 1 points {10 10} {30 80} {80 30}
    }
    example {
	width 128 height 128 antialiased 0 points {10 10} {30 80} {80 30}
    }
}
