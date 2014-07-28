% this subroutine does the weighting functions for downward looking instr 
function raResults = wgtfcndown(iLay,rSatAngle,raLayAngles,raaLay2Sp,raaAbs)

[aa,iNumLayer] = size(raaLay2Sp);

rCos = cos(rSatAngle*pi/180.0);
rCos = cos(raLayAngles(1)*pi/180.0);
 
raResults = zeros(1e4,1);
 
if (iLay > iNumLayer) | (iLay <= 0)
  [iLay iNumLayer]
  error('incorrect layer in wgtfcndown')
  end

if (iLay == iNumLayer)
  % use layer to space transmission iM+1 --> infinity == 1.0 
  iM = iLay;
  rCos = cos(raLayAngles(iM)*pi/180.0) ;
  raResults = 1.0-exp(-raaAbs(:,iM)/rCos);
elseif (iLay == 1) 
  iM1 = iLay + 1;
  iM  = iLay;
  raResults = (1.0-exp(-raaAbs(:,iM)/rCos)).*raaLay2Sp(:,iLay+1);
else
  iM1 = iLay + 1;
  iM  = iLay;
  raResults = (1.0-exp(-raaAbs(:,iM)/rCos)).*raaLay2Sp(:,iLay+1);
  end
