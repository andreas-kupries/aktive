# -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## #############

namespace eval dsl::reader {
    namespace export do
    namespace ensemble create

    variable state {}
    variable counter 0	;# counter for operator groups
    variable topdir [file dirname [file dirname [file normalize [info script]]]]
}

# # ## ### ##### ######## #############

proc dsl::reader::do {package specification} {
    variable state
    variable readdir
    variable importing

    Init $package

    set readdir   [file dirname [file normalize $specification]]
    set importing 0

    puts "Reading [blue $specification]"

    source $specification

    if {[llength [Get todos]]} {
	puts "[cyan "Skipped definitions"]: [red [llength [Get todos]]] noted in [blue todo.txt]"
    }

    ::return $state
}

# # ## ### ##### ######## #############
## DSL commands -- Highlevel
##
## Cache operators (row, column)

proc dsl::reader::cached {kind label function args} {
    CacheCode \
	[CacheCodeConfig \
	     $kind $label $function \
	     [ProcessCacheConfig $args]]
}

proc dsl::reader::ProcessCacheConfig {words} {
    lassign {{} {} {} {} 0} rsize fields setup cleanup cdata
    while {[string match -* [set o [lindex $words 0]]]} {
	switch -exact -- $o {
	    --       { set words [lassign $words _] ; break }
	    -cdata   { set words [lassign $words _ cdata]   }
	    -rsize   { set words [lassign $words _ rsize]   }
	    -fields  { set words [lassign $words _ fields]  }
	    -setup   { set words [lassign $words _ setup]   }
	    -cleanup { set words [lassign $words _ cleanup] }
	    default  {
		Abort "Bad option '$o', expected -cdata, -cleanup, -fields, -rsize, -setup, or --"
	    }
	}
    }

    if {[llength $words]} {
	Abort "Unknown arguments after options"
    }

    list $rsize $fields $setup $cleanup $cdata
}

proc dsl::reader::CacheCodeConfig {kind label function config} {
    set axis [dict get { row y      column x      } $kind]
    set adim [dict get { row height column width  } $kind]
    set oaxs [dict get { row x      column y      } $kind]
    set odim [dict get { row width  column height } $kind]

    lappend map %%%kind%%%     $kind	;# elements, implies axis
    lappend map %%%label%%%    $label
    lappend map %%%function%%% $function
    #
    lappend map %%%axis%%%     $axis	;# axis
    lappend map %%%adim%%%     $adim	;# axis dimension
    lappend map %%%oaxis%%%    $oaxs	;# ortho axis
    lappend map %%%odim%%%     $odim	;# ortho axis dimension
    #
    lassign $config rsize fields setup cleanup cdata
    #
    lappend map %%%rfields%%%  $fields
    lappend map %%%rsetup%%%   $setup
    lappend map %%%rcleanup%%% $cleanup
    lappend map %%%cdata%%%    $cdata

    if {$rsize ne {}} {
	lappend map %%%sfields%%% "aktive_uint size; // quick access to original size of the ${kind}s"
	lappend map %%%ssetup%%%  "state->size = domain->${odim}; domain->${odim} = ${rsize};"
	lappend map %%%subsize%%% "istate->size"
	lappend map %%%rsize%%%   "$rsize"
    } else {
	lappend map %%%sfields%%% {}
	lappend map %%%ssetup%%%  {}
	lappend map %%%subsize%%% "idomain->${odim}"
	lappend map %%%rsize%%%   "subrequest.${odim}"
    }
    #
    # last, because it needs the preceding map
    lappend map %%%loops%%%    [CacheLoops/$kind $map]
}

