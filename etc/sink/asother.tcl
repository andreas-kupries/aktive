## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Getters -- Convert the image DAG into various representions useful to
## debugging, documentation, etc.

operator {format} {
    format::as::tclscript {Tcl script}
    format::as::d2        {D2 graph format}
    format::as::markdown  {Markdown table}
} {

    example {
	butterfly                 | -label assets/butterfly.ppm
	aktive effect charcoal @1 | -label charcoal
	@2                        | -text
    }

    section accessor
    op -> _ _ func

    note Converts the internal DAG representation of the \
	image into a $format and returns the resulting \
	string.

    input

    note Despite the naming the operator is __not strict__. \
	It does not access the input's pixels at all, only the \
	meta information of the pipeline.

    body {
	aktive::AsDict $src aktive::FromDict::@@func@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
