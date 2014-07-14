%
% NAME
%
%   rtchunk -- single-chunk radiative transfer calculation
%
% SYNOPSIS
%
%   [rad = rtchunk(prof, absc, freq, ropt)
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

function [radall,rad,zang,rsol] = rtchunk(prof, absc, freq, ropt)

%[zang]=vaconv( sva, salt, alt );
[zang]=vaconv(prof.satzen,0,prof.palts);  %% zobs at gnd
zang = zang(1:prof.nlevs-1);

rtherm  = ropt.rtherm;
rsolar  = ropt.rsolar;	
soldir  = ropt.soldir;
nltedir = ropt.nltedir;

% make freq a column vector
freq = freq(:);

% ones column to match freq.
onescol = ones(length(freq), 1);

% interpolate profile emissivities to the chunk freq grid
efine = interp_emiss_rho(freq,prof.efreq,prof.emis,prof.nemis);

% profile layer and level indices
nlevs = prof.nlevs;
nlays = nlevs - 1;
ilay = 1:nlevs-1;  % layer indices
ilev = 1:nlevs;    % level indices

% get the index of the closest pressure level (i.e., the closest
% layer boundary) for surface and observer pressures 
surfind = interp1(prof.plevs(1:nlevs), 1:nlevs, prof.spres, ...
	          'nearest', 'extrap');
obsind = interp1(prof.plevs(1:nlevs), 1:nlevs, prof.spres, ...
                  'nearest', 'extrap');
surfind = find(prof.plevs > prof.spres);
surfind = surfind(1);

% set up an upwelling radiance calculation path from surface 
% to observer; for now, assume lower indices correspond to lower 
% pressures
ipath = (surfind - 1) : -1 : obsind;	% surface to space
ipath = (surfind - 1) : -1 : 1;	        % surface to space
spath = fliplr(ipath);			% space to surface

% initialize reflected solar and thermal terms
clear rsol rthrm atmEmis
rsol = zeros(length(freq),1);
rad = zeros(length(freq),1);
atmEmis = zeros(length(freq),1);

% ---------------
% solar solar 
% ---------------
if prof.solzen >= 0 & prof.solzen <= 90
  rsolar = +1
  end

if rsolar > 0

  dstsun = 1.496E+11;              % distance from earth to sun
  radsun = 6.956E+8;		   % radius of the sun
  omega = pi * (radsun/dstsun)^2;  % solid angle of sun from earth

  % load solar spectra for our chunk, defines the variables
  % sfrq and srad, the solar radiance data for this chunk
  eval(sprintf('load %s/srad%d', soldir, freq(1)));
  rsol = srad(:)*1000;      %%%change to correct units
  clear srad sfrq

  %[sunang]=sunang_conv( sza, alt );
  [sunang]=sunang_conv(prof.solzen,prof.palts);

  % get absorptions along solar path
  solang = 2*pi*sunang'/360;	     % convert to radians
  secth = sec(solang(1:nlays));
  wtmp = ones(length(freq),1) * secth;   % weights for each layer and frequency
  solabs = sum(absc .* wtmp, 2);  % sum rows for total column absorption

  rsol = rsol .* cos(solang(nlays)) .* omega .* exp(-solabs);
end

% ------------------
% main radiance path
% ------------------

% although we just use the scalar satzen field for now,
% the setup using the pathwt vector allows for vector of
% angle corrections at some point in the future

theta = 2*pi*zang'/360;		  % convert to radians
secth = sec(theta(1:nlays));
wtmp = ones(length(freq),1) * secth;
newabsc = absc.*wtmp;
lay2sp  = sum(newabsc'); lay2sp = exp(-lay2sp);
tran = exp(-absc .* wtmp);     % transmittance for main path calc

  rtwt = ones(1, nlevs-1) .* secth;  % weights for each layer
  wtmp = ones(1e4,1) * rtwt;     % weights for each layer and frequency
  tran = exp(-absc .* wtmp);     % transmittance for reflected thermal calc

  % radiance calc along reflected thermal path
  tspace = 2.7;
  rad = ttorad(freq, tspace);
  radall = rad;

  clf
  % loop on layers, starting from space
  for i = spath
    pplanck = ttorad(freq,prof.ptemp(i));
    %fprintf(1,'  %3i  %8.6f %8.6f \n',i,prof.ptemp(i),tran(1,i))
    rad = rad .* tran(:,i) + pplanck.* (1 - tran(:,i));
    radall = [radall; rad];
  end

if rsolar > 0
  rad = rad + rsol;
  end
