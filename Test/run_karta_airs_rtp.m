% Test profile for comparing kcarta to sarta
addpath /asl/matlib/h4tools
addpath /asl/matlib/aslutil
addpath /home/sergio/MATLABCODE/kcarta-matlab/
addpath /home/sergio/MATLABCODE/kcarta-matlab/Test
addpath /home/sergio/MATLABCODE/kcarta-matlab/

% addpath /home/sergio/MATLABCODE/kcarta-matlab/rtp_prod2/util
% addpath /home/sergio/MATLABCODE/kcarta-matlab/ccast/source
% addpath ~/Matlab/Utility
% addpath /home/sergio/MATLABCODE/kcarta-matlab/matlib/sconv

addpath /home/sergio/MATLABCODE/kcarta-matlab//private/ANGLES
addpath /home/sergio/MATLABCODE/kcarta-matlab//private/BACKGND_THERMAL
addpath /home/sergio/MATLABCODE/kcarta-matlab//private/READERS
addpath /home/sergio/MATLABCODE/kcarta-matlab//private/JACOBIAN_AUX

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INITIALIZATION OF PROFILE RTP and prof number

%% more involved, do jac calcs
iprof = 21; topts.iDoJac = 1; topts.iJacobOutput = 1;
rtpfile = '/home/sergio/MATLABCODE/oem_pkg_run_sergio_AuxJacs/MakeJacskCARTA/CLEAR_JACS/latbin1_40.clr.rp.rtp';

%% baby stuff, no jacs
iprof = 1; topts = []; rtpfile = '/home/sergio/KCARTA/WORK/clear_h3a2new.op.rtp';
iprof = 1; topts = []; rtpfile = 'junk49.rp.rtp';
iprof = 1; topts = []; rtpfile = 'test_night.rtp';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN BODY OF CODE
[h,ha,p,pa]=rtpread(rtpfile);

p.nlevs = double(p.nlevs);

% btobs = real(rad2bt(h.vchan,p.robs1(:,1)));
% btcal = real(rad2bt(h.vchan,p.rcalc(:,1)));

% Compute kcarta-matlab version
psub = rtp_sub_prof(p,iprof);

if length(topts) == 0
  [rkc] = dokcarta_downlook_rtp(h,ha,psub,pa,iprof);
  disp('your output structure is "rkc" ')
else
  addpath /home/sergio/MATLABCODE/kcarta-matlab/JACDOWN
  [rkc,jacs] = dokcarta_downlook_rtp(h,ha,psub,pa,iprof,topts);
  disp('your output structures are "rkc" and "jacs" ')
end

radkc  = reshape(rkc.radAllChunks,890000,1);
freqkc = rkc.freqAllChunks;

disp('>>>>> stopping here before convolving <<<<< ')
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONVOLUTIONS

% Get obs and rcalc using IASI RTA converted to CrIS
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

%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert kcarta to IASI
addpath /home/sergio/MATLABCODE/kcarta-matlab/iasi_decon

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

%%%%%%%%%%%%%%%%%%%%%%%%%
