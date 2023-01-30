# References and their counting

## Summary

- Operations marking an input `A` as `Keep/Ignore` (`KI`) __require__ a pair of
  `ref`/`unref` commands bracketing `A`, else `A` loses a reference, to the point of being
  obliterated too early, leaving dangling pointers behind, and crashing the process.

- Operations marking an input `A` as `(always) Keep` (`K`) may or may not have a pair of
  `ref`/`unref` commands bracketing `A`. It does not matter. It is recommended to go
  without the pair.

- Operations marking an input `A` as `Keep/Pass` (`KP`) __must not__ have a pair of
  `ref`/`unref` commands bracketing `A`, else `A` loses a reference, to the point of being
  obliterated too early, leaving dangling pointers behind, and crashing the process.

- Any operations marking an input `A` as `Keep/Pass/Ignore` (`KPI`) will treat it in the
  main as `Keep/Pass`. The exception is when `A`'s refcount is 0 and `A` was ignored, then
  dispose of it. Detection of the operation ignoring the input either requires knowledge
  of the operation to replicate its decision process, or cooperation from the operation,
  i.e. the operation signaling the fact to us in some way. The relevant operations in
  __AKTIVE__ all signal.

The details are explained in the following sections.

## Basics

  - Images are managed by counting the references to them.

  - Images are destroyed when their reference count drops to 0, or less!

    __ATTENTION__: Images with a reference count of `0` can exist.  All the constructor
    functions creating a new image start the new image out as such.

    It is only when an image is `unref`d that the reference count becomes important.

## Operational troubles

### Foreword about the tables

The coming tables are all essentially timelines from left to right,
with each row representing a specific sequence of actions, and
consequence. The columns generally are:

  1. Initial refcount of image `A`.
  1. Refcount of `A` after a `ref`, if present.
  1. Action on `A` by the operation.
  1. Refcount of `A` after the operation.
  1. Refcount of `A` after an `unref`, if present.
  1. Consequence for `A` after that.
  1. Verdict (ok, bad)

### KI - Keep/Ignore
<!-- Easy mode -->

Any operation constructor which always creates and returns a new image
starts that image with a reference count of 0.

Any (all or some) input images of the operation are kept as part of the new image and gain
an additional reference. IOW their reference count is incremented.

To handle everything correctly the user of the operation has to aquire a reference for all
inputs, and release that reference when it has the result.

Simply releasing the input images without aquiring them first is __wrong__, and __FATAL__
(hopefully immediately, or debugging will be a pain).

To wit, consider an operation `R = op (A)`.

First, simply `unref` `A` after the `op`:

|A.rc|Action|A.rc|unref|Consequence                                |Verdict|
|---:|---   |---:|---: |---                                        |---    |
|0   |Keep  |1   |0    |A disposed of; R has dangling pointer      |__BAD__|
|^   |Ignore|0   |-1   |A disposed of.                             |OK     |
|1   |Keep  |2   |1    |A kept; R's reference is discounted        |__BAD__|
|^   |Ignore|1   |0    |A disposed of, despite somebody's reference|__BAD__|
|n>1 |Keep  |n+1 |n    |A kept; R's reference is discounted        |__BAD__|
|^   |Ignore|n   |n-1  |A kept; somebody's reference is discounted |__BAD__|

And when doing it right, i.e. aquiring a reference of our own before performing the
operation, this table changes to:

|A.rc|ref |Action|A.rc|unref|Consequence                            |Verdict|
|---:|---:|---   |---:|---: |---                                    |---    |
|0   |1   |Keep  |2   |1    |A kept; R has additional reference     |__OK__ |
|^   |^   |Ignore|1   |0    |A is disposed of                       |__OK__ |
|1   |2   |Keep  |3   |2    |A kept; R and other have references    |__OK__ |
|^   |^   |Ignore|2   |1    |A kept; for somebody's reference       |__OK__ |
|n>1 |n+1 |Keep  |n+2 |n+1  |A kept; R and others have references   |__OK__ |
|^   |^   |Ignore|n+1 |n    |A kept; for somebody others' references|__OK__ |

As a side note, are there actually operations which do ignore their input ?

Does that even make sense ?

Actually yes.

The `geometry` operations (`move-to`, `move-by`, `reshape`) are a nice example.

When multiple geometry changes are stacked, i.e. done after the other, like this:

    R = geo (geo (A move-by 2,2), reshape 4 1 1)

then the entire stack is not truly needed. The essence of a `geometry` operation is to
replace the geometry of the input with a new geometry, possibly derived from the input
geometry (move-by), or constrained by it (reshape). In neither case is the input geometry
needed after the result structures are initialized. There is no need for a tower of
geometry operations on some image `A`. It can always be folded into a single geometry
operation on `A`.

