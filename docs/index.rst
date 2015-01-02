.. kcarta-matlab documentation master file, created by
   sphinx-quickstart on Wed Dec 31 10:41:06 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

kCARTA-Matlab Documentation
===========================

kCARTA is a radiative transfer code for a non-scattering Earth’s
atmosphere. kCARTA outputs monochromatic gas optical depths, and clear
sky radiances and jacobians. This Matlab package is a simpler version
of the f77 version, which includes scattering and fluxes.

The code is driver by profiles in the .rtp format allowing the user to
easily change atmospheric conditions as needed. US Standard Atmosphere
optical depths have been precomputed and saved to a lookup table. This
means (linear) interpolations required to compute the optical depths for
arbitrary atmospheric profiles can be done very rapidly, as can the
derivatives needed for the Jacobians. This makes kCARTA very fast.

The code in the basic Test package allows the user to do RT calculations
for a downlooking instruments at the top of atmosphere (TOA), as well as
code to only compute optical depths. This basic package assumes the
“klayers” levels are the same as those in the kCompressed Database. NLTE
radiance effects in the 4 um CO2 band are included in daytime RT
calculations.

A more versatile package allows one to to use pressure layerings
different than that of the kCompressed Database. This is required for
uplooking instruments as the rapid variation of temperature and profile
gas constituents near the instrument, require a finer layering than that
of the standard kCompressed pressure layering.

We hope that the ease of use, range of features and speed of kCARTA make
it a useful tool. In addition to the main kCARTA source code, some
packages need to be picked up. One is , which allows an user to input a
radiosonde or model point profile, and output a layer averaged profile
that kCARTA can use. Another is the RTP package, which is an AIRS
Level II file format.

This document is very much a work in progress. Some major omissions
include references, significant examples of kCARTA output, and
comparisons of kCARTA output to observed spectra. These omissions will
be rectified in the future. Please give us your feedback on both the
code and the documentation!

Contents:

.. toctree::
    :maxdepth: 2

    README.rst
    kcarta.rst

