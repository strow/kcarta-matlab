
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

% call contcalc to do the continuum calculation
copt.vers='51';
absc = contcalc(ptmp, freq, copt);

% number of layers
nlays = prof.nlevs - 1;

semilogy(freq, absc(:,1:10:nlays))

