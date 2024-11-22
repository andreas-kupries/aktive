note The circle has the `radius`, and is placed at the specified center.


if {$mode eq "sdf"} {
    # core sdf
    example {
	center {64 64} width 128 height 128 radius 32 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 center {64 64} radius 32 color {1 0 0} outlined 1
    }
} else {
    # just draw
    example {
	center {64 64} width 128 height 128 radius 32
    }
    example {
	center {64 64} width 128 height 128 radius 32 outlined 1
    }
    example {
	center {64 64} width 128 height 128 radius 32 antialiased 0
    }
}

uint? 1  radius     Circle radius
sdf-centered
