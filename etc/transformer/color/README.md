# Color conversions

## Color spaces

|Colorspace	|Notes							|
|---		|---							|
|sRGB		|"standard" non-linear RGB space (gamma-compressed)	|
|scRGB		|linear RGB space (gamma compression undone)		|
|___		|___							|
|HSV		|sRGB in a different basis to separate color components |
|HSL		|Another transformation of sRGB				|
|___		|___							|
|XYZ		|CIE XYZ tristimulus space				|
|Yxy		|CIE Yxy space						|
|Lab		|CIE La*b* space					|
|LCh		|CIE LCh(ab) space					|

## Core conversions

```
HSL <--> \                               / <--> ICC (todo ?little cms)
HSV <--> sRGB <--> scRGB <--> XYZ <--> Lab <--> LCh
                                \ <--> Yxy
```

|A	|B	|Done	|
|---	|---	|---	|
|HSL	|sRGB	|ok	|
|HSV	|sRGB	|ok	|
|sRGB	|scRGB	|ok	|
|scRGB	|XYZ	|ok	|
|XYZ	|Lab	|ok	|
|XYZ	|Yxy	|ok	|
|Lab	|LCh	|ok	|


## Other conversions

Are assembled from the core conversions by chaining these.

