# Tools supporting package development

|Tool					|Purpose								|
|---					|---									|
|check-testsuite-command-coverage	|Run test suite in command coverage mode, find untested commands	|
|check-testsuite-simplifier-coverage	|As above, to evaluate coverage of simplification rules by tests	|
|locks.tcl				|Process trace files for cache lock operations and times   		|
|photo					|Mini app to show a P*M file in a Tk photo. Uses `trial-base.tcl`	|
|re					|Re-install AKTIVE into the system. Removes trace and core files. Configurable via `K` variable for the Kettle to use (i.e. Tcl 8.6 / 9). Use the `k*` links in the parent of the top dir	|
|trial-base.tcl				|Common support code for the trial.tcl and pv helper apps		|
|trial.tcl				|Mini app (framework) for ops trialing, edit as needed			|
|trun86					|Run the tests against Tcl 8.6. Assumes presence of a `k86` command in the parent of the top dir	|
|trun9					|See above, for Tcl 9, and assuming presence of a `k9`			|
|webcolor-setup.tcl			|Script to create the `webcolors-*` asset files				|
