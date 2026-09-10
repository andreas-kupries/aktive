## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Polynomial operations
## -- Fitting completely non-image functionality into the framework
#
## - Evaluation


operator math::polynomial::eval {
    section math

    # linear 3*x + 1 @ 5 = 15 + 1 = 16
    example { 5  1 3 | -text }

    # parabolic -2*x*x + 3*x + 1 @ 5 = -8 + 6 + 1 = -1
    example { 2  1 3 -2 | -text }

    # trailing zeros do not matter
    example { 2  1 3 -2 0 0 0 0 0 | -text }

    note Evaluate the polynomial given by the coefficients at the specified point

    note The cofficients are listed from lowest to highest order. \
	In other words, the first coefficient is the contant, \
	followed by the values for `x`, `x^2`, etc.

    note Trailing zeroes are ignored.

    double    x		   The point to evaluate the polynomial at
    double... coefficients The cofficients of the polynomial, from lowest to highest order

    return double {
	int     cn = param->coefficients.c;
	double* cv = param->coefficients.v;
	double  x  = param->x;

	// skip over trailing zeroes
	cn --; while ((cn >= 0) && (cv[cn] == 0)) {
	    // fprintf (stderr, "skip %d\n", cn);
	    cn --; }
	// fprintf (stderr, "order %d\n", cn+1);

	// a zero polynomial evaluates to zero everywhere
	if (cn < 0) { return 0; }

	// horner evaluation
	double result = cv[cn]; cn --;
	while (cn >= 0) {
	    // fprintf (stderr, "r(%f) * x(%f) + cv[%d](%f)\n", result, x, cn, cv[cn]);
	    result = x * result + cv[cn]; cn --; }

	// done
	return result;
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
