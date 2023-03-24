## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Threshold generation

# # ## ### ##### ######## ############# #####################
## Common operator, apply a threshold image, and return indicator mask for foreground
## Foreground is assumed to be darker than the background (Ex: Black text on white page)

tcl-operator image::mask::from::threshold {
    section transform threshold mask generate

    note Return image foreground mask of input, as per threshold image. \
	Note that the threshold is the first argument, and input the second.

    note The foreground are the pixels falling under the threshold. \
	IOW the input foreground is assumed to be darker than background. \
	Invert the result otherwise.

    note The foreground pixels are indicated by white. Background by black.

    arguments t src
    body {
	return [aktive op math le $src $t]
    }
}

tcl-operator {parameters} {
    image::mask::per::bernsen    {}
    image::mask::per::niblack    {k}
    image::mask::per::phansalkar {k R p q}
    image::mask::per::sauvola    {k R}
} {
    def method [lindex [split $__op :] 6]

    section transform threshold mask generate

    note Return image foreground mask of input, \
	using [string totitle $method] thresholding.

    note The foreground are the pixels falling under the threshold. \
	IOW the input foreground is assumed to be darker than background. \
	Invert the result otherwise.

    note The foreground pixels are indicated by white. Background by black.

    arguments {*}$parameters radius src

    def prefs [join [lmap p $parameters { set _ "\$$p" }] { }]

    body {
	set t [aktive image threshold @@method@@ @@prefs@@ $radius $src]
	return [aktive op math le $src $t]
    }
}


##
# # ## ### ##### ######## ############# #####################
::return
