function [fout,rout] = mono_convolve_instr(wmono,dallmono,iInstr)

% [fout,rout] = mono_convolve_instr(wmono,dallmono,iInstr)
%   takes in user supplied wmono,dallmono (monochromatic) and outputs the results in 
%   [fout,rout] after convolving using 
%   appropriate SRFs (AIRS, IASI, CrisLoRes,CrisHiRes)
%   assumes you want complete IR spectrum (605-2830 cm-1)
%
% input
%   wmono,dallmono    : monochromatic wavenumber, rad
%   iInstr            : which instr SRF to use
%                         +1 : AIRS (default)     
%                         +2 : IASI
%                         +3 : CrIS low
%                         +4 : CrIS hi
%
% outout
%   fout,rout      = output wavenubers and convolved rads
%
% S.Machado  Feb 23, 2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
  error('need at least 2 arguments monochromatic (wmono,dallmono)')
end
if nargin > 3
  error('need at most 3 arguments (wmono,dallmono) , iInst')
end

if nargin == 2
  iInstr = +1;    %% use AIRS
end

%% now do convolutions
addpath /asl/matlib/sconv
addpath /asl/matlib/fconv
addpath /asl/packages/ccast/source      %% for inst_params
addpath /asl/packages/airs_decon/test
addpath /asl/packages/iasi_decon
%% see MATLABCODE/CRIS_HiRes/convolverT.m where I compared Scott vs Howard iasi/cris .. there were
%% channnel differences etc - Howard has put in more recent work, so using his codes

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

