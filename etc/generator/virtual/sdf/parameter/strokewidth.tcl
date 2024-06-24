
uint? 0 strokewidth	Stroke width. Lines are `2*strokewidth+1` wide.

def modifier {
    if {$strokewidth != 0} { set sdf [aktive op sdf round $sdf radius $strokewidth] }
}
