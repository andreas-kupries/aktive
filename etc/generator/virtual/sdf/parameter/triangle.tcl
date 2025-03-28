# single element without center, angling, scaling

note The triangle connects the points A, B, and C, in this order.

fpoint   a          Triangle point A
fpoint   b          Triangle point B
fpoint   c          Triangle point C

if {$mode eq "sdf"} {
    # core sdf
    example {
	width 128 height 128 a {10.25 10.75} b {30.2 80.6} c {80.1 30.9} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 a {10.25 10.75} b {30.2 80.6} c {80.1 30.9} color {1 0 0} outlined 1.1
    }
} else {
    # just draw
    example {
	width 128 height 128 a {10.25 10.75} b {30.2 80.6} c {80.1 30.9}
    }
    example {
	width 128 height 128 a {10.25 10.75} b {30.2 80.6} c {80.1 30.9} outlined 1.1
    }
    example {
	width 128 height 128 a {10.25 10.75} b {30.2 80.6} c {80.1 30.9} antialiased 0
    }
}

