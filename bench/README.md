# Benchmarking corpus

Benchmarks for a number of operations provided by `AKTIVE`.

Definitely not all at the moment.

Supporting tools and code reside in the `tools/` and `support/`
directories.

|Location	|File				|Notes						|
|---		|---				|---						|
|`support/`	|				|						|
|		|`bench-gen-utilities.tcl`	|Utility procedures for bench .generate specs	|
|`tool/`	|				|	 	    	      			|
|		|`bench-to-sqlite`		|Conversion of .result file to .sqlite database	|
|		|`bench-to-csv`			|Conversion of .result file to .csv file	|

Files with extension `.bench` are benchmark files immediately usable
with the `kettle bench` command. The files with extension `.generate`
on the other hand are generators producing a suite of `.bench` files.

The generation utilities are set up such that the benchmarks generated
by a file `foo.generate` are placed into the subdirectory
`generated/foo/` of this directory.

The repository is set up such that everything underneath the
`generated/` subdirectory is ignored when listing and committing
changes.
