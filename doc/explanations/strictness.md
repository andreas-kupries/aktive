
<img src='../assets/aktive-logo-128.png' style='float:right;'>

|||||||
|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|[References ↗](../ref/index.md)|

# Strictness

While functional and other paradigms programming have a very good definition of strictness here we
need to know only this:

  - Most of AKTIVE's operators do not actually compute pixels at all.
    They build a processing pipeline in memory instead. Actually a directed acyclic graph.
    Such a pipeline only describes a set of operations to perform, and how they are linked together.

  - A pipeline P is executed, i.e. computes actual pixel data when and only when an operator is
    executed which is __strict__ in the argument P is assigned to.

This makes most of the operators fast, as they only have to construct a small node in memory
describing their operation instead of computing all the pixels.

For the full set please see the [index of the strict operators](../ref/strict.md).

Note that while [materialization](materialize.md) is a related concept, it is not the same.

While a materializing operator is strict by necessity (of having to know the entire image) a strict
operator does not necessarily materialize the image.

An example of the latter are the operators computing image statistics.  They compute their results
incrementally from partial pixel data, as the pixels are computed, and then discard the used pixels.
