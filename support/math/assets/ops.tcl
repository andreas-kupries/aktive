# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## ############# ##################### ##################################
## Math functions of various image and parameter arities - 0/1/2-parameter unary, 0-parameter binary

# Execution environments
# - Unary
#   1. `value` - input value to transform, also output
#   2. Arguments named in the operator spec.
#
# - Binary
#   1. `value` - result to return
#   2. `arga`  - first input value
#   3. `argb`  - second input value
#
# The defines used by the gamma_compress/expand functions reside in the `template.c` asset

def-op unary scalar  acos           {} { value = acos  (value);     }
def-op unary scalar  acosh          {} { value = acosh (value);     }
def-op unary scalar  asin           {} { value = asin  (value);     }
def-op unary scalar  asinh          {} { value = asinh (value);     }
def-op unary scalar  atan           {} { value = atan  (value);     }
def-op unary scalar  atanh          {} { value = atanh (value);     }
def-op unary scalar  cbrt           {} { value = cbrt  (value);     }
def-op unary scalar  ceil           {} { value = ceil  (value);     }
def-op unary scalar  clamp          {} { value = fmax  (0, fmin (1, value)); }
def-op unary scalar  cos            {} { value = cos   (value);     }
def-op unary scalar  cosh           {} { value = cosh  (value);     }
def-op unary scalar  exp            {} { value = exp   (value);     }
def-op unary scalar  exp10          {} { value = pow   (10, value); }
def-op unary scalar  exp2           {} { value = exp2  (value);     }
def-op unary scalar  fabs           {} { value = fabs  (value);     }
def-op unary scalar  floor          {} { value = floor (value);     }
def-op unary scalar  gamma_compress {} { value = (value <= ILIMIT) ? value * IGAIN : SCALE * pow (value, 1.0/GAMMA) - OFFSET; }
def-op unary scalar  gamma_expand   {} { value = (value <= GLIMIT) ? value / IGAIN : pow ((value + OFFSET) / SCALE, GAMMA);   }
def-op unary scalar  invert         {} { value = 1 - value;              }
def-op unary scalar  log            {} { value = log   (value);          }
def-op unary scalar  log10          {} { value = log10 (value);          }
def-op unary scalar  log2           {} { value = log2  (value);          }
def-op unary scalar  neg            {} { value = - value;                }
def-op unary scalar  not            {} { value = (value <= 0.5);         }
def-op unary scalar  reciprocal     {} { value = 1.0 / value;            }
def-op unary scalar  round          {} { value = round (value);          }
def-op unary scalar  sign           {} { value = (value < 0) ? -1 : (value > 0) ? 1 : 0; }
def-op unary scalar  signb          {} { value = (value < 0) ? -1 : 1;   }
def-op unary scalar  sin            {} { value = sin  (value);           }
def-op unary scalar  sinh           {} { value = sinh (value);           }
def-op unary scalar  sqrt           {} { value = sqrt (value);           }
def-op unary scalar  square         {} { value = value * value;             }
def-op unary scalar  tan            {} { value = tan  (value);           }
def-op unary scalar  tanh           {} { value = tanh (value);           }
def-op unary scalar  wrap           {} { value = (value > 1) ? fmod(value, 1) : (value < 0) ? (1 + fmod(value - 1, 1)) : value; }

def-op unary scalar  atan2  {x} { value = atan2 (value, x);         }
def-op unary scalar  eq     {x} { value = (value == x);             }
def-op unary scalar  expx   {x} { value = pow (x, value);           }
def-op unary scalar  fmax   {x} { value = fmax (value, x);          }
def-op unary scalar  fmin   {x} { value = fmin (value, x);          }
def-op unary scalar  fmod   {x} { value = fmod (value, x);          }
def-op unary scalar  ge     {x} { value = (value >= x);             }
def-op unary scalar  gt     {x} { value = (value > x);              }
def-op unary scalar  hypot  {x} { value = hypot (value, x);         }
def-op unary scalar  le     {x} { value = (value <= x);             }
def-op unary scalar  lt     {x} { value = (value <  x);             }
def-op unary scalar  ne     {x} { value = (value != x);             }
def-op unary scalar  nshift {x} { value = x - value;                }
def-op unary scalar  pow    {x} { value = pow (value, x);           }
def-op unary scalar  ratan2 {x} { value = atan2 (x, value);         }
def-op unary scalar  rfmod  {x} { value = fmod (x, value);          }
def-op unary scalar  rscale {x} { value = x / value;                }
def-op unary scalar  scale  {x} { value = value * x;                }
def-op unary scalar  shift  {x} { value = value + x;                }
def-op unary scalar  sol    {x} { value = (value <= x) ? value : 1 - value; }

def-op unary scalar  inside_cc  {low high} { value =   (low <= value) && (value <= high);  }
def-op unary scalar  inside_co  {low high} { value =   (low <= value) && (value <  high);  }
def-op unary scalar  inside_oc  {low high} { value =   (low <  value) && (value <= high);  }
def-op unary scalar  inside_oo  {low high} { value =   (low <  value) && (value <  high);  }
def-op unary scalar  outside_cc {low high} { value = !((low <= value) && (value <= high)); }
def-op unary scalar  outside_co {low high} { value = !((low <= value) && (value <  high)); }
def-op unary scalar  outside_oc {low high} { value = !((low <  value) && (value <= high)); }
def-op unary scalar  outside_oo {low high} { value = !((low <  value) && (value <  high)); }

def-op binary scalar  and   {} { value =   ( arga > 0.5) && (argb >  0.5);  }
def-op binary scalar  nand  {} { value = !(( arga > 0.5) && (argb >  0.5)); }
def-op binary scalar  nor   {} { value = !(( arga > 0.5) || (argb >  0.5)); }
def-op binary scalar  or    {} { value =   ( arga > 0.5) || (argb >  0.5);  }
def-op binary scalar  xor   {} { value = ((arga > 0.5) && (argb <= 0.5)) || ((arga <= 0.5) && (argb >  0.5)); }

def-op binary scalar  add   {} { value = arga + argb; }
def-op binary scalar  sub   {} { value = arga - argb; }
def-op binary scalar  mul   {} { value = arga * argb; }
def-op binary scalar  div   {} { value = arga / argb; }
def-op binary scalar  fmod  {} { value = fmod (arga, argb); }
def-op binary scalar  pow   {} { value = pow  (arga, argb); }

def-op binary scalar  atan2 {} { value = atan2 (arga, argb); }
def-op binary scalar  hypot {} { value = hypot (arga, argb); }
def-op binary scalar  fmax  {} { value = fmax  (arga, argb); }
def-op binary scalar  fmin  {} { value = fmin  (arga, argb); }

def-op binary scalar  eq    {} { value = (arga == argb); }
def-op binary scalar  ge    {} { value = (arga >= argb); }
def-op binary scalar  gt    {} { value = (arga >  argb); }
def-op binary scalar  le    {} { value = (arga <= argb); }
def-op binary scalar  lt    {} { value = (arga <  argb); }
def-op binary scalar  ne    {} { value = (arga != argb); }

# # ## ### ##### ######## ############# ##################### ##################################
return