proc dsl::reader::CacheCode {map} {
    input

    state -fields {
	%%%sfields%%%
	aktive_iveccache ivcache; // result cache, %%%kind%%% %%%label%%%
    } -cleanup {
	aktive_iveccache_release (state->ivcache);
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	%%%ssetup%%%
	state->ivcache = aktive_iveccache_new (domain->%%%adim%%% * domain->depth, domain->%%%odim%%%);
	// note: #(%%%kind%%% vectors) takes bands into account
    } {*}$map

    pixels -state {
	%%%rfields%%%
	aktive_iveccache ivcache; // result cache, %%%kind%%% %%%label%%%, thread-shared
    } -setup {
	state->ivcache = istate->ivcache;
	%%%rsetup%%%
    } -cleanup {
	%%%rcleanup%%%
    } {
	// Scan the %%%kind%%%s of the request
	// - Get the associated cached %%%kind%%% %%%label%%%
	// - Compute and cache any missing results

	aktive_rectangle_def_as (subrequest, request);
	subrequest.%%%adim%%%  = 1;
	subrequest.%%%odim%%%  = %%%subsize%%%;
	subrequest.%%%oaxis%%% = idomain->%%%oaxis%%%;
	TRACE_RECTANGLE_M("%%%kind%%% %%%label%%%", &subrequest);

	aktive_uint stride = block->domain.width * block->domain.depth;
	aktive_uint bands  = block->domain.depth;

	aktive_ivcache_context context = {
	    // .z is set during the iteration. same for subrequest.%%%axis%%%
	    .size    = subrequest.%%%odim%%%,
	    .stride  = bands,
	    .request = &subrequest,
	    .src     = srcs->v[0],
	    .client  = %%%cdata%%%,
	};

	%%%loops%%%

	TRACE_DO (__aktive_block_dump ("%%%kind%%% %%%label%%% out", block));
    } {*}$map
}

proc dsl::reader::CacheLoops/row {map} {
    string map $map {
	// iterator setup
	aktive_uint x, y, z, k, j;
	#define ITERX for (x = request->x, k = 0; k < request->width  ; x++, k++)
	#define ITERY for (y = request->y, j = 0; j < request->height ; y++, j++, py++)
	#define ITERZ for (z = 0; z < bands; z++)

	// 3 kinds of y-coordinates.
	//
	// 1. y  - logical coordinate of %%%kind%%%
	// 2. j  - physical coordinate of %%%kind%%% in memory block
	// 3. py - distance to logical y position -> cache index

	aktive_uint py = request->y - idomain->y;
	ITERY {
	    ITERZ {
		context.z = z;
		/* context->request */ subrequest.y = y;
		double* result = aktive_iveccache_get (state->ivcache,
						       py*bands+z,
						       %%%function%%%,
						       &context);
		// result is full %%%odim%%% of function result.
		// now extract the requested sub section.

		TRACE_HEADER(1); TRACE_ADD ("[y,z=%u,%u] %%%kind%%% %%%label%%% = {", y, z);
		for (int a = 0; a < %%%rsize%%%; a++) { TRACE_ADD (" %f", result[a]); }
		TRACE_ADD(" }", 0); TRACE_CLOSER;

		ITERX {
		    TRACE ("line [%u], band [%u] place k%u b%u j%u s%u -> %u (res[%d] = %f)",
			   y, z, k, bands, j, stride, z+k*bands+j*stride, k, result[k]);
		    block->pixel [z+k*bands+j*stride] = result[k];
		}    // TODO :: ASSERT against capacity
	    }

	    TRACE_HEADER(1); TRACE_ADD ("[y=%u] line = {", y);
	    for (int a = 0; a < request->width; a++) { TRACE_ADD (" %f", block->pixel[a]); }
	    TRACE_ADD(" }", 0); TRACE_CLOSER;
	}

	#undef ITERX
	#undef ITERY
	#undef ITERZ
    }
}

