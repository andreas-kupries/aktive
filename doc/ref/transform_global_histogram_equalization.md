<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform global histogram equalization

## <anchor='top'> Table Of Contents

  - [transform global histogram](transform_global_histogram.md) ↗


### Operators

 - [aktive op equalization global](#op_equalization_global)

## Operators

---
### [↑](#top) <a name='op_equalization_global'></a> aktive op equalization global

Syntax: __aktive op equalization global__ src ?(param value)...? [[→ definition](/file?ci=trunk&ln=7&name=etc/transformer/filter/equalization.tcl)]

Returns input with equalized global histogram. The location of the input is ignored, and passed to the result.

When bandwise is __not__ set (default) then

- Single-band inputs are processed as is.

- Three-band inputs with a known color space images have their equivalent of the luminance channel processed. Inputs using an RGB space are converted into and out of a space where that is possible.

- Anything else has just their last band processed.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|bandwise|bool|0|Flag to process all bands of an image separately.|

#### <a name='op_equalization_global__references'></a> References

  - <https://en.wikipedia.org/wiki/Histogram_equalization>

  - <https://towardsdatascience.com/histogram-equalization-5d1013626e64>

  - <https://docs.opencv.org/4.x/d4/d1b/tutorial_histogram_equalization.html>

  - <https://docs.opencv.org/4.x/d5/daf/tutorial_py_histogram_equalization.html>

