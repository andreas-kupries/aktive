note The circle has the `radius`, and is placed at the specified center.


if {$mode eq "sdf"} {
    # core sdf
    example {
	center {64.25 64.75} width 128 height 128 radius 32.5 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 center {64.25 64.75} radius 32.5 color {1 0 0} outlined 1.1
    }
} else {
    # just draw
    example {
	center {64.25 64.75} width 128 height 128 radius 32.5
    }
    example {
	center {64.25 64.75} width 128 height 128 radius 32.5 outlined 1.1
    }
    example {
	center {64.25 64.75} width 128 height 128 radius 32.5 antialiased 0
    }
}

double? 1  radius     Circle radius
sdf-centered
