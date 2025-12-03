# -*- mode: tcl ; fill-column: 90 -*-
## blitter - predefined blit actions

# # ## ### ##### ######## #############
## catalog

#
# raw      label code		| Code to run per position
# copy				| Copy source to destination
#
#				| Set destination to ...
# zero				| Set destination to 0
# const    v			| ... value `v`
#
# point    C-expression		| ... value computed from `f (@x, @y, @z)` for C expression `f`
# point/2d C-expression		| ... value computed from `f (@x, @y)` for C expression `f`
# pos      C-expression		| ... value computed from `f (@)` for C expression `f` and linear pos `@`
#
# apply1   op args		| ... value computed from `op (source, {*}args)`
# apply1z  op args		| ... value computed from `op (source, {*}args, z)`
# apply2   op			| ... value computed from `op (source1, source2)`
# complex-apply-reduce op	| ... value computed from `complex-op (source1)`
# complex-apply-unary  op	| ... complex value from `complex-op (source1)`
# complex-apply-binary op      	| ... complex value from `complex-op (source1, source2)`
#
# for the `point*` and `pos` actions the source iterated over is virtual, there is no
# actual input. only the iteration coordinates are of importance.
#
# for `raw` the code has access to
#
# - dstx, dsty, dstz, dstpos, dstvalue - destination coordinates, linear position, and buffer pointer
# - srcx, srcy, srcz, srcpos, srcvalue - ditto for a single source
# - src0x, ...                         - for first source of several, i.e. 0, 1, ...
#
# - dstpitch, dststride   - destination #row values, #column values
# - srcpitch, srcstride   - ditto for a single source
# - src0pitch, src0stride - ditto for first source of several
#

##
# # ## ### ##### ######## #############

::dsl blit action new raw {
    code {{label code} {
	+ "TRACE_ADD (\" :: raw code - $label\", 0);"
	+ $code
    }}
    comment {
	// "[lrange $words 0 1]"
    }
}

::dsl blit action new copy {
    code {{} {
	+ "TRACE_ADD (\" :: copy %f\", *srcvalue);"
	+ "*dstvalue = *srcvalue;"
    }}
}

::dsl blit action new zero {
    allowsrc no
    code {{} {
	+ "TRACE_ADD (\" :: zero\", 0);"
	+ "*dstvalue = 0;"
    }}
}

::dsl blit action new const {
    allowsrc no
    code {{v} {
	+ "TRACE_ADD (\" :: set %f\", $v);"
	+ "*dstvalue = $v;"
    }}
    optimize {
	lassign $words cmd v
	if {$v == 0} { return zero }
	return $words
    }
}

::dsl blit action new point {
    virtual yes
    nopos   yes
    code {{cexpr} {
	set cexpr [string trim $cexpr]
	set dexpr [string map {
	    #z  XERR  #x XERR  #y XERR
	    z  srcz  x srcx  y srcy
	    @z srcz @x srcx @y srcy
	} $cexpr]
	if {[string match *XERR* $dexpr]} { E "blit point error: use @x/@y/@z" }
	+ "double value = $dexpr;"
	+ "TRACE_ADD (\" :: %f = \[$cexpr](%u %u %u)\", value, srcy, srcx, srcz);"
	+ "*dstvalue = value;"
    }}
}

::dsl blit action new point/2d {
    virtual yes
    nopos   yes
    code {{cexpr} {
	set cexpr [string trim $cexpr]
	set dexpr [string map {
	    x  srcx  y srcy
	    #x  XERR  #y XERR
	    @x srcx @y srcy
	} $cexpr]
	if {[string match *XERR* $dexpr]} { E "blit point/2d error: use @x/@y" }
	+ "double value = $dexpr;"
	+ "TRACE_ADD (\" :: %f = \[$cexpr](%u %u)\", value, srcy, srcx);"
	+ "*dstvalue = value;"
    }}
}

::dsl blit action new pos {
    virtual yes
    code {{cexpr} {
	set cexpr [string trim $cexpr]
	set dexpr [string map {@ srcpos} $cexpr]
	+ "double value = $dexpr;"
	+ "TRACE_ADD (\" :: %f = \[$cexpr](%f)\", value, srcpos);"
	+ "*dstvalue = value;"
    }}
}

::dsl blit action new apply1 {
    code {{op args} {
	append call "$op (*srcvalue"
	foreach a $args { append call ", $a" }
	append call ")"

	append fmt "$op (%f"
	foreach a $args { append fmt ", %f" }
	append fmt ")"

	append values "*srcvalue"
	foreach a $args { append values ", $a" }

	+ "double result = ${call};"
	+ "TRACE_ADD (\" :: set %f = $fmt\", result, $values);"
	+ "*dstvalue = result;"
    }}
}

