# transform statistics

||||||||
|---|---|---|---|---|---|---|
|[Home ↗](/)|[Main ↗](index.md)|[Sections](index.md#sectree)|[Permuted Sections](bypsections.md)|[Names](byname.md)|[Permuted Names](bypnames.md)|[Implementations](bylang.md)|

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op band arg ge](#op_band_arg_ge)
 - [aktive op band arg gt](#op_band_arg_gt)
 - [aktive op band arg le](#op_band_arg_le)
 - [aktive op band arg lt](#op_band_arg_lt)
 - [aktive op band arg max](#op_band_arg_max)
 - [aktive op band arg min](#op_band_arg_min)
 - [aktive op band cumulative](#op_band_cumulative)
 - [aktive op band histogram](#op_band_histogram)
 - [aktive op band max](#op_band_max)
 - [aktive op band mean](#op_band_mean)
 - [aktive op band median](#op_band_median)
 - [aktive op band min](#op_band_min)
 - [aktive op band otsu](#op_band_otsu)
 - [aktive op band rank](#op_band_rank)
 - [aktive op band stddev](#op_band_stddev)
 - [aktive op band sum](#op_band_sum)
 - [aktive op band sumsquared](#op_band_sumsquared)
 - [aktive op band variance](#op_band_variance)
 - [aktive op column arg max](#op_column_arg_max)
 - [aktive op column arg min](#op_column_arg_min)
 - [aktive op column cumulative](#op_column_cumulative)
 - [aktive op column histogram](#op_column_histogram)
 - [aktive op column max](#op_column_max)
 - [aktive op column mean](#op_column_mean)
 - [aktive op column median](#op_column_median)
 - [aktive op column min](#op_column_min)
 - [aktive op column otsu](#op_column_otsu)
 - [aktive op column profile](#op_column_profile)
 - [aktive op column rank](#op_column_rank)
 - [aktive op column stddev](#op_column_stddev)
 - [aktive op column sum](#op_column_sum)
 - [aktive op column sumsquared](#op_column_sumsquared)
 - [aktive op column variance](#op_column_variance)
 - [aktive op image histogram](#op_image_histogram)
 - [aktive op row arg max](#op_row_arg_max)
 - [aktive op row arg min](#op_row_arg_min)
 - [aktive op row cumulative](#op_row_cumulative)
 - [aktive op row histogram](#op_row_histogram)
 - [aktive op row max](#op_row_max)
 - [aktive op row mean](#op_row_mean)
 - [aktive op row median](#op_row_median)
 - [aktive op row min](#op_row_min)
 - [aktive op row otsu](#op_row_otsu)
 - [aktive op row profile](#op_row_profile)
 - [aktive op row rank](#op_row_rank)
 - [aktive op row stddev](#op_row_stddev)
 - [aktive op row sum](#op_row_sum)
 - [aktive op row sumsquared](#op_row_sumsquared)
 - [aktive op row variance](#op_row_variance)
 - [aktive op tile histogram](#op_tile_histogram)
 - [aktive op tile max](#op_tile_max)
 - [aktive op tile mean](#op_tile_mean)
 - [aktive op tile median](#op_tile_median)
 - [aktive op tile min](#op_tile_min)
 - [aktive op tile rank](#op_tile_rank)
 - [aktive op tile stddev](#op_tile_stddev)
 - [aktive op tile sum](#op_tile_sum)
 - [aktive op tile sumsquared](#op_tile_sumsquared)
 - [aktive op tile variance](#op_tile_variance)

## Operators

---
### <a name='op_band_arg_ge'></a> aktive op band arg ge

Syntax: __aktive op band arg ge__ src0 src1

Returns the second image with its input bands compressed to a single value, the first index where the band value is greater than or equal than the threshold provided by the first image. The result is a single-band image with width and height of the inputs.

If no band matches the condition the result is the depth of the data image.

Both images have to have the same width and height.

The threshold image has to be single-band.


---
### <a name='op_band_arg_gt'></a> aktive op band arg gt

Syntax: __aktive op band arg gt__ src0 src1

Returns the second image with its input bands compressed to a single value, the first index where the band value is greater than than the threshold provided by the first image. The result is a single-band image with width and height of the inputs.

If no band matches the condition the result is the depth of the data image.

Both images have to have the same width and height.

The threshold image has to be single-band.


---
### <a name='op_band_arg_le'></a> aktive op band arg le

Syntax: __aktive op band arg le__ src0 src1

Returns the second image with its input bands compressed to a single value, the first index where the band value is lesser than or equal than the threshold provided by the first image. The result is a single-band image with width and height of the inputs.

If no band matches the condition the result is the depth of the data image.

Both images have to have the same width and height.

The threshold image has to be single-band.


---
### <a name='op_band_arg_lt'></a> aktive op band arg lt

Syntax: __aktive op band arg lt__ src0 src1

Returns the second image with its input bands compressed to a single value, the first index where the band value is lesser than than the threshold provided by the first image. The result is a single-band image with width and height of the inputs.

If no band matches the condition the result is the depth of the data image.

Both images have to have the same width and height.

The threshold image has to be single-band.


---
### <a name='op_band_arg_max'></a> aktive op band arg max

Syntax: __aktive op band arg max__ src

Returns image with input bands compressed to a single value, the first index of the maximal band values. The result is a single-band image with width and height of the input.


---
### <a name='op_band_arg_min'></a> aktive op band arg min

Syntax: __aktive op band arg min__ src

Returns image with input bands compressed to a single value, the first index of the minimal band values. The result is a single-band image with width and height of the input.


---
### <a name='op_band_cumulative'></a> aktive op band cumulative

Syntax: __aktive op band cumulative__ src

Returns image with the input bands transformed into cumulative sums.

This means that each pixel in a band is the sum of the values in the bands before it, having the same row and column.

The result has the same geometry as the input. Only the contents change.


---
### <a name='op_band_histogram'></a> aktive op band histogram

Syntax: __aktive op band histogram__ src ?(param value)...?

Returns image with input bands transformed into a histogram of `bins` values.

The result is an image of bin-sized histogram bands with width and height of the input

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|bins|int|256|The number of bins held by a single histogram. The pixel values are quantized to fit. Only values in the range of [0..1] are considered valid. Values outside of that range are placed into the smallest/largest bin. The default quantizes the image values to 8-bit.|

---
### <a name='op_band_max'></a> aktive op band max

Syntax: __aktive op band max__ src

Returns image with input bands compressed to a single value, the maximum of the band values. The result is a single-band image with width and height of the input.


---
### <a name='op_band_mean'></a> aktive op band mean

Syntax: __aktive op band mean__ src

Returns image with input bands compressed to a single value, the arithmetic mean of the band values. The result is a single-band image with width and height of the input.


---
### <a name='op_band_median'></a> aktive op band median

Syntax: __aktive op band median__ src

Returns image with input bands compressed to a single value, the median of the sorted band values.

The result is a single-band image with width and height of the input


---
### <a name='op_band_min'></a> aktive op band min

Syntax: __aktive op band min__ src

Returns image with input bands compressed to a single value, the minimum of the band values. The result is a single-band image with width and height of the input.


---
### <a name='op_band_otsu'></a> aktive op band otsu

Syntax: __aktive op band otsu__ src

Returns image with the input bands compressed into an otsu threshold.

This assumes as input an image of band histograms.

The result has the same width and height as the input.

The result is single-band.


---
### <a name='op_band_rank'></a> aktive op band rank

Syntax: __aktive op band rank__ src ?(param value)...?

Returns image with input bands compressed to a single value, the chosen rank of the sorted band values.

The result is a single-band image with width and height of the input

Beware. While it is possible to use the rank filter for max/min extractions it is recommended to use the specific max/min operators instead, as they should be faster (linear scan of region, no gather, no sorting of the region).

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|rank|int|-1|Index of the sorted values to return. Default creates a median filter. 0 creates min-filter.|

---
### <a name='op_band_stddev'></a> aktive op band stddev

Syntax: __aktive op band stddev__ src

Returns image with input bands compressed to a single value, the standard deviation of the band values. The result is a single-band image with width and height of the input.


---
### <a name='op_band_sum'></a> aktive op band sum

Syntax: __aktive op band sum__ src

Returns image with input bands compressed to a single value, the sum of the band values. The result is a single-band image with width and height of the input.


---
### <a name='op_band_sumsquared'></a> aktive op band sumsquared

Syntax: __aktive op band sumsquared__ src

Returns image with input bands compressed to a single value, the sum of the squared band values. The result is a single-band image with width and height of the input.


---
### <a name='op_band_variance'></a> aktive op band variance

Syntax: __aktive op band variance__ src

Returns image with input bands compressed to a single value, the variance of the band values. The result is a single-band image with width and height of the input.


---
### <a name='op_column_arg_max'></a> aktive op column arg max

Syntax: __aktive op column arg max__ src

Returns image with input columns compressed to a single value, the first index of the maximal column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_column_arg_min'></a> aktive op column arg min

Syntax: __aktive op column arg min__ src

Returns image with input columns compressed to a single value, the first index of the minimal column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_column_cumulative'></a> aktive op column cumulative

Syntax: __aktive op column cumulative__ src

Returns image with the input columns transformed into cumulative sums.

This means that each pixel in a column is the sum of the values in the row before it, having the same column.

The result has the same geometry as the input. Only the contents change.


---
### <a name='op_column_histogram'></a> aktive op column histogram

Syntax: __aktive op column histogram__ src ?(param value)...?

Returns image with input columns transformed into a histogram of `bins` values.

The result is an image of `bins`-sized histogram columns with width and depth of the input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|bins|int|256|The number of bins held by a single histogram. The pixel values are quantized to fit. Only values in the range of [0..1] are considered valid. Values outside of that range are placed into the smallest/largest bin. The default quantizes the image values to 8-bit.|

---
### <a name='op_column_max'></a> aktive op column max

Syntax: __aktive op column max__ src

Returns image with input columns compressed to a single value, the maximum of the column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_column_mean'></a> aktive op column mean

Syntax: __aktive op column mean__ src

Returns image with input columns compressed to a single value, the arithmetic mean of the column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_column_median'></a> aktive op column median

Syntax: __aktive op column median__ src

Returns image with input columns compressed to a single value, the median of the sorted column values.

The result is a single-column image with height and depth of the input


---
### <a name='op_column_min'></a> aktive op column min

Syntax: __aktive op column min__ src

Returns image with input columns compressed to a single value, the minimum of the column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_column_otsu'></a> aktive op column otsu

Syntax: __aktive op column otsu__ src

Returns image with the input columns compressed into an otsu threshold.

This assumes as input an image of column histograms.

The result has the same width and depth as the input.

The result has a single row.


---
### <a name='op_column_profile'></a> aktive op column profile

Syntax: __aktive op column profile__ src

Returns image with input columns transformed into a profile.

Where a profile contains, per column, the distance of the first pixel != 0

from the top border of the input.

The result is a single-row image with width and depth of the input.


---
### <a name='op_column_rank'></a> aktive op column rank

Syntax: __aktive op column rank__ src ?(param value)...?

Returns image with input columns compressed to a single value, the chosen rank of the sorted column values.

The result is a single-row image with width and depth of the input

Beware. While it is possible to use the rank filter for max/min extractions it is recommended to use the specific max/min operators instead, as they should be faster (linear scan of region, no gather, no sorting of the region).

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|rank|int|-1|Index of the sorted values to return. Default creates a median filter. 0 creates min-filter.|

---
### <a name='op_column_stddev'></a> aktive op column stddev

Syntax: __aktive op column stddev__ src

Returns image with input columns compressed to a single value, the standard deviation of the column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_column_sum'></a> aktive op column sum

Syntax: __aktive op column sum__ src

Returns image with input columns compressed to a single value, the sum of the column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_column_sumsquared'></a> aktive op column sumsquared

Syntax: __aktive op column sumsquared__ src

Returns image with input columns compressed to a single value, the sum of the squared column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_column_variance'></a> aktive op column variance

Syntax: __aktive op column variance__ src

Returns image with input columns compressed to a single value, the variance of the column values. The result is a single-row image with width and depth of the input.

The part about the `depth of the input` means that the bands in each column are handled separately.


---
### <a name='op_image_histogram'></a> aktive op image histogram

Syntax: __aktive op image histogram__ src ?(param value)...?

Returns image with the input transformed into a histogram of `bins` values.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|bins|int|256|The number of bins in the returned histogram. The pixel values are quantized to fit. Only values in the range of [0..1] are considered valid. Values outside of that range are placed into the smallest/largest bin. The default quantizes the image values to 8-bit.|

---
### <a name='op_row_arg_max'></a> aktive op row arg max

Syntax: __aktive op row arg max__ src

Returns image with input rows compressed to a single value, the first index of the maximal row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_row_arg_min'></a> aktive op row arg min

Syntax: __aktive op row arg min__ src

Returns image with input rows compressed to a single value, the first index of the minimal row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_row_cumulative'></a> aktive op row cumulative

Syntax: __aktive op row cumulative__ src

Returns image with the input rows transformed into cumulative sums.

This means that each pixel in a row is the sum of the values in the column before it, having the same row.

The result has the same geometry as the input. Only the contents change.


---
### <a name='op_row_histogram'></a> aktive op row histogram

Syntax: __aktive op row histogram__ src ?(param value)...?

Returns image with input rows transformed into a histogram of `bins` values.

The result is an image of `bins`-sized histogram rows with height and depth of the input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|bins|int|256|The number of bins held by a single histogram. The pixel values are quantized to fit. Only values in the range of [0..1] are considered valid. Values outside of that range are placed into the smallest/largest bin. The default quantizes the image values to 8-bit.|

---
### <a name='op_row_max'></a> aktive op row max

Syntax: __aktive op row max__ src

Returns image with input rows compressed to a single value, the maximum of the row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_row_mean'></a> aktive op row mean

Syntax: __aktive op row mean__ src

Returns image with input rows compressed to a single value, the arithmetic mean of the row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_row_median'></a> aktive op row median

Syntax: __aktive op row median__ src

Returns image with input rows compressed to a single value, the median of the sorted row values.

The result is a single-row image with width and depth of the input


---
### <a name='op_row_min'></a> aktive op row min

Syntax: __aktive op row min__ src

Returns image with input rows compressed to a single value, the minimum of the row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_row_otsu'></a> aktive op row otsu

Syntax: __aktive op row otsu__ src

Returns image with the input rows compressed into an otsu threshold.

This assumes as input an image of row histograms.

The result has the same height and depth as the input.

The result has a single column.


---
### <a name='op_row_profile'></a> aktive op row profile

Syntax: __aktive op row profile__ src

Returns image with input rows transformed into a profile.

Where a profile contains, per row, the distance of the first pixel != 0

from the left border of the input.

The result is a single-column image with height and depth of the input.


---
### <a name='op_row_rank'></a> aktive op row rank

Syntax: __aktive op row rank__ src ?(param value)...?

Returns image with input rows compressed to a single value, the chosen rank of the sorted row values.

The result is a single-column image with height and depth of the input

Beware. While it is possible to use the rank filter for max/min extractions it is recommended to use the specific max/min operators instead, as they should be faster (linear scan of region, no gather, no sorting of the region).

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|rank|int|-1|Index of the sorted values to return. Default creates a median filter. 0 creates min-filter.|

---
### <a name='op_row_stddev'></a> aktive op row stddev

Syntax: __aktive op row stddev__ src

Returns image with input rows compressed to a single value, the standard deviation of the row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_row_sum'></a> aktive op row sum

Syntax: __aktive op row sum__ src

Returns image with input rows compressed to a single value, the sum of the row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_row_sumsquared'></a> aktive op row sumsquared

Syntax: __aktive op row sumsquared__ src

Returns image with input rows compressed to a single value, the sum of the squared row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_row_variance'></a> aktive op row variance

Syntax: __aktive op row variance__ src

Returns image with input rows compressed to a single value, the variance of the row values. The result is a single-column image with height and depth of the input.

The part about the `depth of the input` means that the bands in each row are handled separately.


---
### <a name='op_tile_histogram'></a> aktive op tile histogram

Syntax: __aktive op tile histogram__ src ?(param value)...?

Returns image with input tiles transformed into a histogram of `bins` values.

Only single-band images are legal inputs. The result will have `bins` bands.

Beware, the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for histogram is black. It is chosen to have minimal to no impact on the statistics at the original input's borders.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|
|bins|int|256|The number of bins held by a single histogram. The pixel values are quantized to fit. Only values in the range of [0..1] are considered valid. Values outside of that range are placed into the smallest/largest bin. The default quantizes the image values to 8-bit.|

---
### <a name='op_tile_max'></a> aktive op tile max

Syntax: __aktive op tile max__ src (param value)...

Returns image containing the maximum of the tile values, for all tiles of radius R in the input.

Beware, "all tiles" means that the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for maximum is mirror. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|

---
### <a name='op_tile_mean'></a> aktive op tile mean

Syntax: __aktive op tile mean__ src (param value)...

Returns image containing the arithmetic mean of the tile values, for all tiles of radius R in the input.

Beware, "all tiles" means that the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for arithmetic mean is mirror. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|

---
### <a name='op_tile_median'></a> aktive op tile median

Syntax: __aktive op tile median__ src (param value)...

Returns image with input tiles compressed to a single value, the median of the sorted tile values.

Beware, the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for rank is mirror. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|

---
### <a name='op_tile_min'></a> aktive op tile min

Syntax: __aktive op tile min__ src (param value)...

Returns image containing the minimum of the tile values, for all tiles of radius R in the input.

Beware, "all tiles" means that the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for minimum is mirror. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|

---
### <a name='op_tile_rank'></a> aktive op tile rank

Syntax: __aktive op tile rank__ src ?(param value)...?

Returns image with input tiles compressed to a single value, the chosen rank of the sorted tile values.

Beware, the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for rank is mirror. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

Beware. While it is possible to use the rank filter for max/min extractions it is recommended to use the specific max/min operators instead, as they should be faster (linear scan of region, no gather, no sorting of the region).

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|
|rank|int|-1|Index of the sorted values to return. Default creates a median filter. 0 creates min-filter.|

---
### <a name='op_tile_stddev'></a> aktive op tile stddev

Syntax: __aktive op tile stddev__ src (param value)...

Returns image containing the standard deviation of the tile values, for all tiles of radius R in the input.

Beware, "all tiles" means that the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for standard deviation is mirror. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|

---
### <a name='op_tile_sum'></a> aktive op tile sum

Syntax: __aktive op tile sum__ src (param value)...

Returns image containing the sum of the tile values, for all tiles of radius R in the input.

Beware, "all tiles" means that the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for sum is black. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|

---
### <a name='op_tile_sumsquared'></a> aktive op tile sumsquared

Syntax: __aktive op tile sumsquared__ src (param value)...

Returns image containing the sum of the squared tile values, for all tiles of radius R in the input.

Beware, "all tiles" means that the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for sum is black. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|

---
### <a name='op_tile_variance'></a> aktive op tile variance

Syntax: __aktive op tile variance__ src (param value)...

Returns image containing the variance of the tile values, for all tiles of radius R in the input.

Beware, "all tiles" means that the operator consumes overlapping tiles, not just adjacent.

Beware, the result image is shrunken by 2*radius in width and height relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for variance is mirror. It is chosen to have minimal to no impact on the statistics at the original input's borders.

The input bands are handled separately.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Tile size as radius from center. Full width and height of the tile are `2*radius+1`.|

