function [rad,rthm, zang,efine,rsol0] = rtchunk_Tsurf(prof, absc, freq, rplanckmod, ropt)

% NAME
%
%   rtchunk -- single-chunk radiative transfer calculation
%
% SYNOPSIS
%
%   [rad = rtchunk(prof, absc, freq, ropt)
%
% INPUTS
%
%   prof       - matlab RTP profile structure
%   absc       - 10^4 x nlay mixed absorptions from kcmix
%   rplanckmod - 10^4 x nlay planck NLTE modifiers
%   freq       - 10^4 vector of associated frequencies
%   ropt       - optional additional parameters
%
% OUTPUTS
%
%   rad       - calculated radiances at TOA                         1    x fpts
%   rthm      - thermal contribution (before multiplying with 1-e)  1    x fpts
%   tauG2S    - total gnd-2-space transmission                      1    x fpts
%   efine     - surface emissivity                                  1    x fpts
%   rsol0     - solar at gnd                                        1    x fpts
%
%   so rad should be given by
%   rad = [ttorad(f,tsurf)*ems + (1-ems)*rthm]*tauG2S + atmEmis
%
% DESCRIPTION
%
%   rtchunk calculates radiances at a 10^4-point "chunk" of
%   frequencies.
%   same as rtchunk, but also outputs rthm, atm, and corrected angles, 
%   so we can fit Tsurf
% 
% OPTIONS (valid ropt fields) include
%
%    rtherm  - flag to add reflected thermal radiances, default 1
%    rsolar  - flag to add reflected solar radiances,  default 1
%    soldir  - directory for solar spectral data, default 'solarV2'
%
% BUGS
%
%   this prototype version only does surface to space calculations, 
%   and assumes that low indices correspond to low pressures
%
% AUTHOR
%
%    H. Motteler, 
%    14 June 02
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
%% all this is commented out
%[zang]=vaconv( sva, salt, alt );
%[zang]=vaconv( sva, salt, alt ); %% effectively changes scanang (sva) into satzen (local angle at gnd)
% this code probably from Howard
[zang]=vaconv(prof.satzen,prof.zobs,prof.palts);
zang = zang(1:prof.nlevs-1);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
%% all this is commented out
% this code from Sergio, trying to fix things if eg satzen not there
% typically for AIRS rHeight = 705000  ie height should be in meters
rHeight = prof.zobs;  %% in meters
rAngleY = saconv(prof.satzen, rHeight);   %% assume satzen ok, compute SCANANG
if abs(prof.scanang) > 90 & abs(prof.satzen) < 90 & rHeight > 0
  %% eg prof.scanang = -9999 
  %%    prof.satzen  = 2.5
  %%    prof.zobs    = 705000
  rAngleY = saconv(prof.satzen, rHeight);   %% this is now SCANANG
elseif abs(prof.scanang) < 90 & abs(prof.satzen) < 90 & rHeight > 0
  %% THINGS are OK
  %% eg prof.scanang = 5.003 
  %%    prof.satzen  = 5.757
  %%    prof.zobs    = 829743
else
  fprintf(1,'scanang = %8.6f \n',prof.scanang)
  fprintf(1,'need valid satzen = %8.6f  and sat height %8.6f \n',prof.satzen,prof.zobs)
  error('cannot figure out scanang')
end
zang = vaconv(rAngleY,prof.zobs,prof.palts);  %% these are the zenith view angles at layers
zang = zang(1:prof.nlevs-1);
%fprintf(1,'scanang = %8.6f satzen = %8.6f sat height %8.6f \n',rAngleY,prof.satzen,prof.zobs)
%%%% this is not needed
%zangTOA = vaconv(rAngleY,prof.zobs,prof.zobs);   %% this is zenith view angle at satellite
%                                                 %% and should be same as scanang!!!!
%fprintf(1,'satzen angle zangTOA = vaconv(rAngleY,prof.zobs,prof.zobs) = %8.6f\n',zangTOA)
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% this code from Scott
zlay = 0.5*(prof.palts(1:end-1) + prof.palts(2:end));
zang = sunang_conv(prof.satzen,zlay);                     %% scott

rtherm  = ropt.rtherm;
rsolar  = ropt.rsolar;	
soldir  = ropt.soldir;
nltedir = ropt.nltedir;

% make freq a column vector
freq = freq(:);

% ones column to match freq.
onescol = ones(length(freq), 1);

% interpolate profile emissivities to the chunk freq grid
efine = interp_emiss_rho(freq,prof.efreq,prof.emis,prof.nemis);

% profile layer and level indices
nlevs = prof.nlevs;
nlays = nlevs - 1;
ilay = 1:nlevs-1;  % layer indices
ilev = 1:nlevs;    % level indices

% get the index of the closest pressure level (i.e., the closest
% layer boundary) for surface and observer pressures 
surfind = interp1(double(prof.plevs(1:nlevs)), double(1:nlevs), double(prof.spres), ...
	          'nearest', 'extrap');
obsind = interp1(double(prof.plevs(1:nlevs)), double(1:nlevs), double(prof.pobs), ...
                  'nearest', 'extrap');
surfind = find(prof.plevs > prof.spres);
surfind = surfind(1);

% set up an upwelling radiance calculation path from surface 
% to observer; for now, assume lower indices correspond to lower 
% pressures
ipath = (surfind - 1) : -1 : obsind;	% surface to space
spath = fliplr(ipath);			% space to surface

% initialize reflected solar and thermal terms
clear rsol rthrm tauG2S
rsol    = zeros(length(freq),1);rsol0 = rsol;
rthm    = zeros(length(freq),1);
tauG2S  = zeros(length(freq),1);

% ---------------
% reflected solar
% ---------------
if rsolar > 0

  dstsun = 1.496E+11;              % distance from earth to sun
  radsun = 6.956E+8;		   % radius of the sun
  omega = pi * (radsun/dstsun)^2;  % solid angle of sun from earth

  % load solar spectra for our chunk, defines the variables
  % sfrq and srad, the solar radiance data for this chunk
  if freq(1) >= 605.0 & freq(1) < 2830-0.1
    eval(sprintf('load %s/srad%d', soldir, freq(1)));
    rsol = srad(:)*1000;      %%% change to correct units
  else
    rsol = ttorad(freq,5800);
  end
  rsol0 = rsol * omega;
  clear srad sfrq

  %[sunang]=sunang_conv( sza, alt );
  [sunang] = sunang_conv(prof.solzen,prof.palts);

  % get absorptions along solar path
  solang = 2*pi*sunang'/360;	     % convert to radians
  secth  = sec(solang(1:nlays));
  wtmp   = ones(length(freq),1) * secth;   % weights for each layer and frequency
  solabs = sum(absc .* wtmp, 2);  % sum rows for total column absorption
  rsol0  = rsol0.*exp(-solabs);   % propagate solar down to surface, for jacs

  if prof.nrho > 1
    sunfine = interp_emiss_rho(freq,prof.rfreq,prof.rho,prof.nrho);
  else
    sunfine = (1-efine);
  end
  % get the upwards reflected component
  rsol = rsol .* cos(solang(nlays)) .* omega .* exp(-solabs) .* sunfine;
end

% ---------------------------------------
% simple reflected thermal at arccos(3/5)
% ---------------------------------------

if rtherm == 1
  simple_rtherm;
elseif rtherm == 2
  vary_rtherm;
else
  rthm = zeros(size(freq));
end

% ------------------
% main radiance path
% ------------------

% although we just use the scalar satzen field for now,
% the setup using the pathwt vector allows for vector of
% angle corrections at some point in the future

theta = 2*pi*zang'/360;		  % convert to radians
secth = sec(theta(1:nlays));
wtmp = ones(length(freq),1) * secth;
newabsc = absc.*wtmp;
lay2sp  = sum(newabsc'); lay2sp = exp(-lay2sp);
tran = exp(-absc .* wtmp);     % transmittance for main path calc

% calculate the surface radiance 
pplanck = ttorad(freq,prof.stemp);

rad = pplanck .* efine;
rad = rad + rsol + rthm;

% figure(2); plot(freq,rsol,'b',freq,rthm,'r',freq,rad/100,'k'); hold on; pause(0.1)
% if freq(1) == 2405
%   figure(1); clf; plot(freq,sum(absc'));
%   keyboard
% end


iout = 1;
%allrad(:,iout) = rad;
% loop on layers, starting at the surface

if prof.solzen >= 90
  %% normal LTE during night
  for i = ipath
    pplanck = ttorad(freq,prof.ptemp(i));
    rad = rad .* tran(:,i) + pplanck .* (1 - tran(:,i));
    iout = iout + 1;
    %allrad(:,iout) = rad;
  end
elseif prof.solzen < 90
  if (freq(end) < 2205 | freq(1) >= 2405)
    %% normal LTE
    for i = ipath
      pplanck = ttorad(freq,prof.ptemp(i));
      rad = rad .* tran(:,i) + pplanck .* (1 - tran(:,i));
      iout = iout + 1;
      %allrad(:,iout) = rad;
    end
  elseif (freq(1) < 2391.098 & freq(length(freq)) > 2224.888)
    if ropt.iNLTE == -1

      %% normal LTE
      for i = ipath
        pplanck = ttorad(freq,prof.ptemp(i));
        rad = rad .* tran(:,i) + pplanck .* (1 - tran(:,i));
        iout = iout + 1;
        %allrad(:,iout) = rad;
      end

      disp('  adding on NLTE SARTA')
      %% see /asl/data/sarta_database/Data_AIRS_apr08/Coef/tunmlt_wcon_nte.txt
      raVT = prof.ptemp(ipath);
      hxx.ptype = 1;
      [ppmvLAY,ppmvAVG,ppmvMAX] = layers2ppmv(hxx,prof,1:length(prof.stemp),2);
      co2top = ppmvLAY(end);
      radnlte = nlte(freq,prof.satzen,zang,sunang,raVT,length(raVT),co2top,nltedir);
      rad = rad + radnlte;

    elseif ropt.iNLTE == -2
      disp('  adding on NLTE FAST kComp')
      for i = ipath
        pplanck = ttorad(freq,prof.ptemp(i));
        rad = rad .* tran(:,i) + pplanck .* (1 - tran(:,i)) .* rplanckmod(:,i);
        iout = iout + 1;
        %allrad(:,iout) = rad;
      end
    end
  end
end

%% rthm = rthm./(1-efine);   %%% output total component, no modulation with 1-e
rthm = rthm;                 %%% output total component, no modulation with 1-e
