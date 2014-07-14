
% turn the kcarta ascii reference profile set
% into a single kcmix matlab profile structure

% location of kcarta ascii reference profiles
pdir = '/home/motteler/abscmp/old/refprof/';

refpro.glist = [];
refpro.mpres = [];
refpro.mtemp = [];
refpro.gamnt = [];
refpro.gpart = [];

% loop on possible gas IDs
for gid = 1:72

  % see if there is a reference profile for this gas ID
  pfile = sprintf('%s/refgas%d', pdir, gid);
  if exist(pfile) == 2

    eval(sprintf('load -ascii %s', pfile));
    eval(sprintf('refgas = refgas%d;', gid));
    eval(sprintf('clear refgas%d;', gid));    

    refpro.glist = [refpro.glist; gid];  % save gas ID
    if gid == 1
      refpro.mpres = refgas(:, 2);  % pressure from gas ID 1
      refpro.mtemp = refgas(:, 4);  % temperature from gas ID 1
    end
    refpro.gamnt = [refpro.gamnt, refgas(:, 5)];  % gas amount
    refpro.gpart = [refpro.gpart, refgas(:, 3)];  % partial pressure

  end % ref prof existance test
end % gas ID loop

% convert pressures to mb
refpro.mpres = refpro.mpres * 1000;
refpro.gpart = refpro.gpart * 1000;

% add scott's layer boundaries
nseq = 1:101;
A = -1.5508E-4;
B = -5.5937E-2;
C =  7.4516;
refpro.plev = ((A*nseq .^2 + B*nseq + C) .^ (7/2))';

save refpro refpro

