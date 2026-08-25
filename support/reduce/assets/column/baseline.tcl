
# generate a column reducer function which simply calls on the existing reduction function
# for the handling of the bands of a pixel - this emulates the existing blitter setup. in
# other words, the baseline to compare perf against.
proc reduce-column-baseline {name _ _ _  _ _ _} {
    lappend map @name@ $name
    build-func column baseline $name $map
    return
}