proc dsl::reader::CacheLoops/column {map} {
    string map $map {
	// ATTENTION -- start each line in a different column -- this spreads the threads
	// across the width of the image -- this reduces the chance of lock fighting over
	// the column vectors during the creation phase

	aktive_uint xmin   = request->x;
	aktive_uint xmax   = request->x + request->width - 1;
	aktive_uint xoff   = aktive_fnv_step (request->y) % request->width;
	aktive_uint xstart = xmin + xoff;

	// iterator setup
	aktive_uint q;
	aktive_uint x, y, z, k, j;
	#define ITERX for (x = xstart, k = xoff, q = 0; q < request->width  ; q++)
	#define ITERY for (y = request->y, j = 0      ; j < request->height ; y++, j++, py++)
	#define ITERZ for (z = 0; z < bands; z++)

	// 3 kinds of x-coordinates.
	//
	// 1. x,y   - logical  coordinate of column/row
	// 2. k,j   - physical coordinate of column/row in memory block
	// 3. px,py - distance to logical x/y position  -> cache index %%%label%%%

	aktive_uint xd = request->x - idomain->x;
	aktive_uint yd = request->y - idomain->y;
	aktive_uint px = xstart - idomain->x;
	ITERX {
	    ITERZ {
		TRACE ("VEC INDEX (%u,%u,%u) (%u,%u) %u - vec %u", x,y,z, px,j, bands, px*bands+z);

		context.z = z;
		/* context->request */ subrequest.x = x;
		double* result = aktive_iveccache_get (state->ivcache,
						       px*bands+z,
						       %%%function%%%,
						       &context);

		TRACE_HEADER(1); TRACE_ADD ("[x,z=%u,%u] %%%kind%%% %%%label%%% = {", x, z);
		for (int a = 0; a < %%%rsize%%%; a++) { TRACE_ADD (" %f", result[a]); }
		TRACE_ADD(" }", 0); TRACE_CLOSER;

		aktive_uint py = yd;
		ITERY {
		    TRACE ("line [%u], band [%u] place k%u b%u j%u s%u -> %u (res[%d] = %f)",
			   y, z, k, bands, j, stride, z+k*bands+j*stride, py, result[py]);

		    block->pixel [z+k*bands+j*stride] = result[py];
		}   // TODO :: ASSERT against capacity
	    }

	    // step the column with wrap around
	    x++ ; if (x > xmax) x = request->x;
	    px++;
	    k++ ; if (k >= request->width) { k = 0; px = xd; }
	}

	TRACE_HEADER(1); TRACE_ADD ("[y=%u] line = {", y);
	for (int a = 0; a < request->width; a++) { TRACE_ADD (" %f", block->pixel[a]); }
	TRACE_ADD(" }", 0); TRACE_CLOSER;

	#undef ITERX
	#undef ITERY
	#undef ITERZ
    }
}

# # ## ### ##### ######## #############
## DSL commands -- Core

proc dsl::reader::import? {path} {
    set fullpath [ImportPath $path]
    if {![file exists $fullpath]} {
	puts "    Skip import missing [cyan $path]"
    } elseif {![file isfile $fullpath]} {
	puts "    Skip import nonfile [cyan $path]"
    } else {
	Import $path $fullpath
    }
}

proc dsl::reader::import {path} {
    Import $path [ImportPath $path]
}

proc dsl::reader::ImportPath {path} {
    variable readdir
    file normalize [file join $readdir $path]
}

proc dsl::reader::Import {path fullpath} {
    variable readdir
    variable importing

    incr importing
    puts "Importing [blue $path]"

    set saved   $readdir
    set readdir [file dirname $fullpath]

    uplevel 2 [list source $fullpath]
    incr importing -1

    set readdir $saved
}

proc dsl::reader::type {name critcl ctype conversion {init {}} {finish {}}} {
    OkModes {}
    variable importing

    if {$name in {
	blit body cached def external! import import? input input...
	note nyi op operator pixels result return section simplify
	state type vector void
    } || [string match {[A-Z]*} $name]} {
	Abort "Rejected attempt to replace DSL command with user type"
    }

    if {[Has types $name]} {
	Abort "Duplicate definition of type `$name`"
    }

    if {$critcl eq "-"} { set critcl $name   }
    if {$ctype  eq "-"} { set ctype  $critcl }

    Set types $name imported   $importing
    Set types $name critcl     $critcl
    Set types $name ctype      $ctype
    Set types $name conversion $conversion
    Set types $name init       $init
    Set types $name finish     $finish

    interp alias {} ::dsl::reader::$name      {} ::dsl::reader::Param $name required {}
    interp alias {} ::dsl::reader::${name}... {} ::dsl::reader::Param $name args     {}
    interp alias {} ::dsl::reader::${name}?   {} ::dsl::reader::Param $name optional ;#
    interp alias {} ::dsl::reader::${name}()  {} ::dsl::reader::Param $name vector   {}
}

proc dsl::reader::vector {args} { ;#puts [info level 0]
    OkModes {} C External
    variable importing
    foreach v $args {
	if {[Has vectors $v]} continue
	Set vectors $v $importing
    }
}

proc dsl::reader::operator {args} { ;#puts [info level 0]
    OkModes {}
    # 2 :: operator      NAMES SPEC
    # 3 :: operator VARS NAMES SPEC
    switch -- [llength $args] {
	2       { Operator {} {*}$args }
	3       { Operator    {*}$args }
	default { Abort "wrong#args for operator" }
    }
}

