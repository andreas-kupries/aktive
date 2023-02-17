# Blit definitions

Scratch document to collect and organize what blit ops are currently in AKTIVE, be they in the
runtime (i.e. `runtime/blit.*`), a global generator text block (see `etc/runtime/blitter`), or
directly coded in some operator, with the goal of making this amenable to code generation.

Where generator is able to optimize the code based on the scan arguments and function.
Like, reduce to memcpy, memset where possible, for contiguous runs.

## Shorthands for variables, the variables

|Code	|What		|Meaning			|Notes				|
|---	|---		|---				|---				|
|SW	|s.width	|Source width			|Source block geometry		|
|SH	|s.height	|Source height			|and indexing			|
|SD	|s.depth	|Source depth			|				|
|SAT	|s.index(y,x,z)	|Source linear coordinate	|				|
|	|		|				|				|
|DW	|d.width	|Destination width		|Destination block geometry	|
|DH	|d.height	|Destination height		|and indexing			|
|DD	|d.depth	|Destination depth		|				|
|DAT	|d.index(y,x,z)	|Destination linear coordinate	|				|
|	|		|				|				|
|AX	|a.x		|Area X location		|Destination subset		|
|AY	|a.y		|Area Y location		|				|
|AW	|a.width	|Area width			|				|
|AH	|a.height	|Area height			|				|

Note: No source subset specified, so far source is always used in its entirety, i.e. the full area. Request setup ensures that this can be done.

## Linearized indices

index (x, y, z) = y * pitch + x * depth + z	= y * W * D + x * D + z	= (y * W + x) * D + z
for scanning

  - compute initial (x,y,0) index
  - next row  += pitch	    /times whatever y factor
  - next col  += depth	    /times whatever x factor
  - next cell += 1	    /times whatever z factor

## Scan specification

### Elements

  - Area(s) to scan (destination, (which, if any) source(s))
  - Axis to scan along
  - Min value on the axis
  - Number of scan steps [*]
  - Delta between values per step (including fractions)
  - Direction of scan

Of these elements the number of scan steps HAS TO be the same for all areas scanned together.
All other information can differ between areas.

Multiple nested scans together with a function to invoke then comprise a full blit of some kind.

(Ad *): For step delta `1` the step number is the width, height, depth of the destination or source,
	etc. For a larger step size the dimension of the dst, src, etc. is accordingly larger
	(multiplied). For a fractional step size the dimension is accordingly smaller (divided)

### Syntax

```
scan	  :: list (steps area...)
area	  :: list (axis min delta direction)
axis	  :: x|y|z
min	  :: posint | varref
delta	  :: posint | varref | 1/varref
direction :: up | down
```

### Functions

|Name		|Parameter	|Semantics				|Notes	|
|---		|---		|---					|---	|
|zero		|		|dst := 0				|memset	|
|const		|v		|dst := v				|	|
|linear		|min,delta	|dst := min + delta * DAT		|	|
|lookup		|v, i		|dst := v[i]				|	|
|		|   		|    					|	|
|identity	|		|dst := src				|memcpy	|
|f		|		|dst := f (src)				|	|
|f		|k		|dst := f (src, k)			|	|
|f		|k, m		|dst := f (src, k, m)			|	|

## Shorthands for important common scan specifications

|Name			|Specification				|Notes		|
|---			|---					|---		|
|all-dst-rows		|`{DH {y 0 1 up}}`			|		|
|all-dst-cols		|`{DW {x 0 1 up}}`			|		|
|all-dst-bands		|`{DD {z 0 1 up}}`			|		|
|			|					|		|
|all-dst-src-rows	|`{DH {y 0 1 up} {y 0 1 up}}`		|DH <= SH	|
|all-dst-src-cols	|`{DW {x 0 1 up} {x 0 1 up}}`		|DW <= SW	|
|all-dst-src-bands	|`{DD {z 0 1 up} {z 0 1 up}}`		|DD <= SD	|
|			|					|		|
|all-dst-src1-src2-rows	|`{DH {y 0 1 up} {y 0 1 up} {y 0 1 up}}`|DH <= SH	|
|all-dst-src1-src2-cols	|`{DW {x 0 1 up} {x 0 1 up} {x 0 1 up}}`|DW <= SW	|
|all-dst-src1-src2-bands|`{DD {z 0 1 up} {z 0 1 up} {z 0 1 up}}`|DD <= SD	|

## Known blits

### Destination only, no source

