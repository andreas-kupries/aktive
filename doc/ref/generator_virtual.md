# Documentation -- Reference Pages -- generator virtual

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

||||||||
|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [generator](generator.md) ↗


## Subsections


 - [generator virtual drawing](generator_virtual_drawing.md) ↘
 - [generator virtual sdf](generator_virtual_sdf.md) ↘

### Operators

 - [aktive image cbar](#image_cbar)
 - [aktive image circle](#image_circle)
 - [aktive image cross](#image_cross)
 - [aktive image dbar](#image_dbar)
 - [aktive image disc](#image_disc)
 - [aktive image eye](#image_eye)
 - [aktive image from band](#image_from_band)
 - [aktive image from column](#image_from_column)
 - [aktive image from matrix](#image_from_matrix)
 - [aktive image from row](#image_from_row)
 - [aktive image from sparse deltas](#image_from_sparse_deltas)
 - [aktive image from sparse points](#image_from_sparse_points)
 - [aktive image from value](#image_from_value)
 - [aktive image gradient](#image_gradient)
 - [aktive image grey](#image_grey)
 - [aktive image hbar](#image_hbar)
 - [aktive image indexed](#image_indexed)
 - [aktive image kernel emboss](#image_kernel_emboss)
 - [aktive image kernel gauss3 x](#image_kernel_gauss3_x)
 - [aktive image kernel gauss3 xy](#image_kernel_gauss3_xy)
 - [aktive image kernel gauss3 y](#image_kernel_gauss3_y)
 - [aktive image kernel gauss5 x](#image_kernel_gauss5_x)
 - [aktive image kernel gauss5 y](#image_kernel_gauss5_y)
 - [aktive image kernel gauss7 x](#image_kernel_gauss7_x)
 - [aktive image kernel gauss7 y](#image_kernel_gauss7_y)
 - [aktive image kernel gauss9 x](#image_kernel_gauss9_x)
 - [aktive image kernel gauss9 y](#image_kernel_gauss9_y)
 - [aktive image kernel gauss discrete](#image_kernel_gauss_discrete)
 - [aktive image kernel kirsch md](#image_kernel_kirsch_md)
 - [aktive image kernel kirsch sd](#image_kernel_kirsch_sd)
 - [aktive image kernel kirsch x](#image_kernel_kirsch_x)
 - [aktive image kernel kirsch y](#image_kernel_kirsch_y)
 - [aktive image kernel lanczos](#image_kernel_lanczos)
 - [aktive image kernel laplace 4](#image_kernel_laplace_4)
 - [aktive image kernel laplace 8](#image_kernel_laplace_8)
 - [aktive image kernel laplace X](#image_kernel_laplace_X)
 - [aktive image kernel prewitt md](#image_kernel_prewitt_md)
 - [aktive image kernel prewitt sd](#image_kernel_prewitt_sd)
 - [aktive image kernel prewitt x](#image_kernel_prewitt_x)
 - [aktive image kernel prewitt y](#image_kernel_prewitt_y)
 - [aktive image kernel roberts x](#image_kernel_roberts_x)
 - [aktive image kernel roberts y](#image_kernel_roberts_y)
 - [aktive image kernel scharr x](#image_kernel_scharr_x)
 - [aktive image kernel scharr y](#image_kernel_scharr_y)
 - [aktive image kernel sharp 4](#image_kernel_sharp_4)
 - [aktive image kernel sharp 8](#image_kernel_sharp_8)
 - [aktive image kernel sharp X](#image_kernel_sharp_X)
 - [aktive image kernel sobel md](#image_kernel_sobel_md)
 - [aktive image kernel sobel sd](#image_kernel_sobel_sd)
 - [aktive image kernel sobel x](#image_kernel_sobel_x)
 - [aktive image kernel sobel y](#image_kernel_sobel_y)
 - [aktive image noise gauss](#image_noise_gauss)
 - [aktive image noise salt](#image_noise_salt)
 - [aktive image noise uniform](#image_noise_uniform)
 - [aktive image sines](#image_sines)
 - [aktive image square](#image_square)
 - [aktive image vbar](#image_vbar)
 - [aktive image xcross](#image_xcross)
 - [aktive image zone](#image_zone)

## Operators

---
### <a name='image_cbar'></a> aktive image cbar

Syntax: __aktive image cbar__  ?(param value)...?

Returns square single-band image containing a cross diagonal bar. The image has size `2*radius + 1` squared.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the cross diagonal bar.|
|width|uint|0|Width of the element. Default 0. Has to be less or equal to the radius.|

---
### <a name='image_circle'></a> aktive image circle

Syntax: __aktive image circle__  ?(param value)...?

Returns square single-band image containing a circle (disc perimeter). The image has size `2*radius + 1` squared.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the circle (disc perimeter).|
|width|uint|1|Width of the element. Default 1. Has to be less or equal to the radius.|

---
### <a name='image_cross'></a> aktive image cross

Syntax: __aktive image cross__  ?(param value)...?

Returns square single-band image containing a cross. The image has size `2*radius + 1` squared.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the cross.|
|width|uint|0|Width of the element. Default 0. Has to be less or equal to the radius.|

---
### <a name='image_dbar'></a> aktive image dbar

Syntax: __aktive image dbar__  ?(param value)...?

Returns square single-band image containing a diagonal bar. The image has size `2*radius + 1` squared.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the diagonal bar.|
|width|uint|0|Width of the element. Default 0. Has to be less or equal to the radius.|

---
### <a name='image_disc'></a> aktive image disc

Syntax: __aktive image disc__  ?(param value)...?

Returns square single-band image containing a filled disc. The image has size `2*radius + 1` squared.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the filled disc.|

---
### <a name='image_eye'></a> aktive image eye

Syntax: __aktive image eye__  (param value)...

Returns image containing a test pattern with increasing spatial frequency from left to right, and increasing amplitude (i.e. black to white) from top to bottom.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|factor|double||Maximum spatial frequency. Range 0..1.|

---
### <a name='image_from_band'></a> aktive image from band

Syntax: __aktive image from band__  (param value)...

Returns image where all pixels have the same band values.

Depth is len(value)

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|values|double...||Pixel band values|

---
### <a name='image_from_column'></a> aktive image from column

Syntax: __aktive image from column__  (param value)...

Returns image of the specified with where all columns have the same set of values.

The image's height is the number of values.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|values|double...||Pixel column values|

---
### <a name='image_from_matrix'></a> aktive image from matrix

Syntax: __aktive image from matrix__  ?(param value)...?

Returns single-band image with the pixel VALUEs.

Less than width by height values are extended with zeroes.

Excess values are ignored.

Depth is fixed at 1.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|factor|double|1|Scaling factor|
|values|double...||Pixel values|

---
### <a name='image_from_row'></a> aktive image from row

Syntax: __aktive image from row__  (param value)...

Returns image of the specified height where all rows have the same set of values.

The image's width is the number of values.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|height|uint||Height of the returned image|
|values|double...||Pixel row values|

---
### <a name='image_from_sparse_deltas'></a> aktive image from sparse deltas

Syntax: __aktive image from sparse deltas__  (param value)...

Returns single-band depth image where pixels are set to white at exactly the specified points. Different to `sparse points` the points are specified as linear distances from the origin.

The height is infered from the points

The first delta is relative to index 0

Converts the deltas internally to points and then operates like `sparse points`

Depth is fixed at 1

Pixel value is fixed at 1.0

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image. This is needed for the conversion of the linear indices to (x,y) coordinates.|
|deltas|uint...||Linear distances between points to set|

---
### <a name='image_from_sparse_points'></a> aktive image from sparse points

Syntax: __aktive image from sparse points__  (param value)...

Returns single-band image where pixels are set to white at exactly the specified COORDS.

Generally, the bounding box specifies the geometry, especially also the image origin

Width is implied by the bounding box of the points

Height is implied by the bounding box of the points

Depth is fixed at 1

Pixel value is fixed at 1.0

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|coords|point...||Coordinates of the pixels to set in the image|

---
### <a name='image_from_value'></a> aktive image from value

Syntax: __aktive image from value__  (param value)...

Returns image which has the same VALUE everywhere.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|depth|uint||Depth of the returned image|
|value|double||Pixel value|

---
### <a name='image_gradient'></a> aktive image gradient

Syntax: __aktive image gradient__  (param value)...

Returns image containing a linear gradient through all cells.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|depth|uint||Depth of the returned image|
|first|double||First value|
|last|double||Last value|

---
### <a name='image_grey'></a> aktive image grey

Syntax: __aktive image grey__  (param value)...

Returns image containing a left to right black to white gradient.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|

---
### <a name='image_hbar'></a> aktive image hbar

Syntax: __aktive image hbar__  ?(param value)...?

Returns square single-band image containing a horizontal bar. The image has size `2*radius + 1` squared.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the horizontal bar.|
|width|uint|0|Width of the element. Default 0. Has to be less or equal to the radius.|

---
### <a name='image_indexed'></a> aktive image indexed

Syntax: __aktive image indexed__  (param value)...

Returns 2-band image where the pixels proclaiming their own position

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|

---
### <a name='image_kernel_emboss'></a> aktive image kernel emboss

Syntax: __aktive image kernel emboss__ 

Returns convolution kernel for embossing effect


---
### <a name='image_kernel_gauss3_x'></a> aktive image kernel gauss3 x

Syntax: __aktive image kernel gauss3 x__ 

Returns convolution kernel for gauss3ian blur effect


---
### <a name='image_kernel_gauss3_xy'></a> aktive image kernel gauss3 xy

Syntax: __aktive image kernel gauss3 xy__ 

Returns convolution kernel for gauss3ian blur effect


---
### <a name='image_kernel_gauss3_y'></a> aktive image kernel gauss3 y

Syntax: __aktive image kernel gauss3 y__ 

Returns convolution kernel for gauss3ian blur effect


---
### <a name='image_kernel_gauss5_x'></a> aktive image kernel gauss5 x

Syntax: __aktive image kernel gauss5 x__ 

Returns convolution kernel for gauss5ian blur effect


---
### <a name='image_kernel_gauss5_y'></a> aktive image kernel gauss5 y

Syntax: __aktive image kernel gauss5 y__ 

Returns convolution kernel for gauss5ian blur effect


---
### <a name='image_kernel_gauss7_x'></a> aktive image kernel gauss7 x

Syntax: __aktive image kernel gauss7 x__ 

Returns convolution kernel for gauss7ian blur effect


---
### <a name='image_kernel_gauss7_y'></a> aktive image kernel gauss7 y

Syntax: __aktive image kernel gauss7 y__ 

Returns convolution kernel for gauss7ian blur effect


---
### <a name='image_kernel_gauss9_x'></a> aktive image kernel gauss9 x

Syntax: __aktive image kernel gauss9 x__ 

Returns convolution kernel for gauss9ian blur effect


---
### <a name='image_kernel_gauss9_y'></a> aktive image kernel gauss9 y

Syntax: __aktive image kernel gauss9 y__ 

Returns convolution kernel for gauss9ian blur effect


---
### <a name='image_kernel_gauss_discrete'></a> aktive image kernel gauss discrete

Syntax: __aktive image kernel gauss discrete__  ?(param value)...?

Returns the 1D discrete gaussian convolution kernel, for the specified sigma and radius. By default sigma is 1. By default the radius is max(1,ceil(3*sigma)).

For more about the math see http://en.wikipedia.org/wiki/Scale_space_implementation#The_discrete_Gaussian_kernel

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|sigma|double||Kernel spread, as standard deviation to cover.|
|radius|uint|[expr {max(1,int(ceil(3*$sigma)))}]|Kernel radius, defaults to max(1,ceil(3*sigma)).|

---
### <a name='image_kernel_kirsch_md'></a> aktive image kernel kirsch md

Syntax: __aktive image kernel kirsch md__ 

Returns convolution kernel for kirsch edge detection


---
### <a name='image_kernel_kirsch_sd'></a> aktive image kernel kirsch sd

Syntax: __aktive image kernel kirsch sd__ 

Returns convolution kernel for kirsch edge detection


---
### <a name='image_kernel_kirsch_x'></a> aktive image kernel kirsch x

Syntax: __aktive image kernel kirsch x__ 

Returns convolution kernel for kirsch edge detection


---
### <a name='image_kernel_kirsch_y'></a> aktive image kernel kirsch y

Syntax: __aktive image kernel kirsch y__ 

Returns convolution kernel for kirsch edge detection


---
### <a name='image_kernel_lanczos'></a> aktive image kernel lanczos

Syntax: __aktive image kernel lanczos__  ?(param value)...?

Returns lanczos convolution kernel of the specified order. The default order is 3. Step expands the kernel to the given resolution (default 1).

For more about the math see https://en.wikipedia.org/wiki/Lanczos_resampling#Lanczos_kernel

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|order|uint|3|Order of the lanczos kernel. Acceptable minimum is 2.|
|step|double|1|X-delta between kernel elements.|

---
### <a name='image_kernel_laplace_4'></a> aktive image kernel laplace 4

Syntax: __aktive image kernel laplace 4__ 

Returns convolution kernel for laplacian edge detection


---
### <a name='image_kernel_laplace_8'></a> aktive image kernel laplace 8

Syntax: __aktive image kernel laplace 8__ 

Returns convolution kernel for laplacian edge detection


---
### <a name='image_kernel_laplace_X'></a> aktive image kernel laplace X

Syntax: __aktive image kernel laplace X__ 

Returns convolution kernel for laplacian edge detection


---
### <a name='image_kernel_prewitt_md'></a> aktive image kernel prewitt md

Syntax: __aktive image kernel prewitt md__ 

Returns convolution kernel for prewitt edge detection


---
### <a name='image_kernel_prewitt_sd'></a> aktive image kernel prewitt sd

Syntax: __aktive image kernel prewitt sd__ 

Returns convolution kernel for prewitt edge detection


---
### <a name='image_kernel_prewitt_x'></a> aktive image kernel prewitt x

Syntax: __aktive image kernel prewitt x__ 

Returns convolution kernel for prewitt edge detection


---
### <a name='image_kernel_prewitt_y'></a> aktive image kernel prewitt y

Syntax: __aktive image kernel prewitt y__ 

Returns convolution kernel for prewitt edge detection


---
### <a name='image_kernel_roberts_x'></a> aktive image kernel roberts x

Syntax: __aktive image kernel roberts x__ 

Returns convolution kernel for roberts cross edge detection


---
### <a name='image_kernel_roberts_y'></a> aktive image kernel roberts y

Syntax: __aktive image kernel roberts y__ 

Returns convolution kernel for roberts cross edge detection


---
### <a name='image_kernel_scharr_x'></a> aktive image kernel scharr x

Syntax: __aktive image kernel scharr x__ 

Returns convolution kernel for scharr edge detection


---
### <a name='image_kernel_scharr_y'></a> aktive image kernel scharr y

Syntax: __aktive image kernel scharr y__ 

Returns convolution kernel for scharr edge detection


---
### <a name='image_kernel_sharp_4'></a> aktive image kernel sharp 4

Syntax: __aktive image kernel sharp 4__ 

Returns convolution kernel for sharpening effect


---
### <a name='image_kernel_sharp_8'></a> aktive image kernel sharp 8

Syntax: __aktive image kernel sharp 8__ 

Returns convolution kernel for sharpening effect


---
### <a name='image_kernel_sharp_X'></a> aktive image kernel sharp X

Syntax: __aktive image kernel sharp X__ 

Returns convolution kernel for sharpening effect


---
### <a name='image_kernel_sobel_md'></a> aktive image kernel sobel md

Syntax: __aktive image kernel sobel md__ 

Returns convolution kernel for sobel edge detection


---
### <a name='image_kernel_sobel_sd'></a> aktive image kernel sobel sd

Syntax: __aktive image kernel sobel sd__ 

Returns convolution kernel for sobel edge detection


---
### <a name='image_kernel_sobel_x'></a> aktive image kernel sobel x

Syntax: __aktive image kernel sobel x__ 

Returns convolution kernel for sobel edge detection


---
### <a name='image_kernel_sobel_y'></a> aktive image kernel sobel y

Syntax: __aktive image kernel sobel y__ 

Returns convolution kernel for sobel edge detection


---
### <a name='image_noise_gauss'></a> aktive image noise gauss

Syntax: __aktive image noise gauss__  ?(param value)...?

Returns image where pixels are set to random values drawn from a gaussian distribution with mean and sigma over +/-sigma. The defaults are 0 and 1.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|depth|uint||Depth of the returned image|
|mean|double|0|Mean of the desired gauss distribution.|
|sigma|double|1|Sigma of the desired gauss distribution.|
|seed|uint|[expr {int(4294967296*rand())}]|Randomizer seed. Needed only to force fixed results, or external random numbers.|

---
### <a name='image_noise_salt'></a> aktive image noise salt

Syntax: __aktive image noise salt__  ?(param value)...?

Returns image containing salt and pepper noise.

Pixels are set where the uniformly distributed random value is under the threshold.

For a given desired percentage P of noise pixels set the threshold to P/100.

The value of set pixels is fixed at 1.0

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|depth|uint||Depth of the returned image|
|threshold|double|0.01|Noise threshold within [0..1].|
|seed|uint|[expr {int(4294967296*rand())}]|Randomizer seed. Needed only to force fixed results, or external random numbers.|

---
### <a name='image_noise_uniform'></a> aktive image noise uniform

Syntax: __aktive image noise uniform__  ?(param value)...?

Returns image where pixels are set to random values drawn from a uniform distribution over [0..1]

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|depth|uint||Depth of the returned image|
|seed|uint|[expr {int(4294967296*rand())}]|Randomizer seed. Needed only to force fixed results, or external random numbers.|

---
### <a name='image_sines'></a> aktive image sines

Syntax: __aktive image sines__  (param value)...

Returns image containing a sine wave in two dimensions.

The ratio between horizontal and vertical frequencies determines the angle of the composite wave relative to the X axis.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|
|hf|double||Horizontal frequency|
|vf|double||Vertical frequency|

---
### <a name='image_square'></a> aktive image square

Syntax: __aktive image square__  ?(param value)...?

Returns single-band white square with radius. Default radius 1.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the square. Full size is 2*radius + 1.|

---
### <a name='image_vbar'></a> aktive image vbar

Syntax: __aktive image vbar__  ?(param value)...?

Returns square single-band image containing a vertical bar. The image has size `2*radius + 1` squared.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the vertical bar.|
|width|uint|0|Width of the element. Default 0. Has to be less or equal to the radius.|

---
### <a name='image_xcross'></a> aktive image xcross

Syntax: __aktive image xcross__  ?(param value)...?

Returns square single-band image containing a diagonal cross. The image has size `2*radius + 1` squared.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|radius|uint|1|Radius of the diagonal cross.|
|width|uint|0|Width of the element. Default 0. Has to be less or equal to the radius.|

---
### <a name='image_zone'></a> aktive image zone

Syntax: __aktive image zone__  (param value)...

Returns image containing a zone plate test pattern.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|width|uint||Width of the returned image|
|height|uint||Height of the returned image|

