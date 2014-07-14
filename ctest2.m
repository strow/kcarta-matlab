
% calculate continuum from kcarta tabulated coeff's

% constants
kAvog = 6.022045e26;
kPlanck2=1.4387863;

% specify tabulated continuum data
% sfile = '/asl/data/kcarta/KCARTADATA/General/CKDieee_le/CKDSelf24.bin';
% ffile = '/asl/data/kcarta/KCARTADATA/General/CKDieee_le/CKDFor24.bin';
sfile = '/asl/data/kcarta/KCARTADATA/General/CKDieee_le/CKDSelf51.bin';
ffile = '/asl/data/kcarta/KCARTADATA/General/CKDieee_le/CKDFor51.bin';

% read the continuum data, ks=self, kf=foreign
[ks, fs, ts] = contread(sfile);
[kf, ff, tf] = contread(ffile);

% subplot(2,1,1)
% semilogy(fs, ks)
% subplot(2,1,2)
% semilogy(ff, kf)

% read a layers profile (from klayers) with a full constituent set
klayout = 'klayout.rtp';
[head, hattr, prof, pattr] = rtpread2(klayout);

% convert millibars to atmospheres
prof.plevs = prof.plevs / 1013.25;
prof.plays = prof.plays / 1013.25;

% the following temporary profile setup is from kcrad
glist = head.glist;
ngas = head.ngas;
gind = 1:ngas;

% use the first profile
ip = 1;

% profile layer and level indices
ilay = 1:prof(ip).nlevs-1;  % layer indices
ilev = 1:prof(ip).nlevs;    % level indices

% build a kcmix profile structure 
ptmp.glist = head.glist(1:ngas);
ptmp.mpres = prof(ip).plays(ilay);
ptmp.mtemp = prof(ip).ptemp(ilay);

% convert profile molecules/cm^2 to kmoles/cm^2
kAvog = 6.022045e26;
ptmp.gamnt = prof(ip).gamnt(ilay, gind) ./ kAvog;

% calculate partial pressures
palts = prof(ip).palts;
[m,n] = size(ptmp.gamnt);
ptmp.gpart = zeros(m,n);

C1 = 1.2027e-12 * 1e6 * 1013.25;
C2 = prof.ptemp(ilay) ./ (abs(diff(palts(ilev))) .* C1);
for ig = 1 : ngas
  ptmp.gpart(:, ig) =  ptmp.gamnt(:, ig) .* C2;
end

% set desired frequency interval
v1 = 1530;
freq = v1 + (0:9999) * .0025;

% TEMP -- test with an arbitrary frequency grid
freq = 1301 : .5 : 1600;

% just use water
gind = 1;
glist = 1;
ngas = 1;

% number of layers
nlays = prof.nlevs - 1;

% initialize output
absc = zeros(length(freq), nlays);

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
  tL = prof.ptemp(iL);

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

  % -----------------------------------
  % combine self and foreign components  
  % -----------------------------------

  % scalar values for layer iL
  tL = ptmp.mtemp(iL);                % layer temperature
  pL = ptmp.mpres(iL);		      % layer pressure, atm's
  ppL = ptmp.gpart(iL, 1);	      % water partial pressure, atms
  qL = ptmp.gamnt(iL, 1);             % water gas amount

  a1 = qL * kAvog * 296.0 / tL;	      % scalar multiplier
  a2 = kPlanck2 / (2 * tL);	      % scalar multiplier

  % save this layer's continuum
  absc(:, iL) = ...
      (a1 .* (cs .* ppL + cf .* (pL - ppL)) .* freq .* tanh(a2 .* freq))';

end % loop on layers

semilogy(freq, absc(:,1:10:nlays))

