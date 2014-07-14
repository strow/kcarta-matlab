function [qjac,tjac,wgt] = ...
  jac_uplook(raFreq,zang,raSol0,absc,jacQG,jacTG,prof,iDoJac);

% computes jacs and weighting functions
% input
%   efreq     = 1e4 x 1          input wavenumbers
%   raSol     = 1e4 x 1          input solar radiance at gnd
%   zang   = nlays x 1           input layer angles
%   absc   = 1e4 x nlays         gas ODs
%   jacQG  = 1e4 x nlays         dK/dq for needed gas
%   jacTG  = 1e4 x nlays         dK/dT from all gases
%   prof                         structure with info such as : temp etc
%
% output
%    qjac = 1e4 x nlays      dr/dq
%    tjac = 1e4 x nlays      dr/dT
%    wgt  = 1e4 x nlays      Wgt

global iDebug

[aa,iNumLayer] = size(absc);
if iNumLayer ~= prof.nlevs-1
  error('inconsistent number of layers')
  end

if prof.plevs(1) < prof.plevs(10)
  %% pressures increasing with index ==> height decreasing with index
  %% ==> index 1 = TOA
  %% f77 kCARTA assumed index 1 = TOA, so no need to flip
  raVtemp   = (prof.ptemp(1:prof.nlevs-1));
  absc      = (absc);
  jacQG     = (jacQG);
  jacTG     = (jacTG);
  rTSurface = prof.stemp;
  zang      = (zang);
else
  %% need to flip
  raVtemp   = flipud(prof.ptemp(1:prof.nlevs-1));
  absc      = fliplr(absc);
  jx = jacQG;
  for ii = 1 : length(iDoJac)
    jox = squeeze(jx(ii,:,:));
    jox = fliplr(jox);
    jacQG(ii,:,:) = jox;
    end
  jacTG     = fliplr(jacTG);
  rTSurface = prof.stemp;
  zang      = flipud(zang);
  end

disp('initializing Jac radiances/d/dT(radiances) ...')
[raaRad,raaRadDT,raaOneMinusTau,raaTau,raaLay2Gnd] = ...
  DoPlanck_LookUp(prof,raFreq,zang,absc,raVtemp);

raaRad     = fliplr(raaRad);
raaRadDT   = fliplr(raaRadDT);
raaOneMinusTau = fliplr(raaOneMinusTau);
raaTau         = fliplr(raaTau);

disp('initializing Jacobian loops ...')
raSunAngles = vaconv(prof.solzen,0,prof.palts);
raSurface = ttorad(raFreq,prof.stemp);
raaGeneral = Loop_LookUp(prof.satzen,zang,...
                raSol0,raSunAngles,...
                raaOneMinusTau,raaTau,raaLay2Gnd,raaRad,prof);

%jacQG = fliplr(jacQG);
jx = jacQG;
for ii = 1 : length(iDoJac)
  jox = squeeze(jx(ii,:,:));
  jox = fliplr(jox);
  jacQG(ii,:,:) = jox;
  end
jacTG = fliplr(jacTG);

for ii = 1 : length(iDoJac)
  if iDebug == 1
    fprintf(1,'\n gas  d/dq : jacID%2i \n',ii)
  else
    fprintf(1,'\n gas  d/dq : ')
    end
  for iLay=1 : iNumLayer
    rWeight = 1;
    fprintf(1,'.')
    qjac(ii,:,iLay) = JacobGasAmtFM1UP(iLay,raFreq,raaRad,raaRadDT,...
                   raaOneMinusTau,raaTau,squeeze(jacQG(ii,:,:)),...
                   raaLay2Gnd,prof.satzen,zang,raaGeneral,prof.solzen);
    end
  end

if iDebug == 1
  fprintf(1,'\n temp d/dT : \n')
else
  fprintf(1,'\n temp d/dT : ')
  end
for iLay=1 : iNumLayer
  fprintf(1,'.')
  rWeight = 1.0;
  tjac(:,iLay) = JacobTempFM1UP(iLay,raFreq,raaRad,raaRadDT,...
                   raaOneMinusTau,raaTau,jacTG,...
                   raaLay2Gnd,prof.satzen,zang,raaGeneral,prof.solzen);
   end

raaLay2Gnd     = fliplr(raaLay2Gnd);  %% this has been done wierdly, so do this here!
fprintf(1,'\n wgt       : ')
for iLay=1 : iNumLayer
  fprintf(1,'.')
  rWeight = 1.0;
  wgt(:,iNumLayer-iLay+1) = wgtfcnup(iLay,prof.satzen,zang,raaLay2Gnd,absc);
  end

fprintf(1,' \n');
