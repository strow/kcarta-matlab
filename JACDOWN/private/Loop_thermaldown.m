% the easy part of backgnd thermal Jacobians is done in Loop_lookdown([])
% this subroutine does the hard part of backgnd thermal Jacobians
function [raaOneMinusTauTh,raaGeneralTh] = Loop_thermaldown(...
                               rSatAngle,raLayAngles,...
                               raaSumAbsCoeffs,raFreq,raaRad,raaLay2Gnd);

[aa,iNumLayer] = size(raaSumAbsCoeffs);

% since we are using acos(3/5) approx here, instead of the more accurate 
% diffusive approximation, might as well also approximate these contributions,
% so as to speed up the code
iB = iNumLayer;

kThermalAngle = 53.3;    %% acos(2/3) diffuse approx
rTh=cos(kThermalAngle*pi/180.0);

raaOneMinusTauTh = 1.0-exp(-raaSumAbsCoeffs/rTh);

raaGeneralTh = zeros(size(raaOneMinusTauTh));

% this is "hard" part of the thermal, where we loop over lower layers 
% that contribute
%*** if we want to correctly loop over all 100 layers, set iB = iNumLayer *****

for iLyr = iNumLayer-1 : -1 : 1
  iJ = iLyr + 1;
  raTemp = JacobTermGnd(iJ-1,iLyr,raaLay2Gnd);
  raaGeneralTh(:,iLyr) = raaGeneralTh(:,iLyr+1) + ...
                         raaOneMinusTauTh(:,iJ).*raaRad(:,iJ).*raTemp;
  end

