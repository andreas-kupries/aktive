
double? 0 outlined	Outline thickness. Draw filled if zero (Default).

def modifier {
    if {$outlined < 0} { aktive error "expected an outline thickness >= 0" }
    if {$outlined > 0} {
	set outlined [expr {$outlined - [tcl::mathfunc::sign $outlined]}]
	set sdf [aktive op sdf ring $sdf thickness $outlined]
    }
}
