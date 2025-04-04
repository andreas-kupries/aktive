
# binary tree of independent line-segments.
body {
    aktive op sdf or {*}[lmap s $segments {
	lassign $s a b
	aktive image sdf line x $x y $y width $width height $height from $a to $b
    }]
}
