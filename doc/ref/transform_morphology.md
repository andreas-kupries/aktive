# Documentation -- Reference Pages -- transform morphology

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op morph close](#op_morph_close)
 - [aktive op morph dilate](#op_morph_dilate)
 - [aktive op morph erode](#op_morph_erode)
 - [aktive op morph gradient all](#op_morph_gradient_all)
 - [aktive op morph gradient external](#op_morph_gradient_external)
 - [aktive op morph gradient internal](#op_morph_gradient_internal)
 - [aktive op morph open](#op_morph_open)
 - [aktive op morph toggle](#op_morph_toggle)
 - [aktive op morph tophat black](#op_morph_tophat_black)
 - [aktive op morph tophat white](#op_morph_tophat_white)

## Operators

---
### <a name='op_morph_close'></a> aktive op morph close

Syntax: __aktive op morph close__ src ?(param value)...?

Returns image containing the morphological closing of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_dilate'></a> aktive op morph dilate

Syntax: __aktive op morph dilate__ src ?(param value)...?

Returns image containing the morphological dilation of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_erode'></a> aktive op morph erode

Syntax: __aktive op morph erode__ src ?(param value)...?

Returns image containing the morphological erosion of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_gradient_all'></a> aktive op morph gradient all

Syntax: __aktive op morph gradient all__ src ?(param value)...?

Returns image containing the morphological gradient of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_gradient_external'></a> aktive op morph gradient external

Syntax: __aktive op morph gradient external__ src ?(param value)...?

Returns image containing the morphological outer gradient of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_gradient_internal'></a> aktive op morph gradient internal

Syntax: __aktive op morph gradient internal__ src ?(param value)...?

Returns image containing the morphological inner gradient of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_open'></a> aktive op morph open

Syntax: __aktive op morph open__ src ?(param value)...?

Returns image containing the morphological opening of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_toggle'></a> aktive op morph toggle

Syntax: __aktive op morph toggle__ src ?(param value)...?

Returns image containing the morphological toggle of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_tophat_black'></a> aktive op morph tophat black

Syntax: __aktive op morph tophat black__ src ?(param value)...?

Returns image containing the morphological black tophat of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

---
### <a name='op_morph_tophat_white'></a> aktive op morph tophat white

Syntax: __aktive op morph tophat white__ src ?(param value)...?

Returns image containing the morphological white tophat of the input using a (2*radius+1)x(2*radius+1) square structuring element.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Size of the structuring element to perform the operation with.|
|embed|str|black|Embedding method to use before core operators to keep output from shrinking.|

