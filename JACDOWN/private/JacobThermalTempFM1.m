% this subroutine does the hard part of the THERMAL Jacobians wrt temperature
function raResultsTh = JacobTHERMALTempFM1(raFreq,raaRad,raaRadDT,iLay,...
            raUseEmissivity,raTemp,raaLay2Sp,...
            raaLay2Gnd,raaGeneralTh,raaOneMinusTauTh)

[aa,iNumLayer] = size(raaOneMinusTauTh);

iM1 = iLay;

kThermalAngle = 53.3;
rTempTh=cos(kThermalAngle*pi/180.0);

% read the appropriate layer from general results
raResultsTh = raaGeneralTh(:,iLay);

% we have already set the constant factor we have to multiply results with
raResultsTh = MinusOne(raTemp,raResultsTh);

% this is the part where we include the effect of the radiating layer
if ((iLay > 1) & (iLay <= iNumLayer))
  iJ1 = iLay;
  iJm1 = iJ1-1;
  raEmittance = raaOneMinusTauTh(:,iJ1);
  raEmittance = raTemp.*raaRad(:,iJ1).*raaLay2Gnd(:,iJ1)+...
                raEmittance/rTempTh.*raaRadDT(:,iJ1).*raaLay2Gnd(:,iJm1);
  raResultsTh = raResultsTh + raEmittance;
elseif (iLay == 1)
  % do the bottommost layer correctly
  iJ1 = iLay;
  raEmittance = raaOneMinusTauTh(:,iJ1);
  raEmittance = raTemp.*raaRad(:,iJ1).*raaLay2Gnd(:,iJ1)+...
                raEmittance/rTempTh.*raaRadDT(:,iJ1);
  raResultsTh = raResultsTh + raEmittance;
  end

% now multiply results by the tau(layer_to_space)
% include a diffusivity factor of 0.5 
% thus (1-ems)/pi * (2pi) *(0.5) === (1-ems)
raW = (1.0-raUseEmissivity)/rTempTh;
raResultsTh = raResultsTh.*raW.*raaLay2Sp(:,1);
