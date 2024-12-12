<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform location

## <anchor='top'> Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op location move by](#op_location_move_by)
 - [aktive op location move to](#op_location_move_to)

## Operators

---
### [↑](#top) <a name='op_location_move_by'></a> aktive op location move by

Syntax: __aktive op location move by__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=64&name=etc/transformer/location.tcl)]

Returns image translationally shifted along the x- and y-axes by a specific amount

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|dx|int||Shift amount for x location of image in the plane, positive to the right, negative left|
|dy|int||Shift amount for y location of image in the plane, positive downward, negative upward|

---
### [↑](#top) <a name='op_location_move_to'></a> aktive op location move to

Syntax: __aktive op location move to__ src (param value)... [[→ definition](../../../../file?ci=trunk&ln=7&name=etc/transformer/location.tcl)]

Returns image translationally shifted along the x- and y-axes to a specific location

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|int||New absolute x location of image in the plane|
|y|int||New absolute y location of image in the plane|

