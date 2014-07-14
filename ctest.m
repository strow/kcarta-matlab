
% function absc = contin(prof, freq, vers);

sfile = '/asl/data/kcarta/KCARTADATA/General/CKDieee_le/CKDSelf52.bin';
ffile = '/asl/data/kcarta/KCARTADATA/General/CKDieee_le/CKDFor52.bin';

[ks, fs, ts] = contread(sfile);
[kf, ff, tf] = contread(ffile);

klayout = 'klayout.rtp';
[head, hattr, prof, pattr] = rtpread2(klayout);

% set desired frequency interval
v1 = 630;
freq = v1 + (0:9999) * .0025;

% 
% figure(1) 
% semilogy(fs, ks)

% figure(2) 
% semilogy(ff, kf)

% test loop on layers
absc = zeros(1e4, prof.nlevs);

nlays = prof.nlevs - 1;
ptemp = prof.ptemp(1:nlays);

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
  c1 = interp1(fs, ks(i1,:), freq, 'linear');
  c2 = interp1(fs, ks(i2,:), freq, 'linear');

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
  c1 = interp1(ff, kf(i1,:), freq, 'linear');
  c2 = interp1(ff, kf(i2,:), freq, 'linear');

  % interpolate in temperature
  cf = tw1 .* c1 + tw2 .* c2;

end

toc

