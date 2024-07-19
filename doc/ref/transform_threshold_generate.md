<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform threshold generate

## Table Of Contents

  - [transform threshold](transform_threshold.md) ↗


### Operators

 - [aktive image threshold bernsen](#image_threshold_bernsen)
 - [aktive image threshold mean](#image_threshold_mean)
 - [aktive image threshold niblack](#image_threshold_niblack)
 - [aktive image threshold otsu](#image_threshold_otsu)
 - [aktive image threshold phansalkar](#image_threshold_phansalkar)
 - [aktive image threshold sauvola](#image_threshold_sauvola)
 - [aktive image threshold wolfjolion](#image_threshold_wolfjolion)

## Operators

---
### <a name='image_threshold_bernsen'></a> aktive image threshold bernsen

Syntax: __aktive image threshold bernsen__ src (param value)...

Returns image containing per-pixel thresholds for the input, as per Bernsen's method.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_threshold_mean'></a> aktive image threshold mean

Syntax: __aktive image threshold mean__ src (param value)...

Returns image containing per-pixel thresholds for the input, as per the local mean.

There are better methods. Extensions to the simple mean, in order of creation (and complexity), are Sauvola, Niblack, and Phansalkar. Each of these modifies the plain mean with a bias based on a mix of standard deviation, parameters, and the mean itself.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_threshold_niblack'></a> aktive image threshold niblack

Syntax: __aktive image threshold niblack__ src ?(param value)...?

Returns image containing per-pixel thresholds for the input, as per Niblack's method.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|-0.2|niblack parameter|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_threshold_otsu'></a> aktive image threshold otsu

Syntax: __aktive image threshold otsu__ src ?(param value)...?

Returns image containing per-pixel thresholds for the input, as per Otsu's method.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Size of region to consider, as radius from center|
|bins|int|256|The number of bins used by the internal histograms. The pixel values are quantized to fit. Only values in the range of [0..1] are considered valid. Values outside of that range are placed into the smallest/largest bin. The default quantizes the image values to 8-bit.|

---
### <a name='image_threshold_phansalkar'></a> aktive image threshold phansalkar

Syntax: __aktive image threshold phansalkar__ src ?(param value)...?

Returns image containing per-pixel thresholds for the input, as per Phansalkar's method.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.25|phansalkar parameter|
|R|double|0.5|phansalkar parameter|
|p|double|3|phansalkar parameter|
|q|double|10|phansalkar parameter|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_threshold_sauvola'></a> aktive image threshold sauvola

Syntax: __aktive image threshold sauvola__ src ?(param value)...?

Returns image containing per-pixel thresholds for the input, as per Sauvola's method.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.5|sauvola parameter|
|R|double|128|sauvola parameter|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_threshold_wolfjolion'></a> aktive image threshold wolfjolion

Syntax: __aktive image threshold wolfjolion__ src ?(param value)...?

Returns image containing per-pixel thresholds for the input, as per Wolf+Jolion's method.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.5|wolfjolion parameter|
|radius|uint||Size of region to consider, as radius from center|