proc dsl::reader::nyi {args} { ;#puts [info level 0]
    OkModes {}
    # Disable a command
    set cmd [lindex $args 0]
    if {$cmd eq "operator"} {
	switch -- [llength $args] {
	    4 {
		lassign $args _ vars values _
		foreach [list __op {*}$vars] $values {
		    #puts "  Skipped $cmd [cyan $__op]"
		    Lappend todos $__op
		}
	    }
	    3 {
		foreach name [lindex $args 1] {
		    #puts "  Skipped $cmd [cyan $name]"
		    Lappend todos $name
		}
	    }
	}
    } else {
	puts "  Skipped [lrange $args 0 1]"
    }
}

# # ## ### ##### ######## #############
## DSL support - (Tcl)Operator handling

proc dsl::reader::Operator {vars ops specification} {
    set key [Next] ;# key identifying the entire group of operators
    foreach [list __op {*}$vars] $ops {
	OpStart $__op $key
	foreach v $vars { def $v [set $v] }
	set __parts [split [string map {:: \0} $__op] \0]
	# __parts -> `op` command input
	#
	eval $specification
	OpFinish
    }
}

proc dsl::reader::OpLoc {} {
    variable topdir
    set frame [info frame -5]   ;# OpLoc -> OpStart -> Operator -> operator -> (caller)
    set line  [dict get $frame line]
    set path  [dict get $frame file]
    set path  [string range $path [string length $topdir]+1 end]

    list $path $line
}

proc dsl::reader::OpStart {op key} {
    if {[Get opname] ne {}} { Abort "Nested operator definition `$op`" }
    if {[Has ops $op]}      {
	variable state ; set old [join [dict get $state ops $op defloc] @]
	Abort "Duplicate operator definition `$op`, original defined at $old"
    }

    Set opmode {}		;# Allow all commands at the beginning.
    Set opname $op		;# Current operator, lock against nesting
    Set opspec defloc   [OpLoc]

    variable importing
    incr     importing
    puts     "[cyan Operator] [blue $op]"
    incr     importing -1

    Set opspec key        $key  ;# Group code for multiple operators from one spec
    Set opspec notes      {}	;# Description
    Set opspec references {}	;# References
    Set opspec section    {}	;# Command category
    Set opspec images     {}	;# Input images
    Set opspec params     {}	;# Parameters
    Set opspec overlays   {}	;# Policy overlays - checks and simplifications
    Set opspec strict     0	;# Strictness flag, default not.

    Set opspec result   image	;# Return value
    Set opspec rcode    {}	;# C code fragment for non-image return (getter, doer)

    Set opspec state/setup   {}	;# State constructor - Geometry initialization at least
    Set opspec state/cleanup {}	;# State destructor, optional
    Set opspec state/fields  {}	;# State fields, C decl code, optional

    Set opspec region/setup   {} ;# Region state constructor, optional
    Set opspec region/cleanup {} ;# Region state destructor, optional
    Set opspec region/fields  {} ;# Region state fields, C decl code, optional
    Set opspec region/fetch   {} ;# Region pixel fetcher

    Set opspec args     0	;# Presence of variadic input or parameter
    Set opspec blocks   {}	;# Shared text blocks
    Set opspec support  {}	;# Supporting C code blocks
    Set opspec examples {}	;# Collected examples for docs
}

