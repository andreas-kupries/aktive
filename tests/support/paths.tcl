# -*- tcl -*-
## (c) 2021,2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands - Path Construction

# - Shorthand for test directory
# - Shorthand for test assets
# - Shorthand for tesult result assets

proc td {}     { return $tcltest::testsDirectory }
proc A  {path} { file join [td] assets $path }
proc R  {path} { A results/$path }

# - list directory
# - list directory, names + sizes

proc lsdir {path} {
    string trim [join [lsort -dict [fileutil::find $path]] \n]
}

proc lsdir+size {path} {
    string trim [join [lmap p [lsort -dict [fileutil::find $path]] {
	list [file size $p] $p
    }] \n]
}

# # ## ### ##### ######## ############# #####################
return
