# wobble configuration

point?   {{}} center		Center of the wobble, relative to the origin. \
    Defaults to the image center.
double?  500  amplitude		Base amplitude of the displacement.
double?  2    frequency		Base wave frequency.
double?  0.5  chirp		Chirp (power) factor modulating the frequency.
double?  0.6  attenuation	Power factor tweaking the base 1/x attenuation.

note The effect modulates the distance from the center based on the formula \
    `sin (radius^chirp * frequency) * amplitude / (1+radius)^attenuation`, \
    where `radius` is the original distance.

note All parameters, including the center are optional.
