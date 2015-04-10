CrIS TVAC
=========

The  TVAC gas cell tests showed generally good agreement between
observed and calculated spectra. We show representative results from the
PFL side 1 CO, CH\ :math:`_4`, CO\ :math:`_2`, and the MN side 1
NH\ :math:`_3` test, and a representative summary of CO and
CO\ :math:`_2` residuals across different test stages. The PFL tests
show good agreement with calculated transmittances for CO,
CH\ :math:`_4` and CO\ :math:`_2`. The CO CH\ :math:`_4`, and
CO\ :math:`_2` side 1 residuals are reasonably consistent across the MN,
PFH, and PFL tests. There was a low-frequency component in the residuals
in some tests. In addition, there was a significant difference between
nominal and observed gas cell pressure in some tests. When this occured
the observed value was used for the calculated spectra.

There is a close parallel between our expression for transmittance

.. math:: {\tau_{\mbox{\tiny obs}}}= f\cdot{\mbox{\small SA}}^{-1}\cdot f \cdot \frac{{\mbox{\small FT}}_2 - {\mbox{\small FT}}_1}{{\mbox{\small ET}}_2 - {\mbox{\small ET}}_1}

and our default  calibration equation

.. math::

   r_{\mbox{\tiny obs}} = F \cdot r_{\mbox{\tiny ICT}}\cdot f \cdot
       {\mbox{\small SA}}^{-1}\cdot f \cdot \frac{{\mbox{\small ES}}- {\mbox{\small SP}}}{{\mbox{\small IT}}- {\mbox{\small SP}}}

 Here :math:`f` is a raised-cosine bandpass filter,
:math:`{\mbox{\small SA}}^{-1}` the inverse of the ILS matrix,
:math:`r_{\mbox{\tiny ICT}}` is expected ICT radiance at the sensor
grid, and :math:`F` is Fourier interpolation from sensor to user grid.
The same :math:`f` is applied to line-by-line transmittances before
convolution to the  sensor grid. All tests shown here were done using
UMBC LBL for calculated transmittances.

To match observed and calculated transmittance spectra we minimize
:math:`{\mbox{\small RMS}}(a\cdot{\tau_{\mbox{\tiny obs}}}+ b - {\tau_{\mbox{\tiny calc}}})`
over the fitting interval as a function of the metrology laser
wavelength. From this we get both a conventional residual and the
difference of wavelength at the minima from the neon calibration value.
The latter difference is the “metrology laser residual.” The CO and
CH\ :math:`_4` side 1 residuals are very consistent across the MN, PFH,
and PFL tests. For CO\ :math:`_2`, the MN and PFH tests were in good
agreement, in comparison with the PFL tests. Our NH\ :math:`_3`
residuals were generally larger than for CO\ :math:`_2`.

Remaining work includes checking and refining measurements of the focal
plane geometery and adding a nonlinearity correction to the observed
data.

.. figure:: figures/CO_obs_and_calc.pdf
   :alt: CO observed and calculated transmittance for all s, over the
   fitting interval. At this level of detail we see all values are very
   close.

   CO observed and calculated transmittance for all s, over the fitting
   interval. At this level of detail we see all values are very close.
.. figure:: figures/CO_breakout_2.pdf
   :alt: CO observed minus calculated transmittance for side and corner
   FOVs, over the fitting interval.

   CO observed minus calculated transmittance for side and corner FOVs,
   over the fitting interval.
.. figure:: figures/CH4_obs_and_calc.pdf
   :alt: CH\ :math:`_4` observed and calculated transmittance for all s,
   over the fitting interval. At this level of detail we see all values
   are very close.

   CH\ :math:`_4` observed and calculated transmittance for all s, over
   the fitting interval. At this level of detail we see all values are
   very close.
.. figure:: figures/CH4_breakout_2.pdf
   :alt: CH\ :math:`_4` observed minus calculated transmittance for side
   and corner s, over the fitting interval.

   CH\ :math:`_4` observed minus calculated transmittance for side and
   corner s, over the fitting interval.
.. figure:: figures/NH3_obs_and_calc.pdf
   :alt: NH\ :math:`_3` observed and calculated transmittance for all s,
   over the fitting interval. At this level of detail we see all values
   are close.

   NH\ :math:`_3` observed and calculated transmittance for all s, over
   the fitting interval. At this level of detail we see all values are
   close.
.. figure:: figures/NH3_breakout_2.pdf
   :alt: NH\ :math:`_3` observed minus calculated transmittance for side
   and corner s, over the fitting interval.

   NH\ :math:`_3` observed minus calculated transmittance for side and
   corner s, over the fitting interval.
.. figure:: figures/CO2_obs_and_calc.pdf
   :alt: CO\ :math:`_2` observed and calculated transmittance for all s,
   over the fitting interval. At this level of detail we see all values
   are close.

   CO\ :math:`_2` observed and calculated transmittance for all s, over
   the fitting interval. At this level of detail we see all values are
   close.
