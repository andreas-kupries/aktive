note The parallelogram is axis-aligned, of width `2*ewidth+1`, height `2*eheight+1`, \
    skewed by `eskew`, and placed at the specified center.

uint? 1  eskew    Element skew
sdf-whc

if {$mode eq "sdf"} {
    example {
	center {64 64} width 128 height 128 ewidth 32 eheight 32 eskew 8 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
}
