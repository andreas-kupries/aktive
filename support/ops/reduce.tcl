# -*- mode: tcl ; fill-column: 90 -*-
##
## Generate the reducer code computing the per-image statistics

package require textutil::adjust

namespace eval dsl::reduce {
    namespace export gen
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc dsl::reduce::gen {destination script} {
    set text {}
    eval $script
    Into $destination $text
}

proc dsl::reduce::fun {name region merge finalize} {
    upvar 1 text text

    set code [Emit $name $region $merge $finalize]
    append text $code
    return
}

# # ## ### ##### ######## #############

proc dsl::reduce::Into {destination text} {
    file mkdir [file dirname $destination]
    set	   chan [open $destination w]
    ::puts $chan $text
    close  $chan
    return
}

proc dsl::reduce::Emit {function region merge finalize} {
    set code {
        // / / // /// /////
        // @@function@@ / / // /// ///// //////// ///////////// /////////////////////
        // Internal :: worker - region reduction

        static reduce_result*
        @@function@@_worker (const reduce_batch_state* state,
                             aktive_rectangle*         task,
                             aktive_region*            wstate)
        {
            TRACE_FUNC("((reducer_batch_state*) %p, (task) %p, (ws) %p)", state, task, wstate);

            if (! *wstate) {
                TRACE ("initialize wstate", 0);
		aktive_context c = aktive_context_new ();
                *wstate = aktive_region_new (state->image, c);
                TRACE ("(region*) %p", *wstate);
            }

            if (!task) {
		aktive_context c = aktive_region_context (*wstate);
                aktive_region_destroy (*wstate);
		aktive_context_destroy (c);
                TRACE_RETURN ("", 0);
            }

            TRACE_RECTANGLE (task);
            aktive_block* p = aktive_region_fetch_area_head (*wstate, task);

            reduce_result* result = ALLOC (reduce_result);

            // / / // /// ///// //////// /////////////
            // reduce pixel region to partial result /
        @@region-reduce@@
            // / / // /// ///// //////// /////////////

            ckfree (task);
            TRACE_RETURN ("(reduce_result*) %p", result);
        }

        // Internal :: completer - merging partial results to final

        static void
        @@function@@_completer (aktive_batch __ignored,
				reduce_batch_state* state,
                                reduce_result*      result)
        {
            if (!result) {
                // / / // /// ///// //////// /////////////
                // finalize result  //////// /////////////
        @@finalize-result@@
                // / / // /// ///// //////// /////////////
                return;
            }
            if (state->initialized) {
                // / / // /// ///// //////// /////////////
                // merge partial results /// /////////////
        @@merge-partial@@
                // / / // /// ///// //////// /////////////
            } else {
                state->acc = *result;
                state->initialized ++;
            }
            ckfree (result);
        }

        // Public
        extern double
        aktive_image_@@function@@ (aktive_image src, void* __client__ /* ignored */) {
            return image_reduce ("image::@@function@@", src,
                                 (aktive_batch_work)     @@function@@_worker,
                                 (aktive_batch_complete) @@function@@_completer);
        }
    }

    set region [textutil::adjust::undent $region]
    set region [string trim $region]
    set region [textutil::adjust::indent $region {    }]

    set merge [textutil::adjust::undent $merge]
    set merge [string trim $merge]
    set merge [textutil::adjust::indent $merge {        }]

    set finalize [textutil::adjust::undent $finalize]
    set finalize [string trim $finalize]
    set finalize [textutil::adjust::indent $finalize {        }]

    set code [textutil::adjust::undent $code]

    lappend map @@function@@	    $function
    lappend map @@region-reduce@@   $region
    lappend map @@finalize-result@@ $finalize
    lappend map @@merge-partial@@   $merge

    return [string map $map $code]
}

# # ## ### ##### ######## #############
return
