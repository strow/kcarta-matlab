function [iB] = WhichLevelKcMix(plev,nlevs,p)
%this is to find at which pressure level boundary a pressure "p" lies at

iB = nlevs;
if (plev(1) > plev(iB))
  plev = flipud(plev);
  end

while ((p <= plev(iB)) & (iB >= 1))
  iB = iB - 1;
  end
