# Image statistics

These are here, under Transformers, because they compute results per row, column, band or tile, and
return them as an image.

We have

|Op		|Result per unit (row, column, band, tile)	|
|---		|---						|
|argmax		|First index where the maximal value is reached	|
|argmin		|First index where the minimal value is reached	|
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

Note that not all operations are sensible for all units.

Note that the index operations are useful to feed `take` operators.
