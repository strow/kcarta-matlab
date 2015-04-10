% Test profile for comparing kcarta to sarta
addpath /asl/matlib/h4tools
addpath /asl/matlib/aslutil
addpath ~/Git/airs_decon/Test
addpath ~/Git/kcarta-matlab
addpath ~/Git/kcarta-matlab/Test
addpath ~/Git/rtp_prod2/util
addpath ~/Git/ccast/source
addpath ~/Matlab/Utility
addpath ~/Git/matlib/sconv

addpath ~/Git/kcarta-matlab/private/ANGLES
addpath ~/Git/kcarta-matlab/private/BACKGND_THERMAL
addpath ~/Git/kcarta-matlab/private/READERS
addpath ~/Git/kcarta-matlab/private/JACOBIAN_AUX


iMatlab_vs_f77 = -1

% Get obs and rcalc using IASI RTA converted to CrIS
%[h,ha,p,pa]=rtpread('test_night.rtp');
[h,ha,p,pa]=rtpread('junk49.rp.rtp');
p.nlevs = double(p.nlevs);

% btobs = real(rad2bt(h.vchan,p.robs1(:,1)));
% btcal = real(rad2bt(h.vchan,p.rcalc(:,1)));

% Compute kcarta-matlab version
iprof = 1;
psub = rtp_sub_prof(p,iprof);
rkc = dokcarta_downlook_rtp(h,ha,psub,pa,iprof);
%dokcarta_downlook_rtp;
%rkc = rad;  % temporary
radkc  = reshape(rkc.radAllChunks,890000,1);
freqkc = rkc.freqAllChunks;

% Convert to CrIS ILS
opts.resmode = 'hires2';
wlaser = 773.1301;
rad = []; freq = [];
band = {'LW'; 'MW'; 'SW'};
for i=1:3
   [inst,user]=inst_params(band{i},wlaser,opts);
   [radx, freqx]=kc2cris(user,radkc,freqkc);
   rad = [rad; radx];
   freq = [freq; freqx];
end
btkc = rad2bt(freq,rad);

k = find(h.ichan <= 2211);  % Get real channels

btobs = btobs(k);
btcal = btcal(k);

% Convert kcarta to IASI
addpath ~/Git/iasi_decon

[r_iasi,f_iasi] = kc2iasi(radkc,freqkc);
btkc_iasi = rad2bt(f_iasi,r_iasi);

% Run SARTA IASI on this profile
rtpin = 'test_night.rtp';
[h,ha,p,pa] = rtpread(rtpin);
load_fiasi

SARTA='/asl/packages/sartaV108/BinV201/sarta_iasi_may09_wcon_nte';
h.nchan = 4231;
h.ichan = (1:4231)';
h.vchan = fiasi(1:4231);
rtpi = tempname;
rtpwrite(rtpi,h,ha,p,pa);
rtprad = tempname;
disp('running SARTA for IASI channels 1-4231')
eval(['! ' SARTA ' fin=' rtpi ' fout=' rtprad ' > sartastdout1.txt']);
[h, ha, p, pa] = rtpread(rtprad);
rad_pt1 = p.rcalc;
% Second half of IASI
h.nchan = 4230;
h.ichan = (4232:8461)';
h.vchan = fiasi(4232:8461);
rtpwrite(rtpi,h,ha,p,pa);
disp('running SARTA for IASI channels 4232-8461')
eval(['! ' SARTA ' fin=' rtpi ' fout=' rtprad ' > sartastdout2.txt' ]);
[h, ha, p, pa] = rtpread(rtprad);
rad_pt2 = p.rcalc;
%
r_iasi = [rad_pt1; rad_pt2];
clear rad_pt1 rad_pt2
btcal_i = rad2bt(fiasi,r_iasi);
