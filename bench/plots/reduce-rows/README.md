<img src='../../../doc/assets/aktive-logo-128.png' style='float:right;'>

Benchmark results for row reducers

||
|---|
|[Parent ↗](../README.md)|

## Summary


### Aug 27, 2026

The big outliers are the two profile operations, where the
unrolling makes them very much worse than the baseline. The
reasons for that are actually quite simple. The baseline
implementation checks only until it finds the desired border and
then stops. Whereas the framework always scans the entire
vector. In other words, while both baseline and framework are
`O(n)` theoretically, for baseline this is worst-case behaviour,
leaving us with a much smaller constant compared to the framework.

Beyond that, for most cases there is no speed difference for
vector sizes up to a hundred pixels, regardless of depth. Thus,
while the code complexity of the unrolling does not give us
anything there, the overhead does not hurt us either. Mostly. The
exceptions are `stddev` and `variance`, for `depths > 4`. In the
balance I see no reason to introduce different methodologies based
on vector size.

In the following table we show the best variant per operator and
depth, for `baseline` (b), `perdepth0` (p0), and `perdepth1` (p1).

|Op |1| |2|3| |4|5+   |
|---|---: |---: |---: |---: |---: |---: |---: |
|argmax |p1   | |p1   |p1   | |p1   |p1   |
|argmin |p1   | |p1   |p1   | |p1   |p1   |
|max|p1   | |p1   |p1   | |p1   |p1   |
|mean   |p1   | |p1   |p1   | |p1   |p1   |
|min|p1   | |p1   |p1   | |p1   |p1   |
|profile|b| |b|b| |b|b|
|rprofile   |b| |b|b| |b|b|
|stddev |p1   | |p1   |p1   | |p1   |p1   |
|sum|p1   | |p1   |p1   | |p1   |p1   |
|sumsquared |p1   | |p1   |p1   | |p1   |p1   |
|variance   |p1   | |p1   |p1   | |p1   |p1   |

Overall I am giving the win to `perdepth1`.

To get the profiles up to speed we need two things the framework currently does not have:

1. The ability to specify a stop condition enabling the loops to abort early, and

1. The ability to scan the vector from the end.

The first is required for both profile operations. The second applies only to `rprofile`.

Defer this to later.

## Plots

  - [All](plots-all.md)

### Speed per operator, across depths

  - [argmax](plots-operator-argmax.md)
  - [argmin](plots-operator-argmin.md)
  - [max](plots-operator-max.md)
  - [mean](plots-operator-mean.md)
  - [min](plots-operator-min.md)
  - [profile](plots-operator-profile.md)
  - [rprofile](plots-operator-rprofile.md)
  - [stddev](plots-operator-stddev.md)
  - [sum](plots-operator-sum.md)
  - [sumsquared](plots-operator-sumsquared.md)
  - [variance](plots-operator-variance.md)

### Speed per depth, across operators

  - [1](plots-depth-1.md)
  - [2](plots-depth-2.md)
  - [3](plots-depth-3.md)
  - [4](plots-depth-4.md)
  - [5](plots-depth-5.md)
  - [6](plots-depth-6.md)
  - [7](plots-depth-7.md)
  - [8](plots-depth-8.md)
