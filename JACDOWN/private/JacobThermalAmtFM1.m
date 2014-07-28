% this subroutine does the hard part of backgnd thermal Jacobians wrt amt
function raResultsTh = JacobTHERMALAmtFM1(raFreq,raaRad,...
            iLay,raUseEmissivity,raTemp,raaLay2Sp,...
            raaLay2Gnd,raaGeneralTh,raaOneMinusTauTh)

[aa,iNumLayer] = size(raaOneMinusTauTh);

iM1 = iLay;

% fix the thermal angle weight factor
kThermalAngle = 53.3;
rTempTh=cos(kThermalAngle*pi/180.0);

% read the appropriate layer from general results
raResultsTh = raaGeneralTh(:,iLay);

raResultsTh = MinusOne(raTemp,raResultsTh);

% this is the part where we include the effect of the radiating layer
if ((iLay > 1) & (iLay <= iNumLayer))
  iJ1 = iLay;
  raEmittance = raTemp.*raaRad(:,iJ1).*raaLay2Gnd(:,iJ1);
  raResultsTh = raResultsTh + raEmittance;
elseif (iLay == 1) 
  %% do the bottommost layer correctly
  iJ1 = iLay;
  raEmittance = raTemp.*raaRad(:,iJ1).*raaLay2Gnd(:,iJ1);
  raResultsTh = raResultsTh + raEmittance;
  end

% now multiply results by the tau(layer_to_space)
% include a diffusivity factor of 0.5 and a factor of 2pi (azimuth integ)
% thus (1-ems)/pi * (2pi) *(0.5) === (1-ems)
raXYZ = (1.0-raUseEmissivity)/rTempTh;
raResultsTh = raResultsTh.*raXYZ.*raaLay2Sp(:,1);
