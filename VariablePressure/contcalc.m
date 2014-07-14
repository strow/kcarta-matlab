%
% NAME
%
%   contcalc -- continuum calculation from kcarta tabulated values
%
% SYNOPSIS
%
%   absc = contcalc(prof, freq, copt)
%
% INPUTS
%
%   prof   - kcmix format profile data
%   freq   - desired output frequency grid
%   copt   - optional function parameters
% 
% OUTPUTS
%
%   absc   - npt by nlev arr
%   freq   - n-vector of radiance frequencies
% 
% DESCRIPTION
%
%   contcalc calculates water absorption continuum over a requested 
%   frequency interval, by interpolating from tabulated data
%
% OPTIONS (valid copt fields) include
%
%   cdir   - location of tabulated continuum data, default 
%            '/asl/data/kcarta/KCARTADATA/General/CKDieee_le'
%   cvers  - continuum version, default '24'
%   cswt   - self continuum adjustment weight, default 1
%   cfwt   - foreign continuum adjustment weight, default 1
%
% BUGS
%
%   the code is significantly slower than a calculation from compact
%   tabulated coefficients
%
% AUTHOR
%
%    H. Motteler, 
%    14 June 02
%

function absc = contcalc(prof, freq, copt)

% physcial constants
kAvog = 6.022045e26;
kPlanck2=1.4387863;

cvers = copt.cvers;
cdir  = copt.cdir;
cswt  = copt.cswt;  %% self component weight
cfwt  = copt.cfwt;  %% forn component weight

% build self and foreign continuum files 
sfile = [cdir, '/CKDSelf', cvers, '.bin'];
ffile = [cdir, '/CKDFor',  cvers, '.bin'];

% read the continuum data, ks=self, kf=foreign
[ks, fs, ts] = contread(sfile);
[kf, ff, tf] = contread(ffile);

% initialize output
nfreq = length(freq);
nlays = length(prof.mpres);
absc = zeros(nfreq, nlays);

%---------------------------------
%  set up frequency interpolation 
%---------------------------------

df = diff(fs);   % frequency step sizes
n = length(df);  % number of frequency steps
fmid = fs(1:n) + df./2;  % midpoints of step intervals
imid = interp1(fmid, 1:n, freq, 'nearest');   % indices of midpoints
fw1 = (fs(imid+1) - freq) ./ df(imid);  % weight for lower coarse point
fw2 = (freq - fs(imid)) ./ df(imid);    % weight for upper coarse point

% apply the weights as:
% kfine = fw1 .* ks(imid) + fw2 * ks(imid+1);

% loop on layers
for iL = 1 : nlays

  % this layer temp
  tL = prof.mtemp(iL);

  % ------------------------------
  % interpolate the self-continuum
  % ------------------------------
  
  % table index of greatest lower bound temp
  i1 = max(find(ts <= tL));

  % table index of least upper bound temp
  i2 = min(find(tL <= ts));

  % get temperature interpolation weights
  if ts(i2) ~= ts(i1)
    tw2 = (tL - ts(i1)) / (ts(i2) - ts(i1));
    tw1 = 1 - tw2;
  else
    tw2 = 1;
    tw1 = 0;
  end

  % interpolate in frequency at the two temperature points
  c1 = fw1 .* ks(i1,imid) + fw2 .* ks(i1,imid+1);
  c2 = fw1 .* ks(i2,imid) + fw2 .* ks(i2,imid+1);

  % check the intermediate results
  % c1x = interp1(fs, ks(i1,:), freq, 'linear');
  % c2x = interp1(fs, ks(i2,:), freq, 'linear');
  % rms(c1 - c1x) / rms(c1)

  % interpolate in temperature
  cs = tw1 .* c1 + tw2 .* c2;

  % adjust the self continuum
  cs = cs * cswt;

  % ---------------------------------
  % interpolate the foreign continuum
  % ---------------------------------

  % table index of greatest lower bound temp
  i1 = max(find(tf <= tL));

  % table index of least upper bound temp
  i2 = min(find(tL <= tf));

  % get temperature interpolation weights
  if tf(i2) ~= tf(i1)
    tw2 = (tL - tf(i1)) / (tf(i2) - tf(i1));
    tw1 = 1 - tw2;
  else
    tw2 = 1;
    tw1 = 0;
  end

  % interpolate in frequency at the two temperature points
  c1 = fw1 .* kf(i1,imid) + fw2 .* kf(i1,imid+1);
  c2 = fw1 .* kf(i2,imid) + fw2 .* kf(i2,imid+1);

  % interpolate in temperature
  cf = tw1 .* c1 + tw2 .* c2;

  % adjust the foreign continuum
  cf = cf * cfwt;

  % -----------------------------------
  % combine self and foreign components  
  % -----------------------------------

  % scalar values for layer iL
  tL = prof.mtemp(iL);                % layer temperature
  pL = prof.mpres(iL);		      % layer pressure, atm's
  ppL = prof.gpart(iL, 1);	      % water partial pressure, atms
  qL = prof.gamnt(iL, 1);             % water gas amount

  a1 = qL * kAvog * 296.0 / tL;	      % scalar multiplier
  a2 = kPlanck2 / (2 * tL);	      % scalar multiplier

  %fprintf(1,'contcalc     %3i %8.6e %8.6e %8.6f %8.6f %8.6f %8.6e \n',iL,a1,a2,tL,pL,ppL,qL)
  %fprintf(1,'contcalc     %3i %8.6e %8.6e \n',iL,cs(1),cf(1))

  % save this layer's continuum
  absc(:, iL) = ...
      (a1 .* (cs .* ppL + cf .* (pL - ppL)) .* freq .* tanh(a2 .* freq))';

end % loop on layers

