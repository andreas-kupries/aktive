# -*- mode: tcl ; fill-column: 90 -*-
##
## Extract the structures declared with the A_* macros (see runtime.base.h)
## Emit [D2](d2lang.com) definitions for use by the developer documentation.

namespace eval dsl::structs {
    namespace export scan render
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc dsl::structs::render {figures} {
    set dtwo [auto_execok d2]
    if {![llength $dtwo]} {
	puts [::dsl reader red {d2 command not found, unable to render SVG}]
	return
    }

    puts "Rendering figures to SVG, using structures:"

    foreach figure [glob -nocomplain -directory $figures *.d2] {
	puts "  - [file rootname [file tail $figure]]"

	set dst [file rootname $figure].svg
	exec >@ stdout 2>@ stderr $dtwo --layout=elk $figure $dst
    }
    return
}

proc dsl::structs::scan {_into_ destination _from_ args} {
    # _into_ and _from_ are dummies to make the call syntax nicer to read
    Init
    foreach directory $args {
	foreach header [glob -nocomplain -directory $directory *.h *.c] {
	    Ingest $header
	}
    }
    EmitTo $destination
}

# # ## ### ##### ######## #############

proc dsl::structs::Init {} {
    variable cname   {} ;# name of current structure
    variable structs {} ;# structure database
    # dict :: type -> "field"  -> field -> list (type, ref, description)
    #      :: type -> "fields" -> list (string)
    #      :: type -> "ref"    -> bool
    return
}

proc dsl::structs::Ingest {headerfile} {
    puts "Scanning $headerfile ..."

    foreach line [split [fileutil::cat $headerfile] \n] {
	switch -glob $line {
	    {*#define*} {}
	    {* A_END_PTR*}   - {A_END_PTR*}   { End     1 $line }
	    {* A_END*}       - {A_END*}       { End     0 $line }
	    {* A_FIELD*}     - {A_FIELD*}     { Field     $line }
	    {* A_STRUCTURE*} - {A_STRUCTURE*} { Structure $line }
	    default {}
	}
    }
    CheckOutside {}
    return
}

proc dsl::structs::Structure {line} {
    CheckOutside $line

    # Example: `A_STRUCTURE (aktive_image_info) <open-brace>`
    set xline [string trim $line " \t\{;"]
    # xline: `A_STRUCTURE (aktive_image_info)`

    if {![regexp -- "A_STRUCTURE\\s*\\((.*)\\)\$" $xline -> spec]} {
	return -code error "Bad structure start, syntax"
    }
    # spec: `aktive_image_info`
    if {[string match aktive_* $spec]} { set spec [string range $spec 7 end] }
    # spec: `image_info`

    variable structs
    if {[dict exists $structs $spec]} {
	return -code error "Duplicate structure `$spec`"
    }
    variable cname $spec
    dict set structs $spec {
	fields {}
    }
    return
}

proc dsl::structs::End {ref line} {
    CheckInside $line

    # Example: `<close-brace> A_END (aktive_image_info);`
    set xline [string trim $line " \t\};"]
    # xline: A_END (aktive_image_info)

    if {![regexp -- "A_END(_PTR)?\\s*\\((.*)\\)\$" $xline -> _ spec]} {
	return -code error "Bad closure, syntax"
    }
    # spec: `aktive_image_info`
    if {[string match aktive_* $spec]} { set spec [string range $spec 7 end] }
    # spec: `image_info`

    variable cname
    if {$spec ne $cname} {
	return -code error "Bad closure, expected `$cname`"
    }

    puts "  + Structure `$cname`"

    variable structs
    dict set structs $cname ref $ref
    set cname {}
    return
}

proc dsl::structs::Field {line} {
    CheckInside $line

    # Example: `    A_FIELD (A_OP_DEPENDENT,      state)  ; // Image state, if any, operator dependent`

    lassign  [split $line \;] def desc
    # def:  `    A_FIELD (A_OP_DEPENDENT,      state)  `
    # desc: ` // Image state, if any, operator dependent`

    set desc [string trim $desc " \t/"]
    set def  [string trim $def]
    # def:  `A_FIELD (A_OP_DEPENDENT,      state)`
    # desc: `Image state, if any, operator dependent`

    if {![regexp -- "A_FIELD\\s*\\((.*)\\)$" $def -> spec]} {
	return -code error "Bad field syntax"
    }
    # spec: `A_OP_DEPENDENT,      state`

    lassign [lmap w [split $spec ,] { string trim $w }] type field
    # type:  `A_OP_DEPENDENT`
    # field: `state`

    lassign [Retype $type] type ref

    variable cname
    variable structs
    dict set structs $cname field  $field [list $type $ref $desc]
    dict set structs $cname fields [linsert [dict get $structs $cname fields] end $field]
    return
}

proc dsl::structs::IsRef {type} {
    variable structs
    if {![dict exists $structs $type]} { return 0 }
    dict get $structs $type ref
}

proc dsl::structs::Retype {type} {
    set suffix ""
    if {[string match {A_FUNC *} $type]} {
	set type [string trim [string range $type 6 end]]
	append suffix ()
    }

    if {[string match aktive_* $type]} { set type [string range $type 7 end] }
    set map {
	A_OP_DEPENDENT "<op-dependent>*"
	A_STRING       "string"
	A_CSTRING      "const-string"
    }
    if {[dict exists $map $type]} { set type [dict get $map $type] }
    set ref [string match "*\\*" $type]
    if {$ref} { set type [string range $type 0 end-1] }
    list $type$suffix $ref
}

proc dsl::structs::CheckInside {line} {
    #puts "Ingesting: $line"
    variable cname
    if {$cname eq {}} { return -code error "Outside of structure" }
    return
}

proc dsl::structs::CheckOutside {line} {
    #if {$line ne {}} { puts "Ingesting: $line" }
    variable cname
    if {$cname ne {}} { return -code error "Still inside structure `$cname`" }
    return
}

proc dsl::structs::EmitTo {destination} {
    variable structs
    # clear out old definitions
    file delete {*}[glob -nocomplain -directory $destination *.d2]

    puts "Writing structures:"

    dict for {name spec} $structs {
	EmitStruct $destination/${name}.d2 $name $spec
    }
    return
}

proc dsl::structs::EmitStruct {destination name spec} {
    # dict :: "field"  -> field -> list (type, ref, description)
    #      :: "fields" -> list (string)
    #      :: "ref"    -> bool

    puts "  - $name"

    lappend lines "$name : \{"
    lappend lines "  shape: class"

    foreach field [dict get $spec fields] {
	lassign [dict get $spec field $field] type ref description
	if {[IsRef $type]} { set ref 1 }
	if {$ref} { set type "\u2192 $type" }

	lappend lines "  \"F $field\": \"$type\""
    }

    lappend lines "\}"

    # commit
    fileutil::writeFile $destination [join $lines \n]\n
    return
}

# # ## ### ##### ######## #############
return
