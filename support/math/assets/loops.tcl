# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Loop code fragments, for varying levels of unrolling
#
# Placeholders
#
#  - opcode<N>	loop body for N-unrolled operation
#

def-loop unary 1 {
    // base loop, not unrolled
    for (; n > 0; n--, d++, s++) {
	double value = *s;
	@opcode1@
	*d = value;
    }
}

def-loop unary 2 {
    // unrolled 2 times
    for (; n > 1; n -= 2, d += 2, s += 2) {
	double value0 = s[0];
	double value1 = s[1];
	@opcode2@
	d[0] = value0;
	d[1] = value1;
    }
}

def-loop unary 4 {
    // unrolled 4 times
    for (; n > 3; n -= 4, d += 4, s += 4) {
	double value0 = s[0];
	double value1 = s[1];
	double value2 = s[2];
	double value3 = s[3];
	@opcode4@
	d[0] = value0;
	d[1] = value1;
	d[2] = value2;
	d[3] = value3;
    }
}

def-loop binary 1 {
    // base loop, not unrolled
    for (; n > 0; n--, d++, sa++, sb++) {
	double arga = *sa, argb = *sb, value;
	@opcode1@
	*d = value;
    }
}

def-loop binary 2 {
    // unrolled 2 times
    for (; n > 1; n -= 2, d += 2, sa += 2, sb += 2) {
	double arga0 = sa[0], argb0 = sb[0], value0;
	double arga1 = sa[1], argb1 = sb[1], value1;
	@opcode2@
	d[0] = value0;
	d[1] = value1;
    }
}

def-loop binary 4 {
    // unrolled 4 times
    for (; n > 3; n -= 4, d += 4, sa += 4, sb += 4) {
	double arga0 = sa[0], argb0 = sb[0], value0;
	double arga1 = sa[1], argb1 = sb[1], value1;
	double arga2 = sa[2], argb2 = sb[2], value2;
	double arga3 = sa[3], argb3 = sb[3], value3;
	@opcode4@
	d[0] = value0;
	d[1] = value1;
	d[2] = value2;
	d[3] = value3;
    }
}

# # ## ### ##### ######## #############
return
