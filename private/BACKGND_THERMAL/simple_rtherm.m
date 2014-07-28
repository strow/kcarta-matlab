%% does simple background thermal, at acos(3/5) everywhere

rtang = 0.9273;  % nominal thermal path angle, about 53 deg = acos(3/5)
rtwt = ones(1, nlevs-1) .* sec(rtang);  % weights for each layer
wtmp = ones(1e4,1) * rtwt;     % weights for each layer and frequency
tran = exp(-absc .* wtmp);     % transmittance for reflected thermal calc

% radiance calc along reflected thermal path
tspace = 2.7;
rthm = ttorad(freq, tspace);

clf
% loop on layers, starting from space
for i = spath
  pplanck = ttorad(freq,prof.ptemp(i));
  rthm = rthm .* tran(:,i) + pplanck.* (1 - tran(:,i));
end

% get the upwards reflected component
% rthm = rthm .* (1 - efine) ./ pi;
rthm = rthm .* (1 - efine);

