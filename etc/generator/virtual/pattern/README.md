# Useful patterns

  - Configurable stripes, grids, and checkerboards

  - Eye test pattern (left to right increasing spatial frequency, top to bottom black to white)

  - 2D sine wave

  - Zone plate test pattern

  - Small common convolution kernels

      - [Edge Detection Notes](http://www.holoborodko.com/pavel/image-processing/edge-detection)
      - [Tcler's Wiki TkPhotoLab](https://wiki.tcl-lang.org/page/TkPhotoLab)
      - [Wikipedia Prewitt](https://en.wikipedia.org/wiki/Prewitt_operator)
      - [Wikipedia Robert's Cross](https://en.wikipedia.org/wiki/Roberts_cross)
      - [Wikipedia Sobel](https://en.wikipedia.org/wiki/Sobel_operator)
      - [Wikipedia Scharr](https://en.wikipedia.org/wiki/Scharr_operator)

  - Small common structuring elements, parameterized by a radius.
    The resulting SE's have width and height of `2*radius+1`.

      - square
      - disc
      - circle
      - horizontal bar
      - vertical bar
      - axis-aligned cross (+)
      - main diagonal
      - cross (secondary) diagonal
      - diagonal-aligned cross (x)

      Examples for `radius == 2` (=> `width|height == 5`):

      ```
      square disc   circle hbar   vbar   cross dbar    cbar  xcross
      *****  ..*..  ..*..  .....  ..*..  ..*..  *....  ....*  *...*
      *****  .***.  .*.*.  .....  ..*..  ..*..  .*...  ...*.  .*.*.
      *****  *****  *...*  *****  ..*..  *****  ..*..  ..*..  ..*..
      *****  .***.  .*.*.  .....  ..*..  ..*..  ...*.  .*...  .*.*.
      *****  ..*..  ..*..  .....  ..*..  ..*..  ....*  *....  *...*
      ```
