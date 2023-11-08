
# Performance of the `column histogram` operation under various scan methods and image heights

The scan method is selectable at compile time, at the beginning of `runtime/sink.c`.

We have

|Method         |Description    |
|---            |---            |
|`ALL`          |Computes entire result in one step. Uses a single region covering the entire input.    |
|`ROWS`         |Computes result row by row. Overhead: Recomputes the entire histogram once per bin. I.e. 256 times|
|`CROWS`        |Like ROWS, using 8 concurrent threads.|
|`ROWSc`        |Like ROWS, with cached histograms|
|`CROWSc`       |Like CROWS, with cached histograms|

The standard mode used by AKTIVE is `CROWS`.

Generally all methods are O(n), however with different constants, i.e. overhead.

Expect `ROWS` overhead to be  256x.

`CROWS` should then reduce that by 8 to "only" 32x over `ALL`.

The `cXXX` methods have a column cache added to their base operation.

The `CROWSc` method was originally much slower than `CROWS` itself (2-3x). This was likely due to
the threads lock-fighting over the columns, as all the threads scanned their row from left to right,
starting at the same column. The system was then modified to have each thread start scanning in a
different column, by some randomization. I.e. spread the threads over the columns as means of
reducing the change of contention. The performance data shown here is from this modified code.

`CROWSv` is based on the redone `IVecCache` which does not use the global cache at all, may use only
two locks (vector, and tracking alocator) in the worst case, and no locking at all when the vector
is created.

Details below. Performance numbers are given as values/millisecond

|Height |Factor |`ALL`  |`ROWS` |`ROWSc` |`CROWS` |`CROWSc` |`CROWSv` |
|---:   |---:   |---:   |---:   |---:    |---:    |---:     |---:     |
|800    |1      |15693  |82     |470     |662     |758      |1097     |
|1600   |2      |7846   |41     |242     |382     |514      |737      |
|3200   |4      |4024   |23     |123     |202     |321      |375      |
|6400   |8      |2092   |14     |61      |50      |178      |191      |
|12800  |16     |1090   |6      |30      |18      |88       |99       |
|25600  |32     |477    |2      |15      |9       |49       |50       |

|Method   |Performance |Overhead vs `ALL` |
|---      |---:        |---:              |
|`ALL`    |15693       |1                 |
|`ROWS`   |82          |~ 195             |
|`ROWSc`  |470         |~ 33   (x5.73)    |
|         |            |                  |
|`CROWS`  |662         |~ 24              |
|`CROWSc` |758         |~ 20   (x1.14)    |
|`CROWSv` |1097        |~ 14   (x1.66)    |

The measured overheads are somewhat better than the expected.
They are however in the rough ballpark.

This might be because the system does some small caching of the last requested region of an image.

# Summary

While the column histogram cache does provide a boost to performance (~ 14%) I had hoped for more.
I suspect that the locking we have is eating a substantial part of the possible boost.

It would be simpler if the cache were unlimited, i.e. would not have to care about invalidated
blocks. In that case the moment a cache block exists no locking is required anymore, as all access
would be read-only, of immutable data.

# Summary II

With the changed `IVecCache` we get arond 66% boost over the `CROWS` baseline.
Much happier.

Work on similar changes for the `VecCache`.


# TODO

- Look into designs requiring less locking.
- Look into lock-free data structures.
- Maybe reduce when and how often trim completion is done ?

  NOTE: Given that the default limit is 100M and the examples used are way below that no time should
  	have been spent on actual trimming. While we still content on the global cache lock for
  	this.