proc dsl::reader::OpFinish {} {
    # Cross check operator specification for missing code fragments.

    if {[Get opmode] eq {}} {
	Abort "Incomplete specification, unable to determine implementation language"
    }

    if {[Get opmode] eq "C"} {
	if {[Get opspec result] eq "image"} {
	    # Image result.
	    # Input images, if any, are kept.

	    if {[Get opspec region/fetch] eq {}} { Abort "Returns image, has no pixel fetch"	  }
	    if {[Get opspec state/setup]  eq {}} { Abort "Returns image, has no state/geometry setup" }
	    # Note: state, region state optional
	    #
	    if {[Get opspec rcode] ne {}} { Abort "Returns image, yet has result code" }

	    # Set rc mode of inputs to `keep`.
	    Set opspec images [lmap imspec [Get opspec images] {
		dict set imspec rcmode keep ; set imspec
	    }]
	} else {
	    # Non-image result, possibly void.
	    # Input images are not kept.

	    if {[Get opspec region/fetch]   ne {}} { Abort "No image returned, yet pixel fetch"	 }
	    if {[Get opspec region/fields]  ne {}} { Abort "No image returned, yet region state" }
	    if {[Get opspec region/setup]   ne {}} { Abort "No image returned, yet region state" }
	    if {[Get opspec region/cleanup] ne {}} { Abort "No image returned, yet region state" }
	    #
	    if {[Get opspec state/fields]  ne {}} { Abort "No image returned, yet state fields"  }
	    if {[Get opspec state/setup]   ne {}} { Abort "No image returned, yet state setup"   }
	    if {[Get opspec state/cleanup] ne {}} { Abort "No image returned, yet state cleanup" }
	    #
	    if {[Get opspec rcode] eq {}} { Abort "No image returned, has no result code" }

	    # Set rc mode of inputs to `ignore`.
	    Set opspec images [lmap imspec [Get opspec images] {
		dict set imspec rcmode ignore ; set imspec
	    }]
	}
    }

    Set   opspec lang [Get opmode]
    Unset opspec param
    Unset opspec args

    Set ops [Get opname] [Get opspec]
    Set opname {}
    Set opspec {}
    Set opmode {}
}

# # ## ### ##### ######## #############
## DSL support - general operator details

proc dsl::reader::support {cfragment args} { ;#puts [info level 0]
    OkModes {} C
    LappendX opspec support [TemplateCode $cfragment $args]
}

proc dsl::reader::note {args} { ;#puts [info level 0]
    OkModes {} C Tcl External
    LappendX opspec notes [lmap a $args { TemplateCode $a {} }]
}

proc dsl::reader::ref {link} { ;#puts [info level 0]
    OkModes {} C Tcl External
    LappendX opspec references $link
}

proc dsl::reader::example {{spec {}}} { ;#puts [info level 0]
    OkModes {} C Tcl External

    set runs [split [string trim $spec] \n]
    set n    [llength $runs]

    # default run
    if {$n == 0} { incr n ; lappend runs {} }

    Example [lmap run $runs {
	# per run extract the generation command and its modifiers (formatting, display processing)
	lassign [split $run |] gen modifiers
	set gen       [string trim $gen]
	set modifiers [string trim $modifiers]

	# extend the last generation part with the command to demonstrate, except if
	# overridden by spec
	incr n -1
	if {($n == 0) && ![string match {aktive *} $gen]} {
	    set gen "aktive [string map {:: { }} [Get opname]] $gen"
	}
	# scan modifiers for result formatting, extract, remove
	set show {}
	set format image
	set int  0
	set label {}
	foreach {m modcmd} {
	    -matrix {set format matrix}
	    -text   {set format text}
	    -int    {set int  1}
	    -full   {set int  2}
	} {
	    if {![string match *${m}* $modifiers]} continue
	    eval $modcmd
	}
	set modifiers [string trim [string map {
	    -matrix {} -text {} -int {} -full {}
	} $modifiers]]
	if {[regexp -- {-label (.*)$} $modifiers -> xlabel]} {
	    set label $xlabel
	    set modifiers [regsub -- {-label .*$} {} $modifiers]
	}
	# process remaining modifiers into display transforms
	set showcmds [lmap s [split $modifiers \;] { string trim $s }]
	# default show command, non transforming
	if {![llength $showcmds]} { lappend showcmds {} }

	# record parsed part
	list $gen $showcmds $format $int $label
    }]
}

proc dsl::reader::Example {spec} { ;#puts [info level 0]
    LappendX opspec examples $spec
}

proc dsl::reader::strict {ids args} { ;#puts [info level 0]
    OkModes {} C Tcl External

    if {![llength ids]} { Abort "Missing spec of which arguments are strict" }

    set a     input
    set infix the

    if {[llength $ids] > 1} {
	append a s
	set ids [linsert [join $ids {, }] end-1 and]
    } else {
	if {$ids eq "all"}      { append a s ; set infix ""    }
	if {$ids eq "its"}      {              set infix ""    }
	if {$ids eq "single"}   {              set infix "its" }
	if {$ids eq "both"}     { append a s ; set infix ""    }
    }

    note This operator is __strict__ in {*}$infix {*}$ids ${a}. {*}$args
    Set opspec strict 1
}

