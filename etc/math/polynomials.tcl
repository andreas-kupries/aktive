## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Polynomial operations
## -- Fitting completely non-image functionality into the framework
#
## - Evaluation

operator math::polynomial::map {
    section math

    # linear 3*x+1 @ 5 = 3*5 + 1 = 15 + 1 = 16
    #        3*x+1 @ 6 = 3*6 + 1 = 18 + 1 = 19
    #        3*x+1 @ 7 = 3*7 + 1 = 21 + 1 = 22
    example { {1 3} {5 6 7} | -text }

    # quadratic -2*x*x + 3*x + 1 @ 2 = -2*2*2 + 3*2 + 1 =  -8 +  6 + 1 =  -1
    #           -2*x*x + 3*x + 1 @ 3 = -2*3*3 + 3*3 + 1 = -18 +  9 + 1 =  -8
    #           -2*x*x + 3*x + 1 @ 4 = -2*4*4 + 3*4 + 1 = -32 + 12 + 1 = -19
    example { {1 3 -2} {2 3 4} | -text }

    note Evaluate the polynomial given by the coefficients at the series of specified x-values

    note The cofficients are listed from lowest to highest order. \
	In other words, the first coefficient (index 0) is the constant, \
	followed by the values for `x`, `x^2`, etc.

    note Trailing zeroes are ignored.

    double() coefficients  The coefficients of the polynomial. Ordered lowest (x^0) to highest.
    double() xs            The series of x-values to evaluate the polynomial at.

    external!
}

operator math::polynomial::map* {
    section math

    # linear 3*x+1 @ 5 = 3*5 + 1 = 15 + 1 = 16
    #        3*x+1 @ 6 = 3*6 + 1 = 18 + 1 = 19
    #        3*x+1 @ 7 = 3*7 + 1 = 21 + 1 = 22
    example { {1 3} 5 6 7 | -text }

    # quadratic -2*x*x + 3*x + 1 @ 2 = -2*2*2 + 3*2 + 1 =  -8 +  6 + 1 =  -1
    #           -2*x*x + 3*x + 1 @ 3 = -2*3*3 + 3*3 + 1 = -18 +  9 + 1 =  -8
    #           -2*x*x + 3*x + 1 @ 4 = -2*4*4 + 3*4 + 1 = -32 + 12 + 1 = -19
    example { {1 3 -2} 2 3 4 | -text }

    note Evaluate the polynomial given by the coefficients at the series of specified x-values

    note The coefficients are listed from lowest to highest order. \
	In other words, the first coefficient (index 0) is the constant, \
	followed by the values for `x`, `x^2`, etc.

    note Trailing zeroes are ignored.

    double()  coefficients  The coefficients of the polynomial. Ordered lowest (x^0) to highest.
    double... xs            The series of x-values to evaluate the polynomial at.

    external!
}

operator math::polynomial::at {
    section math

    # linear 3*x + 1 @ 5 = 15 + 1 = 16
    example { {1 3} 5 | -text }
    #example { {1 3} 5 | plot 0 10 }

    # quadratic -2*x*x + 3*x + 1 @ 5 = -8 + 6 + 1 = -1
    example { {1 3 -2} 2 | -text }
    #example { {1 3 -2} | plot 0 10 }

    # trailing zeros do not matter
    example { {1 3 -2 0 0 0 0 0} 2 | -text }

    note Evaluate the polynomial given by the coefficients at the specified point

    note The coefficients are listed from lowest to highest order. \
	In other words, the first coefficient (index 0) is the constant, \
	followed by the values for `x`, `x^2`, etc.

    note Trailing zeroes are ignored.

    double()  coefficients  The coefficients of the polynomial. Ordered lowest (x^0) to highest.
    double    x             The x-value to evaluate the polynomial at.

    return double {
	int     cn = param->coefficients.c;
	double* cv = param->coefficients.v;
	double  x  = param->x;

	return aktive_poly_eval_horner (x, cn, cv);
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