.. figure:: figures/CO2_breakout_2.pdf
   :alt: CO\ :math:`_2` observed minus calculated transmittance for side
   and corner s, over the fitting interval.

   CO\ :math:`_2` observed minus calculated transmittance for side and
   corner s, over the fitting interval.
::

              --- rms fit ----        --- met laser --
      FOV    MN      PH      PL      MN      PH      PL  
       1     4.4     1.5     9.9    13.2    15.0    10.3
       2     2.8     3.5    10.6     3.4     5.2     2.3
       3     4.9     2.4    10.0     4.1     2.8     2.6
       4     2.7     3.4     7.7     4.4     6.7     3.9
       5     1.7     2.8     7.9     3.1     3.1     2.6
       6     2.4     3.3     8.1     3.1     2.6     3.6
       7     3.9     1.6     5.3    -0.5    -0.5    -0.8
       8     2.4     3.3     6.5    -6.7    -6.7    -5.7
       9     4.7     2.6     5.2     7.2     4.9     7.5

      log torr: MN 40.5 PH 39.9 PL 45.0
      obs torr: MN 41.0 PH 26.0 PL 45.0

::

              --- rms fit ----        --- met laser --
      FOV    MN      PH      PL      MN      PH      PL  
       1     1.6     1.4     3.3     8.3    11.3     0.3
       2     1.6     1.2     3.2     2.1     2.6    -6.2
       3     2.8     1.9     4.0     1.3    -0.3    -4.1
       4     1.8     1.8     3.0     3.6     5.4    -3.1
       5     2.5     2.1     3.4     3.6     4.9    -1.8
       6     2.5     1.6     3.0     2.1     1.8    -3.9
       7     1.7     1.2     3.1    -6.2    -3.9   -13.4
       8     1.8     2.4     3.1    -6.5    -4.9   -11.1
       9     1.7     1.9     3.6     0.8     0.8    -6.2

    log torr: MN 40.2 PH 40.0 PL 40.7
    obs torr: MN 40.2 PH 40.0 PL 22.0

CrIS full resolution processing
===============================

After several earlier tests, on 4 Dec 2014 the CrIS instrument changed
over to full resolution processing, with a nominal 0.8 cm OPD for all
three bands. We show a representative comparison of results from the and
/ full resolution processing. The tests shown here were done with and
high res data from 6–8 Dec 2014. We take the average and standard
deviation of  15 and 16 independently for each , and compare these
values with the values for  5. Results are for 32,186  and 32,120
descending s. The intent is to show variation among s, as might arise
from varying nonlinearity or artifacts of the self-apodization
correction. Due to some initial problems with the impulse mask, as a
precaution s where any LW channel was greater than 320K were discarded.

For the MW band  7 is the least linear, and only partially corrected
with the first-order adjustment. The variation in response is much
greater than what we see with . This may be due to problems with the
 nonlinearity correction. A normalized frequency domain representation
of the numeric filter needs a scaling factor to match the original
nonlinearity measurements. We used 1.6047 for LW, 0.9826 for MW, and
0.2046 for SW for these values.

For the SW band  and  are generally in good agreement. Residuals for
both are significantly larger than for the LW band, and  vs  differences
are generally greatest for the coldest lines and regions.  7 minus  5 is
significantly greater than for other s at 2255 and 2359 , for both  and
.

There is significant convergence in the  and  processing. We are working
with Yong Han’s group on the MW differences. Variation due to
nonlinearity, especially for the MW band, is significantly greater than
some of the more subtle effects we have been considering recently. Note
again that these results are relative to  5 and are not comparisons with
with expected observed radiance from model data or radiance from other
sounders.

.. figure:: figures/ccast_MW_avg_2014_340-342_hr.pdf
   :alt:  MW mean

    MW mean
.. figure:: figures/noaa_MW_avg_2014_340-342.pdf
   :alt:  MW mean

    MW mean
.. figure:: figures/ccast_MW_dif_2014_340-342_hr.pdf
   :alt:  MW  groups

    MW  groups
.. figure:: figures/noaa_MW_dif_2014_340-342.pdf
   :alt:  MW  groups

    MW  groups
.. figure:: figures/ccast_SW_avg_2014_340-342_hr.pdf
   :alt:  SW mean

    SW mean
.. figure:: figures/noaa_SW_avg_2014_340-342.pdf
   :alt:  SW mean

    SW mean
.. figure:: figures/ccast_SW_dif_2014_340-342_hr.pdf
   :alt:  SW  groups

    SW  groups
.. figure:: figures/noaa_SW_dif_2014_340-342.pdf
   :alt:  SW  groups

    SW  groups