proc dsl::reader::section {args} { ;#puts [info level 0]
    OkModes {} C Tcl External
    Set opspec section $args
}

# # ## ### ##### ######## #############
## DSL support - External operator details

proc dsl::reader::external! {} { ;#puts [info level 0]
    OkModes {}
    Set opmode External
}

# # ## ### ##### ######## #############
## DSL support - Tcl operator details

proc dsl::reader::body {script args} {
    OkModes {} Tcl
    Set opmode Tcl
    Set opspec body [TemplateCode $script $args]
}

# # ## ### ##### ######## #############
## DSL support - C operator details

proc dsl::reader::op {_ args} {
    upvar 1 __parts __parts
    foreach v $args p $__parts {
	if {$v eq "_"} continue
	upvar 1 $v $v
	def $v $p
    }
}

proc dsl::reader::void   {script args} { return void $script {*}$args }
proc dsl::reader::return {type script args} { ;#puts [info level 0]
    OkModes {} C
    Set opmode C
    Set opspec result $type
    Set opspec rcode  [TemplateCode $script $args]
}

proc dsl::reader::blit {name scans function} {
    OkModes {} C
    Set opmode C
    def $name [dsl blit gen $name $scans $function]
}

proc dsl::reader::def {name text args} {
    OkModes {} C Tcl
    set text [TemplateCode $text $args]
    if {[Get opname] eq {}} {
	Set blocks $name $text
    } else {
	Set opspec blocks $name $text
    }
    upvar 1 $name var
    set var $text
}

proc dsl::reader::state {args} {
    OkModes {} C
    Set opmode C
    lassign {} fields setup cleanup
    while {[string match -* [set o [lindex $args 0]]]} {
	switch -exact -- $o {
	    --       { set args [lassign $args _] ; break }
	    -fields  { set args [lassign $args _ fields]  }
	    -setup   { set args [lassign $args _ setup]    }
	    -cleanup { set args [lassign $args _ cleanup] }
	    default  { Abort "Bad option '$o', expected -fields, -setup, -cleanup, or --" }
	}
    }
    # Remainder of args is key/value map for templating.

    if {($fields ne {}) && ($setup eq {})} { Abort "Setup required when fields specified" }

    State $fields $setup $cleanup $args
}

proc dsl::reader::State {fields setup cleanup map} { ;# puts [info level 0]
    Set opspec state/setup   [TemplateCode $setup   $map]
    Set opspec state/cleanup [TemplateCode $cleanup $map]
    Set opspec state/fields  [TemplateCode $fields  $map]
}

proc ::dsl::reader::pixels {args} { ;# puts [info level 0]
    OkModes {} C
    Set opmode C
    lassign {} fields setup cleanup
    while {[string match -* [set o [lindex $args 0]]]} {
	switch -exact -- $o {
	    --       { set args [lassign $args _] ; break }
	    -state   { set args [lassign $args _ fields]  }
	    -setup   { set args [lassign $args _ setup]   }
	    -cleanup { set args [lassign $args _ cleanup] }
	    default  { Abort "Bad option '$o', expected -state, -setup, -cleanup, or --" }
	}
    }
    # Remainder of args is fetch and key/value map for templating.

    if {($fields ne {}) && ($setup eq {})} { Abort "Setup required when fields specified" }
    if {![llength $args]} { Abort "Fetch specification missing, required" }
    set args [lassign $args fetch]

    Pixels $fields $setup $cleanup $fetch $args
}

proc ::dsl::reader::Pixels {fields setup cleanup fetch map} { ;#puts [info level 0]
    Set opspec region/setup   [TemplateCode $setup   $map]
    Set opspec region/cleanup [TemplateCode $cleanup $map]
    Set opspec region/fields  [TemplateCode $fields  $map]
    Set opspec region/fetch   [TemplateCode $fetch   $map]
}

proc dsl::reader::simplify {args} {
    OkModes {} C Tcl
    LappendX opspec overlays $args
}

proc dsl::reader::input... {}          { Input ...            }
proc dsl::reader::input    {{name {}} args} { Input required $name $args}

