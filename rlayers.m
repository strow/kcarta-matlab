%
% NAME
%
%   rlayers - interpolate a layer profile
%
% SYNOPSIS
%
%   p2 = rlayers(p1, ropt)
%
% INPUTS
%
%   p1    - RTP profile structure
%   ropt  - interpolation parameters
%
% OUTPUTS
%
%   p2    - interpolation of profile p1
%
% DESCRIPTION
%
%

function p2 = rlayers(p1, ropt)

% optional ropt parameter defaults
nlay2 = 0;      % if non-zero, rescale p1 to nlay2 layers
plev2 = 0;      % if non-zero, an explicit set of levels for p2
addsurf = 1;    % flag to add a level at the surface pressure
addpobs = 1;    % flag to add a level at the observer pressure

% option to override the above defaults with kopt fields
% (other options set with kopt are passed along to rtcalc)
if nargin == 2
  optvar = fieldnames(ropt);
  for i = 1 : length(optvar)
    vname = optvar{i};
    if exist(vname, 'var')
      eval(sprintf('%s = ropt.%s;', vname, vname));
    end
  end
end

% get number of gasses from the gamnt field
[m, ngas] = size(p1.gamnt);

% short names for levels and layers from profile p1
nlev1 = p1.nlevs;
nlay1 = nlev1 - 1;
plev1 = p1.plevs(1:nlev1);  % truncate to actual level set
play1 = p1.plays(1:nlay1);  % truncate to actual layer set

% make sure p1 pressure increases with index
% (we should just quietly flip things, here)
if p1.plevs(1) > p1.plevs(2)
  error('pressure levels should be in increasing order')
end

% p2 starts out as a copy of p1
p2 = p1;

% -----------------------------------------------------------
% If a new number of layers is specified but no explicit new
% level set is provided, then create new level and layers sets
% for p2 by interpolating the p1 values
% -----------------------------------------------------------

if nlay2 > 0 & plev2 == 0

  nlev2 = nlay2 + 1;
  p2.nlevs = nlev2;

  % calculate new level set
  nseq2 = (((1:nlev2) - 1) ./ (nlev2 - 1)) .* (nlev1 - 1) + 1;
  p2.plevs = interp1(1:nlev1, plev1', nseq2, 'spline')';

  % calculate new altitudes
  p2.palts = interp1(1:nlev1, p1.palts(1:nlev1)', nseq2, 'spline')';

  % show level pressure interpolation points
  semilogy(1:nlev1, plev1, '+', nseq2, p2.plevs, 'o');
  legend(sprintf('%d level', nlev1), sprintf('%d level', nlev2))

  % calculate a new layer set
  % (this should be done as a finer integral)
  p2.playsA = (p2.plevs(1:nlev2-1) + p2.plevs(2:nlev2)) / 2;
  p2.playsB = exp((log(p2.plevs(1:nlev2-1)) + log(p2.plevs(2:nlev2))) / 2);

  % the following old "vlayers" calculation was wrong:
  nseq2 = (((1:nlay2) - 1) ./ (nlay2 - 1)) .* (nlay1 - 1) + 1;
  p2.playsC = interp1(1:nlay1, play1', nseq2, 'linear')';

  [p1.plays(1:10), p2.playsA(1:10), p2.playsB(1:10), p2.playsC(1:10)]

end

return

% -------------------------------------------------------------------
% Option to add a surface level to the original level set, splitting
% the layer surrounding the surface level.
% -------------------------------------------------------------------

if addsurf

  % short names for p2
  nlev2 = p2.nlevs;
  nlay2 = nlev2 - 1;

  % get index of closest pressure level above surface pressure
  si = max(find(plev1 <= p1.spres));
  
  plev1(si)
  p1.spres
  p1.spres = input('new surf pres > ');
  si = max(find(plev1 <= p1.spres));

  % splice in a true surface level, if necessay; 

  abs((p1.spres - plev1(si)) / p1.spres)
  if abs((p1.spres - plev1(si)) / p1.spres) > 0.01

    % create a new level set
    p2.plevs = [plev1(1:si); p1.spres];
    p2.nlevs = si + 1;

    % short names for p2
    nlev2 = p2.nlevs;
    nlay2 = nlev2 - 1;

    % new altitudes
    p2.palts = interp1(1:nlev1, p1.palts(1:nlev1)', p2.plevs, 'spline')';

    % create a new layer set
    pa = plev1(si);    % pressure level above surface
    pb = plev1(si+1);	% pressure level below surface
    pwt = (p1.spres - pa) / (pb - pa);
    nseq2 = [1:si-1, si+pwt];
    p2.plays = interp1(1:nlay1, play1', nseq2, 'spline')';

  end
end

% ---------------------
% do the interpolations
% ---------------------

% interpolate temperature to the new layer set
p2.ptemp = interp1(log(p1.plays(1:nlay1)), p1.ptemp(1:nlay1), ...
	           log(p2.plays(1:nlay2)), 'spline');

% interpolate partial pressures to the new layers
% p2.gpart = interp1(p1.plays, p1.gpart, p2.plays);

% interpolate gas amounts to the new layer set
dz1 = abs(diff(p1.plevs(1:nlev1))) * ones(1,ngas);
dz2 = abs(diff(p2.plevs(1:nlev2))) * ones(1,ngas);

% interpolate absorber amount to the new layers
p2.gamnt = interp1(log(p1.plays(1:nlay1)), ...
                   p1.gamnt(1:nlay1,:) ./ dz1, ...
                   log(p2.plays), 'spline') .* dz2;

