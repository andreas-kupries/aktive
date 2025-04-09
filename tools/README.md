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
|trun					|Run the tests against Tcl in PATH	     				|
|webcolor-setup.tcl			|Script to create the `webcolors-*` asset files				|
