function [i1,i2,tw1,tw2,jtw1,jtw2] = continuum_temp_interp_weights(prof, freq, copt);

%% determine temp interp weights for each continuum chunk

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
%   weights for interpolation

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
[ks, junk, ts] = contread(sfile);
[kf, fcoarse, tf] = contread(ffile);
if (length(junk) ~= length(fcoarse))
   sfile
   ffile
   error('Mismatched length of self and foreign continuum files');
end
if (abs(fcoarse-junk) > 0.01)
   sfile
   ffile
   error('Mismatched frequency points in self and foreign continuum files');
end
nts = length(ts);

nfreq = length(freq);
nlays = length(prof.mpres);

%-------------------------------
% set up frequency interpolation
%-------------------------------
df = diff(fcoarse);   % frequency step sizes
n = length(df);       % number of frequency steps
fmid = fcoarse(1:n) + df./2;                 % midpoints of step intervals
imid = interp1(fmid, 1:n, freq, 'nearest');  % indices of midpoints
ineed = unique([imid, imid(length(imid)) + 1]);
fw1 = (fcoarse(imid+1) - freq) ./ df(imid);  % weight for lower coarse point
fw2 = (freq - fcoarse(imid)) ./ df(imid);    % weight for upper coarse point
% Note: kfine = fw1 .* ks(imid) + fw2 * ks(imid+1);

indh2o = find(prof.glist == 1);

% loop on layers
for iL = 1 : nlays

  % Current layer mean temperature {Kelvin}
  tL = prof.mtemp(iL);

  % ------------------------------------------
  % temperature interpolate the self-continuum
  % ------------------------------------------
  % table index of greatest lower bound temp
  i1(iL) = max([find(ts <= tL); 1]);
  % table index of least upper bound temp
  i2(iL) = min([find(tL <= ts); nts]);
  % get temperature interpolation weights
  if ts(i2(iL)) ~= ts(i1(iL))
    tw2(iL) = (tL - ts(i1(iL))) / (ts(i2(iL)) - ts(i1(iL)));
    tw1(iL) = 1 - tw2(iL);
    jtw1(iL) = -1/(ts(i2(iL)) - ts(i1(iL))); jtw2(iL) = +1/(ts(i2(iL)) - ts(i1(iL)));
  else
    tw2(iL) = 1;
    tw1(iL) = 0;
    jtw1(iL) = -1/(ts(i1(iL)+1) - ts(i1(iL))); jtw2 = +1/(ts(i1(iL)+1) - ts(i1(iL)));
    end
  end
