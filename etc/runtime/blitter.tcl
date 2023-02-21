## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Blitter definitions used in and exposed by the runtime as common functions

# aktive_blit_copy -- Use when properly optimized
dsl blit into generated/blit/copy.c {
    {AH {y AY 1 up} {y SY 1 up}}
    {AW {x AX 1 up} {x SX 1 up}}
    {DD {z 0  1 up} {z 0  1 up}}
} copy

# aktive_blit_copy0 -- Use when properly optimized
dsl blit into generated/blit/copy0.c {
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

# aktive_blit_clear_bands_from
dsl blit into generated/blit/clear_bands_from.c {
    {AH {y AY 1 up}}
    {AW {x AX 1 up}}
    {n  {z first 1 up}}
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
} {apply1 op}

# aktive_blit_unary1
dsl blit into generated/blit/unary1.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
    {DD {z 0  1 up} {z 0 1 up}}
} {apply1 op a}

# aktive_blit_unary2
dsl blit into generated/blit/unary2.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
    {DD {z 0  1 up} {z 0 1 up}}
} {apply1 op a b}

# aktive_blit_binary
dsl blit into generated/blit/binary.c {
    {AH {y AY 1 up} {y 0 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up} {x 0 1 up}}
    {DD {z 0  1 up} {z 0 1 up} {z 0 1 up}}
} {apply2 op}

# aktive_blit_cunary
dsl blit into generated/blit/complex_unary.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
} {complex-apply-unary op}

# aktive_blit_cbinary
dsl blit into generated/blit/complex_binary.c {
    {AH {y AY 1 up} {y 0 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up} {x 0 1 up}}
} {complex-apply-binary op}

# aktive_blit_creduce
dsl blit into generated/blit/complex_reduce.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
} {complex-apply-reduce op}

# aktive_blit_fill_bands
# aktive_blit_copy0_bands

# aktive_blit_copy0_bands_to
dsl blit into generated/blit/copy_bands.c {
    {AH {y AY 1 up} {y 0 1 up}}
    {AW {x AX 1 up} {x 0 1 up}}
    {SD {z DZ 1 up} {z 0 1 up}}
} copy

##
# # ## ### ##### ######## ############# #####################
::return