proc dsl::reader::Input {mode {name {}} {desc {}}} { ;#puts [info level 0]
    OkModes {} C Tcl
    if {[Has opspec args] &&
	[Get opspec args]} { Abort "Rejecting more image arguments, we have a variadic" }

    switch -exact -- $mode {
	required { dict set imspec args 0	                             }
	...      { dict set imspec args 1 ; Set opspec args 1 ; vector image }
    }
    dict set imspec name $name
    dict set imspec desc $desc

    LappendX opspec images $imspec
}

# parameter commands - See `type` above for setup, and `Param` below for handling.

# # ## ### ##### ######## #############
## DSL support - Parameter handling

proc dsl::reader::pass {args} { ;#puts [info level 0]

    Set opspec pass .

    # process the parameter as-is ...
    uplevel 1 $args

    Unset opspec pass
}

proc dsl::reader::Param {type mode dvalue name args} { ;#puts [info level 0]
    OkModes {} C Tcl External
    # args :: help text

    if {$mode ni {required args optional vector}} { Abort "Internal: Bad mode $mode" }

    if {$name eq {}}              { Abort "Bad parameter name, empty" }
    if {[Has opspec param $name]} { Abort "Duplicate parameter `$name`" }
    if {[Has opspec args] &&
	[Get opspec args]}        { Abort "Rejecting more parameters, we have a variadic" }

    set isargs   [expr {$mode eq "args"}]
    set isvector [expr {$mode eq "vector"}]
    if 0 {
	if {$isargs && [llength [Get opspec images]]} {
	    Abort "Rejecting variadic parameter, we have images"
	}
    }

    set desc [join $args { }]
    if {$desc eq {}} { Abort "Empty description" }

    dict set argspec name   $name
    dict set argspec desc   $desc
    dict set argspec type   $type
    dict set argspec args   $isargs
    dict set argspec vector $isvector

    switch -exact -- $mode {
	required {}
	optional { dict set argspec default $dvalue }
	args     { vector $type ; Set opspec args 1 }
	vector   { vector $type }
    }

    Set      opspec param  $name .
    LappendX opspec params $argspec

    if {![Has opspec pass]} ::return

    # extend text block `passthrough`
    set pass {}
    catch { set pass [Get opspec blocks passthrough] }

    append pass " $name"
    if {$isargs} {
	append pass " \{*\}\$$name"
    } else {
	append pass " \$$name"
    }
    Set opspec blocks passthrough [string trimleft $pass]
}

# # ## ### ##### ######## #############
## Messaging

