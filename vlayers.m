
function p2 = vlayers(p1, nlay2)

% vlayers rescales the output of klayers to an arbitrary
% number of layers interpolated regularly between supplied
% top and bottom levels
%
% inputs
%   p1     - kcmix profile structure
%   nlay2  - number of layers in output profile
%
% output
%   p2     - p1 interpolated to nlay2 layers
%

% create a new set of layer boundry pressures that fall smoothly
% among the existing 100 layer/101 level reference set.  The first
% and last levels of the new set will have the same pressure as the
% first and last levels of the reference set.

nlay1 = length(p1.mpres);
nlev1 = length(p1.plev);
if nlev1 ~= nlay1 + 1
  error('bad layer or level number in input profile')
end
nlev2 = nlay2 + 1;

% calculate new level set
nseq2 = (((1:nlev2) - 1) ./ (nlev2 - 1)) .* (nlev1 - 1) + 1;
p2.plev = interp1(1:nlev1, p1.plev', nseq2, 'linear')';

% show level pressure interpolation points
% semilogy(1:nlev1, p1.plev, '+', nseq2, p2.plev, 'o');
% legend(sprintf('%d level', nlev1), sprintf('%d level', nlev2))

% calculate new layer set
nseq2 = (((1:nlay2) - 1) ./ (nlay2 - 1)) .* (nlay1 - 1) + 1;
p2.mpres = interp1(1:nlay1, p1.mpres', nseq2, 'linear')';

% show layer pressure interpolation points
% semilogy(1:nlay1, p1.mpres, '+', nseq2, p2.mpres, 'o');
% legend(sprintf('%d layer', nlay1), sprintf('%d layer', nlay2))

% interpolate temperature and partial pressures to the new layers
p2.mtemp = interp1(log(p1.mpres), p1.mtemp, log(p2.mpres), 'spline');
p2.gpart = interp1(p1.mpres, p1.gpart, p2.mpres, 'spline');

% rescale layer gas amounts
ngas = length(p1.glist);
dz1 = abs(diff(p1.plev)) * ones(1,ngas);
dz2 = abs(diff(p2.plev)) * ones(1,ngas);
p2.gamnt = ...
   interp1(log(p1.mpres), p1.gamnt ./ dz1, log(p2.mpres), 'spine') ...
   .* dz2;

% pass gas list along unchagned
p2.glist = p1.glist;

