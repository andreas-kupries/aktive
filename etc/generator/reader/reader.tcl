## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Reader -- Any format, auto-detects actual format

# parameter: `supported`.
# collected by the sibling .tcl operator specifications

# # ## ### ##### ######## ############# #####################
## Format auto-detection

critcl::msg "\t[dsl::reader::cyan Formats]: [dsl::reader::blue [join $supported {, }]]"

def supported_formats $supported
def expected_formats  [linsert [join $supported {, }] end-1 or]

operator read::from::string {

    section generator reader

    note Construct image from a Tcl byte array value in one of the supported formats. \
	The format is auto-detected.

    object value \
	Tcl value holding the image data to read

    body {
	foreach format {
	    @@supported_formats@@
	} {
	    if {[catch {
		$format string value $value
	    } image]} continue
	    return $image
	}

	aktive error "Unable to read unknown image format, expected one of @@expected_formats@@"
    }
}

operator read::from::file {

    section generator reader

    note Construct image from file content in one of the supported formats. \
	The format is auto-detected.

    object path \
	Path to file holding the image data to read

    body {
	foreach format {
	    @@supported_formats@@
	} {
	    if {[catch {
		$format file path $path
	    } image]} continue
	    return $image
	}

	aktive error "Unable to read unknown image format, expected one of @@expected_formats@@"
    }
}

# TODO: undef supported_formats, expected_formats

##
# # ## ### ##### ######## ############# #####################
::return
