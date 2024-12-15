## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Threshold generation

# # ## ### ##### ######## ############# #####################
## Common operator, apply a threshold image, and return indicator mask for foreground
## Foreground is assumed to be darker than the background (Ex: Black text on white page)

operator image::mask::from::threshold {
    section transform threshold mask generate

    note Returns mask image indicating the foreground pixels of the input, \
	as per the thresholds.

    note The foreground are the pixels __less or equal__ to the threshold. \
	IOW the input's foreground is assumed to be darker than the \
	background. Invert the result otherwise.

    note The foreground pixels are indicated by white. Background by black.

    input threshold	Per-pixel thresholds
    input src		Image to threshold

    body {
	return [aktive op math le $src1 $src0]
    }
}

operator {parameters link} {
    image::mask::per::mean       {}                         {}
    image::mask::per::bernsen    {}			    https://craftofcoding.wordpress.com/2021/10/27/thresholding-algorithms-bernsen-local
    image::mask::per::niblack    { k -0.2 }		    https://craftofcoding.wordpress.com/2021/09/30/thresholding-algorithms-niblack-local
    image::mask::per::sauvola    { k 0.5  R 128 }	    https://craftofcoding.wordpress.com/2021/10/06/thresholding-algorithms-sauvola-local
    image::mask::per::phansalkar { k 0.25 R 0.5 p 3 q 10 }  https://craftofcoding.wordpress.com/2021/09/28/thresholding-algorithms-phansalkar-local
    image::mask::per::otsu       { bins 256 }               https://en.wikipedia.org/wiki/Otsu%27s_method
    image::mask::per::wolfjolion { k 0.5 }		    https://chriswolfvision.github.io/www/software/binarize/index.html
} {
    op -> _ _ _ method

    def methodname    [string totitle $method]
    def mainmethodref [if {$link eq {}} {
	set _ "`${methodname}`"
    } else {
	set _ "\[$methodname\]($link)"
    }]

    example {
	scancrop
	@1 radius 7
    }

    if {$method ne "otsu"} { ;# otsu does not handle color input
	example {
	    butterfly
	    @1 radius 7
	}
    }

    section transform threshold mask generate

    note Return image foreground mask of input, using $mainmethodref thresholding.

    if {$link ne {}} {
	ref $link
	switch -exact -- $method {
	    otsu {
		ref http://www.labbookpages.co.uk/software/imgProc/otsuThreshold.html
	    }
	    wolfjolion {
		ref https://chriswolfvision.github.io/www/papers/icpr2002v.pdf
		ref https://github.com/chriswolfvision/local_adaptive_binarization
		# ref https://github.com/chriswolfvision/local_adaptive_binarization
		#       /blob/2eb51465a917297910f2795fc149abafc96e657f/binarizewolfjolion.cpp#L182
	    }
	}
    }

    note The foreground are the pixels falling under the threshold. \
	IOW the input foreground is assumed to be darker than background. \
	Invert the result otherwise.

    note The foreground pixels are indicated by white. Background by black.

    note The local thresholds are computed using \
	"<!xref: aktive image threshold ${method}>."

    foreach {n d} $parameters {
	if {$n eq "bins"} {
	    int?    $d $n	$method histogram parameter
	} else {
	    double? $d $n	$method parameter
	}
    }

    uint radius	Size of region to consider, as radius from center

    input

    def prefs [join [lmap {n d} $parameters { set _ "$n \$$n" }] { }]

    body {
	set t [aktive image threshold @@method@@ $src @@prefs@@ radius $radius]
	return [aktive op math le $src $t]
    }
}

# # ## ### ##### ######## ############# #####################
## Masks from global thresholds

operator {parameters link} {
    image::mask::per::global::mean       {}                        {}
    image::mask::per::global::bernsen    {}			   https://craftofcoding.wordpress.com/2021/10/27/thresholding-algorithms-bernsen-local
    image::mask::per::global::niblack    { k -0.2 }		   https://craftofcoding.wordpress.com/2021/09/30/thresholding-algorithms-niblack-local
    image::mask::per::global::phansalkar { k 0.25 R 0.5 p 3 q 10 } https://craftofcoding.wordpress.com/2021/10/06/thresholding-algorithms-sauvola-local
    image::mask::per::global::sauvola    { k 0.5  R 128 }	   https://craftofcoding.wordpress.com/2021/09/28/thresholding-algorithms-phansalkar-local
    image::mask::per::global::otsu       { bins 256 }		   https://en.wikipedia.org/wiki/Otsu%27s_method
} {
    op -> _ _ _ _ method

    def methodname    [string totitle $method]
    def mainmethodref [if {$link eq {}} {
	set _ "`${methodname}`"
    } else {
	set _ "\[$methodname\]($link)"
    }]

    example {
	scancrop
	@1
    }

    if {$method ne "otsu"} { ;# otsu does not handle color input
	example {
	    butterfly
	    @1
	}
    }

    section transform threshold mask generate

    note Returns mask image indicating the foreground pixels of the input, \
	using global $mainmethodref thresholding.

    if {$link ne {}} {
	ref $link
	switch -exact -- $method {
	    otsu {
		ref http://www.labbookpages.co.uk/software/imgProc/otsuThreshold.html
	    }
	}
    }

    note The foreground are the pixels __less or equal__ to the threshold. \
	IOW the input's foreground is assumed to be darker than the \
	background. Invert the result otherwise.

    note The foreground pixels are indicated by white. Background by black.

    note The threshold is computed using \
	"<!xref: aktive image threshold global ${method}>."

    foreach {n d} $parameters {
	if {$n eq "bins"} {
	    int?    $d $n	$method histogram parameter
	} else {
	    double? $d $n	$method parameter
	}
    }

    input

    def prefs [join [lmap {n d} $parameters { set _ "$n \$$n" }] { }]

    body {
	set t [aktive image threshold global @@method@@ $src @@prefs@@]
	return [aktive op math1 le $src threshold $t]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
