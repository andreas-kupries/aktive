# transform threshold mask generate

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|&mdash;|[Documentation ↗](../index.md)|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

||||||||
|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform threshold mask](transform_threshold_mask.md) ↗


### Operators

 - [aktive image mask from threshold](#image_mask_from_threshold)
 - [aktive image mask per bernsen](#image_mask_per_bernsen)
 - [aktive image mask per global bernsen](#image_mask_per_global_bernsen)
 - [aktive image mask per global mean](#image_mask_per_global_mean)
 - [aktive image mask per global niblack](#image_mask_per_global_niblack)
 - [aktive image mask per global otsu](#image_mask_per_global_otsu)
 - [aktive image mask per global phansalkar](#image_mask_per_global_phansalkar)
 - [aktive image mask per global sauvola](#image_mask_per_global_sauvola)
 - [aktive image mask per mean](#image_mask_per_mean)
 - [aktive image mask per niblack](#image_mask_per_niblack)
 - [aktive image mask per otsu](#image_mask_per_otsu)
 - [aktive image mask per phansalkar](#image_mask_per_phansalkar)
 - [aktive image mask per sauvola](#image_mask_per_sauvola)
 - [aktive image mask per wolfjolion](#image_mask_per_wolfjolion)

## Operators

---
### <a name='image_mask_from_threshold'></a> aktive image mask from threshold

Syntax: __aktive image mask from threshold__ src0 src1

Return image foreground mask of input, as per threshold image. Note that the threshold is the first argument, and input the second.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.


---
### <a name='image_mask_per_bernsen'></a> aktive image mask per bernsen

Syntax: __aktive image mask per bernsen__ src (param value)...

Return image foreground mask of input, using Bernsen thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_mask_per_global_bernsen'></a> aktive image mask per global bernsen

Syntax: __aktive image mask per global bernsen__ src

Return image foreground mask of input, using global Bernsen thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.


---
### <a name='image_mask_per_global_mean'></a> aktive image mask per global mean

Syntax: __aktive image mask per global mean__ src

Return image foreground mask of input, using global Mean thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.


---
### <a name='image_mask_per_global_niblack'></a> aktive image mask per global niblack

Syntax: __aktive image mask per global niblack__ src ?(param value)...?

Return image foreground mask of input, using global Niblack thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|-0.2|niblack parameter|

---
### <a name='image_mask_per_global_otsu'></a> aktive image mask per global otsu

Syntax: __aktive image mask per global otsu__ src ?(param value)...?

Return image foreground mask of input, using global Otsu thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|bins|int|256|otsu histogram parameter|

---
### <a name='image_mask_per_global_phansalkar'></a> aktive image mask per global phansalkar

Syntax: __aktive image mask per global phansalkar__ src ?(param value)...?

Return image foreground mask of input, using global Phansalkar thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.25|phansalkar parameter|
|R|double|0.5|phansalkar parameter|
|p|double|3|phansalkar parameter|
|q|double|10|phansalkar parameter|

---
### <a name='image_mask_per_global_sauvola'></a> aktive image mask per global sauvola

Syntax: __aktive image mask per global sauvola__ src ?(param value)...?

Return image foreground mask of input, using global Sauvola thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.5|sauvola parameter|
|R|double|128|sauvola parameter|

---
### <a name='image_mask_per_mean'></a> aktive image mask per mean

Syntax: __aktive image mask per mean__ src (param value)...

Return image foreground mask of input, using Mean thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_mask_per_niblack'></a> aktive image mask per niblack

Syntax: __aktive image mask per niblack__ src ?(param value)...?

Return image foreground mask of input, using Niblack thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|-0.2|niblack parameter|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_mask_per_otsu'></a> aktive image mask per otsu

Syntax: __aktive image mask per otsu__ src ?(param value)...?

Return image foreground mask of input, using Otsu thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|bins|int|256|otsu histogram parameter|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_mask_per_phansalkar'></a> aktive image mask per phansalkar

Syntax: __aktive image mask per phansalkar__ src ?(param value)...?

Return image foreground mask of input, using Phansalkar thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.25|phansalkar parameter|
|R|double|0.5|phansalkar parameter|
|p|double|3|phansalkar parameter|
|q|double|10|phansalkar parameter|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_mask_per_sauvola'></a> aktive image mask per sauvola

Syntax: __aktive image mask per sauvola__ src ?(param value)...?

Return image foreground mask of input, using Sauvola thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.5|sauvola parameter|
|R|double|128|sauvola parameter|
|radius|uint||Size of region to consider, as radius from center|

---
### <a name='image_mask_per_wolfjolion'></a> aktive image mask per wolfjolion

Syntax: __aktive image mask per wolfjolion__ src ?(param value)...?

Return image foreground mask of input, using Wolfjolion thresholding.

The foreground are the pixels falling under the threshold. IOW the input foreground is assumed to be darker than background. Invert the result otherwise.

The foreground pixels are indicated by white. Background by black.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|k|double|0.5|wolfjolion parameter|
|radius|uint||Size of region to consider, as radius from center|

