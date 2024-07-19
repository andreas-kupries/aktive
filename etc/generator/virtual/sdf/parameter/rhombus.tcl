note The rhombus is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, \
    and placed at the specified center.

sdf-whc

if {$mode eq "sdf"} {
    example \
	-transform sdf-fit       \
	-transform sdf-smooth    \
	-transform sdf-pixelated \
	{center {64 64} width 128 height 128 ewidth 32 eheight 32}
}
