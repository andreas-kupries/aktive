# Notes on terminology

  - https://dspguru.com/dsp/faqs/multirate/decimation/
  - https://dspguru.com/dsp/faqs/multirate/interpolation/

Loosely speaking, `decimation` is the process of reducing the sampling rate. In practice, this
usually implies lowpass-filtering a signal, then throwing away some of its samples.

`Downsampling` is a more specific term which refers to just the process of throwing away samples,
without the lowpass filtering operation.

`Upsampling` is the process of inserting zero-valued samples between original samples to increase
the sampling rate. (This is called `zero-stuffing`.) Upsampling adds to the original signal
undesired spectral images which are centered on multiples of the original sampling rate.

`Interpolation`, in the DSP sense, is the process of upsampling followed by filtering. (The
filtering removes the undesired spectral images.)
