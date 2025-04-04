# many independent lines

note Each line connects two locations.

#fsegment... segments	Line segments
str... segments	Line segments	;# str'ing as placeholder for the actual segment type to come

if {$mode eq "sdf"} {
    # core sdf
    example {
	width 128 height 128 segments {{10.1 10.9} {30.3 80.6}} {{10.1 80.6} {30.3 10.9}} | sdf-fit ; sdf-smooth ; sdf-pixelated
    }
} elseif {$on} {
    # draw on
    example {
	butterfly
	@1 color {1 0 0} strokewidth 1.1 segments {{10.1 10.9} {30.3 80.6}} {{10.1 80.6} {30.3 10.9}}
    }
} else {
    # just draw
    example {
	width 128 height 128 segments {{10.1 10.9} {30.3 80.6}} {{10.1 80.6} {30.3 10.9}}
    }
    example {
	width 128 height 128 strokewidth 1.1 segments {{10.1 10.9} {30.3 80.6}} {{10.1 80.6} {30.3 10.9}}
    }
    example {
	width 128 height 128 antialiased 0 segments {{10.1 10.9} {30.3 80.6}} {{10.1 80.6} {30.3 10.9}}
    }
}
