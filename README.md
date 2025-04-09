
<a href='doc/logo.md'><img src='doc/assets/aktive-logo-128.png' style='float:right;'></a>

||||
|---|---|---|
|Project|[Documentation](doc/index.md)|[Developer Index](doc/dev/index.md)|

# Welcome

Welcome to `AKTIVE`, Andreas Kupries's Tcl Image Vector Extension.

It is yet another attempt at creating an image processing package for Tcl, which started out with
the `CRIMP` (CRItcl IMage Processor).

While it only started as an experiment in massive code generation, it was successful and now
continued normally.

Operator specifications written in a custom Tcl-based DSL are converted into Tcl and C code working
on top of a small fixed runtime, making the combination a functional Tcl extension.

#  License

The license is [MIT/BSD](doc/license.md)

# Ticket Tracking

AKTIVE is currently available from three repositories:

  - The [primary fossil repository](https://core.tcl-lang.org/akupries/aktive), which is also where
    the   [official ticket tracker](https://core.tcl-lang.org/akupries/aktive/reportlist) lives.

  - A [github mirror](https://github.com/andreas-kupries/aktive) updated from the primary, roughly
    once a day.

    __Please do not submit tickets at the mirror__.

    Note that you may be reading this README at the mirror.

  - And a [fossil mirror](https://chiselapp.com/user/andreas_kupries/repository/aktive/index) at
    [Chiselapp](https://chiselapp.com), also updated from the primary roughly once a day.

# Guides and other Documentation

  - [License](doc/license.md)
  - [Command Reference](doc/ref/index.md)
  - [Changes By Version](doc/changes.md)
  - [How To Install AKTIVE](doc/howtos/install.md)
  - [Documentation Main](doc/index.md)
  - [Logo](doc/logo.md)

# State

The extension currently implements a few hundred operators in 7 major sections.
For the full details please read the [command reference](/doc/trunk/doc/ref/index.md).

Last time it was checked the sources (after code generation) were split into

|Section|Lines|Percent|
|:---|---:|---:|
|Runtime|__9617__|__9.42__|
|→ C|8895|8.71|
|→ Tcl|722|0.71|
|DSL|__5100__|__5.00__|
|Operators|__15414__|__15.10__|
|Generated|__69504__|__68.09__|
|→ C|52403|51.33|
|→ Tcl|17101|16.75|
|Doc Source|__2447__|__2.40__|
|Total|102082|100.00|
