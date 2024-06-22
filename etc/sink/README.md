# Sinks

Operations taking images and returning nothing.

  - Saving images using the `AKTIVE` format, or a host of the NetPBM formats.

  - Converting images into a Tcl dictionary representation. This is a materialization.

  - A `null` sink to simply trigger an image pipeline. Main use is performance debugging and
    benchmarking.

  - Global image statistics. These could be placed under `accessor` as well, and it would likely be
    the better place.

  - Converting image pipelines to other representations, notably Tcl script, Markdown (table), and
    [D2 - declarative diagram](https://d2lang.com/). These do not materialize anything. They can be
    classified as accessors too.

## Example to the last:

Running the script

```
set i [aktive image sdf circle width 11 height 11 radius 3 center {5 5}]
set i [aktive image threshold phansalkar $i radius 7]

foreach format {
    tclscript
    markdown
    d2
} {
    puts "### $format"
    puts ""
    if {$format ne "markdown"} { puts "\`\`\`" }
    puts [aktive format as $format $i]
    if {$format ne "markdown"} { puts "\`\`\`" }
    puts ""
}
```

returns the image pipeline rendered in all possible formats, shown below.
For D2 the PNG made from the SVG made by D2 is also shown.

### tclscript

```
set tmp1     [aktive image sdf circle width 11 height 11 x 0 y 0 radius 3 center {5 5}]	;# FO(2): tmp2, tmp3
set tmp2     [aktive op flip x $tmp1]	;# FO(2): tmp3, tmp4
set tmp3     [aktive op montage x-core $tmp2 $tmp1]
set tmp4     [aktive op montage x-core $tmp3 $tmp2]	;# FO(2): tmp5, tmp6
set tmp5     [aktive op flip y $tmp4]	;# FO(2): tmp6, tmp7
set tmp6     [aktive op montage y-core $tmp5 $tmp4]
set tmp7     [aktive op montage y-core $tmp6 $tmp5]
set tmp8     [aktive op select x $tmp7 from 4 to 28]
set tmp9     [aktive op select y $tmp8 from 4 to 28]
set tmp10    [aktive op location move to $tmp9 x -7 y -7]	;# FO(2): tmp11, tmp15
set tmp11    [aktive op tile mean $tmp10 radius 7]	;# FO(2): tmp12, result
set tmp12    [aktive op math1 scale $tmp11 factor -10.0]
set tmp13    [aktive op math1 exp $tmp12]
set tmp14    [aktive op math1 scale $tmp13 factor 3.0]
set tmp15    [aktive op tile stddev $tmp10 radius 7]
set tmp16    [aktive op math1 scale $tmp15 factor 2.0]
set tmp17    [aktive op math1 shift $tmp16 offset -1.0]
set tmp18    [aktive op math1 scale $tmp17 factor 0.25]
set tmp19    [aktive op math1 shift $tmp18 offset 1.0]
set tmp20    [aktive op math add-core $tmp14 $tmp19]
set result   [aktive op math mul-core $tmp11 $tmp20]
```

### markdown

||Id|Command|Config|Inputs|Notes|
|:---|:---|:---|:---|:---|:---|
||1|aktive image sdf circle|width 11 height 11 x 0 y 0 radius 3 center {5 5}||FO(2): 3, 2|
||2|aktive op flip x||1|FO(2): 4, 3|
||3|aktive op montage x-core||2, 1||
||4|aktive op montage x-core||3, 2|FO(2): 6, 5|
||5|aktive op flip y||4|FO(2): 7, 6|
||6|aktive op montage y-core||5, 4||
||7|aktive op montage y-core||6, 5||
||8|aktive op select x|from 4 to 28|7||
||9|aktive op select y|from 4 to 28|8||
||10|aktive op location move to|x -7 y -7|9|FO(2): 11, 15|
||11|aktive op tile mean|radius 7|10|FO(2): 21, 12|
||12|aktive op math1 scale|factor -10.0|11||
||13|aktive op math1 exp||12||
||14|aktive op math1 scale|factor 3.0|13||
||15|aktive op tile stddev|radius 7|10||
||16|aktive op math1 scale|factor 2.0|15||
||17|aktive op math1 shift|offset -1.0|16||
||18|aktive op math1 scale|factor 0.25|17||
||19|aktive op math1 shift|offset 1.0|18||
||20|aktive op math add-core||14, 19||
|__OUT__|21|aktive op math mul-core||11, 20||

### d2

```
# -*- d2 -*-
direction: left
1: "aktive image sdf circle\n(width 11 height 11 x 0 y 0 radius 3 center {5 5})"
1.shape: oval
2: "aktive op flip x"
2.shape: oval
1 -> 2
3: "aktive op montage x-core"
3.shape: oval
2 -> 3
1 -> 3
4: "aktive op montage x-core"
4.shape: oval
3 -> 4
2 -> 4
5: "aktive op flip y"
5.shape: oval
4 -> 5
6: "aktive op montage y-core"
6.shape: oval
5 -> 6
4 -> 6
7: "aktive op montage y-core"
7.shape: oval
6 -> 7
5 -> 7
8: "aktive op select x\n(from 4 to 28)"
8.shape: oval
7 -> 8
9: "aktive op select y\n(from 4 to 28)"
9.shape: oval
8 -> 9
10: "aktive op location move to\n(x -7 y -7)"
10.shape: oval
9 -> 10
11: "aktive op tile mean\n(radius 7)"
11.shape: oval
10 -> 11
12: "aktive op math1 scale\n(factor -10.0)"
12.shape: oval
11 -> 12
13: "aktive op math1 exp"
13.shape: oval
12 -> 13
14: "aktive op math1 scale\n(factor 3.0)"
14.shape: oval
13 -> 14
15: "aktive op tile stddev\n(radius 7)"
15.shape: oval
10 -> 15
16: "aktive op math1 scale\n(factor 2.0)"
16.shape: oval
15 -> 16
17: "aktive op math1 shift\n(offset -1.0)"
17.shape: oval
16 -> 17
18: "aktive op math1 scale\n(factor 0.25)"
18.shape: oval
17 -> 18
19: "aktive op math1 shift\n(offset 1.0)"
19.shape: oval
18 -> 19
20: "aktive op math add-core"
20.shape: oval
14 -> 20
19 -> 20
21: "aktive op math mul-core"
21.shape: oval
21.style.fill: orange
11 -> 21
20 -> 21
```

This can be converted into an SVG via the `d2` command,
and then into a PNG image with a number of tools. This
results in:

![phansalkar pipeline](/doc/trunk/etc/sink/README-pipeline.png)

