
# Performance of the `column histogram` operation under various scan methods and image heights

The scan method is selectable at compile time, at the beginning of `runtime/sink.c`.

We have

|Method	|Description	|
|---	|---		|
|`ALL`	|Computes entire result in one step. Uses a single region covering the entire input.	|
|`ROWS`	|Computes result row by row. Overhead: Recomputes the entire histogram once per bin. I.e. 256 times|
|`CROWS`|Like rows, using 8 concurrent threads.|

The standard mode used by AKTIVE is `CROWS`.

Generally all methods are O(n), however with different constants, i.e. overhead.

Expect `ROWS` overhead to be  256x.

`CROWS` should then reduce that by 8 to "only" 32x over `ALL`.

Details below. Performance numbers are given as values/millisecond

|Height	|Factor	 |`ALL`	|`ROWS`	|`CROWS`|
|---:	|---:	 |---:	|---:	|---:	|
|800	|1	 |15693	|82	|662	|
|1600	|2	 |7846	|41	|382	|
|3200	|4	 |4024	|23	|202	|
|6400	|8	 |2092	|14	|50	|
|12800	|16	 |1090	|6	|18	|
|25600	|32	 |477	|2	|9	|

|Method	|Performance	|Overhead vs `ALL`|
|---	|---:		|---:		|
|`ALL`	|15693		|1		|
|`ROWS`	|82		|~ 195		|
|`CROWS`|662		|~ 24		|

The measured overheads are somewhat better than the expected.
They are however in the rough ballpark.

This might be because the system does some small caching of the last requested region of an image.
