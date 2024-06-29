# transform metadata

||||||||
|---|---|---|---|---|---|---|
|[Home ↗](/)|[Main ↗](index.md)|[Sections](index.md#sectree)|[Permuted Sections](bypsections.md)|[Names](byname.md)|[Permuted Names](bypnames.md)|[Implementations](bylang.md)|

## Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive meta append](#meta_append)
 - [aktive meta create](#meta_create)
 - [aktive meta filter](#meta_filter)
 - [aktive meta incr](#meta_incr)
 - [aktive meta lappend](#meta_lappend)
 - [aktive meta map](#meta_map)
 - [aktive meta merge](#meta_merge)
 - [aktive meta remove](#meta_remove)
 - [aktive meta replace](#meta_replace)
 - [aktive meta set](#meta_set)
 - [aktive meta unset](#meta_unset)
 - [aktive op meta set](#op_meta_set)

## Operators

---
### <a name='meta_append'></a> aktive meta append

Syntax: __aktive meta append__ src args...

Wraps the dict method "append" for image meta data management.

Returns input with meta data dictionary modified by application of "dict append"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_create'></a> aktive meta create

Syntax: __aktive meta create__ src args...

Wraps the dict method "create" for image meta data management.

Returns input with meta data dictionary modified by application of "dict create"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_filter'></a> aktive meta filter

Syntax: __aktive meta filter__ src args...

Wraps the dict method "filter" for image meta data management.

Returns input with meta data dictionary modified by application of "dict filter"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_incr'></a> aktive meta incr

Syntax: __aktive meta incr__ src args...

Wraps the dict method "incr" for image meta data management.

Returns input with meta data dictionary modified by application of "dict incr"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_lappend'></a> aktive meta lappend

Syntax: __aktive meta lappend__ src args...

Wraps the dict method "lappend" for image meta data management.

Returns input with meta data dictionary modified by application of "dict lappend"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_map'></a> aktive meta map

Syntax: __aktive meta map__ src args...

Wraps the dict method "map" for image meta data management.

Returns input with meta data dictionary modified by application of "dict map"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_merge'></a> aktive meta merge

Syntax: __aktive meta merge__ src args...

Wraps the dict method "merge" for image meta data management.

Returns input with meta data dictionary modified by application of "dict merge"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_remove'></a> aktive meta remove

Syntax: __aktive meta remove__ src args...

Wraps the dict method "remove" for image meta data management.

Returns input with meta data dictionary modified by application of "dict remove"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_replace'></a> aktive meta replace

Syntax: __aktive meta replace__ src args...

Wraps the dict method "replace" for image meta data management.

Returns input with meta data dictionary modified by application of "dict replace"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_set'></a> aktive meta set

Syntax: __aktive meta set__ src args...

Wraps the dict method "set" for image meta data management.

Returns input with meta data dictionary modified by application of "dict set"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='meta_unset'></a> aktive meta unset

Syntax: __aktive meta unset__ src args...

Wraps the dict method "unset" for image meta data management.

Returns input with meta data dictionary modified by application of "dict unset"

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|args|str...||Dict command arguments, except for dict value or variable.|

---
### <a name='op_meta_set'></a> aktive op meta set

Syntax: __aktive op meta set__ src meta

Returns input with specified meta data replacing the old.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|src|image||Input to modify|
|meta|object||New meta data dictionary replacing the input's.|

