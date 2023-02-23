# -*- tcl -*-
## (c) 2021-2023 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Test Utility Commands - File Manipulation

# - Load file into memory, binary
# - Load file into memory, text
# - Create a file, possibly with content, binary
# - Extend file with content, binary, create missing
# - Edit a file in place, per the command (read, modify, write)
# - Load a TSV file, return as list of rows (list of cells).
#   Note: Ignores empty lines, and lines starting with `=`.

proc cat {path} {
    set c [open $path rb]
    set d [read $c]
    close $c
    return $d
}

proc catx {path} {
    set c [open $path r]
    set d [read $c]
    close $c
    return $d
}

proc wtouch {path {content {}}} {
    writable $path
    touch    $path $content
}

proc touch {path {content {}}} {
    file mkdir [file dirname $path]
    set c [open $path wb]
    if {$content ne {}} { puts -nonewline $c $content }
    close $c
    return $path
}

proc touch+ {path content} {
    file mkdir [file dirname $path]
    set c [open $path ab]
    puts -nonewline $c $content
    close $c
    return
}

# Setting files writable and readonly, dependent on platform
if {$tcl_platform(platform) eq "unix"} {
    # unix
    proc writable {path} {
	file attributes $path -permissions ugo+w
    }
    proc readonly {path} {
	file attributes $path -permissions ugo-w
    }
} else {
    # not unix - windows
    proc writable {path} {
	file attributes $path -readonly 0
    }
    proc readonly {path} {
	file attributes $path -readonly 1
    }
}

proc fedit {cmd path} {
    writable $path
    touch    $path [{*}$cmd [cat $path]]
    #readonly $path
    return
}

proc tsv {path} {
    return [lmap line [split [catx $path] \n] {
	if {[string match =* $line]} continue
	if {[string trim $line] eq {}} continue
	split [regsub -all {\t+} $line \033] \033
    }]
}

# # ## ### ##### ######## ############# #####################
return
