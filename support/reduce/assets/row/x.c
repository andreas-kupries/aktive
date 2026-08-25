
    // single-band: unroll 4x over pixels, reduce the 4 lanes, and merge into single result at the end
    // 2-band:      unroll 2x over pixels, reduce the 4 lanes, and merge lane pairs into the 1 results at the end
    // 3-band:      unroll 2x over pixels, reduce the 6 lanes, and merge lane pairs into the 3 results at the end
    // 4-band:      reduce 4 lanes, and store into the 4 results at the end
    // ...



	    // reducing more than 4 bands along the row, serially
	    // look into unrolled - i.e. 4 bands, 2 band, 1 band until we have all
