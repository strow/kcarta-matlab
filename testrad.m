
% radiative transfer test
% note: no H2O continuum!

% addpath /home/motteler/ftctest

% get a point profile in matlab format
[plev, temp, gasid, gasmx, lat] = ...
       gproread('/home/motteler/asl/radtrans/klayers/Data/Pexample/myp1');

% call klayers for genln/kcarta input format 
kopt.kvers = 'gen';
pout = doklay(plev, temp, gasid, gasmx, lat, kopt);

% build kmix profile structure
prof.glist = squeeze(pout(1,1,:));
prof.mpres = pout(5, :, 1)';
prof.mtemp = pout(3, :, 1)';
prof.gamnt = squeeze(pout(2, :, :));
prof.gpart = squeeze(pout(7, :, :));

% if we only use a subset of the gasses mpres will be wrong...
% gind = 1 : length(prof.glist); % everything
gind = 1 : 31 ; % all "regular" gasses
% gind = 2; % just CO2
% gind = 1; % just H2O
prof.glist = prof.glist(gind);
prof.gamnt = prof.gamnt(:,gind);
prof.gpart = prof.gpart(:,gind);

vchunk = 605;
kpath = '/asl/data/kcarta/v20.matlab/';

% profile on 

tic
[absc, fr] = kcmix(prof, vchunk, kpath);
toc

trans = exp(-absc);
clear absc

% basic calc of radiances and brightness temps
onescol = ones(10000,1);
tic
R = planck(fr', prof.mtemp(1) * onescol);    % surface radiance
% loop on layers
for L = 1:100
  R = R .* trans(:,L) + ...
      planck(fr', prof.mtemp(L) * onescol) .* (1 - trans(:,L));
end
toc

Tb = rad2bt(fr, R/1000);

% profile report

plot(fr, Tb)