|Name			|Params		|Scan Specification					|Function		|Constraints				|
|---			|---		|---							|---			|---					|
|clear			|		|`all-dst-rows all-dst-cols all-dst-bands`		|zero			|					|
|set			|v		|`all-dst-rows all-dst-cols all-dst-bands`		|const[v]		|					|
|set-bands-as		|v...		|`all-dst-rows all-dst-cols all-dst-bands`		|lookup (v,z)		|DD <= v.c				|
|gradient		|min,delta	|`all-dst-rows all-dst-cols all-dst-bands`		|linear (min,delta)	|					|
|			|		|							|			|					|
|clear-bands		|s, d		|`all-dst-rows all-dst-cols {d {z s 1 up}}`		|zero			|s+d-1 <= DD				|
|set-bands-from		|s, d, v	|`all-dst-rows all-dst-cols {d {z s 1 up}}`		|const[v]		|s+d-1 <= DD				|
|set-bands-from-as	|s, v...	|`all-dst-rows all-dst-cols {v.c {z s 1 up}}`		|lookup (v,z)		|s+v.c-1 <= DD				|
|			|		|							|			|					|
|clear-area		|A		|`{AH {y AY 1 up}} {AW {x AX 1 up}} all-dst-bands`	|zero			|AH <= DH, AW <= DW			|
|set-area		|A, v		|`{AH {y AY 1 up}} {AW {x AX 1 up}} all-dst-bands`	|const[v]		|AH <= DH, AW <= DW			|
|set-area-band-as	|A, v...	|`{AH {y AY 1 up}} {AW {x AX 1 up}} all-dst-bands`	|lookup (v,z)		|AH <= DH, AW <= DW, DD <= v.c		|
|			|		|							|			|					|
|clear-area-bands	|A, s, d	|`{AH {y AY 1 up}} {AW {x AX 1 up}} {d {z s 1 up}}`	|zero			|AH <= DH, AW <= DW, s+d-1 <= DD	|
|set-area-bands-from	|A, s, d, v	|`{AH {y AY 1 up}} {AW {x AX 1 up}} {d {z s 1 up}}`	|const[v]		|AH <= DH, AW <= DW, s+d-1 <= DD	|
|set-area-bands-from-as	|A, s, v...	|`{AH {y AY 1 up}} {AW {x AX 1 up}} {v.c {z s 1 up}}`	|lookup (v, z)		|AH <= DH, AW <= DW, s+v.c-1 <= DD	|

### Scans of destination with single source together

|Name			|Params	|Scan Specification									|Function	|Constraints			|
|---			|---	|---											|---		|---				|
|copy			|	|`all-dst-src-rows all-dst-src-cols all-dst-src-bands`					|identity	|See shorthands			|
|fastcopy		|	|`all-dst-src-rows all-dst-src-cols all-dst-src-bands`					|identity	|DH == SH, DW == SW, DD == SD	|
|fun/0			|f	|`all-dst-src-rows all-dst-src-cols all-dst-src-bands`					|f		|See shorthands			|
|fun/1			|f, k	|`all-dst-src-rows all-dst-src-cols all-dst-src-bands`					|f[k]		|See shorthands			|
|fun/2			|f, k, m|`all-dst-src-rows all-dst-src-cols all-dst-src-bands`					|f[k,m]		|See shorthands			|
|copy-bands		|s, d	|`all-dst-src-rows all-dst-src-cols {d {z 0  1 up} {z s 1 up}}`				|identity	|d <= DD, s+d-1 <= SD		|
|copy-bands-to		|s, d	|`all-dst-src-rows all-dst-src-cols {d {z s  1 up} {z 0 1 up}}`				|identity	|d <= SD, s+d-1 <= DD		|
|			|	|		   		    							|		|    				|
|copy-area		|A	|`{AH {y AY 1 up} {y 0 1 up}} {AW {x AX 1 up} {x 0 1 up}} {DD {z 0  1 up} {z 0 1 up}}`	|identity	|AH <= DH <= SH, ... 	   	|
|			|	|     	      	       	      	     	      	     	      	      	       	 	|		|				|
|flip-y			|	|`{DH {y 0 1 up} {y 0 1 down}} all-dst-src-cols             all-dst-src-bands`		|identity	|See shorthands			|
|flip-x			|	|`all-dst-src-rows             {DW {x 0 1 up} {x 0 1 down}} all-dst-src-bands`		|identity	|See shorthands			|
|flip-z			|	|`all-dst-src-rows             all-dst-src-cols             {DD {z 0 1 up} {z 0 1 down}}`|identity	|See shorthands			|
|			|	|		   		    	       	      	  				|		|    				|
|downsample-y		|n	|`{DH {y 0 1 up} {y 0 n up}} all-dst-src-cols           all-dst-src-bands`		|identity	|See shorthands, n*DH <= SH	|
|downsample-x		|n	|`all-dst-src-rows           {DW {x 0 1 up} {x 0 n up}} all-dst-src-bands`		|identity	|See shorthands, n*DW <= SW	|
|downsample-z		|n	|`all-dst-src-rows           all-dst-src-cols           {DD {z 0 1 up} {z 0 n up}`	|identity	|See shorthands, n*DD <= SD	|
|			|	|		   		    	       	      	  				|		|    				|
|upsample-y		|n	|`{SH {y 0 n up} {y 0 1 up}} all-dst-src-cols           all-dst-src-bands`		|identity	|Note: Scanning by S* ranges	|
|upsample-x		|n	|`all-dst-src-rows           {SW {x 0 n up} {x 0 1 up}} all-dst-src-bands`		|identity	|      		      		|
|upsample-z		|n	|`all-dst-src-rows           all-dst-src-cols           {SD {z 0 n up} {z 0 1 up}`	|identity	|				|
|			|	|		   		    	       	      	  				|		|    				|
|upsample-y-rep		|n, p	|`{DH {y 0 1 up} {y 0 1/n up}} all-dst-src-cols             all-dst-src-bands`		|identity	|Note: Fractional stepping	|
|upsample-x-rep		|n, p	|`all-dst-src-rows             {DW {x 0 1 up} {x 0 1/n up}} all-dst-src-bands`		|identity	|      		  		|
|upsample-z-rep		|n, p	|`all-dst-src-rows             all-dst-src-cols             {DD {z 0 1 up} {z 0 1/n up}`|identity	|				|
|			|	|		   		    	       	      	  				|		|    				|
|swap-xy		|	|`{DH {y 0 1 up} {x 0 1 up}} {DW {x 0 1 up} {y 0 1 up}} all-dst-src-bands`		|identity	|				|
|swap-xz		|	|`all-dst-src-rows           {DW {x 0 1 up} {z 0 1 up}} {DD {z 0 1 up} {x 0 1 up}}`	|identity	|				|
|swap-yz		|	|`{DH {y 0 1 up} {z 0 1 up}} all-dst-src-cols           {DD {z 0 1 up} {y 0 1 up}}`	|identity	|				|

