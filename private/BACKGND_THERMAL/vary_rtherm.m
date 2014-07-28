% set up an upwelling radiance calculation path from surface  
% to observer; for now, assume lower indices correspond to lower  
% pressures 

%% does more accurate background thermal : 
%%    acos(3/5) everywhere in the upper layers
%%    more selective at lower layers

% radiance calc along reflected thermal path
tspace = 2.7;
rthm = ttorad(freq, tspace);
preslevels = prof.plevs;

rCos = 3/5;

nlays = prof.nlevs-1;
iThermalLayer = FindDiffusivityBdry(freq,preslevels,nlevs);
iLL = surfind-1;
%fprintf(1,'thermlayer,obsind,gnd = %3i %3i %3i \n',iThermalLayer,obsind,iLL);

iN = length(freq);

sumk   = sum(absc(:,1:iLL)')';
sumkm1 = sum(absc(:,2:iLL)')';

for ii = obsind:iThermalLayer-1
  angle(ii) = rCos;
  iiM1     = ii + 1;
  cos_ii   = rCos;
  cos_iiM1 = rCos;
  Temp     = prof.ptemp(ii);
  raT      = exp(-sumk/cos_ii);
  raTm1    = exp(-sumkm1/cos_iiM1);
  raPlanck = ttorad(freq,Temp);
  raEmission = (raTm1 - raT).*raPlanck;
  rthm       = raEmission + rthm;
  sumk   = sumkm1;
  sumkm1 = sumkm1 - absc(:,iiM1);
  %fprintf(1,'a %3i   %8.6f \n',ii,Temp);
  end

for ii=iThermalLayer:iLL-1
  iiM1     = ii + 1;
  cos_ii   = ExpInt3(sumk);
  cos_iiM1 = ExpInt3(sumkm1);
  Temp     = prof.ptemp(ii);
  raT      = exp(-sumk./cos_ii);
  raTm1    = exp(-sumkm1./cos_iiM1);
  raPlanck = ttorad(freq,Temp);
  raEmission = (raTm1 - raT).*raPlanck;
  rthm       = raEmission + rthm;
  sumk   = sumkm1;
  sumkm1 = sumkm1 - absc(:,iiM1);
  %fprintf(1,'b %3i   %8.6f \n',ii,Temp);
  end

for ii=iLL:iLL
  iiM1     = ii + 1;
  cos_ii   = ExpInt3(sumk);
  cos_iiM1 = ExpInt3(0);
  Temp     = prof.ptemp(ii);
  raT      = exp(-sumk./cos_ii);
  raTm1    = exp(-sumkm1/cos_iiM1);
  raPlanck = ttorad(freq,Temp);
  raEmission = (raTm1 - raT).*raPlanck;
  rthm       = raEmission + rthm;
  %fprintf(1,'b %3i   %8.6f \n',ii,Temp);
  end
  
% get the upwards reflected component
rthm = rthm .* (1 - efine);
%plot(acos(angle)*360/2/pi); pause
