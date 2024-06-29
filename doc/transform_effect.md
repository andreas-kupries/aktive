# transform effect

||||||||
|---|---|---|---|---|---|---|
|[Home ↗](../README.md)|[Main ↗](index.md)|[Sections](index.md#sectree)|[Permuted Sections](bypsections.md)|[Names](byname.md)|[Permuted Names](bypnames.md)|[Implementations](bylang.md)|

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


---
### <a name='effect_sharpen'></a> aktive effect sharpen

Syntax: __aktive effect sharpen__ src

Returns sharpened input.


---
### <a name='effect_sketch'></a> aktive effect sketch

Syntax: __aktive effect sketch__ src

Returns image with a general sketch of the input.


