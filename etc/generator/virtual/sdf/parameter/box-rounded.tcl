note The box is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, \
    with rounded corners per the radii, and placed at the specified center.

if {$mode eq "sdf"} {
    example \
	-transform sdf-fit       \
	-transform sdf-smooth    \
	-transform sdf-pixelated \
	{center {64 64} width 128 height 128 ewidth 32 eheight 32}

    example \
	-transform sdf-fit       \
	-transform sdf-smooth    \
	-transform sdf-pixelated \
	{center {64 64} width 128 height 128 ewidth 32 eheight 32 upleftradius 32}
}

uint? 0  upleftradius     Radius of element at upper left corner
uint? 0  uprightradius    Radius of element at upper right corner
uint? 0  downleftradius   Radius of element at lower left corner
uint? 0  downrightradius  Radius of element at lower right corner

note The radii defauilt to 0, i.e. no rounded corners.

sdf-whc
