## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image statistics - Generate reduce worker/completer functionality.
## See op/reduce.c for the context the code is embedded into.

dsl reduce gen generated/reduce.c {
    # fun NAME REGION-REDUCTION MERGE-PARTS FINAL-RESULT

    # REGION-REDUCTION -- runs in workers, generates partial result for the processed region
    # MERGE-PARTS      -- main thread, merges partial results into the semi-final state
    # FINAL-RESULT     -- main thread, extracts final result from the semi-final state
    ##
    # PARTIAL -- kahan accumulator for partial results
    # ACC     -- primary   kahan accumulator
    # AUX     -- secondary kahan accumulator
    # FINAL   -- place to hold the final double result
    #
    # Each kahan accumulator can also be used to simply hold one or two (separate) double
    # values instead of using it for the precise summation of many double values.

    # max of max
    fun max {
	PARTIAL.sum = aktive_reduce_max (p->pixel, p->used, 1, 0);
    } {
	ACC.sum = MAX (ACC.sum, PARTIAL.sum);
    } {
	FINAL = ACC.sum;
    }

    # min of min
    fun min {
	PARTIAL.sum = aktive_reduce_min (p->pixel, p->used, 1, 0);
    } {
	ACC.sum = MIN (ACC.sum, PARTIAL.sum);
    } {
	FINAL = ACC.sum;
    }

    # sum of sum
    fun sum {
	sum_1 (&PARTIAL, p->pixel, p->used, 1);
    } {
	aktive_kahan_add_kahan (&ACC, &PARTIAL);
    } {
	FINAL = aktive_kahan_final (&ACC);
    }

    # sum of sum-squared
    fun sumsquared {
	sum_squared (&PARTIAL, p->pixel, p->used, 1);
    } {
	aktive_kahan_add_kahan (&ACC, &PARTIAL);
    } {
	FINAL = aktive_kahan_final (&ACC);
    }

    # sum of sums, scaled
    fun mean {
	sum_1 (&PARTIAL, p->pixel, p->used, 1);
    } {
	aktive_kahan_add_kahan (&ACC, &PARTIAL);
    } {
	FINAL = aktive_kahan_final (&ACC) / (double) state->size;
    }

    # sum of sums, sum-squared, scaled, mixed
    fun variance {
	// main = sum, aux = sum-squared
	sum_and_squared (&PARTIAL, &P_AUX, p->pixel, p->used, 1);
    } {
	aktive_kahan_add_kahan (&ACC, &PARTIAL);
	aktive_kahan_add_kahan (&AUX, &P_AUX);
    } {
	double n    = state->size;
	double mean = aktive_kahan_final (&ACC) / n;
	double sq   = aktive_kahan_final (&AUX) / n;

	FINAL = sq - mean*mean;
    }

    # see variance, sqrt post-transform
    fun stddev {
	// main = sum, aux = sum-squared
	sum_and_squared (&PARTIAL, &P_AUX, p->pixel, p->used, 1);
    } {
	aktive_kahan_add_kahan (&ACC, &PARTIAL);
	aktive_kahan_add_kahan (&AUX, &P_AUX);
    } {
	double n    = state->size;
	double mean = aktive_kahan_final (&ACC) / n;
	double sq   = aktive_kahan_final (&AUX) / n;

	FINAL = sqrt (sq - mean*mean);
    }
}
