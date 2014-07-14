%
% NAME
%
%   kcrad -- radiative transfer from compact coefficients
%
% SYNOPSIS
%
%   [rad, freq] = kcrad(fin, kopt)
%
% INPUTS
%
%   fin    - RTP input profile file
%   kopt  - optional additional parameters
% 
% OUTPUTS
%
%   rad    - n by k array of calculated radiances
%   freq   - n-vector of radiance frequencies
% 
% DESCRIPTION
%
%   kcrad calculates radiances over an arbitrary requested frequency 
%   interval, at the frequency spacing of the underlying coefficient
%   tabulation.  Most parameters for this calculation are taken from
%   the input profile.
%
%   The requested frequency interval is taken from vcmin and vcmax 
%   in the RTP header, and can be overridden by setting these values 
%   in ktops.  The frequency interval returned will be the smallest 
%   set of chunk intervals spanning the requested frequencies.
%
% BUGS
%
%   probably plenty, this is just an "alpha" release
%
% AUTHOR
%
%   H. Motteler, 
%   20 Apr 02

function  [rad, freq] = kcrad(fin, kopt)

% read the specified profile
[head, hattr, prof, pattr] = rtpread2(fin);

% kcmix defaults from RTP header fields
vcmin = head.vcmin;		       % min requested frequency
vcmax = head.vcmax;		       % max requested frequency
glist = head.glist;		       % consitituent list

% other kcmix defaults
refp = 'refpro.mat';		       % matlab reference profile
kdir = '/asl/data/kcarta/v20.matlab';  % path to compressed data 

% water continuum parameter defaults
cslow = 1;	      % do a slow continuum calculation
cfast = 0;	      % do a fast continuum calculation
cvers = '24';	      % continuum default is version 2.4
cswt = 1;	      % continuum foreign-component adjustment
cfwt = 1;	      % continuum self-component adjustment

% path to tabulated continuum data
cdir = '/asl/data/kcarta/KCARTADATA/General/CKDieee_le';

% radiance calculation parameters
rtfnx = 'rtchunk';    % default procedure for radiance calc's
rtherm = 1;           % add reflected thermal radiances
rsolar = 1;	      % add reflected solar radiances
soldir = 'solarV2';   % directory for solar spectral data

% option to override the above defaults with kopt fields
% (other options set with kopt are passed along to rtcalc)
if nargin == 2
  optvar = fieldnames(kopt);
  for i = 1 : length(optvar)
    vname = optvar{i};
    if exist(vname, 'var')
      eval(sprintf('%s = kopt.%s;', vname, vname));
    end
  end
end

% copt parameters for the continuum calc procedure
copt.cdir = cdir;
copt.cvers = cvers;
copt.cswt = cswt;
copt.cfwt = cfwt;

% ropt parameters for the radiance calc procedure
ropt.rtherm = rtherm;
ropt.rsolar = rsolar;
ropt.soldir = soldir;

% sanity checks to make sure we can use this data
% (maybe add selected unit translations at some point)
for i = 1 : head.ngas
  if head.gunit(i) ~= 1
    error('constituent units must be molecules/cm^2');
  end
end

% allow for constituent subsets from kopt
glist = intersect(glist, head.glist);
gind = interp1(head.glist, 1:head.ngas, glist, 'nearest');
ngas = length(gind);

% get the list of requested chunks
chunklist = clist(vcmin, vcmax);
nchunks = length(chunklist);

% get the number of profiles
npro = length(prof);

% initialize the output arrays
rad  = zeros(nchunks*1e4, npro);
freq = zeros(nchunks*1e4, 1);

% loop on profiles
for ip = 1 : npro;

  % profile layer and level indices
  ilay = 1:prof(ip).nlevs-1;  % layer indices
  ilev = 1:prof(ip).nlevs;    % level indices

  % check that layer boundaries are close to the supplied
  % surface and observer pressures; warn if they are not
  n = prof.nlevs;
  surfind = interp1(prof.plevs(1:n), 1:n, prof.spres, 'nearest', 'extrap');
  if  abs((prof.spres - prof.plevs(surfind)) / prof.spres) > .01
    fprintf(1, ...
      'kcrad(): warning -- profile %d, psurf %g does not match level %g\n', ...
       ip, prof.spres, prof.plevs(surfind));
  end
  obsind = interp1(prof.plevs(1:n), 1:n, prof.pobs, 'nearest', 'extrap');
  if  abs((prof.plevs(obsind) - prof.pobs) / prof.plevs(obsind)) > .01
    fprintf(1, ...
      'kcrad(): warning -- profile %d, pobs %g does not match level %g\n', ...
       ip, prof.pobs, prof.plevs(obsind));
  end

  % build a kcmix profile structure 
  ptmp.glist = glist;
  ptmp.mpres = prof(ip).plays(ilay) / 1013.25;  % convert mb to atms
  ptmp.mtemp = prof(ip).ptemp(ilay);

  % convert profile molecules/cm^2 to kmoles/cm^2
  kAvog = 6.022045e26;
  ptmp.gamnt = prof(ip).gamnt(ilay, gind) ./ kAvog;

  % calculate constituent partial pressures
  palts = prof(ip).palts;
  [m,n] = size(ptmp.gamnt);
  ptmp.gpart = zeros(m,n);

  C1 = 1.2027e-12 * 1e6 * 1013.25;
  C2 = prof.ptemp(ilay) ./ (abs(diff(palts(ilev))) .* C1);
  for ig = 1 : ngas
    ptmp.gpart(:, ig) =  ptmp.gamnt(:, ig) .* C2;
  end

  % loop on chunks
  for ic = 1 : nchunks

    % chunk starting frequency
    vchunk = chunklist(ic);

    % calculate the mixed absorptions
    [absc, ftmp] = kcmix2(ptmp, vchunk, kdir, refp);

    % option for slow continuum calculation
    if cslow
      atmp = contcalc(ptmp, ftmp, copt);
      absc = absc + atmp;
    end

    % do the radiance calculation 
    rtmp = rtchunk(prof(ip), absc, ftmp, ropt);
    % rtmp = eval(sprintf('%s(prof(ip), absc, ftmp, ropt), rtfnx));

    % save the results for this chunk
    cind = (1:1e4) + (ic-1)*1e4;
    rad(cind, ip) = rtmp;
    freq(cind) = ftmp;

  end % loop on chunks

end % loop on profiles

