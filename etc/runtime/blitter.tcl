## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Blitter definitions used in and exposed by the runtime as common functions

# aktive_blit_copy -- Use when properly optimized
dsl blit into generated/blit/copy0.c {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
    {DD {z 0  1 up} {z 0  1 up}}
} copy

# aktive_blit_copy0 -- Use when properly optimized
dsl blit into generated/blit/copy.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
    {DD {z 0  1 up} {z 0 1 up}}
} copy

# aktive_blit_clear_all -- Use when properly optimized
dsl blit into generated/blit/clearall.c {
    {DH {y 0 1 up}}
    {DW {x 0 1 up}}
    {DD {z 0 1 up}}
} zero

# aktive_blit_clear -- Use when properly optimized
dsl blit into generated/blit/clear.c {
    {AH {y AY 1 up}}
    {AW {x AX 1 up}}
    {DD {z 0  1 up}}
} zero

# aktive_blit_fill
dsl blit into generated/blit/fill.c {
    {AH {y AY 1 up}}
    {AW {x AX 1 up}}
    {DD {z 0  1 up}}
} {const v}

# aktive_blit_unary0
dsl blit into generated/blit/unary0.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
    {DD {z 0  1 up} {z 0 1 up}}
} {apply op}

# aktive_blit_unary1
dsl blit into generated/blit/unary1.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
    {DD {z 0  1 up} {z 0 1 up}}
} {apply op a}

# aktive_blit_unary2
dsl blit into generated/blit/unary2.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
    {DD {z 0  1 up} {z 0 1 up}}
} {apply op a b}

# aktive_blit_fill_bands
# aktive_blit_copy0_bands
# aktive_blit_copy0_bands_to

##
# # ## ### ##### ######## ############# #####################
::return
