function r = planck(v,t)

% function r = planck(v,t)
%
% compute planck's function at wavenumber v, temperature t
%

AVOGAD   = 6.02297E+23;
BOLTZMNS = 1.38062E-23;
PLANCKS  = 6.62620E-34;
CLIGHT   = 2.99793E+10;
PLCON1   = 2.0 * PLANCKS * CLIGHT * CLIGHT * 1.E7;
PLCON2   = PLANCKS * CLIGHT / BOLTZMNS;

r = PLCON1*v.^3./(exp(PLCON2*v./t)-1.0);
