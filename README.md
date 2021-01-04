# dlas

Library for D programming language that provides tools to work with LAS (Well Log ASCII Standart) files.
-----------

Simple library for D to deal with well logs. 

## Information

Documentation is available [here](https://dlas.dpldocs.info/dlas.html) 

Author: Dmitriy Linev

License: MIT

## Features

  - Import LAS files version 1, 2 and 3

## Example

```D
auto loader = new Loader;
auto lasHeader = loader.loadLasHeader("path/to/file.las");
double start = lasHeader["STRT"].value.get!double;
double stop = lasHeader["STOP"].value.get!double;
double step = lasHeader["STEP"].value.get!double;
int nsamples = (stop - start) / step; // computes amount of samples in LAS file
auto lasData = loader.loadLasData("path/to/file.las");
auto md = data[0][];  // data is a 2D array of doubles so all cool D stuff can be applied

```

## Package content

| Directory     | Contents                       |
|---------------|--------------------------------|
| `./source`    | Source code.                   |
| `./test`      | Unittest data.                 |

## Installation

dlas is available in dub. If you're using dub run `dub add dlas` in your project folder and dub will add dependency and fetch the latest version.