::dsl blit action new apply1z {
    code {{op args} {
    append call "$op (*srcvalue"
    foreach a $args { append call ", $a" }
    append call ", srcz)"

    append fmt "$op (%f"
    foreach a $args { append fmt ", %p" }
    append fmt ", %u)"

    append values "*srcvalue"
    foreach a $args { append values ", $a" }
    append values ", srcz"

    + "double result = ${call};"
    + "TRACE_ADD (\" :: set %f = $fmt\", result, $values);"
    + "*dstvalue = result;"
    }}
}

::dsl blit action new apply2 {
    code {{op} {
	+ "double result = $op (*src0value, *src1value);"
	+ "TRACE_ADD (\" :: set %f = $op (%f, %f)\", result, *src0value, *src1value);"
	+ "*dstvalue = result;"
    }}
}

# Ref https://en.cppreference.com/w/c/language/arithmetic_types#Complex_floating_types:
##
#     Each complex type has the same object representation and alignment requirements as
#     an array of two elements of the corresponding real type (...). The first element of
#     the array holds the real part, and the second element of the array holds the
#     imaginary component.

::dsl blit action new complex-apply-reduce {
    code {{op} {
	+ "TRACE_ADD (\" :: complexR $op (%f+i*%f)\", srcvalue\[0], srcvalue\[1]);"
	## double complex srccvalue = CMPLX (srcvalue\[0], srcvalue\[1]);
	+ "*dstvalue                = $op (*((double complex*) srcvalue));"
    }}
}

::dsl blit action new complex-apply-unary {
    code {{op} {
	+ "TRACE_ADD (\" :: complex1 $op (%f+i*%f)\", srcvalue\[0], srcvalue\[1]);"
	## double complex srccvalue = CMPLX (srcvalue\[0], srcvalue\[1]);
	+ "double complex result    = $op (*((double complex *) srcvalue));"
	+ "dstvalue\[0]              = creal (result);"
	+ "dstvalue\[1]              = cimag (result);"
    }}
}

::dsl blit action new complex-apply-binary {
    code {{op} {
	+ "TRACE_ADD (\" :: complex2 = $op ((%f+i*%f), (%f+i*%f))\", src0value\[0], src0value\[1], src1value\[0], src1value\[1]);"
	## double complex src0cvalue = CMPLX (src0value\[0], src0value\[1]);
	## double complex src1cvalue = CMPLX (src1value\[0], src1value\[1]);
	+ "double complex result     = $op (*((double complex *) src0value), *((double complex*) src1value));"
	+ "dstvalue\[0]               = creal (result);"
	+ "dstvalue\[1]               = cimag (result);"
    }}
}

# # ## ### ##### ######## #############
## blit vector actions

apply {{} {
    source data/math/spec.tcl

    foreach {name spec} $unary0 {
	lappend map @@ $name
	::dsl blit action new vec/unary/$name [string map $map {
	    vector 1
	    code {{} {
		+ "TRACE_ADD (\":: vec/unary/@@\[%d] (%d <-- %d)\", vecrange, dstpos, srcpos);"
		+ "aktive_vector_unary_@@ (dstvalue, srcvalue, vecrange);"
	    }}}]
	unset map
    }

    foreach {name spec} $unary1 {
	lappend map @@ $name
	::dsl blit action new vec/unary/$name [string map $map {
	    vector 1
	    code {{} {
		+ "TRACE_ADD (\":: vec/unary/@@\[%d] (%d <-- %d)\", vecrange, dstpos, srcpos);"
		+ "aktive_vector_unary_@@ (dstvalue, srcvalue, vecrange, parama);"
	    }}}]
	unset map
    }

    foreach {name spec} $unary2 {
	lappend map @@ $name
	::dsl blit action new vec/unary/$name [string map $map {
	    vector 1
	    code {{} {
		+ "TRACE_ADD (\":: vec/unary/@@\[%d] (%d <-- %d)\", vecrange, dstpos, srcpos);"
		+ "aktive_vector_unary_@@ (dstvalue, srcvalue, vecrange, parama, paramb);"
	    }}}]
	unset map
    }

    foreach {name spec} $binary {
	lappend map @@ $name
	::dsl blit action new vec/binary/$name [string map $map {
	    vector 1
	    code {{} {
		+ "TRACE_ADD (\":: vec/binary/@@\[%d] (%d <-- (%d, %d))\", vecrange, dstpos, src0pos, src1pos);"
		+ "aktive_vector_binary_@@ (dstvalue, src0value, src1value, vecrange);"
	    }}}]
	unset map
    }

}}

# # ## ### ##### ######## #############
return
