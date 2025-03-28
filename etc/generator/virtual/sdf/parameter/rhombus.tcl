note The rhombus is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, \
    and placed at the specified center.

sdf-whc

if {$mode eq "sdf"} {
    # core sdf
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 center {64.25 64.75} ewidth 32.2 eheight 32.8 outlined 1.1 color {1 0 0} outlined 1
    }
} else {
    # just draw
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8
    }
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8 outlined 1.1
    }
    example {
	center {64.25 64.75} width 128 height 128 ewidth 32.2 eheight 32.8 antialiased 0
    }
}
