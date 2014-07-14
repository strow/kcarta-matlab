%
% NAME
%
%   contjaccalc -- continuum + jac calculation from kcarta tabulated values
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

function [absc,jacTG,jacQG] = contjaccalc(prof, freq, copt, iDoJac,...
                                 i1, i2, tw1, tw2, jtw1, jtw2)

% physcial constants
kAvog = 6.022045e26;
kPlanck2=1.4387863;

cvers = copt.cvers;
cdir  = copt.cdir;
cswt  = copt.cswt;  %% self component weight
cfwt  = copt.cfwt;  %% forn component weight

% build self and foreign continuum files 
sfile = [cdir, '/CKDSelf', cvers, '.bin'];
ffile = [cdir, '/CKDFor', cvers, '.bin'];

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


% initialize output
nfreq = length(freq);
nlays = length(prof.mpres);
absc = zeros(nfreq, nlays);
jacTG  = zeros(nfreq, nlays);
if length(intersect(1,iDoJac)) == 1
  jacQG  = zeros(nfreq, nlays);
else
  jacQG  = [];
  end

%---------------------------------
%  set up frequency interpolation 
%---------------------------------
df = diff(fcoarse);   % frequency step sizes
n = length(df);       % number of frequency steps
fmid = fcoarse(1:n) + df./2;                 % midpoints of step intervals
imid = interp1(fmid, 1:n, freq, 'nearest');  % indices of midpoints
ineed = unique([imid, imid(length(imid)) + 1]);
fw1 = (fcoarse(imid+1) - freq) ./ df(imid);  % weight for lower coarse point
fw2 = (freq - fcoarse(imid)) ./ df(imid);    % weight for upper coarse point
% Note: kfine = fw1 .* ks(imid) + fw2 * ks(imid+1);

% Declare work arrays
np1= n + 1;
cscoarse = zeros(1,np1); csjacT = cscoarse;
cfcoarse = zeros(1,np1); cfjacT = cfcoarse;
odcoarse = zeros(1,np1);

indh2o = find(prof.glist == 1);

%%iBlah = 0;

% loop on layers
for iL = 1 : nlays

  % scalar values for layer iL
  tL = prof.mtemp(iL);                % layer temperature
  pL = prof.mpres(iL);		      % layer pressure, atm's
  ppL = prof.gpart(iL, 1);	      % water partial pressure, atms
  qL = prof.gamnt(iL, 1);             % water gas amount

  % ------------------------------------------
  % temperature interpolate the self-continuum
  % ------------------------------------------
  % table index of greatest lower bound temp
  %i1 = max([find(ts <= tL); 1]);
  % table index of least upper bound temp
  %i2 = min([find(tL <= ts); nts]);
  % get temperature interpolation weights
  %if ts(i2) ~= ts(i1)
  %  tw2 = (tL - ts(i1)) / (ts(i2) - ts(i1));
  %  tw1 = 1 - tw2;
  %  jtw1 = -1/(ts(i2) - ts(i1)); jtw2 = +1/(ts(i2) - ts(i1));
  %else
  %  tw2 = 1;
  %  tw1 = 0;
  %  jtw1 = -1/(ts(i1+1) - ts(i1)); jtw2 = +1/(ts(i1+1) - ts(i1));
  %end
  cscoarse(ineed) = ( (tw1(iL).*ks(i1(iL),ineed)) + ...
                      (tw2(iL).*ks(i2(iL),ineed)) ).*cswt;
  csjacT(ineed)   = ( (jtw1(iL).*ks(i1(iL),ineed)) + ...
                      (jtw2(iL).*ks(i2(iL),ineed)) ).*cswt;

  % ---------------------------------
  % interpolate the foreign continuum
  % ---------------------------------

  cfcoarse(ineed) = kf(1,ineed)*cfwt;
  cfjacT(ineed) = 0;

  % -----------------------------------
  % combine self and foreign components  
  % -----------------------------------

  a1 = qL * kAvog * 296.0 / tL;	      % scalar multiplier
  a2 = kPlanck2 / (2 * tL);	      % scalar multiplier

  odcoarse(ineed) = (cscoarse(ineed).*ppL + cfcoarse(ineed).*(pL - ppL)) ...
     .* fcoarse(ineed) .* tanh(a2.*fcoarse(ineed)) .* a1;

  % Interpolate from coarse to output freqs
  absc(:, iL) = (odcoarse(imid).*fw1 + odcoarse(imid+1).*fw2); %

  blah1 = zeros(size(odcoarse)); blah2 = blah1; blah3 = blah1;
  blah1(ineed) = csjacT(ineed) * ppL + cfjacT(ineed) * (pL - ppL);
  blah1(ineed) = (a1 * (blah1(ineed))) .* fcoarse(ineed) .* tanh(a2 .* fcoarse(ineed));
  blah2(ineed) = (cscoarse(ineed) * ppL + cfcoarse(ineed) * (pL - ppL)) ...
              .* fcoarse(ineed) .* tanh(a2 .* fcoarse(ineed));
  blah2(ineed) = blah2(ineed)* (-a1/tL);
  blah3(ineed) = a1 * (cscoarse(ineed) * ppL + cfcoarse(ineed) * (pL - ppL)) .* fcoarse(ineed);
  bx = tanh(a2 * fcoarse(ineed));
  blah3(ineed) = blah3(ineed).*(1 - bx.*bx) .* fcoarse(ineed) *(-a2/tL);
  gah  = blah1 + blah2 + blah3;
  jacTG(:,iL) = (gah(imid).*fw1 + gah(imid+1).*fw2); %

  if length(intersect(1,iDoJac)) == 1
    a1Q = kAvog * 296.0 / tL;	      % scalar multiplier
    blah1 = zeros(size(odcoarse)); blah2 = blah1; 
    blah1(ineed) = (2*a1Q * (cscoarse(ineed) * ppL) .* fcoarse(ineed) .* tanh(a2 .* fcoarse(ineed)));
    blah2(ineed) = (  a1Q * (cfcoarse(ineed) * (pL - ppL)) .* fcoarse(ineed) .* tanh(a2 * fcoarse(ineed)));
    gah  = blah1 + blah2;
    jacQG(:,iL) = (gah(imid).*fw1 + gah(imid+1).*fw2); %
  end

end % loop on layers

%if iBlah == 0
%  save blah0 absc jacT
%elseif iBlah == 1
%   save blah1 absc jacT
%   end
