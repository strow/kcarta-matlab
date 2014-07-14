function [fAA,fBB,prefix,df,f0] = find_chunks(fA,fB);
%% this finds the start and stop chunks, based on fA and fB which
%% are WAVENUMBERS

[prefix,kcartachunks,df,f0] = chunksNprefixes(fA,fB);

donk = find(kcartachunks <= fA); 
if length(donk) >= 1 
  donk = donk(length(donk)); 
  fAA = kcartachunks(donk);
else
  fAA = kcartachunks(1);
end

donk = find(kcartachunks >= fB); 
if length(donk) >= 1 
  donk = donk(1); 
  fBB = kcartachunks(donk);
else
  fBB = kcartachunks(length(kcartachunks));
end

fBB = fBB-df;

if fBB < fAA
  fBB = fAA;
end