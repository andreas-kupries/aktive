## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Polynomial operations
## -- Fitting completely non-image functionality into the framework
#
## - Evaluation


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

    note The cofficients are listed from lowest to highest order. \
	In other words, the first coefficient (index 0) is the constant, \
	followed by the values for `x`, `x^2`, etc.

    note Trailing zeroes are ignored.

    double()  coefficients  The cofficients of the polynomial. Ordered lowest (x^0) to highest.
    double    x             The point to evaluate the polynomial at.

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
