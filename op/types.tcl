# -*- tcl -*-
# # ## ### ##### ######## #############
## -- etc/aktive.tcl support
#
## PGM/PPM format variants

# # ## ### ##### ######## #############
## Enum for P*M format variants

critcl::enum::def aktive_pgm_variant {
    aktive_pgm_text	     text
    aktive_pgm_text_extended etext
    aktive_pgm_byte	     byte
    aktive_pgm_short         short
}

critcl::enum::def aktive_ppm_variant {
    aktive_ppm_text	     text
    aktive_ppm_text_extended etext
    aktive_ppm_byte	     byte
    aktive_ppm_short         short
}

# # ## ### ##### ######## #############
