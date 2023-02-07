## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
##
## Unoptimized loop nest for rectangle copies (blit)
## Configurable via
##
##  XSRC, XINIT, XNEXT
##  YSRC, YINIT, YNEXT
##  ZSRC, ZINIT, ZNEXT
##
## to rearrange the copied data in some way (flip, swap, sample, ...)

def blitcore {
    TRACE ("sy  sx  sz  | in  | dy  dx  dz  | out |", 0);
    #define SRC  src->domain
    #define DST  block->domain

    aktive_uint dsty, dstx, dstz;
    aktive_uint srcy, srcx, srcz;
    aktive_uint row, col, band;

    for (row = 0, dsty = DST.y, YSRC = YINIT;
         row < DST.height;
         row ++ , dsty ++     , YSRC YNEXT) {
        for (col = 0, dstx = DST.x, XSRC = XINIT;
             col < DST.width;
             col ++ , dstx ++     , XSRC XNEXT) {
            for (band = 0, dstz = 0, ZSRC = ZINIT;
                 band < DST.depth;
                 band ++, dstz ++, ZSRC ZNEXT) {

                aktive_uint srcpos = srcy * SRC.width * SRC.depth + srcx * SRC.depth + srcz;
                aktive_uint dstpos = dsty * DST.width * DST.depth + dstx * DST.depth + dstz;

                double value = src->pixel [srcpos];

                TRACE ("%3d %3d %3d | %3d | %3d %3d %3d | %3d | %.2f",
                       srcy, srcx, srcz, srcpos, dsty, dstx, dstz, dstpos, value);

                block->pixel [dstpos] = value;
            }
        }
    }
}

##
## # # ## ### ##### ######## ############# #####################
::return