I.e. while the modifiers for changing a geometry are limited, in the data structures that
does not matter, as the modifiers always simply store the resulting geometry.

As such, when a geometry operation `G` sees another geometry operation `Gx` as its input
it simply folds the geometries together and then references Gx's input as its own, instead
of `Gx`. With this behaviour the stack in the example above collapses down to:

    R = geo (A, geo'), where geo' combines the move-by and reshape operations.

So what we see here is that `G` ignores its input `Gx`, but actually keeps the input `A`
of `Gx`.

#### K - (always) Keep (never ignored)
<!-- Truly easy mode -->

When we have an operation for which we know that it always keeps the/its input(s), then
and only then can we elide the `ref`/`unref` pair around the operation.

When we keep doing `ref`/`unref` the second table of the previous section collapses to:

|A.rc|ref |Action|A.rc|unref|Consequence                            |Verdict|
|---:|---:|---   |---:|---: |---                                    |---    |
|0   |1   |Keep  |2   |1    |A kept; R has additional reference     |__OK__ |
|1   |2   |Keep  |3   |2    |A kept; R and other have references    |__OK__ |
|n>1 |n+1 |Keep  |n+2 |n+1  |A kept; R and others have references   |__OK__ |

And removing the bracketing `ref`/`unref` pair changes it to:

|A.rc|Action|A.rc|Consequence                            |Verdict|
|---:|---   |---:|---                                    |---    |
|0   |Keep  |1   |A kept; R has additional reference     |__OK__ |
|1   |Keep  |2   |A kept; R and other have references    |__OK__ |
|n>1 |Keep  |n+1 |A kept; R and others have references   |__OK__ |

Which is still correct.

### KP - Keep/Pass
<!-- Different mode -->

The montage and selection operations are able to optimize themselves by not constructing
themselves at all when possible, and simply returning their input.

For example, doing a montage of a single image is that image itself.  Similarly, selecting
the single column, row, or plane of an image with a width/height/depth of 1, is again the
image itself.

So, when we have such `R = op (A)`, with `op` allowing for a bypass, how do we have to
handle the reference count of `A` ?

Let us try the `ref`/`unref` scheme of easy mode first. Instead of a `Keep` vs. `Ignore`
difference we now have `Keep` vs. `Pass`:

|A.rc|ref |Action|A.rc|unref|Consequence                                 |Verdict|
|---:|---:|---   |---:|---: |---                                         |---    |
|0   |1   |Keep  |2   |1    |A kept; R's reference                       |OK     |
|^   |^   |Pass  |1   |0    |A is disposed of; R = A now dangling pointer|__BAD__|
|1   |2   |Keep  |3   |2    |A kept; R and other have references         |OK     |
|^   |^   |Pass  |2   |1    |A kept; for somebody's reference            |OK     |
|n>1 |n+1 |Keep  |n+2 |n+1  |A kept; R and others have references        |OK     |
|^   |^   |Pass  |n+1 |n    |A kept; for somebody others' references     |OK     |

This is the inverse of the first easy mode table with respect to outcomes. Then what
happens if we do not bracket the operation with a `ref`/`unref` pair?

|A.rc|Action|A.rc|Consequence                                 |Verdict|
|---:|---   |---:|---                                         |---    |
|0   |Keep  |1   |A kept; R's reference                       |__OK__ |
|^   |Pass  |0   |A = R kep   				      |__OK__ |
|1   |Keep  |2   |A kept; R and other have references         |__OK__ |
|^   |Pass  |1   |A kept; for somebody's reference            |__OK__ |
|n>1 |Keep  |n+1 |A kept; R and others have references        |__OK__ |
|^   |Pass  |n	 |A kept; for somebody others' references     |__OK__ |

### KPI - Keep/Ignore/Pass
<!-- Hard mode -->

Yes, this is possible. Consider the scaling of an image by a scalar. Depending on the
scaling factor we may wish to pass the input (`factor == 1`) through, ignore the input
(`factor == 0`), or keep it (any other factor). As a table:

|Factor |Action|Reason					|
|---:   |---   |---					|
|0	|Ignore|Output is constant 0, input not relevant|
|1	|Pass  |Factor is identity, nothing changes	|
|other	|Keep  |We actually operate on the input	|

How do we have to handle the reference count of `A` ?

Starting trivially, without a bracketing pair of `ref`/`unref`:

|A.rc|Action|A.rc|Consequence                                 |Verdict|
|---:|---   |---:|---                                         |---    |
|0   |Keep  |1   |A kept; R's reference                       |OK     |
|^   |Pass  |0   |A = R kept   				      |OK     |
|^   |Ignore|0	 |A kept; should have been disposed of	      |__BAD__|
|1   |Keep  |2   |A kept; R and other have references         |OK     |
|^   |Pass  |1   |A kept; for somebody's reference            |OK     |
|^   |Ignore|1	 |A kept; for somebody's reference            |OK     |
|n>1 |Keep  |n+1 |A kept; R and others have references        |OK     |
|^   |Pass  |n	 |A kept; for somebody others' references     |OK     |
|^   |Ignore|n	 |A kept; for somebody others' references     |OK     |

Now bracket `A`:

|A.rc|ref |Action|A.rc|unref|Consequence                                 |Verdict|
|---:|---:|---   |---:|---: |---                                         |---    |
|0   |1   |Keep  |2   |1    |A kept; R's reference                       |OK     |
|^   |^   |Pass  |1   |0    |A is disposed of; R = A now dangling pointer|__BAD__|
|^   |^	  |Ignore|1   |0    |A is disposed of				 |OK	 |
|1   |2   |Keep  |3   |2    |A kept; R and other have references         |OK     |
|^   |^   |Pass  |2   |1    |A kept; for somebody's reference            |OK     |
|^   |^	  |Ignore|2   |1    |A kept; for somebody's reference            |OK     |
|n>1 |n+1 |Keep  |n+2 |n+1  |A kept; R and others have references        |OK     |
|^   |^   |Pass  |n+1 |n    |A kept; for somebody others' references     |OK     |
|^   |^	  |Ignore|n+1 |n    |A kept; for somebody others' references     |OK     |

Neither works. The issue is with inputs with a reference count of 0 either getting passed
or ignored.

Without a bracketing `ref`/`unref` a fix has to detect when the input is ignored. That
requires the caller to know the operation in detail.

With a bracketing `ref`/`unref` a fix has to detect when the input is passed. That is
trivial, just compare result to input.

A possible fix might therefore be to make `unref` conditional. Do not perform it for `R ==
A`, and `A`'s initial ref count was 0:

|A.rc|ref |Action|A.rc|c/unref|Consequence                                 |Verdict|
|---:|---:|---   |---:|---:   |---                                         |---    |
|0   |1   |Keep  |2   |1      |A kept; R's reference                       |OK     |
|^   |^   |Pass  |1   |__n/a__|A kept; A has superfluous reference	   |__BAD__|
|^   |^	  |Ignore|1   |0      |A is disposed of				   |OK	   |
|1   |2   |Keep  |3   |2      |A kept; R and other have references         |OK     |
|^   |^   |Pass  |2   |1      |A kept; for somebody's reference            |OK     |
|^   |^	  |Ignore|2   |1      |A kept; for somebody's reference            |OK     |
|n>1 |n+1 |Keep  |n+2 |n+1    |A kept; R and others have references        |OK     |
|^   |^   |Pass  |n+1 |n      |A kept; for somebody others' references     |OK     |
|^   |^	  |Ignore|n+1 |n      |A kept; for somebody others' references     |OK     |

Still no good. It is the `ref` which would have to be conditional. And for that we have to
know when the operation passes the input. This the equivalent to knowing when the input is
ignored to make it work without bracketing. It requires the caller to know the operation
in detail.

The best (generic) solution devised so far has been to not have any bracketing, and have
the operation signal to the caller when it ignored the input, to force an `unref`. That
way the caller does not have to replicate the checks done by the operation itself (and get
it wrong):

|A.rc|Action|A.rc|c/unref|Consequence                                 |Verdict|
|---:|---   |---:|---:   |---                                         |---    |
|0   |Keep  |1   |n/a    |A kept; R's reference                       |__OK__ |
|^   |Pass  |0   |n/a    |A = R kept   				      |__OK__ |
|^   |Ignore|0	 |__-1__ |A disposed of	      			      |__OK__ |
|1   |Keep  |2   |n/a    |A kept; R and other have references         |__OK__ |
|^   |Pass  |1   |n/a    |A kept; for somebody's reference            |__OK__ |
|^   |Ignore|1	 |n/a    |A kept; for somebody's reference            |__OK__ |
|n>1 |Keep  |n+1 |n/a    |A kept; R and others have references        |__OK__ |
|^   |Pass  |n	 |n/a    |A kept; for somebody others' references     |__OK__ |
|^   |Ignore|n	 |n/a    |A kept; for somebody others' references     |__OK__ |
