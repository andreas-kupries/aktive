## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
##
## Unoptimized loop nest for rectangle copies (blit)
## Configurable via
##
##  XSRC, XINIT, XNEXT
##  YSRC, YINIT, YNEXT
##  ZSRC, ZINIT, ZNEXT
##
## to rearrange the copied data in some way (flip, swap, sample, ...)
## The elements configure the handling of the __source__ position

def blitcore {
    #define SRC  src->domain
    #define DST  block->domain

    aktive_uint sdepth = SRC.depth;
    aktive_uint ddepth = DST.depth;

    aktive_uint spitch = SRC.width * sdepth;
    aktive_uint dpitch = DST.width * ddepth;

    TRACE ("s depth %d pitch %d | d depth %d pitch %d", sdepth, spitch, ddepth, dpitch);
    TRACE ("sy  sx  sz  | in  | dy  dx  dz  | out | capS %d | capD %d", src->used, block->used);

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

                aktive_uint srcpos = srcy * spitch + srcx * sdepth + srcz;
                aktive_uint dstpos = dsty * dpitch + dstx * ddepth + dstz;

                double value = src->pixel [srcpos];

                TRACE ("%3d %3d %3d | %3d | %3d %3d %3d | %3d | %.2f",
                       srcy, srcx, srcz, srcpos, dsty, dstx, dstz, dstpos, value);

		ASSERT (srcpos < src->used,   "pixel source out of bounds");
		ASSERT (dstpos < block->used, "pixel destin out of bounds");

                block->pixel [dstpos] = value;
            }
        }
    }
}

# # ## ### ##### ######## ############# #####################
##
## Unoptimized loop nest for rectangle copies (blit)
## Configurable via
##
##  XDST, XINIT, XNEXT
##  YDST, YINIT, YNEXT
##  ZDST, ZINIT, ZNEXT
##
## to rearrange the copied data in some way (flip, swap, sample, ...)
## The elements configure the handling of the __destination__ position

def blitcore/dst {
    #define SRC  src->domain
    #define DST  block->domain

    aktive_uint sdepth = SRC.depth;
    aktive_uint ddepth = DST.depth;

    aktive_uint spitch = SRC.width * sdepth;
    aktive_uint dpitch = DST.width * ddepth;

    TRACE ("spitch %d dpitch %d", spitch, dpitch);
    TRACE ("sy  sx  sz  | in  | dy  dx  dz  | out | capS %d | capD %d", src->used, block->used);

    aktive_uint dsty, dstx, dstz;
    aktive_uint srcy, srcx, srcz;
    aktive_uint row, col, band;

    for (row = 0, YDST = YINIT, srcy = SRC.y;
         row < SRC.height;
         row ++ , YDST YNEXT     , srcy ++) {
        for (col = 0, XDST = XINIT, srcx = SRC.x;
             col < SRC.width;
             col ++ , XDST XNEXT     , srcx ++) {
            for (band = 0, ZDST = ZINIT, srcz = 0;
                 band < SRC.depth;
                 band ++, ZDST ZNEXT, srcz ++) {

                aktive_uint srcpos = srcy * spitch + srcx * sdepth + srcz;
                aktive_uint dstpos = dsty * dpitch + dstx * ddepth + dstz;

                double value = src->pixel [srcpos];

                TRACE ("%3d %3d %3d | %3d | %3d %3d %3d | %3d | %.2f",
                       srcy, srcx, srcz, srcpos, dsty, dstx, dstz, dstpos, value);

		ASSERT (srcpos < src->used,   "pixel source out of bounds");
		ASSERT (dstpos < block->used, "pixel destin out of bounds");

                block->pixel [dstpos] = value;
            }
        }
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
