% this subroutine adds on the AIRS NLTE predictors. Note the AIRS channels
% are spaced approx 2 cm-1 apart in this region, so we need to interpolate
% to the 0.0025 cm-1 of KCARTA

% fixed it so that if the spline from AIRS 1 cm-1 to kcarta 0.025 cm-1 is ever negative, it is set to 0
% that means kcarta will overall return LTE calc at this errant channel.

function radNLTE = nlte(raFreq,satzen,raSatAngles,raSunAngles,raVT,iNumLayer,CO2TOP,nltedir)

CO2NTE = 370; %% default

if raFreq(1) > 2405 | raFreq(length(raFreq)) < 2205
  %% no NLTE
  return
end

suncos = raSunAngles(1);           %% at surface
scos1  = raSunAngles(iNumLayer);   %% at TOA
vsec1  = raSatAngles(iNumLayer);   %% at TOA

suncos = cos(suncos*pi/180.0);
scos1  = cos(scos1*pi/180.0);
vsec1  = 1/cos(vsec1*pi/180.0);

% this subroutine mimics the SARTA NLTE model
% see /asl/packages/sartaV106/Src/calnte.f

tHigh = sum(raVT(iNumLayer-4:iNumLayer))/5;

      pred(1) = 1.0;
      pred(2) = scos1;
      pred(3) = scos1*scos1;
      pred(4) = scos1*vsec1;
      pred(5) = scos1*tHigh;
      pred(6) = suncos;

fncoefn = nltedir;
ee = exist(fncoefn);
if ee == 0
  fprintf(1,'you have set nlte file = %s \n',fncoefn)
  error('file DNE');
end
ibe = strfind(fncoefn,'.be.dat');
ile = strfind(fncoefn,'.le.dat');
if length(ibe) > 0 & length(ile) > 0 
  fprintf(1,'nlte file %s : looking for be.dat or le.dat in name ...\n',fncoefn)
  error('how can the nlte file be both le and be???')
elseif length(ibe) == 0  & length(ile) == 0
  fprintf(1,'nlte file %s : looking for be.dat or le.dat in name ...\n',fncoefn)
  error('how can the nlte file be neither le and be???')
elseif length(ile) > 0 & length(ibe) == 0
  [ichan, frqchn, coefn] = rd_nte_le(fncoefn);
elseif length(ibe) > 0 & length(ile) == 0
  [ichan, frqchn, coefn] = rd_nte_be(fncoefn);
end

nchnte = length(ichan);

% !/asl/packages/sartaV106/Src/calnte.f
raDrad = coefn(:,1:6) * pred';

% adjust for co2 mixing ratio
[mm,nn] = size(coefn);
%fprintf(1,'CO2TOP,CO2NTE = %8.6f %8.6f nn = %2i \n',CO2TOP,CO2NTE,nn)
if nn == 7
  raDrad = raDrad .* (coefn(:,7)*(CO2TOP - CO2NTE) + 1.0);
end

radNLTE = interp1(frqchn,raDrad,raFreq,'linear');
oo = find(raFreq > max(frqchn) | raFreq < min(frqchn));
if length(oo) > 0
  radNLTE(oo) = 0.0;
end

oo = find(radNLTE < 0);
radNLTE(oo) = 0.0;

