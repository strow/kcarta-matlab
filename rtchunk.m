%
% NAME
%
%   rtchunk -- single-chunk radiative transfer calculation
%
% SYNOPSIS
%
%   rad = rtchunk(prof, absc, freq, ropt)
%
% INPUTS
%
%   prof   - matlab RTP profile structure
%   absc   - 10^4 x nlay mixed absorptions from kcmix
%   freq   - 10^4 vector of associated frequencies
%   ropt   - optional additional parameters
%
% OUTPUTS
%
%   rad    - calculated radiances
% 
% DESCRIPTION
%
%   rtchunk calculates radiances at a 10^4-point "chunk" of
%   frequencies.
% 
% OPTIONS (valid ropt fields) include
%
%    rtherm  - flag to add reflected thermal radiances, default 1
%    rsolar  - flag to add reflected solar radiances,  default 1
%    soldir  - directory for solar spectral data, default 'solarV2'
%
% BUGS
%
%   this prototype version only does surface to space calculations, 
%   and assumes that low indices correspond to low pressures
%
% AUTHOR
%
%    H. Motteler, 
%    14 June 02
%

function rad = rtchunk(prof, absc, freq, ropt)

% parameters that can be changed in ropt
rtherm = 1;          % flag to add reflected thermal radiances
rsolar = 1;	     % flag to add reflected solar radiances
soldir = 'solarV2';  % directory for matlab solar spectral data

% override defaults with values passed in as ropt fields
if nargin == 4
  optvar = fieldnames(ropt);
  for i = 1 : length(optvar)
    vname = optvar{i};
    if ~exist(vname, 'var')
      warning(sprintf('unexpected option %s', vname))
    end
    eval(sprintf('%s = ropt.%s;', vname, vname));
  end
end

% make freq a column vector
freq = freq(:);

% ones column to match freq.
onescol = ones(1e4, 1);

% interpolate profile emissivities to the chunk freq grid
X = prof.efreq(1:prof.nemis);
Y = prof.emis(1:prof.nemis);
efine = interp1(X, Y, freq, 'linear', 'extrap');

% profile layer and level indices
nlevs = prof.nlevs;
ilay = 1:nlevs-1;  % layer indices
ilev = 1:nlevs;    % level indices

% get the index of the closest pressure level (i.e., the closest
% layer boundary) for surface and observer pressures 
surfind = interp1(prof.plevs(1:nlevs), 1:nlevs, prof.spres, ...
	          'nearest', 'extrap');
obsind = interp1(prof.plevs(1:nlevs), 1:nlevs, prof.pobs, ...
                  'nearest', 'extrap');

% set up an upwelling radiance calculation path from surface 
% to observer; for now, assume lower indices correspond to lower 
% pressures
ipath = (surfind - 1) : -1 : obsind;	% surface to space
spath = fliplr(ipath);			% space to surface

% initialize reflected solar and thermal terms
rsol = zeros(1e4,1);
rthm = zeros(1e4,1);

% ---------------
% reflected solar
% ---------------

if rsolar

  dstsun = 1.496E+11;              % distance from earth to sun
  radsun = 6.956E+8;		   % radius of the sun
  omega = pi * (radsun/dstsun)^2;  % solid angle of sun from earth

  % load solar spectra for our chunk, defines the variables
  % sfrq and srad, the solar radiance data for this chunk
  eval(sprintf('load %s/srad%d', soldir, freq(1)));
  rsol = srad(:);
  clear srad sfrq

  % get absorptions along solar path
  solang = 2*pi*prof.solzen/360;	     % convert to radians
  solwt = ones(1, nlevs-1) .* sec(solang);   % weights for each layer
  wtmp = ones(1e4,1) * solwt;     % weights for each layer and frequency
  solabs = sum(absc .* wtmp, 2);  % sum rows for total column absorption

  % get the upwards reflected component
  rsol = rsol .* cos(solang) .* omega .* exp(-solabs) .* (1 - efine);
end

% -----------------
% reflected thermal
% -----------------

if rtherm

  rtang = 0.9273;  % nominal thermal path angle, about 53 deg.
  rtwt = ones(1, nlevs-1) .* sec(rtang);  % weights for each layer
  wtmp = ones(1e4,1) * rtwt;     % weights for each layer and frequency
  tran = exp(-absc .* wtmp);     % transmittance for reflected thermal calc

  % radiance calc along reflected thermal path
  tspace = 2.7;
  rthm = planck(freq, tspace * onescol);  

  % loop on layers, starting from space
  for i = spath
    rthm = rthm .* tran(:,i) + ...
       planck(freq, prof.ptemp(i) * onescol) .* (1 - tran(:,i));
  end

  % get the upwards reflected component
  % rthm = rthm .* (1 - efine) ./ pi;
  rthm = rthm .* (1 - efine);
end

% ------------------
% main radiance path
% ------------------

% although we just use the scalar scanang field for now,
% the setup using the pathwt vector allows for vector of
% angle corrections at some point in the future

theta = 2*pi*prof.scanang/360;		  % convert to radians
pathwt = ones(1, nlevs-1) .* sec(theta);  % weights for each layer
wtmp = ones(1e4,1) * pathwt;   % weights for each layer and freq.
tran = exp(-absc .* wtmp);     % transmittance for main path calc

% calculate the surface radiance 
rad = planck(freq, prof.stemp * onescol) .* efine;
rad = rad + rsol + rthm;

% loop on layers, starting at the surface
for i = ipath
  rad = rad .* tran(:,i) + ...
      planck(freq, prof.ptemp(i) * onescol) .* (1 - tran(:,i));
end

