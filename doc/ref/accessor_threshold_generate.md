# Documentation -- Reference Pages -- accessor threshold generate

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [accessor threshold](accessor_threshold.md) ↗


### Operators

 - [aktive image threshold global bernsen](#image_threshold_global_bernsen)
 - [aktive image threshold global mean](#image_threshold_global_mean)
 - [aktive image threshold global niblack](#image_threshold_global_niblack)
 - [aktive image threshold global otsu](#image_threshold_global_otsu)
 - [aktive image threshold global phansalkar](#image_threshold_global_phansalkar)
 - [aktive image threshold global sauvola](#image_threshold_global_sauvola)

## Operators

---
### <a name='image_threshold_global_bernsen'></a> aktive image threshold global bernsen

Syntax: __aktive image threshold global bernsen__ src

Returns a global threshold for the input, according to Bernsen's method.

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately reduced to the threshold.


---
### <a name='image_threshold_global_mean'></a> aktive image threshold global mean

Syntax: __aktive image threshold global mean__ src

Returns a global threshold for the input, as the image mean.

There are better methods. Extensions to the simple mean, in order of creation (and complexity), are Sauvola, Niblack, and Phansalkar. Each of these modifies the plain mean with a bias based on a mix of standard deviation, parameters, and the mean itself.

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately reduced to the threshold.


---
### <a name='image_threshold_global_niblack'></a> aktive image threshold global niblack

Syntax: __aktive image threshold global niblack__ src ?(param value)...?

Returns a global threshold for the input, according to Niblack's method.

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately reduced to the threshold.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|-0.2|niblack parameter|

---
### <a name='image_threshold_global_otsu'></a> aktive image threshold global otsu

Syntax: __aktive image threshold global otsu__ src ?(param value)...?

Returns a global threshold for the input, according to Otsu's method.

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately reduced to the threshold.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|bins|int|256|The number of bins used by the internal histogram. The pixel values are quantized to fit. Only values in the range of [0..1] are considered valid. Values outside of that range are placed into the smallest/largest bin. The default quantizes the image values to 8-bit.|

---
### <a name='image_threshold_global_phansalkar'></a> aktive image threshold global phansalkar

Syntax: __aktive image threshold global phansalkar__ src ?(param value)...?

Returns a global threshold for the input, according to Phansalkar's method.

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately reduced to the threshold.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.25|phansalkar parameter|
|R|double|0.5|phansalkar parameter|
|p|double|3|phansalkar parameter|
|q|double|10|phansalkar parameter|

---
### <a name='image_threshold_global_sauvola'></a> aktive image threshold global sauvola

Syntax: __aktive image threshold global sauvola__ src ?(param value)...?

Returns a global threshold for the input, according to Sauvola's method.

This operator is __strict__ in its single input. The computed pixels are not materialized. They are immediately reduced to the threshold.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.5|sauvola parameter|
|R|double|128|sauvola parameter|

