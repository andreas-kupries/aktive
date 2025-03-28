note The box is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, \
    with rounded corners per the radii, and placed at the specified center.

if {$mode eq "sdf"} {
    # core sdf
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8 upleftradius 32.32 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 center {64.25 64.75} ewidth 32.2 eheight 32.8 upleftradius 32.32 outlined 1.1 color {1 0 0}
    }
} else {
    # just draw
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8
    }
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8 upleftradius 32.32 outlined 1.1
    }
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8 upleftradius 32.32 antialiased 0
    }
}

double? 0  upleftradius     Radius of element at upper left corner
double? 0  uprightradius    Radius of element at upper right corner
double? 0  downleftradius   Radius of element at lower left corner
double? 0  downrightradius  Radius of element at lower right corner

note The radii default to 0, i.e. no rounded corners.

sdf-whc
