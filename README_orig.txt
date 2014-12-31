kcmix is a Matlab based version of kCARTA (also available under
github) which was designed to be the Reference ClearSky Forward Model
for NASA's AIRS instrument, a hyperspectral infared nadir
sounder. Mixed absorptions and radiances are computed using compressed
tabulated absorptions.

kcmix is designed to be fast, accurate and easy-to-use; compressed
optical depths come from a Matlab-based line-by-line code which
currently uses the HITRAN 2012 lineshape parameters, with CO2
linemixing and MT-CKDv2.5 water continuum. A key idea is that the
profile should define the set of mixed paths.  kcmix does 3-d
interpolation in pressure, temperature, and partial pressure to the
user-supplied layer set, and radiance calculations are done on
user-supplied layers.

In order to run kcmix, the user also needs to install/download
a) hdf packages
b) rtp package, which is our native file format for storing
   atmospheric geophysical variables and instrument view geometry
   parameters, needed for RT calculations
c) klayers package, which takes in a LEVELS rtp file and produces a LAYERS 
   average rtp file, needed for RT calculations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Main Top Level Routines
-----------------------

kcrad - radiative transfer top-level wrapper, manages defaults and
        loops on chunks, calling kcmix2, contcalc, and rtchunk

rtchunk - radiative transfer calc's in 10^4 point chunks, including
          reflected solar and basic reflected thermal

kcmix2 - calculates 25 1/cm chunks of mixed absorptions for a
         supplied profile, from tabulated compressed absorptions

kcmix100 - version of kcmix that assumes a 100-layer input profile
           with the same layers as the reference profiles

contcalc - continuum calculation from kcarta tabulated values


Performance
------------

Code for the mixed absorptions has been tested against the Fortran
kcarta and line-by-line codes.  The code for radiance calculations
is newer and has not be tested as much, for example reflected solar
is not working.

Runtime performance is good.  Recent benchmarks with ktest1.m from
605 to 2805 1/cm with 44 gasses, reflected solar, reflected thermal,
and the version '24' of the water continuum code took 83 seconds on
a maya cluster node.  A top level breakdown of runtimes had

  kcmix2    51 pct
  rtchunk   35 pct
  contcalc  13 pct

Interpolation is less than 1 pct of kcmix runtime, and calculation
of interpolation weights even less, because we are interpolating the
compact representation.  The most time consuming lines in kcmix2 are

  29 pct, load tabulated coefficients
  23 pct, apply the decompression transform
  10 pct, check for existance of the coefficient file

The rest is spread around, mostly in find statements, dividing out
by the reference profile, and so on.  Except possibly for the load
there is isn't much left to optimize.


Data
-----

kcmix uses compressed tabulated optical depths.  The optical depths
are generated from GENLN2 or other line-by-line codes.  Code to do
this compression is in an earlier "push" of the abscmp subdirectory,
see the README there for an overview.


Documentation
--------------

Documentation is available in the DOC subdirectory, and is fairly
up-to-date. 


Authors
--------

All kcmix code is by H. Motteler, with guidance for the radiative
transfer calculations from Sergio DeSouza-Machado and Scott Hannon.
L. Larrabee Strow is Principal Investigator, and we all contributed
to the fundamental ideas and initial development.

