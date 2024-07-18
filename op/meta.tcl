# -*- tcl -*-
# # ## ### ##### ######## #############
## -- etc/aktive.tcl support
#
## Meta data modification - core operation, full replacement, clearing

critcl::cproc aktive::op::meta::set {
    aktive_image src
    object       meta
} aktive_image {
    return aktive_image_meta_set (src, meta);
}

critcl::cproc aktive::op::meta::clear {
    aktive_image src
} aktive_image {
    return aktive_image_meta_set (src, 0);
}

# # ## ### ##### ######## #############
