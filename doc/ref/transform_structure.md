# Documentation -- Reference Pages -- transform structure

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op align bottom](#op_align_bottom)
 - [aktive op align left](#op_align_left)
 - [aktive op align right](#op_align_right)
 - [aktive op align top](#op_align_top)
 - [aktive op center-origin x](#op_center_origin_x)
 - [aktive op center-origin xy](#op_center_origin_xy)
 - [aktive op center-origin y](#op_center_origin_y)
 - [aktive op center-origin z](#op_center_origin_z)
 - [aktive op crop](#op_crop)
 - [aktive op embed band black](#op_embed_band_black)
 - [aktive op embed band copy](#op_embed_band_copy)
 - [aktive op embed bg](#op_embed_bg)
 - [aktive op embed black](#op_embed_black)
 - [aktive op embed copy](#op_embed_copy)
 - [aktive op embed mirror](#op_embed_mirror)
 - [aktive op embed tile](#op_embed_tile)
 - [aktive op embed white](#op_embed_white)
 - [aktive op flip x](#op_flip_x)
 - [aktive op flip y](#op_flip_y)
 - [aktive op flip z](#op_flip_z)
 - [aktive op if-then-else](#op_if_then_else)
 - [aktive op rotate ccw](#op_rotate_ccw)
 - [aktive op rotate cw](#op_rotate_cw)
 - [aktive op rotate half](#op_rotate_half)
 - [aktive op sample decimate x](#op_sample_decimate_x)
 - [aktive op sample decimate xy](#op_sample_decimate_xy)
 - [aktive op sample decimate y](#op_sample_decimate_y)
 - [aktive op sample fill x](#op_sample_fill_x)
 - [aktive op sample fill xy](#op_sample_fill_xy)
 - [aktive op sample fill y](#op_sample_fill_y)
 - [aktive op sample fill z](#op_sample_fill_z)
 - [aktive op sample interpolate x](#op_sample_interpolate_x)
 - [aktive op sample interpolate xy](#op_sample_interpolate_xy)
 - [aktive op sample interpolate y](#op_sample_interpolate_y)
 - [aktive op sample replicate x](#op_sample_replicate_x)
 - [aktive op sample replicate xy](#op_sample_replicate_xy)
 - [aktive op sample replicate y](#op_sample_replicate_y)
 - [aktive op sample replicate z](#op_sample_replicate_z)
 - [aktive op sample sub x](#op_sample_sub_x)
 - [aktive op sample sub xy](#op_sample_sub_xy)
 - [aktive op sample sub y](#op_sample_sub_y)
 - [aktive op sample sub z](#op_sample_sub_z)
 - [aktive op scroll x](#op_scroll_x)
 - [aktive op scroll y](#op_scroll_y)
 - [aktive op scroll z](#op_scroll_z)
 - [aktive op select x](#op_select_x)
 - [aktive op select y](#op_select_y)
 - [aktive op select z](#op_select_z)
 - [aktive op split x](#op_split_x)
 - [aktive op split y](#op_split_y)
 - [aktive op split z](#op_split_z)
 - [aktive op swap xy](#op_swap_xy)
 - [aktive op swap xz](#op_swap_xz)
 - [aktive op swap yz](#op_swap_yz)
 - [aktive op take x](#op_take_x)
 - [aktive op take y](#op_take_y)
 - [aktive op take z](#op_take_z)
 - [aktive op transpose](#op_transpose)
 - [aktive op transverse](#op_transverse)

## Operators

---
### <a name='op_align_bottom'></a> aktive op align bottom

Syntax: __aktive op align bottom__ src ?(param value)...?

Returns image aligned to a border in a larger image.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|size|uint||Desired size of the image along the y-axis.|
|border|str|black|Method of embedding to use.|

---
### <a name='op_align_left'></a> aktive op align left

Syntax: __aktive op align left__ src ?(param value)...?

Returns image aligned to a border in a larger image.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|size|uint||Desired size of the image along the x-axis.|
|border|str|black|Method of embedding to use.|

---
### <a name='op_align_right'></a> aktive op align right

Syntax: __aktive op align right__ src ?(param value)...?

Returns image aligned to a border in a larger image.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|size|uint||Desired size of the image along the x-axis.|
|border|str|black|Method of embedding to use.|

---
### <a name='op_align_top'></a> aktive op align top

Syntax: __aktive op align top__ src ?(param value)...?

Returns image aligned to a border in a larger image.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|size|uint||Desired size of the image along the y-axis.|
|border|str|black|Method of embedding to use.|

---
### <a name='op_center_origin_x'></a> aktive op center-origin x

Syntax: __aktive op center-origin x__ src

Returns image where the center column of the input is shifted to the origin of the @@coordinate@@ axis.


---
### <a name='op_center_origin_xy'></a> aktive op center-origin xy

Syntax: __aktive op center-origin xy__ src

Returns image where the center pixel of the input is shifted to the origin.


---
### <a name='op_center_origin_y'></a> aktive op center-origin y

Syntax: __aktive op center-origin y__ src

Returns image where the center row of the input is shifted to the origin of the @@coordinate@@ axis.


---
### <a name='op_center_origin_z'></a> aktive op center-origin z

Syntax: __aktive op center-origin z__ src

Returns image where the center band of the input is shifted to the origin of the @@coordinate@@ axis.


---
### <a name='op_crop'></a> aktive op crop

Syntax: __aktive op crop__ src ?(param value)...?

Returns image containing a rectangular subset of input, specified by the amount of rows and columns to remove from the four borders.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|left|uint|0|Number of columns to remove from the left input border|
|right|uint|0|Number of columns to remove from the right input border|
|top|uint|0|Number of rows to remove from the top input border|
|bottom|uint|0|Number of rows to remove from the bottom input border|

---
### <a name='op_embed_band_black'></a> aktive op embed band black

Syntax: __aktive op embed band black__ src ?(param value)...?

Returns image embedding the input into a set of black bands.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|up|uint|0|Number of bands to add before the image bands|
|down|uint|0|Number of bands to add after the image bands|

---
### <a name='op_embed_band_copy'></a> aktive op embed band copy

Syntax: __aktive op embed band copy__ src ?(param value)...?

Returns image embedding the input into a set of copied bands.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|up|uint|0|Number of first band copies to add before the image bands|
|down|uint|0|Number of last band copies to add after the image bands|

---
### <a name='op_embed_bg'></a> aktive op embed bg

Syntax: __aktive op embed bg__ src ?(param value)...?

Returns image embedding the input into an arbitrarily colored border. The color is specified through the band values.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|left|uint|0|Number of columns to extend the left input border by|
|right|uint|0|Number of columns to extend the right input border by|
|top|uint|0|Number of rows to extend the top input border by|
|bottom|uint|0|Number of rows to extend the bottom input border by|
|values|double[]||Band values|

---
### <a name='op_embed_black'></a> aktive op embed black

Syntax: __aktive op embed black__ src ?(param value)...?

Returns image embedding the input into a black border.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|left|uint|0|Number of columns to extend the left input border by|
|right|uint|0|Number of columns to extend the right input border by|
|top|uint|0|Number of rows to extend the top input border by|
|bottom|uint|0|Number of rows to extend the bottom input border by|

---
### <a name='op_embed_copy'></a> aktive op embed copy

Syntax: __aktive op embed copy__ src ?(param value)...?

Returns image embedding the input into a border made from the replicated input edges.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|left|uint|0|Number of columns to extend the left input border by|
|right|uint|0|Number of columns to extend the right input border by|
|top|uint|0|Number of rows to extend the top input border by|
|bottom|uint|0|Number of rows to extend the bottom input border by|

---
### <a name='op_embed_mirror'></a> aktive op embed mirror

Syntax: __aktive op embed mirror__ src ?(param value)...?

Returns image embedding the input into a border made from the replicated mirrored input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|left|uint|0|Number of columns to extend the left input border by|
|right|uint|0|Number of columns to extend the right input border by|
|top|uint|0|Number of rows to extend the top input border by|
|bottom|uint|0|Number of rows to extend the bottom input border by|

---
### <a name='op_embed_tile'></a> aktive op embed tile

Syntax: __aktive op embed tile__ src ?(param value)...?

Returns image embedding the input into a border made from the replicated input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|left|uint|0|Number of columns to extend the left input border by|
|right|uint|0|Number of columns to extend the right input border by|
|top|uint|0|Number of rows to extend the top input border by|
|bottom|uint|0|Number of rows to extend the bottom input border by|

---
### <a name='op_embed_white'></a> aktive op embed white

Syntax: __aktive op embed white__ src ?(param value)...?

Returns image embedding the input into a white border.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|left|uint|0|Number of columns to extend the left input border by|
|right|uint|0|Number of columns to extend the right input border by|
|top|uint|0|Number of rows to extend the top input border by|
|bottom|uint|0|Number of rows to extend the bottom input border by|

---
### <a name='op_flip_x'></a> aktive op flip x

Syntax: __aktive op flip x__ src

Returns image which mirrors the input along the x-axis.


---
### <a name='op_flip_y'></a> aktive op flip y

Syntax: __aktive op flip y__ src

Returns image which mirrors the input along the y-axis.


---
### <a name='op_flip_z'></a> aktive op flip z

Syntax: __aktive op flip z__ src

Returns image which mirrors the input along the z-axis.


---
### <a name='op_if_then_else'></a> aktive op if-then-else

Syntax: __aktive op if-then-else__ src0 src1 src2

Choose between second and third images based on the content of the first.

All images have to have the same width and height. The selector image has to be single-band. The other images may have arbitrary depth, as long as both have the same.


---
### <a name='op_rotate_ccw'></a> aktive op rotate ccw

Syntax: __aktive op rotate ccw__ src

Returns image rotating the input 90 degrees counter clockwise


---
### <a name='op_rotate_cw'></a> aktive op rotate cw

Syntax: __aktive op rotate cw__ src

Returns image rotating the input 90 degrees clockwise.


---
### <a name='op_rotate_half'></a> aktive op rotate half

Syntax: __aktive op rotate half__ src

Returns image rotating the input 180 degrees (counter) clockwise.


---
### <a name='op_sample_decimate_x'></a> aktive op sample decimate x

Syntax: __aktive op sample decimate x__ src ?(param value)...?

Returns image with the input decimated along the x-axis according to the decimation factor (>= 1).

This is accomplished by sub sampling the result of a lowpass filter applied to the input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Decimation factor, range 2...|
|embed|str|mirror|Embedding to apply to prevent input from shrinking before sampled down.|

---
### <a name='op_sample_decimate_xy'></a> aktive op sample decimate xy

Syntax: __aktive op sample decimate xy__ src ?(param value)...?

Returns image with the input decimated along both x and y axes according to the decimation factor (>= 1).

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Decimation factor, range 2...|
|embed|str|mirror|Embedding to apply to prevent input from shrinking before sampled down.|

---
### <a name='op_sample_decimate_y'></a> aktive op sample decimate y

Syntax: __aktive op sample decimate y__ src ?(param value)...?

Returns image with the input decimated along the y-axis according to the decimation factor (>= 1).

This is accomplished by sub sampling the result of a lowpass filter applied to the input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Decimation factor, range 2...|
|embed|str|mirror|Embedding to apply to prevent input from shrinking before sampled down.|

---
### <a name='op_sample_fill_x'></a> aktive op sample fill x

Syntax: __aktive op sample fill x__ src ?(param value)...?

Returns image where the input is "zero-stuffed" along the x-axis according to the stuffing factor S (>= 1). The S-1 gaps in the result are set to the given fill value, with zero, i.e. 0, used by default.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Stuff factor, range 2...|
|fill|double|0|Pixel fill value|

---
### <a name='op_sample_fill_xy'></a> aktive op sample fill xy

Syntax: __aktive op sample fill xy__ src ?(param value)...?

Returns image where the input is "zero-stuffed" along both x and y axes according to the stuffing factor S (>= 1). The S-1 gaps in the result are set to the given fill value, with zero, i.e. 0, used by default.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Stuff factor, range 2...|
|fill|double|0|Pixel fill value|

---
### <a name='op_sample_fill_y'></a> aktive op sample fill y

Syntax: __aktive op sample fill y__ src ?(param value)...?

Returns image where the input is "zero-stuffed" along the y-axis according to the stuffing factor S (>= 1). The S-1 gaps in the result are set to the given fill value, with zero, i.e. 0, used by default.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Stuff factor, range 2...|
|fill|double|0|Pixel fill value|

---
### <a name='op_sample_fill_z'></a> aktive op sample fill z

Syntax: __aktive op sample fill z__ src ?(param value)...?

Returns image where the input is "zero-stuffed" along the z-axis according to the stuffing factor S (>= 1). The S-1 gaps in the result are set to the given fill value, with zero, i.e. 0, used by default.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Stuff factor, range 2...|
|fill|double|0|Pixel fill value|

---
### <a name='op_sample_interpolate_x'></a> aktive op sample interpolate x

Syntax: __aktive op sample interpolate x__ src ?(param value)...?

Returns image with the input interpolated along the x-axis according to the interpolation factor (>= 1).

This is accomplished by low-pass filtering applied to the result of zero-stuffing the input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Interpolation factor, range 2...|
|embed|str|mirror|Embedding to apply to prevent input from shrinking before sampled down.|

---
### <a name='op_sample_interpolate_xy'></a> aktive op sample interpolate xy

Syntax: __aktive op sample interpolate xy__ src ?(param value)...?

Returns image with the input interpolated along both x and y axes according to the interpolation factor (>= 1).

This is accomplished by low-pass filtering applied to the result of zero-stuffing the input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Interpolation factor, range 2...|
|embed|str|mirror|Embedding to apply to prevent input from shrinking before sampled down.|

---
### <a name='op_sample_interpolate_y'></a> aktive op sample interpolate y

Syntax: __aktive op sample interpolate y__ src ?(param value)...?

Returns image with the input interpolated along the y-axis according to the interpolation factor (>= 1).

This is accomplished by low-pass filtering applied to the result of zero-stuffing the input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Interpolation factor, range 2...|
|embed|str|mirror|Embedding to apply to prevent input from shrinking before sampled down.|

---
### <a name='op_sample_replicate_x'></a> aktive op sample replicate x

Syntax: __aktive op sample replicate x__ src (param value)...

Returns image where the input is stretched along the x-axis according to the stretching factor (>= 1), and the gaps are filled by replicating the preceding non-gap pixel.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Stretch factor, range 2...|

---
### <a name='op_sample_replicate_xy'></a> aktive op sample replicate xy

Syntax: __aktive op sample replicate xy__ src ?(param value)...?

Returns image where the input is stretched along both x and y axes according to the stretching factor (>= 1), and the gaps are filled by replicating the preceding non-gap pixel.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Stretch factor, range 2...|

---
### <a name='op_sample_replicate_y'></a> aktive op sample replicate y

Syntax: __aktive op sample replicate y__ src (param value)...

Returns image where the input is stretched along the y-axis according to the stretching factor (>= 1), and the gaps are filled by replicating the preceding non-gap pixel.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Stretch factor, range 2...|

---
### <a name='op_sample_replicate_z'></a> aktive op sample replicate z

Syntax: __aktive op sample replicate z__ src (param value)...

Returns image where the input is stretched along the z-axis according to the stretching factor (>= 1), and the gaps are filled by replicating the preceding non-gap pixel.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Stretch factor, range 2...|

---
### <a name='op_sample_sub_x'></a> aktive op sample sub x

Syntax: __aktive op sample sub x__ src ?(param value)...?

Returns image with the input sampled down along the x-axis according to the sampling factor S (>= 1). The result keeps every S'th pixel of the input. S-1 pixels after every kept pixel are removed.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Sampling factor, range 2...|

---
### <a name='op_sample_sub_xy'></a> aktive op sample sub xy

Syntax: __aktive op sample sub xy__ src ?(param value)...?

Returns image with the input sampled down along both x and y axes according to the sampling factor S (>= 1). The result keeps every S'th pixel of the input. S-1 pixels after every kept pixel are removed.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Sampling factor, range 2...|

---
### <a name='op_sample_sub_y'></a> aktive op sample sub y

Syntax: __aktive op sample sub y__ src ?(param value)...?

Returns image with the input sampled down along the y-axis according to the sampling factor S (>= 1). The result keeps every S'th pixel of the input. S-1 pixels after every kept pixel are removed.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Sampling factor, range 2...|

---
### <a name='op_sample_sub_z'></a> aktive op sample sub z

Syntax: __aktive op sample sub z__ src ?(param value)...?

Returns image with the input sampled down along the z-axis according to the sampling factor S (>= 1). The result keeps every S'th pixel of the input. S-1 pixels after every kept pixel are removed.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint|2|Sampling factor, range 2...|

---
### <a name='op_scroll_x'></a> aktive op scroll x

Syntax: __aktive op scroll x__ src (param value)...

Returns image with the pixels of the input shifted along the @@coordinate@@ axis so that the N'th column becomes the origin on that axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|offset|uint||x scroll offset|

---
### <a name='op_scroll_y'></a> aktive op scroll y

Syntax: __aktive op scroll y__ src (param value)...

Returns image with the pixels of the input shifted along the @@coordinate@@ axis so that the N'th row becomes the origin on that axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|offset|uint||y scroll offset|

---
### <a name='op_scroll_z'></a> aktive op scroll z

Syntax: __aktive op scroll z__ src (param value)...

Returns image with the pixels of the input shifted along the @@coordinate@@ axis so that the N'th band becomes the origin on that axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|offset|uint||z scroll offset|

---
### <a name='op_select_x'></a> aktive op select x

Syntax: __aktive op select x__ src ?(param value)...?

Returns image containing a contiguous subset of the input's columns.

The result has a properly reduced width.

The other two dimension are unchanged.

The 2D location of the first cell of the input going into the

result is the location of the result.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|from|uint||The input's first column to be placed into the result.|
|to|uint|from|The input's last column to be placed into the result. If not specified defaults to the first.|

---
### <a name='op_select_y'></a> aktive op select y

Syntax: __aktive op select y__ src ?(param value)...?

Returns image containing a contiguous subset of the input's rows.

The result has a properly reduced height.

The other two dimension are unchanged.

The 2D location of the first cell of the input going into the

result is the location of the result.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|from|uint||The input's first row to be placed into the result.|
|to|uint|from|The input's last row to be placed into the result. If not specified defaults to the first.|

---
### <a name='op_select_z'></a> aktive op select z

Syntax: __aktive op select z__ src ?(param value)...?

Returns image containing a contiguous subset of the input's bands.

The result has a properly reduced depth.

The other two dimension are unchanged.

The 2D location of the first cell of the input going into the

result is the location of the result.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|from|uint||The input's first band to be placed into the result.|
|to|uint|from|The input's last band to be placed into the result. If not specified defaults to the first.|

---
### <a name='op_split_x'></a> aktive op split x

Syntax: __aktive op split x__ src

Returns list containing each column of the input as separate image.


---
### <a name='op_split_y'></a> aktive op split y

Syntax: __aktive op split y__ src

Returns list containing each row of the input as separate image.


---
### <a name='op_split_z'></a> aktive op split z

Syntax: __aktive op split z__ src

Returns list containing each band of the input as separate image.


---
### <a name='op_swap_xy'></a> aktive op swap xy

Syntax: __aktive op swap xy__ src

Returns image with the x- and y-axes of the input exchanged.

The location of the image is not changed.


---
### <a name='op_swap_xz'></a> aktive op swap xz

Syntax: __aktive op swap xz__ src

Returns image with the x- and z-axes of the input exchanged.

The location of the image is not changed.


---
### <a name='op_swap_yz'></a> aktive op swap yz

Syntax: __aktive op swap yz__ src

Returns image with the y- and z-axes of the input exchanged.

The location of the image is not changed.


---
### <a name='op_take_x'></a> aktive op take x

Syntax: __aktive op take x__ src0 src1

Select values of the input (2nd argument) under the control of the index.

Takes two inputs of the same height and depth.

The first input, the index, is single-column.

Its height and depth match the second input.

The result image has the same geometry as the index.

The stored indices select, per result pixel, the column value to take from the second input and place into the result.

Indices are clamped to the interval 0 ... #columns of the second input.

Fractional indices are rounded down to integer.

The locations of index and data inputs are ignored.

The resut is placed at the coordinate origin/zero.


---
### <a name='op_take_y'></a> aktive op take y

Syntax: __aktive op take y__ src0 src1

Select values of the input (2nd argument) under the control of the index.

Takes two inputs of the same width and depth.

The first input, the index, is single-row.

Its width and depth match the second input.

The result image has the same geometry as the index.

The stored indices select, per result pixel, the row value to take from the second input and place into the result.

Indices are clamped to the interval 0 ... #rows of the second input.

Fractional indices are rounded down to integer.

The locations of index and data inputs are ignored.

The resut is placed at the coordinate origin/zero.


---
### <a name='op_take_z'></a> aktive op take z

Syntax: __aktive op take z__ src0 src1

Select values of the input (2nd argument) under the control of the index.

Takes two inputs of the same width and height.

The first input, the index, is single-band.

Its width and height match the second input.

The result image has the same geometry as the index.

The stored indices select, per result pixel, the band value to take from the second input and place into the result.

Indices are clamped to the interval 0 ... #bands of the second input.

Fractional indices are rounded down to integer.

The locations of index and data inputs are ignored.

The resut is placed at the coordinate origin/zero.


---
### <a name='op_transpose'></a> aktive op transpose

Syntax: __aktive op transpose__ src

Returns image with the input mirrored along the primary diagonal.

This is an alias of `swap xy`.


---
### <a name='op_transverse'></a> aktive op transverse

Syntax: __aktive op transverse__ src

Returns image with the input mirrored along the secondary diagonal.


