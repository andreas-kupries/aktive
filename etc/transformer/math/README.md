# Image math

Unary and binary math on images, for regular and `complex`-valued images.
All functions are applied per-cell.

## Unary

The applied functions may have no, one, or two parameters.

|Op		|Result per pixel, applied function		|
|---		|---						|
|abs		| Absolute value				|
|acos		| Arccosinus					|
|acosh		| Hyperbolic arccosinus				|
|asin		| Arcsinus					|
|asinh		| Hyperbolic arcsinus				|
|atan		| Arctangens					|
|atanh		| Hyperbolic arctangens				|
|cbrt		| `pow(I,1/3)`, cubic root			|
|ceil		| `ceil(I)`, next integer greater or equal	|
|clamp		| `min(1,max(0,I))`				|
|cos		| Cosinus					|
|cosh		| Hyperbolic cosinus				|
|exp		| `pow(e,I)`					|
|exp10		| `pow(10,I)`					|
|exp2		| `pow(2,I)`					|
|floor		| `floor(I)`, next integer less or equal	|
|gamma::compress| [Gamma compression](https://en.wikipedia.org/wiki/SRGB#Transfer_function_(%22gamma%22))	|
|gamma::expand	| [Gamma expansion](https://en.wikipedia.org/wiki/SRGB#Transfer_function_(%22gamma%22))		|
|invert		| `1-I`							|
|log		| `log(e,I)`						|
|log10		| `log(10,I)`						|
|log2		| `log(2,I)`						|
|neg		| `0-I`							|
|not		| `I <= 0.5 ? 1 : 0`					|
|reciproc	| `1/I`							|
|round		| `round(I)` to nearest integer				|
|sign		| `sign(I)`  { -1, 0, 1 }				|
|sign*		| `sign*(I)` { -1, 1, 1 }				|
|sin		| Sinus							|
|sinh		| Hyperbolic sinus					|
|sqrt		| `pow(I,1/2)`, square root				|
|square		| `pow(I,2)` = `I*I`					|
|tan		| Tangens						|
|tanh		| Hyperbolic tangens					|
|wrap		| Reduce to interval [0,1], via `fmod` (wrapping)	|
|		|							|
|atan2		|`atan2(x, I)`						|
|atan2b		|`atan2(I, y)`						|
|eq		|`I == threshold`, bool result, `1` if true, `0` else	|
|expx		|`pow(base, I)`						|
|ge		|`I >= threshold`					|
|gt		|`I >  threshold`					|
|hypot		|`hypot(I,y)`						|
|le		|`I <= threshold`					|
|lt		|`I <  threshold`					|
|max		|`max(I, minlimit)`					|
|min		|`min(I, maxlimit)`					|
|mod		|`fmod(I, modulus)`, remainder by scalar modulus	|
|modb		|`fmod(modulus, I)`					|
|ne		|`I != threshold`					|
|neg-shift	|`offset-I`						|
|pow		|`pow(I, exponent)`					|
|reciproc-scale |`factor/I`						|
|scale		|`I*factor`, scalar factor				|
|shift		|`I+offset`, scalar offset				|
|solarize	|`I <= threshold ? I : 1-I`				|
|		|							|
|inside-cc	|`I in [low,high] ? 1 : 0`				|
|inside-co	|`I in [low,high) ? 1 : 0`				|
|inside-oc	|`I in (low,high] ? 1 : 0`				|
|inside-oo	|`I in (low,high) ? 1 : 0`				|
|outside-cc	|`!inside-cc`						|
|outside-co	|`!inside-co`						|
|outside-oc	|`!inside-oc`						|
|outside-oo	|`!inside-oo`						|

## Binary

Note that the logical operations (`and`, `or`, ...) all threshold their input at `0.5` to determine
their input's logical levels before applying the actual logical function.

|Op		|Result per pixel, applied function	|
|---		|---					|
|difference	|`abs(A-B)`				|
|screen		|`A+B-A*B` = `A-A*B+B` = `A*(1-B)+B`	|
|		|					|
|and		|`A and B`				|
|nand		|`not (A and B)`			|
|or		|`A or B`    				|
|nor		|`not (A or B)`				|
|xor		|`A xor B`  				|
|		|   					|
|add		|`A + B`	|
|atan2		|`atan2(A, B)`	|
|div		|`A / B`	|
|eq		|`A == B`	|
|ge		|`A >= B`	|
|gt		|`A > B`	|
|hypot		|`hypot(A,B)`	|
|le		|`A <= B`	|
|lt		|`A < B`	|
|max		|`max(A,B)`	|
|min		|`min(A,b)`	|
|mod		|`A % B`	|
|mul		|`A * B`	|
|ne		|`A != B`	|
|pow		|`pow(A,B)`	|
|sub		|`A - B`	|

## Trinary

|Op		|Result per pixel, applied function	|
|---		|---					|
|linear		|`A+T*(B-A)` = `(1-T)*A+T*B`		|

## Complex

`Complex` images are 2-band images, where band `0` holds the real part of the complex value, and
band `1` the complex part.

### Unary

|Op		|Result per pixel, applied function				|
|---		|---								|
|as-real	|Turn 1-band input to complex, input becomes real part		|
|as-imaginary	|Turn 1-band input to complex, input becomes imaginary part	|
|		|     	     	      	       	    	      			|
|acos		| Arccosinus					|
|acosh		| Hyperbolic arccosinus				|
|asin		| Arcsinus					|
|asinh		| Hyperbolic arcsinus				|
|atan		| Arctangens					|
|atanh		| Hyperbolic arctangens				|
|cbrt		| Cubic root					|
|conjugate	| Negate the imaginary part			|
|cos		| Cosinus					|
|cosh		| Hyperbolic cosinus				|
|exp		| `pow(e,I)`					|
|exp10		| `pow(10,I)`					|
|exp2		| `pow(2,I)`					|
|log		| `log(e,I)`					|
|log10		| `log(10,I)`					|
|log2		| `log(2,I)`					|
|neg		| `0-I`						|
|reciproc	| `1/I`						|
|sign		| `I/abs(I)`					|
|sin		| Sinus						|
|sinh		| Hyperbolic sinus				|
|sqrt		| Square root					|
|square		| `pow(I,2)`					|
|tan		| Tangens					|
|tanh		| Hyperbolic tangens				|
|		| 	     					|
|tocartesian	| Change polar representation to cartesian	|
|topolar	| Change cartesion representation to polar	|

### Binary

|Op		|Result per pixel, applied function				|
|---		|---								|
|cons		|Turn 2 1-band inputs to complex, as real and imaginary parts	|
|		|     	       	      	 	     	      			|
|add		|`A + B`	|
|div		|`A / B`	|
|mul		|`A * B`	|
|pow		|`pow(A,B)`	|
|sub		|`A - B`	|

### Reduce

|Op		|Result per pixel, applied function	|
|---		|---					|
|real		|Extract real part of complex input	|
|imaginary	|Extract imaginary part of complex input|
|abs		|Absolute value	   	   	   	|
|sqabs		|Absolute value, squared		|
|arg		|Phase-angle				|