proc dsl::reader::red     {message} { string cat \033\[31m$message\033\[0m }
proc dsl::reader::green   {message} { string cat \033\[32m$message\033\[0m }
proc dsl::reader::yellow  {message} { string cat \033\[33m$message\033\[0m }
proc dsl::reader::blue    {message} { string cat \033\[34m$message\033\[0m }
proc dsl::reader::magenta {message} { string cat \033\[35m$message\033\[0m }
proc dsl::reader::cyan    {message} { string cat \033\[36m$message\033\[0m }

proc dsl::reader::puts {message} {
    variable importing
    set indent [string repeat {  } $importing]

    ::puts "  - $indent$message"
}

# # ## ### ##### ######## #############
## Templating

proc dsl::reader::TemplateCode {code map} {
    set code [FormatCode $code]

    # Operator blocks first - May contain references to global blocks

    if {[Has opspec blocks]} {
	set blocks [Get opspec blocks]
	foreach key [lsort -dict [dict keys $blocks]] {
	    set code [TemplateBlock $code $key [dict get $blocks $key]]
	}
    }

    # Global blocks

    if {[Has blocks]} {
	set blocks [Get blocks]
	foreach key [lsort -dict [dict keys $blocks]] {
	    set code [TemplateBlock $code $key [dict get $blocks $key]]
	}
    }

    # Last minute things

    set code [string map $map $code]

    # Check for use of internal functionality

    if {[string match *aktive_void_fail* $code]} {
	Abort "User code rejected due to forbidden use of internal `aktive_void_fail*` facilities."
    }

    ::return $code
}

proc dsl::reader::TemplateBlock {code key replacement} {
    set needle @@${key}@@

    if {![string match *${needle}* $code]} { ::return $code }
    # Block present.

    set pattern "\n(\S*)$needle"
    if {[string match *\n* $replacement] &&
	[regexp -- $pattern $code -> prefix]
    } {
	# Multi-line expansion expansion is needed and supported
	set replacement [textutil::adjust::indent $replacement $prefix 1]
    }

    string map [list $needle $replacement] $code
}

proc dsl::reader::FormatCode {code} {
    set code [textutil::adjust::undent $code]
    set code [string trim $code]
    ::return $code
}

proc dsl::reader::OkModes {args} {
    if {[Get opmode] ni $args} {
	Abort "Command '[lindex [info level -1] 0]' not allowed for mode [Get opmode]"
    }
}

# # ## ### ##### ######## #############
## State management (changing, querying)

proc dsl::reader::Init {package} {
    variable state {
	argspec {}
	blocks  {}
	imspec  {}
	opmode  {}
	opname  {}
	ops     {}
	opspec  {blocks {}}
	todos   {}
	tops    {}
	types   {}
	vectors {}
    }
    dict set state package $package
}

proc dsl::reader::Set {args} {
    variable state
    set keypath [lreverse [lassign [lreverse $args] value]]
    dict set state {*}$keypath $value
}

proc dsl::reader::Unset {args} {
    variable state
    dict unset state {*}$args
}

proc dsl::reader::Lappend {key args} {
    variable state
    dict lappend state $key {*}$args
}

proc dsl::reader::LappendX {args} {
    variable state
    set keypath [lreverse [lassign [lreverse $args] value]]
    set words [dict get $state {*}$keypath]
    lappend words $value
    dict set state {*}$keypath $words
}

proc dsl::reader::Get {args} {
    variable state
    dict get $state {*}$args
}

proc dsl::reader::Has {args} {
    variable state
    dict exists $state {*}$args
}

proc dsl::reader::Next {} {
    variable counter
    incr counter
}

# ... ... ... ingestion commands ... ... ... ... ... ...
## Data
##  - name
##  - todos   :: list (string)
##  - types   :: dict (typename -> typespec)
##  - vectors :: dict (typename -> imported)
##  - blocks  :: dict (name -> text-fragment)
##  - ops     :: dict (opname -> opspec)
##  - opname  :: string               [Only during collection]
##  - opmode  :: string               [Only during collection]
##  - opspec  :: dict (key -> value)  [Only during collection]
##
## typespec keys
##  - imported   :: bool
##  - critcl     :: string
##  - ctype      :: string
##  - conversion :: string
##  - init       :: string
##  - finish     :: string
##
## opspec keys
##  - defloc     :: definition location
##  - args       :: bool
##  - blocks     :: dict (name -> text-fragment)
##  - body       :: string	[presence indicates tcl operator]
##  - examples   :: list (example-spec)
##  - images     :: list (imspec)
##  - lang       :: string	[auto set] C|Tcl
##  - notes      :: list (string)
##  - references :: list (string)
##  - overlays   :: list (overspec)
##  - param      :: dict (string -> '.') [Only during collection]
##  - params     :: list (argspec)
##  - result     :: string
##  - section    :: list (string)
##  - strict     :: bool
##  - support    :: list (string)
##  - state/setup
##  - state/cleanup
##  - state/fields
##  - region/setup
##  - region/cleanup
##  - region/fields
##  - region/fetch
##
## argspec keys
##  - args    :: bool
##  - default :: string, optional
##  - desc    :: string
##  - name    :: string
##  - type    :: string
##
## imspec keys
##  - rcmode :: string
##  - args   :: bool
##
## example-spec - list
##  - pre  Code to run before the actual example.
##  - run  Code to run as the actual example
##  - post Code to run after the actual example to get the final result.
#
##  The result of `pre` is available in the `pre` variable, if code is specified.
##  The result of `run` is available in the `run` variable.
#
##  Post code refers to result of `run` with `<run>` placeholder.
##  Post code refers to result of `pre` with `<pre>` placeholder.
##
## # # ## ### ##### ######## #############
##
## overspec
##   /1/ input overlay-type overlay-action... :: run action if input is of given type
##   /2/ constant MATH-FUNC                   :: return constant, mathfunc applied to input param value
##
## overlay-type
##   @self
##   operator-name
##
## overlay-action
##   pass            :: return input as construction result
##   pass-grandchild :: return input of input as construction result

proc dsl::reader::Abort {x} {
    set opname [Get opname]
    if {$opname ne {}} { set x "Operation $opname: $x" }
    ::return -code error $x
}

# # ## ### ##### ######## #############
return