Notes:
  - `copy-bands` = band selection for `select z`.
  - `copy-bands-to` = band movement for `montage z`.

### Scans of destination with two sources together

|Name	|Params	|Scan Specification							|Function	|Constraints	|
|---	|---	|---									|---		|---		|
|fun	|f	|`all-dst-src1-src2-rows all-dst-src1-src2-cols all-dst-src1-src2-bands`|f		|See shorthands	|

Notes

  - Convolutions scan dst and src1 together, and src2 separately, with a complex function (aggregation of result)

# Collected unique scans

|Name			|Specification					|
|---			|---						|
|all-dst-rows		|`{DH {y 0 1 up}}`				|
|all-dst-cols		|`{DW {x 0 1 up}}`				|
|all-dst-bands		|`{DD {z 0 1 up}}`				|
|			|						|
|all-dst-src-rows	|`{DH {y 0 1 up} {y 0 1 up}}`			|
|all-dst-src-cols	|`{DW {x 0 1 up} {x 0 1 up}}`			|
|all-dst-src-bands	|`{DD {z 0 1 up} {z 0 1 up}}`			|
|			|						|
|all-dst-src1-src2-rows	|`{DH {y 0 1 up} {y 0 1 up} {y 0 1 up}}`	|
|all-dst-src1-src2-cols	|`{DW {x 0 1 up} {x 0 1 up} {x 0 1 up}}`	|
|all-dst-src1-src2-bands|`{DD {z 0 1 up} {z 0 1 up} {z 0 1 up}}`	|
|			|						|
|			|`{AH {y AY 1 up} {y 0 1 up}}`			|
|			|`{AH {y AY 1 up}}`				|
|			|`{AW {x AX 1 up} {x 0 1 up}}`			|
|			|`{AW {x AX 1 up}}`				|
|			|						|
|			|`{DD {z 0 1 up} {z 0 1 up}}`			|
|			|`{DD {z 0 1 up} {x 0 1 up}}`			|
|			|`{DD {z 0 1 up} {y 0 1 up}}`			|
|			|`{DD {z 0 1 up} {z 0 1 down}}`			|
|			|`{DD {z 0 1 up} {z 0 1/n up}`			|
|			|`{DD {z 0 1 up} {z 0 n up}`			|
|			|						|
|			|`{DH {y 0 1 up} {x 0 1 up}}`			|
|			|`{DH {y 0 1 up} {y 0 1 down}}`			|
|			|`{DH {y 0 1 up} {y 0 1/n up}}`			|
|			|`{DH {y 0 1 up} {y 0 n up}}`			|
|			|`{DH {y 0 1 up} {z 0 1 up}}`			|
|			|						|
|			|`{DW {x 0 1 up} {x 0 1 down}}`			|
|			|`{DW {x 0 1 up} {x 0 1/n up}}`			|
|			|`{DW {x 0 1 up} {x 0 n up}}`			|
|			|`{DW {x 0 1 up} {y 0 1 up}}`			|
|			|`{DW {x 0 1 up} {z 0 1 up}}`			|
|			|						|
|			|`{SD {z 0 n up} {z 0 1 up}`			|
|			|`{SH {y 0 n up} {y 0 1 up}}`			|
|			|`{SW {x 0 n up} {x 0 1 up}}`			|
|			|						|
|			|`{d {z 0 1 up} {z s 1 up}}`			|
|			|`{d {z s 1 up} {z 0 1 up}}`			|
|			|`{d {z s 1 up}}`				|
|			|						|
|			|`{v.c {z s 1 up}}`				|
