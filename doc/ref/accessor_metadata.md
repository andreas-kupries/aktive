# Documentation -- Reference Pages -- accessor metadata

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

||||||||
|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [accessor](accessor.md) ↗


### Operators

 - [aktive meta exists](#meta_exists)
 - [aktive meta for](#meta_for)
 - [aktive meta get](#meta_get)
 - [aktive meta info](#meta_info)
 - [aktive meta keys](#meta_keys)
 - [aktive meta size](#meta_size)
 - [aktive meta values](#meta_values)
 - [aktive query meta](#query_meta)

## Operators

---
### <a name='meta_exists'></a> aktive meta exists

Syntax: __aktive meta exists__ src args...

Wraps the dict method "exists" for image meta data management.

Returns result of "dict exists" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_for'></a> aktive meta for

Syntax: __aktive meta for__ src args...

Wraps the dict method "for" for image meta data management.

Returns result of "dict for" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_get'></a> aktive meta get

Syntax: __aktive meta get__ src args...

Wraps the dict method "get" for image meta data management.

Returns result of "dict get" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_info'></a> aktive meta info

Syntax: __aktive meta info__ src args...

Wraps the dict method "info" for image meta data management.

Returns result of "dict info" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_keys'></a> aktive meta keys

Syntax: __aktive meta keys__ src args...

Wraps the dict method "keys" for image meta data management.

Returns result of "dict keys" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_size'></a> aktive meta size

Syntax: __aktive meta size__ src args...

Wraps the dict method "size" for image meta data management.

Returns result of "dict size" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_values'></a> aktive meta values

Syntax: __aktive meta values__ src args...

Wraps the dict method "values" for image meta data management.

Returns result of "dict values" applied to the input's meta data dictionary

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input queried|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='query_meta'></a> aktive query meta

Syntax: __aktive query meta__ src

Returns the image meta data (a Tcl dictionary).


