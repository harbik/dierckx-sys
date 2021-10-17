# Dierckx: B-Splines Curve and Surface Fitting

Dierckx is a Fortran library for fitting curve and surface *B-Splines* to sets of data points.  It was written by Paul
Dierckx in the mid 1980s, and it is still the most advanced general B-spline fitting library today.
It is based on a solid mathematical foundation, implements many advanced algorithms, and is described in detail in Paul Dierckx' book:
[Curve and Surface Fitting with Splines](https://www.google.com/books/edition/Curve_and_Surface_Fitting_with_Splines/-RIQ3SR0sZMC?hl=en "Paul Dierckx, Curve and Surface Fitting with Splines, Oxford University Press, 1993").


# Usage

You need a Fortran compiler on your system to use this library:
in specific, at the moment, it requires the Gnu Fortran **GFortran** compiler to be installed.
See [Installing GFortran](https://fortran-lang.org/learn/os_setup/install_gfortran) how to do this on your machine.

Having to install a Fortran compiler is a big restriction, so I recommend not using this crate as a dependency in big projects.

The Fortran files are located in the `src/netlib-dierckx` directory, and were downloaded from the [netlib.org](http://www.netlib.org/dierckx/) server on Oct 12, 2021.
The code was adapted to fix some warnings, in specific the float equality comparisons, which were replaced with the
`abs(f)<epsilon(f)` pattern when checking for a `0.0` value, and the `abs(fa-fb)<epsilon(fa)`-pattern, to check between
equality of two `REAL` numbers.
The files use `REAL` precision floating point values, but are cast to Rust `f64` values using the `-fdefault-real-8` gfortran compiler flag.
The original Fortran files do not define any double precision values.

The Fortran compilation is performed using the build.rs script, which uses the `cc` crate,
and the `gfortran` compiler,
and sets the following compiler flags:
  - `-std=legacy`
  - `-fdefault-real-8` cast all single precision floats to `f64`
  - `-Wno-maybe-uninitialized` 
  - `-O3`  highest optimization for gfortran

To use this library add this to your `Cargo.toml` file:

```
[dependencies]
dierckx-sys = "0.0.1"
```

For further instructions and examples see the separate `dierckx` crate.

# License
The Dierckx' Fortran code, included in this repository, was downloaded from `netlib.org`, and has no license
restrictions, but please acknowledge Paul Dierckx' work and library in your projects.

All the other content in this repository is &copy;2021 Harbers Bik LLC, and licensed under either of

 * Apache License, Version 2.0
   ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
 * MIT license
   ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>?)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
