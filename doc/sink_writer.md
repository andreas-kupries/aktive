# sink writer

||||||||
|---|---|---|---|---|---|---|
|[Home ↗](/)|[Main ↗](index.md)|[Sections](index.md#sectree)|[Permuted Sections](bypsections.md)|[Names](byname.md)|[Permuted Names](bypnames.md)|[Implementations](bylang.md)|

## Table Of Contents

  - [sink](sink.md) ↗


### Operators

 - [aktive format as aktive 2chan](#format_as_aktive_2chan)
 - [aktive format as aktive 2file](#format_as_aktive_2file)
 - [aktive format as aktive 2string](#format_as_aktive_2string)
 - [aktive format as null-s 2string](#format_as_null_s_2string)
 - [aktive format as null 2string](#format_as_null_2string)
 - [aktive format as pgm byte 2chan](#format_as_pgm_byte_2chan)
 - [aktive format as pgm byte 2file](#format_as_pgm_byte_2file)
 - [aktive format as pgm byte 2string](#format_as_pgm_byte_2string)
 - [aktive format as pgm etext 2chan](#format_as_pgm_etext_2chan)
 - [aktive format as pgm etext 2file](#format_as_pgm_etext_2file)
 - [aktive format as pgm etext 2string](#format_as_pgm_etext_2string)
 - [aktive format as pgm short 2chan](#format_as_pgm_short_2chan)
 - [aktive format as pgm short 2file](#format_as_pgm_short_2file)
 - [aktive format as pgm short 2string](#format_as_pgm_short_2string)
 - [aktive format as pgm text 2chan](#format_as_pgm_text_2chan)
 - [aktive format as pgm text 2file](#format_as_pgm_text_2file)
 - [aktive format as pgm text 2string](#format_as_pgm_text_2string)
 - [aktive format as ppm byte 2chan](#format_as_ppm_byte_2chan)
 - [aktive format as ppm byte 2file](#format_as_ppm_byte_2file)
 - [aktive format as ppm byte 2string](#format_as_ppm_byte_2string)
 - [aktive format as ppm etext 2chan](#format_as_ppm_etext_2chan)
 - [aktive format as ppm etext 2file](#format_as_ppm_etext_2file)
 - [aktive format as ppm etext 2string](#format_as_ppm_etext_2string)
 - [aktive format as ppm short 2chan](#format_as_ppm_short_2chan)
 - [aktive format as ppm short 2file](#format_as_ppm_short_2file)
 - [aktive format as ppm short 2string](#format_as_ppm_short_2string)
 - [aktive format as ppm text 2chan](#format_as_ppm_text_2chan)
 - [aktive format as ppm text 2file](#format_as_ppm_text_2file)
 - [aktive format as ppm text 2string](#format_as_ppm_text_2string)
 - [aktive format as tcl](#format_as_tcl)

## Operators

---
### <a name='format_as_aktive_2chan'></a> aktive format as aktive 2chan

Syntax: __aktive format as aktive 2chan__ src (param value)...

Writes image to the DST channel, serialized with the AKTIVE raw format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the image data is written to|

---
### <a name='format_as_aktive_2file'></a> aktive format as aktive 2file

Syntax: __aktive format as aktive 2file__ src (param value)...

Writes image to the destination file, serialized with the AKTIVE format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the image data is written to.|

---
### <a name='format_as_aktive_2string'></a> aktive format as aktive 2string

Syntax: __aktive format as aktive 2string__ src

Returns byte array containing the image serialized with the AKTIVE raw format.


---
### <a name='format_as_null_s_2string'></a> aktive format as null-s 2string

Syntax: __aktive format as null-s 2string__ src

Returns nothing, while triggering full pixel calculation for the input.


---
### <a name='format_as_null_2string'></a> aktive format as null 2string

Syntax: __aktive format as null 2string__ src

Returns nothing, while triggering full pixel calculation for the input.


---
### <a name='format_as_pgm_byte_2chan'></a> aktive format as pgm byte 2chan

Syntax: __aktive format as pgm byte 2chan__ src (param value)...

Writes image to the destination channel, serialized with PGM's byte format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the pgm byte image data is written to.|

---
### <a name='format_as_pgm_byte_2file'></a> aktive format as pgm byte 2file

Syntax: __aktive format as pgm byte 2file__ src (param value)...

Writes image to the destination file, serialized with PGM's byte format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the pgm byte image data is written to.|

---
### <a name='format_as_pgm_byte_2string'></a> aktive format as pgm byte 2string

Syntax: __aktive format as pgm byte 2string__ src

Returns byte array containing the image serialized with PGM's byte format.


---
### <a name='format_as_pgm_etext_2chan'></a> aktive format as pgm etext 2chan

Syntax: __aktive format as pgm etext 2chan__ src (param value)...

Writes image to the destination channel, serialized with PGM's etext format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the pgm etext image data is written to.|

---
### <a name='format_as_pgm_etext_2file'></a> aktive format as pgm etext 2file

Syntax: __aktive format as pgm etext 2file__ src (param value)...

Writes image to the destination file, serialized with PGM's etext format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the pgm etext image data is written to.|

---
### <a name='format_as_pgm_etext_2string'></a> aktive format as pgm etext 2string

Syntax: __aktive format as pgm etext 2string__ src

Returns byte array containing the image serialized with PGM's etext format.


---
### <a name='format_as_pgm_short_2chan'></a> aktive format as pgm short 2chan

Syntax: __aktive format as pgm short 2chan__ src (param value)...

Writes image to the destination channel, serialized with PGM's short format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the pgm short image data is written to.|

---
### <a name='format_as_pgm_short_2file'></a> aktive format as pgm short 2file

Syntax: __aktive format as pgm short 2file__ src (param value)...

Writes image to the destination file, serialized with PGM's short format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the pgm short image data is written to.|

---
### <a name='format_as_pgm_short_2string'></a> aktive format as pgm short 2string

Syntax: __aktive format as pgm short 2string__ src

Returns byte array containing the image serialized with PGM's short format.


---
### <a name='format_as_pgm_text_2chan'></a> aktive format as pgm text 2chan

Syntax: __aktive format as pgm text 2chan__ src (param value)...

Writes image to the destination channel, serialized with PGM's text format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the pgm text image data is written to.|

---
### <a name='format_as_pgm_text_2file'></a> aktive format as pgm text 2file

Syntax: __aktive format as pgm text 2file__ src (param value)...

Writes image to the destination file, serialized with PGM's text format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the pgm text image data is written to.|

---
### <a name='format_as_pgm_text_2string'></a> aktive format as pgm text 2string

Syntax: __aktive format as pgm text 2string__ src

Returns byte array containing the image serialized with PGM's text format.


---
### <a name='format_as_ppm_byte_2chan'></a> aktive format as ppm byte 2chan

Syntax: __aktive format as ppm byte 2chan__ src (param value)...

Writes image to the destination channel, serialized with PPM's byte format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the ppm byte image data is written to.|

---
### <a name='format_as_ppm_byte_2file'></a> aktive format as ppm byte 2file

Syntax: __aktive format as ppm byte 2file__ src (param value)...

Writes image to the destination file, serialized with PPM's byte format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the ppm byte image data is written to.|

---
### <a name='format_as_ppm_byte_2string'></a> aktive format as ppm byte 2string

Syntax: __aktive format as ppm byte 2string__ src

Returns byte array containing the image serialized with PPM's byte format.


---
### <a name='format_as_ppm_etext_2chan'></a> aktive format as ppm etext 2chan

Syntax: __aktive format as ppm etext 2chan__ src (param value)...

Writes image to the destination channel, serialized with PPM's etext format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the ppm etext image data is written to.|

---
### <a name='format_as_ppm_etext_2file'></a> aktive format as ppm etext 2file

Syntax: __aktive format as ppm etext 2file__ src (param value)...

Writes image to the destination file, serialized with PPM's etext format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the ppm etext image data is written to.|

---
### <a name='format_as_ppm_etext_2string'></a> aktive format as ppm etext 2string

Syntax: __aktive format as ppm etext 2string__ src

Returns byte array containing the image serialized with PPM's etext format.


---
### <a name='format_as_ppm_short_2chan'></a> aktive format as ppm short 2chan

Syntax: __aktive format as ppm short 2chan__ src (param value)...

Writes image to the destination channel, serialized with PPM's short format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the ppm short image data is written to.|

---
### <a name='format_as_ppm_short_2file'></a> aktive format as ppm short 2file

Syntax: __aktive format as ppm short 2file__ src (param value)...

Writes image to the destination file, serialized with PPM's short format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the ppm short image data is written to.|

---
### <a name='format_as_ppm_short_2string'></a> aktive format as ppm short 2string

Syntax: __aktive format as ppm short 2string__ src

Returns byte array containing the image serialized with PPM's short format.


---
### <a name='format_as_ppm_text_2chan'></a> aktive format as ppm text 2chan

Syntax: __aktive format as ppm text 2chan__ src (param value)...

Writes image to the destination channel, serialized with PPM's text format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|channel||Destination channel the ppm text image data is written to.|

---
### <a name='format_as_ppm_text_2file'></a> aktive format as ppm text 2file

Syntax: __aktive format as ppm text 2file__ src (param value)...

Writes image to the destination file, serialized with PPM's text format.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|into|str||Destination file the ppm text image data is written to.|

---
### <a name='format_as_ppm_text_2string'></a> aktive format as ppm text 2string

Syntax: __aktive format as ppm text 2string__ src

Returns byte array containing the image serialized with PPM's text format.


---
### <a name='format_as_tcl'></a> aktive format as tcl

Syntax: __aktive format as tcl__ src

Returns string containing the image serialized into readable Tcl structures. Dictionary with flat pixel list.

