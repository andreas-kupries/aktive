
    body {
	aktive op sdf or {*}[lmap a [lrange $points 0 end-1] b [lrange $points 1 end] {
	    aktive image sdf line x $x y $y width $width height $height \
		from $a to $b
	}]
    }
