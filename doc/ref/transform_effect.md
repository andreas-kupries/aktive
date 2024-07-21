<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform effect

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive effect blur](#effect_blur)
 - [aktive effect charcoal](#effect_charcoal)
 - [aktive effect emboss](#effect_emboss)
 - [aktive effect sharpen](#effect_sharpen)
 - [aktive effect sketch](#effect_sketch)

## Operators

---
### <a name='effect_blur'></a> aktive effect blur

Syntax: __aktive effect blur__ src ?(param value)...?

Returns blurred input, per the specified blur radius.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|double|2|Blur kernel radius. Defaults to 2.|

## Examples

### aktive effect blur @1 radius 16

|||
|---|---|
|@1|aktive effect blur @1 radius 16|
|<img src='example-00002.gif' alt='aktive effect blur @1 radius 16' style='border:4px solid gold'>|<img src='example-00001.gif' alt='aktive effect blur @1 radius 16' style='border:4px solid gold'>|

### aktive effect blur @1 radius 16

|||
|---|---|
|@1|aktive effect blur @1 radius 16|
|<img src='example-00004.gif' alt='aktive effect blur @1 radius 16' style='border:4px solid gold'>|<img src='example-00003.gif' alt='aktive effect blur @1 radius 16' style='border:4px solid gold'>|

---
### <a name='effect_charcoal'></a> aktive effect charcoal

Syntax: __aktive effect charcoal__ src ?(param value)...?

Returns grey image with a charcoal-like sketch of the sRGB input.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|light|bool|no|Artistic choice between stronger and lighter sketch lines.|

---
### <a name='effect_emboss'></a> aktive effect emboss

Syntax: __aktive effect emboss__ src

Returns embossed input.


## Examples

### aktive effect emboss @1

|||
|---|---|
|@1|aktive effect emboss @1|
|<img src='example-00006.gif' alt='aktive effect emboss @1' style='border:4px solid gold'>|<img src='example-00005.gif' alt='aktive effect emboss @1' style='border:4px solid gold'>|

---
### <a name='effect_sharpen'></a> aktive effect sharpen

Syntax: __aktive effect sharpen__ src

Returns sharpened input.


## Examples

### aktive effect sharpen @1

|||
|---|---|
|@1|aktive effect sharpen @1|
|<img src='example-00008.gif' alt='aktive effect sharpen @1' style='border:4px solid gold'>|<img src='example-00007.gif' alt='aktive effect sharpen @1' style='border:4px solid gold'>|

---
### <a name='effect_sketch'></a> aktive effect sketch

Syntax: __aktive effect sketch__ src

Returns image with a general sketch of the input.


## Examples

### aktive effect sketch @1

|||
|---|---|
|@1|aktive effect sketch @1|
|<img src='example-00010.gif' alt='aktive effect sketch @1' style='border:4px solid gold'>|<img src='example-00009.gif' alt='aktive effect sketch @1' style='border:4px solid gold'>|

### aktive effect sketch @1

|||
|---|---|
|@1|aktive effect sketch @1|
|<img src='example-00012.gif' alt='aktive effect sketch @1' style='border:4px solid gold'>|<img src='example-00011.gif' alt='aktive effect sketch @1' style='border:4px solid gold'>|

