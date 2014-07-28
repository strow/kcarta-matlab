function [raaRadDT,raaOneMinusTau,raaTau,raaLay2Gnd] = ...
    DoPlanck_LookDown(prof,raFreq,zang,raaSumAbs,raVtemp,raaRad);

% this subroutine calculates the Planck radiances, and the derivatives
% for DOWNWARD looking instrument
% these are the first and second Planck constants
r1 = 1.1911E-5;
r2 = 1.4387863;

rCos = cos(prof.satzen*pi/180.0);

raVT1 = raVtemp;
[aa,bb] = size(raaSumAbs);

%for iL = 1 : bb
  %%raaRad(:,iL) = ttorad(raFreq,raVT1(iL));
  %r4 = r2*raFreq/raVT1(iL);
  %r5 = exp(r4);
  %raaRadDT(:,iL) = raaRad(:,iL).*r4'.*r5'./(r5'-1.0)/raVT1(iL);
  %end

r4 = r2 * raFreq' * (1./raVT1');
r5 = exp(r4);
raaRadDT = raaRad .*r4 .*r5 ./(r5-1.0) ./ (ones(10000,1) * raVT1');

angles = ones(aa,1)*zang';
raaCos = cos(angles*pi/180.0);
raaTau = raaSumAbs./raaCos;
raaTau = exp(-raaTau);
raaOneMinusTau = 1 - raaTau;

%% this is for background thermal  ... use acos 3/5
angles = ones(aa,bb)*53.13;
raaCos = cos(angles*pi/180.0);
raaLay2Gnd = zeros(size(raaSumAbs));
raaLay2Gnd = cumsum(raaSumAbs,2);
raaLay2Gnd = exp(-raaLay2Gnd./raaCos);

