# Documentation -- Reference Pages -- sink statistics

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [sink](sink.md) ↗


### Operators

 - [aktive op compare mse](#op_compare_mse)
 - [aktive op compare rmse](#op_compare_rmse)
 - [aktive op image max](#op_image_max)
 - [aktive op image mean](#op_image_mean)
 - [aktive op image mean-stddev](#op_image_mean_stddev)
 - [aktive op image min](#op_image_min)
 - [aktive op image min-max](#op_image_min_max)
 - [aktive op image stddev](#op_image_stddev)
 - [aktive op image sum](#op_image_sum)
 - [aktive op image sumsquared](#op_image_sumsquared)
 - [aktive op image variance](#op_image_variance)

## Operators

---
### <a name='op_compare_mse'></a> aktive op compare mse

Syntax: __aktive op compare mse__ src0 src1

Compares the two input images and returns the MSE metric for their difference

This operator is __strict__ in both inputs. The computed pixels are not materialized. They are immediately used for the comparison and then discarded.


---
### <a name='op_compare_rmse'></a> aktive op compare rmse

Syntax: __aktive op compare rmse__ src0 src1

Compares the two input images and returns the RMSE metric for their difference

This operator is __strict__ in both inputs. The computed pixels are not materialized. They are immediately used for the comparison and then discarded.


---
### <a name='op_image_max'></a> aktive op image max

Syntax: __aktive op image max__ src

Returns a single value, the maximum of the values (across all rows, columns, and bands)

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately used for the calculation of the statistic and then discarded.


---
### <a name='op_image_mean'></a> aktive op image mean

Syntax: __aktive op image mean__ src

Returns a single value, the arithmetic mean of the values (across all rows, columns, and bands)

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately used for the calculation of the statistic and then discarded.


---
### <a name='op_image_mean_stddev'></a> aktive op image mean-stddev

Syntax: __aktive op image mean-stddev__ src ?(param value)...?

Returns a 2-element list containing lower and upper bounds for the image values, based on the image's mean and a multiple of its standard deviation.

This operator is __strict__ in its single input. The computed pixels are not materialized and just used for the calculation of the statistics.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|sigma|double|1.2|Interval around the mean to return.|

---
### <a name='op_image_min'></a> aktive op image min

Syntax: __aktive op image min__ src

Returns a single value, the minimum of the values (across all rows, columns, and bands)

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately used for the calculation of the statistic and then discarded.


---
### <a name='op_image_min_max'></a> aktive op image min-max

Syntax: __aktive op image min-max__ src ?(param value)...?

Returns a 2-element list containing the min and max of the image, in this order.

The results can be modified by setting lower and upper percentiles.

This operator is __strict__ in its single input. The computed pixels are not materialized and just used for the for the calculation of the statistics.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|upper|double|1|Upper percentile to apply to max. Default is 100%|
|lower|double|0|Lower percentile to apply to min. Default is 0%|

---
### <a name='op_image_stddev'></a> aktive op image stddev

Syntax: __aktive op image stddev__ src

Returns a single value, the standard deviation of the values (across all rows, columns, and bands)

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately used for the calculation of the statistic and then discarded.


---
### <a name='op_image_sum'></a> aktive op image sum

Syntax: __aktive op image sum__ src

Returns a single value, the sum of the values (across all rows, columns, and bands)

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately used for the calculation of the statistic and then discarded.


---
### <a name='op_image_sumsquared'></a> aktive op image sumsquared

Syntax: __aktive op image sumsquared__ src

Returns a single value, the sum of the squared values (across all rows, columns, and bands)

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately used for the calculation of the statistic and then discarded.


---
### <a name='op_image_variance'></a> aktive op image variance

Syntax: __aktive op image variance__ src

Returns a single value, the variance of the values (across all rows, columns, and bands)

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately used for the calculation of the statistic and then discarded.


