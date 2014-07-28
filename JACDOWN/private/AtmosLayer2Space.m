% this subroutine computes the Layer_to_Space transmission coeffs for the
% current atmosphere
function raaLay2Space = AtmosLayer2Space(raaSumAbs,raLayAngles)

[aa,bb] = size(raaSumAbs);
angles = ones(aa,1)*raLayAngles';
raaCos = cos(angles*pi/180.0);

raaLay2Space = zeros(size(raaSumAbs));
raaLay2Space = fliplr(cumsum(fliplr(raaSumAbs),2));
%raaLay2Space = raaLay2Space - (raaSumAbs(:,bb)*ones(1,bb));
raaLay2Space = exp(-raaLay2Space./raaCos);
