# Image statistics

These are here, under Transformers, because they compute results per row, column, band or tile, and
return them as an image.

We have

|Op		|Result per unit (row, column, band, tile)	|
|---		|---						|
|arg.max	|First index where the maximal value is reached	|
|arg.min	|First index where the minimal value is reached	|
|arg.ge		|First index where value greater or equal than threshold	|
|arg.gt		|First index where value greater than threshold	|
|arg.le		|First index where value less or equal than threshold	|
|arg.lt		|First index where value less than threshold	|
|cumulative	|A prefix sum over the unit			|
|histogram	|Histogram of the unit 				|
|max		|The maximum of the values			|
|mean		|The arithmetic mean of the values		|
|median		|The median of the values			|
|min		|The minimum of the values   			|
|otsu		|The otsu threshold for the values		|
|rank		|The value of the specified rank of the values	|
|stddev		|The standard deviation of the values		|
|sum		|The sum of all values	     	 		|
|sumsquared	|The sum of all squared values 	 		|
|variance	|The variance of the values			|
|profile	|Top/Left profile of the unit			|

Note that not all operations are sensible for all units.

Note that the index operations are useful to feed `take` operators.
