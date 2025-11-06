!include ../parts/topnav-quadrant-ref.inc

# Interpolation methods

Pixel interpolation is used when an image undergoes some kind of coordinate transformation.

AKTIVE currently supports 4 methods, each implemented by its own operator. The
operator documentation behind the links below provides links to more detailed
explanations of the various methods.

|Method			|Operator				|
|---			|---					|
|`near-neighbour`	|<!xref aktive op warp near-neighbour>	|
|`bilinear`		|<!xref aktive op warp bilinear>	|
|`bicubic`		|<!xref aktive op warp bicubic>		|
|`lanczos`		|<!xref aktive op warp lanczos>		|

The operators above are ordered from simplest and fastest at the top of the
table down to the slowest at the bottom. This is also the order from lowest to
highest-quality interpolation.

All operators using interpolation use `bilinear` as their default, balancing
speed and quality.

__Note__ that the `interpolation` parameters of all these operators takes the
method __name__, not the operator command. The mapping from name to command is
done internally.
