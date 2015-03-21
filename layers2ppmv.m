function [ppmvLAY,ppmvAVG,ppmvMAX,pavgLAY,tavgLAY,ppmv500,ppmv75] = layers2ppmv(hIN,pIN,index,gid)

%% input
%%   hIN = klayers head structure, giving hIN.ptype
%%   pIN = klayers prof structure
%%   index = which of the profiles you want ppmv computed over
%%   gid   = gasID of interest
%%
%% output
%%   ppmvLAY = ppmv for each layer
%%   ppmvAVG = avg over the layers
%%   ppmvMAX = max over the layers
%%   pavgLAY = layer pressures
%%   tavgLAY = layer temps
%%   ppmv500 = ppmv at 500 mb
%%   ppmv75  = ppmv at  75 mb

if hIN.ptype == 0
  error('need ptype = 1,2')
end

%% takes kLAYERS output, and for gasID = gid, computes an estimate of ppmv

%% ppmv = gas(i) amount/ total gas amount

R = 8.31;   %% J mol-1 K-1

T = pIN.ptemp;    %% layer temp
L = pIN.palts(1:100,:) - pIN.palts(2:101,:);   %% in meters

p = pIN.plevs;    %% levels pressure

gstr = ['gas_' num2str(gid)];
str = ['ok = isfield(pIN,''' gstr ''');'];
eval(str);
if ok == 0
  error('gasID not present in p!')
else
  str = ['qgas = pIN.gas_' num2str(gid) ';'];
  eval(str);
end

[mm,nn] = size(qgas);
ppmv = zeros(mm,length(index));

pA = p(1:mm-1,:) - p(2:mm,:);
pB = log(p(1:mm-1,:)./p(2:mm,:));
p  = pA./pB;
p = p * 100;   %% mb --> N/m2

% total_gas_amount = L*p/R TR
for ii = 1 : length(index)
  iix = index(ii);
  nlays = pIN.nlevs(iix)-1;
  Tii = T(1:nlays,iix);
  Lii = L(1:nlays,iix);
  Pii = p(1:nlays,iix);

  tavgLAY(1:nlays,ii) = Tii;
  pavgLAY(1:nlays,ii) = Pii;

  Qii = (Lii .* Pii)./(R * Tii);      %% total gas amount
  qii = qgas(1:nlays,iix)/6.023e23;    %% moles/cm2
  qii = qii * 1e4;                    %% moles/m2
  ratio = qii./(Qii+eps) * 1e6; 
  ppmvLAY(1:nlays,ii) = ratio;
  ppmvAVG(ii) = nanmean(ratio(30:50));
  ppmvMAX(ii) = nanmax(ratio);

  i500 = abs(Pii-500*100);           %% remmeber we changed mb --> N/m2 by multiplying by 100
  i500 = find(i500 == min(i500),1);
  ppmv500(ii) = ratio(i500);

  i75 = abs(Pii-75*100);           %% remmeber we changed mb --> N/m2 by multiplying by 100
  i75 = find(i75 == min(i75),1);
  ppmv75(ii) = ratio(i75);

end



