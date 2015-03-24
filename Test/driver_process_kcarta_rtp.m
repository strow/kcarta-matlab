function [hout,pout,iWarning,fout,rout,wmono,dallmono] = driver_process_kcarta_rtp(hin,hain,pin,pain,profiles,iInstr)

% [hout,pout,iWarning,fout,rout] = driver_process_kcarta_rtp(hin,hain,pin,pain,[profiles],[iInstr])
%   takes in user supplied [h,ha,p,pa] structures and attributes, 
%   plus list of input profiles to subsample; then runs Matlab-kcarta
%   and outputs the results in [hout,pout] after convolving using 
%   appropriate SRFs (AIRS, IASI, CrisLoRes,CrisHiRes)
%   assumes you want complete IR spectrum (605-2830 cm-1)
%
% input
%   hin,hain,pin,pain : comes from rtpread(profile)
%   profiles          : which ones to subset and run matlab-kcarta for (-1 : default all)
%   iInstr            : which instr SRF to use
%                         +1 : AIRS (default)     
%                         +2 : IASI
%                         +3 : CrIS low
%                         +4 : CrIS hi
%
% outout
%   hout = hin
%   pout = pin, except rcalcs have been substituted IF numchans is same as hin.nchans
%   iWarning       = 0 if hin.nchan = size of fout,rout, +1 if they are different sizes
%   fout,rout      = output wavenubers and convolved rads
%   wmono,dallmono = monochromatic wavenumbers and rads
%
% S.Machado  Feb 23, 2015

%{
% testing
[h,ha,p,pa]                    = rtpread('feb2002_raw_op_airs.rad.constemiss.rtp');
[hout,pout,iWarning,fout,rout] = driver_process_kcarta_rtp(h,ha,p,pa,[1 5 49],4);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
  error('need at least 4 arguments hin,hain,pin,pain')
end
if nargin > 6
  error('need at most 6 arguments hin,hain,pin,pain and profilelist, iInst')
end

if nargin == 4
  profiles = -1;  %% do all
  iInstr = +1;    %% use AIRS
elseif nargin == 5
  iInstr = +1;    %% use AIRS
end

if profiles == -1
  profiles = 1 : length(pin.stemp);
end

%% check which profiles to be done
if max(profiles) > length(pin.stemp)
  error('max(profiles) > length(pin.stemp)')
end
if min(profiles) < 1
  error('min(profiles) < 1')
end

%% all initial tests passed, go ahead and subset profiles
if length(profiles) < length(pin.stemp)
  [hx,px] = subset_rtp(hin,pin,[],[],profiles);
else
  hx = hin;
  px = pin;
end

for iCurrentProf = 1 : length(px.stemp)
  fprintf(1,'processing %4i out of %4i profiles \n',iCurrentProf,length(px.stemp))
  [radsOut,stuff] = dokcarta_downlook_rtp(hx,hain,px,pain,iCurrentProf);

  [mmr,nnr] = size(radsOut.radAllChunks);
  [mmf,nnf] = size(radsOut.freqAllChunks);
  if (mmr*nnr ~= mmf*nnf)
    error('rads and freq sizes incompatible')
  end
  if (nnf ~= mmr)
    disp('you probably did this in parallel, resizing radiance')
    radsOut.radAllChunks = reshape(radsOut.radAllChunks,1,nnf)';                                                  
  end                                                                                                             

  monorad(iCurrentProf,:) = radsOut.radAllChunks';
end

%% now do convolutions
addpath /asl/matlib/sconv
addpath /asl/matlib/fconv
addpath /asl/packages/ccast/source      %% for inst_params
addpath /asl/packages/airs_decon/test
addpath /asl/packages/iasi_decon
%% see MATLABCODE/CRIS_HiRes/convolverT.m where I compared Scott vs Howard iasi/cris .. there were
%% channnel differences etc - Howard has put in more recent work, so using his codes


wmono     = radsOut.freqAllChunks;
dallmono  = monorad';
if iInstr == 1
  disp('AIRS convolution, all channels')
  sfile = '/asl/matlab2012/srftest/srftables_m140f_withfake_mar08.hdf';
  [rout, fout] = sconv2(dallmono, wmono, 1:2378, sfile);

elseif iInstr == 2
  disp('IASI convolution, all channels')

  [rKcIasi2, fiasi2] = kc2iasi(dallmono, wmono);

  fout = fiasi2;
  rout = rKcIasi2;
elseif iInstr == 3
  disp('CRIS LoRes convolution, all channels')
  wlaser = 773.1301;  % real value

  atype = 'hamming';
  aparg = 6;   %% for hamming, this is irrelevant
  fcris = instr_chans('cris');

  band = 'LW';   % cris band
  [inst, user] = inst_params(band, wlaser);
  [rad1, frq1] = kc2cris(user, dallmono, wmono);

  band = 'MW';   % cris band
  [inst, user] = inst_params(band, wlaser);
  [rad2, frq2] = kc2cris(user, dallmono, wmono);

  band = 'SW';   % cris band
  [inst, user] = inst_params(band, wlaser);
  [rad3, frq3] = kc2cris(user, dallmono, wmono);

  wchx2 = [frq1; frq2; frq3];
  rchx2 = [rad1; rad2; rad3];
  rKcCris2 = interp1(wchx2,rchx2,fcris);

  fout = fcris;
  rout = rKcCris2;
elseif iInstr == 4
  disp('CRIS HiRes convolution, all channels')
  wlaser = 773.1301;  % real value

  opt = struct;
  opt.resmode = 'hires2';

  band = 'LW';   % cris band
  [inst, user] = inst_params(band, wlaser);
  [hrad1, hfrq1] = kc2cris(user, dallmono, wmono);

  band = 'MW';   % cris band
  [inst, user] = inst_params(band, wlaser,opt);
  [hrad2, hfrq2] = kc2cris(user, dallmono, wmono);

  band = 'SW';   % cris band
  [inst, user] = inst_params(band, wlaser,opt);
  [hrad3, hfrq3] = kc2cris(user, dallmono, wmono);

  hwchx2H = [hfrq1; hfrq2; hfrq3];
  hrchx2H = [hrad1; hrad2; hrad3];
 
  fout = hwchx2H;
  rout = hrchx2H;
end

iWarning = 0;
hout = hx;
pout = px;
[mm,nn] = size(fout);

if hout.nchan ~= length(fout)
  disp('Warning : h.nchan = different size than final convolved rads')
  iWarning = 1;
end

if iWarning == 0
   %% can happily substitue in rout
  if hout.pfields == 3
    hout.pfields = 7;
  end
  pout.rcalc = rout;
end
