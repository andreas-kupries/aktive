note The box is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, \
    with rounded corners per the radii, and placed at the specified center.

if {$mode eq "sdf"} {
    # core sdf
    example {
	center {64 64} width 128 height 128 ewidth 32 eheight 32 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
    example {
	center {64 64} width 128 height 128 ewidth 32 eheight 32 upleftradius 32 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 center {64 64} ewidth 32 eheight 32 upleftradius 32 outlined 1 color {1 0 0}
    }
} else {
    # just draw
    example {
	center {64 64} width 128 height 128 ewidth 32 eheight 32
    }
    example {
	center {64 64} width 128 height 128 ewidth 32 eheight 32 upleftradius 32 outlined 1
    }
    example {
	center {64 64} width 128 height 128 ewidth 32 eheight 32 upleftradius 32 antialiased 0
    }
}

uint? 0  upleftradius     Radius of element at upper left corner
uint? 0  uprightradius    Radius of element at upper right corner
uint? 0  downleftradius   Radius of element at lower left corner
uint? 0  downrightradius  Radius of element at lower right corner

note The radii default to 0, i.e. no rounded corners.

sdf-whc
