## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Structure Tensor
#
## BEWARE: Input images are assumed to be in linear light. IOW not gamma-compressed.

## References - See operator below
## Notes
## -	The structure tensor of a single-band image is a 2x2 matrix
##
##      | A B |
##      | B C |
##
##      where
##            A = low-pass (DX^2)
##            C = low-pass (DY^2)
##            B = low-pass (DX*DY)
##      where
##            DX       = discrete gradient along X-axis
##            DY       = discrete gradient along Y-axis
##            low-pass = low-pass filter, for example gaussian
##      where
##            gradient = gradient filter, for example sobel
##
##      For a multi-band image the tensor is simply the sum of the band tensors
##
## -	The eigenvalues and -vectors of the tensor summarize the distribution of
##	the gradient.
##
##      Using tensor determinant DET (= A*C - B*B)
##      and   tensor trace       TRA (= A + C)
##      the eigen values L1 and L2 are
##
##	L1 = (TRA + sqrt (TRA^2 - 4*DET))/2
##         = (A+C + sqrt ((A+C)^2 - 4(AC-BB)))/2
##         = (A+C + sqrt (AA + 2AC + CC - 4AC + 4BB))/2
##         = (A+C + sqrt (AA - 2AC + CC + 4BB))/2
##         = (A+C + sqrt ((A-C)^2 + 4BB))/2
##
##	L2 = (TRA - sqrt (TRA^2 - 4*DET))/2
##         = (A+C - sqrt ((A-C)^2 + 4BB))/2
##
## -	Derived from the eigen values above
##
##            LE
##	  C = --
##            TE
##
##	where
##	  LE = L1 - L2 = sqrt ((A-C)^2 + 4BB)	- "line energy", dominant energy without perpendicular noise
##	  TE = L1 + L2 = A+C			- total local derivative energy
##
##      is a measure of coherence, assuming L2 > 0.
##
##      C == 0	indicates that there is no prefered direction at all
##	C == 1	indicates that there is total alignment into a single direction

# # ## ### ##### ######## ############# #####################
##

operator op::structure::lines {
    section transform gradient

    example {
	butterfly
	aktive op color sRGB to scRGB @1 | -label {linear light}
	@2
    }

    note Computes and returns the line energy of the input image, \
	based on the <!xref: aktive op structure tensor> of the input.

    input

    body {
	lassign [tensor $src] a c b

	# cache here ?

	set fbb [aktive op math1 scale  [aktive op math1 square $b] factor 4]
	set acs [aktive op math1 square [aktive op math sub $a $c]]

	# line energy (L1 - L2)
	return [aktive op math1 sqrt [aktive op math add $acs $fbb]]
    }
}

operator op::structure::tensor {
    section transform gradient

    ref https://www.cs.cmu.edu/~sarsen/structureTensorTutorial
    ref https://en.wikipedia.org/wiki/Structure_tensor

    example {
	butterfly
	aktive op color sRGB to scRGB @1           | -label {linear light}
	!!lindex [aktive op structure tensor @2] 0 | -label XX
    }
    example {
	butterfly
	aktive op color sRGB to scRGB @1           | -label {linear light}
	!!lindex [aktive op structure tensor @2] 1 | -label YY
    }
    example {
	butterfly
	aktive op color sRGB to scRGB @1           | -label {linear light}
	!!lindex [aktive op structure tensor @2] 2 | -label XY
    }

    note Returns the structure tensor of the input. \
	Expects the input to be in linear light. \
	The tensor is a list of 3 images describing the components of the tensor's matrix. \
	It consists of only three elements because the tensor is symmetric.

    note The tensor elements are returned in the order top-left, bottom-right (the diagonal), \
	and top-right/bottom-left (the single anti-diagonal element).

    input

    str? sobel   gradient	Filter kernel to use in the calculation of the axis-aligned dicrete gradient. \
    	The name refers into the `aktive image kernel` hierarchy. It will be called as \
	`aktive image kernel <gradient> x` and `aktive image kernel <gradient> y`.

    str? gauss3  lowpass	Filter kernel to smooth the raw tensor elements with. \
	The name refers into the `aktive image kernel` hierarchy. It will be called as \
	`aktive image kernel <lowpass> xy`.

    body {
	# prepare for gradient convolution
	set src [aktive op embed mirror $src left 1 right 1 top 1 bottom 1]

	# gradient kernels
	set kgx [aktive image kernel $gradient x]
	set kgy [aktive image kernel $gradient y]

	# partial gradients in all bands
	set gx [aktive op convolve xy $kgx $src]
	set gy [aktive op convolve xy $kgy $src]

	# assemble tensor elements
	foreach bx [aktive op split z $gx] by [aktive op split z $gy] {
	    lappend as [aktive op math1 square $bx]
	    lappend cs [aktive op math1 square $by]
	    lappend bs [aktive op math mul $bx $by]
	} ; unset bx by
	set a [aktive op math add {*}$as]
	set b [aktive op math add {*}$bs]
	set c [aktive op math add {*}$cs]

	# TODO insert cache here ?

	# prepare for low-pass filter convolution
	set a [aktive op embed mirror $a left 1 right 1 top 1 bottom 1]
	set b [aktive op embed mirror $b left 1 right 1 top 1 bottom 1]
	set c [aktive op embed mirror $c left 1 right 1 top 1 bottom 1]

	# filter kernel
	set lowpass [aktive image kernel $lowpass xy]

	# smooth with it
	set a [aktive op convolve xy $lowpass $a]
	set b [aktive op convolve xy $lowpass $b]
	set c [aktive op convolve xy $lowpass $c]

	# done
	return [list $a $c $b]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
