!include ../parts/topnav-dev-b.inc

# Data Structures for Image Processing Pipelines

## Overview

AKTIVE uses two sets of data structures for its Image Processing Pipelines.

The definition structures form a DAG recording the defered
(i.e. non-[strict](../explanations/strictness.md)) operations, their parameters,
and their connections.

The runtime structures on the other hand are only created when a pipeline is
invoked to actually compute results, and are torn down again after that is
done. They also form a DAG which runs parallel to the definition structures and
holds all the state needed to compute the pixels.

## Structure visualizations

  - [Definitions](definitions.md)
  - [Runtime](runtime.md)
  - [Definition & Runtime](defrun.md)
