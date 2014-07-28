function [iB] = FindDiffusivityBdry(raWaves,plev,nlevs)

%iB= WhichLevelKcMix(plev,nlevs,940.0);         %AIRS100 ==> level iB=6
iB= WhichLevelKcMix(plev,nlevs,500.0);         %AIRS100 ==> level iB=25

if ((raWaves(1) >= 605.0) & (raWaves(10000) <= 630.0)) 
  iB= WhichLevelKcMix(plev,nlevs,500.0);       %AIRS100 ==> level iB=25 
elseif ((raWaves(1) >= 705.0) & (raWaves(10000) <= 830.0)) 
  iB= WhichLevelKcMix(plev,nlevs,4.8);         %AIRS100 ==> level iB=85
elseif ((raWaves(1) >= 830.0) & (raWaves(10000) <= 1155.0)) 
  iB= WhichLevelKcMix(plev,nlevs,157.0);       %AIRS100 ==> level iB=50
elseif ((raWaves(1) >= 1155.0) & (raWaves(10000) <= 1505.0)) 
  iB= WhichLevelKcMix(plev,nlevs,415.0);       %AIRS100 ==> level iB=30
elseif ((raWaves(1) >= 1730.0) & (raWaves(10000) <= 2230.0)) 
  iB= WhichLevelKcMix(plev,nlevs,500.0);       %AIRS100 ==> level iB=25
elseif ((raWaves(1) >= 2380.0) & (raWaves(10000) <= 2830.0)) 
  iB= WhichLevelKcMix(plev,nlevs,500.0);       %AIRS100 ==> level iB=25
  end
