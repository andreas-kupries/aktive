# Embeddings

Embeddings add a border of some kind around their input. One can say that the input is embedded into
a larger frame. The size of the border is specified separately for all 4 possible edges.

|Name	|Description								|
|---	|---									|
|black	|A black border								|
|white	|A white border								|
|bg	|A border of some arbitrary "color" (band values)			|
|copy	|Replicate the edge itself 	   	 				|
|tile	|Place (partial) copies of the input around it (toroidal closure)	|
|mirror	|Place (partial) mirrored copies of the input around it	 		|

# Details

For the more detailed explanations of the embeddings we look only at a single row of the image, and
its left/right borders. The explanation shows both input and output row, in abstract form, without
concrete values. The input row is shown on top of the output row. The borders are of width 3 in most
examples.


## `black`, `white`, and `bg`

```
      a b c d e f g h i j k l
X X X a b c d e f g h i j k l X X X
```

where X is the chosen color / band values.

## `copy`

```
      a b c d e f g h i j k l
a a a a b c d e f g h i j k l l l l
\-\-\-/                     \-/-/-/
```

## `tile`

```
      a b c d e f g h i j k l
j k l a b c d e f g h i j k l a b c
----/ \---------------------/ \----
```

## `mirror`

```
      a b c d e f g h i j k l
c b a a b c d e f g h i j k l l k j
----/ \---------------------/ \----
```

Note the mirroring (here: `flip x`) going on for the tiles.

For borders larger than the width of the image the tiles continue to be flipped:

```
      a b c d e 
c b a a b c d e e d c b a a b c d e
----/ \-------/ \-------/ \-------/
                flip x    flip flip x ...
```
