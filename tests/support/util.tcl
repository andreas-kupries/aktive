# -*- tcl -*-
## (c) 2021,2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands

kt source support/image.tcl
kt source support/builtin.tcl
kt source support/paths.tcl
kt source support/files.tcl
kt source support/match.tcl

# # ## ### ##### ######## ############# #####################
## match command registration

customMatch double4        match4
customMatch image          matchImage
customMatch listpix        matchPixelLists
customMatch pixels         matchPixels
customMatch content        matchFileContent
customMatch content/string matchFileContentString

# # ## ### ##### ######## ############# #####################
## Automated wrong#args checking based on command name and argument
## list, with light annotations. Handles `args` and optional arguments
## (`?x?`). Generates and runs all the needed test cases.

proc syntax {spec basecmd {setup {}} {cleanup {}} {xlabel {}} {map {}}} {
    # spec :: dict ( method -> methodargs )

    set xtlabel {}
    if {$xlabel ne {}} {
	set xtlabel ${xlabel}-
	append xlabel ": "
    }

    # Auto-detect how to join the methods with their base command,
    # based on the separator used in the base command.
    set gap [expr {[string match {*::*} $basecmd]
		   ? "::"
		   : " " }]

    foreach {mcmd margs} $spec {
	if {$mcmd eq "-"} continue

	lassign [arg-counts $margs] required limit dargnames
	# I.e. min arguments needed, and max allowed.
	# `max == ""` implies infinity.

	# Skip commands who need nothing, and accept an unlimited number of arguments.
	# Such a command does not have a wrong#args condition, and we cannot test that.
	if {($required == 0) && ($limit eq {})} continue

	# Compute general common strings.

	if {$dargnames ne {}} { set dargnames " $dargnames"}

	if {$mcmd eq {}} {
	    # Nothing to append to the base. We are testing the base here.
	    set cmd "$basecmd"
	} else {
	    set cmd "$basecmd$gap$mcmd"
	}
	set expected "wrong # args: should be \"$cmd$dargnames\""
	if {[llength $map]} { set expected [string map $map $expected] }

	set tbase    [string map {{ } - :: -} $basecmd]

	# Assemble test cases from the min/max information.
	set testcases {}
	if {$required > 0} {
	    lappend testcases {}
	    for {set i 0} {$i < ($required - 1)} {incr i} {
		lappend testcases [lrange $margs 0 $i]
	    }
	} else {
	}
	if {$limit ne {}} {
	    lappend margs X
	    lappend testcases $margs
	}

	# And run the cases ...
	set k 0
	foreach params $testcases {
	    set tlabel "$xlabel$cmd ($params), wrong # args"
	    set tname  ${tbase}-${xlabel}${mcmd}-[join $params /]-1.${k}

	    test $tname $tlabel -setup {
		uplevel 1 $setup
	    } -cleanup {
		uplevel 1 $cleanup
	    } -body {
		{*}$cmd {*}$params
	    } -returnCodes error -result $expected

	    incr k
	}
    }
    return
}

proc arg-counts {signature} {
    set min [llength $signature]
    set max $min

    # TODO: Can Tcl handle optional arguments and infinite ?
    # TODO: Can Tcl handle optional arguments in the middle?

    # Arbitrary number of arguments after the required.
    if {[lindex $signature end] eq "args"} {
	set  max {}
	incr min -1
	set signature [lreplace $signature end end "?arg ...?"]
	return [list $min $max [join $signature { }]]
    }

    # Ditto, different form. If this form is specified nothing is
    # changed, and assumed to be what is reported by the command in
    # question.
    if {[lindex $signature end] eq "?args...?"} {
	set  max {}
	incr min -1
	return [list $min $max [join $signature { }]]
    }

    # Optional arguments, can be only at the end.
    foreach arg [lreverse $signature] {
	if {![string match {\?*\?} $arg]} break
	incr min -1
    }

    return [list $min $max [join $signature { }]]
}

if 0 {proc syntax {spec cv av kv pv script} {
    upvar 1 $cv cmd $kv k $pv params $av dargnames

    foreach {cmd argnames} $spec {

	if {$cmd eq "-"} continue

	if {[llength $argnames]} {
	    set dargnames " $argnames"
	} else {
	    set dargnames $argnames
	}

	set params {}

	set k 0
	foreach a [linsert $argnames end X .] {
	    if {[llength $params] == [llength $argnames]} {
		lappend params $a
		continue
	    }

	    # -> cmd k params dargnames
	    uplevel 1 $script

	    incr k
	    lappend params $a
	}
    }

    uplevel 1 [list unset $cv $kv $pv $av]
    return
}}

# # ## ### ##### ######## ############# #####################

catch { kt source support/config.tcl }

# # ## ### ##### ######## ############# #####################
return
