function y = instr_chans(instr,iFreqOrNoise,BT0,BTX)

% iFreqOrNoise = 1 for freq, 2 for NEdT
%    if you want to change the default AIRS noise (at BT0 = 250K, to new noise at BTX)
% inst = 'airs','cris1305','cris1371','crisHR,'crisHR'','iasi'

if nargin == 0
  instr = 'airs';
  iFreqOrNoise = 1;  %% gets freqs
  BT0 = 250.0;
  BTX = 250.0;
end

if nargin == 1
  iFreqOrNoise = 1;  %% gets freqs
  BT0 = 250.0;
  BTX = 250.0;
end

if nargin == 2
  BT0 = 250.0;
  BTX = 250.0;
end

if nargin == 3
  BTX = 250.0;
end

if iFreqOrNoise == 1
  if findstr(instr,'iasi') | findstr(instr,'IASI')
    y = 1:8461;
    y = 645 + (y-1)*0.25;
  elseif findstr(instr,'cris1317') | findstr(instr,'CRIS1317')
    fo = [(650-2*0.625):0.625:(1095+2*0.625),  ...
          (1210-2*1.25):1.25:(1750+2*1.25), ...
          (2155-2*2.5):2.5:(2550+2*2.5)]';
    load cris_chans_jan2012.mat
    y = hcris.vchan;

    %% not doing noise
    %addpath /home/sergio/MATLABCODE/CRIS_HiRes
    %[nscrisOut,wnOut] = cris_noise(1);
    %y = wnOut;
    %disp('warning : wn are sorted, istead of 1:1305 and then guard chans')

  elseif findstr(instr,'cris1305') | findstr(instr,'CRIS1305')
     %load /home/sergio/MATLABCODE/CRIS_HiRes/cris_wavenumbers.mat
    load cris_wavenumbers.mat
    y = wchx2;
  elseif findstr(instr,'crisHR') | findstr(instr,'CRISHR')
     %load /home/sergio/MATLABCODE/CRIS_HiRes/cris_wavenumbers.mat
    load cris_wavenumbers.mat
    y = hwchx2;
  elseif findstr(instr,'airs') | findstr(instr,'AIRS')
    fx = 'airs_chanlist_calib_tomp';
    dd = load(fx);
    %% everything is screwup here ie need to re-order things 
    %% from this Lockhed Martin file
    dd2 = dd(:,2); [Y,I] = sort(dd2);
    dd = dd(I,:);
    y = dd(:,3); 
  end
end

if iFreqOrNoise == 2
  if findstr(instr,'iasi') | findstr(instr,'IASI')
    y = 1:8461;
    y = 645 + (y-1)*0.25;
    nu = y;   %wavenumber
    error('iasi noise???')
  elseif findstr(instr,'cris1317') | findstr(instr,'CRIS1317')
    fo = [(650-2*0.625):0.625:(1095+2*0.625),  ...
          (1210-2*1.25):1.25:(1750+2*1.25), ...
          (2155-2*2.5):2.5:(2550+2*2.5)]';
    load cris_chans_jan2012.mat
    y1 = hcris.vchan;
    %% not doing noise
    %addpath /home/sergio/MATLABCODE/CRIS_HiRes
    %[nscrisOut,wnOut] = cris_noise(1);
    %y = nscrisOut;
    disp('warning : cris noise in NeDN (rad units!!) -- use convertNEDTtoNEDN')
  elseif findstr(instr,'cris1305') | findstr(instr,'CRIS1305')
     %addpath /home/sergio/MATLABCODE/CRIS_HiRes
     %%[nscrisOut,wnOut] = cris_noise(2);
    y = nscrisOut;
    disp('warning : cris noise in NeDN (rad units!!) -- use convertNEDTtoNEDN')
  elseif findstr(instr,'crisHR') | findstr(instr,'CRISHR')
     %addpath /home/sergio/MATLABCODE/CRIS_HiRes
     %[nscrisOut,wnOut] = cris_noise(10);
    y = nscrisOut;
    disp('warning : cris noise in NeDN (rad units!!) -- use convertNEDTtoNEDN')
  elseif findstr(instr,'airs') | findstr(instr,'AIRS')
    fx = 'airs_chanlist_calib_tomp';
    dd = load(fx);
    %% everything is screwup here ie need to re-order things 
    %% from this Lockhed Martin file
    dd2 = dd(:,2); [Y,I] = sort(dd2);
    dd = dd(I,:);
    y = dd(:,6); 
    nu = dd(:,3);   %wavenumber
  end

  if abs(BT0 - BTX) > eps
    %% oops need to convert
    %% from Eric NEDT(at Tnew) = NEDT(at Tref) * [dB(Tref)/dT/dB(Tnew)/dT]
    yold = y;
    [junk,jacA] = dBTdT(nu,BT0);
    [junk,jacB] = dBTdT(nu,BTX);
    y = yold .* (jacA./jacB);
  end
end
