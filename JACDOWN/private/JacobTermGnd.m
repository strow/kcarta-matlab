% this subroutine does d/dr(tau_layer2gnd) for gas iG
% where r == gas amount q or temperature T at layer iM
% and  iL is the relevant layer we want tau_layer2space differentiated
% HENCE IF iL > iM, derivative == 0
% i.e. this does d(tau(l--> inf)/dr_m

function raTemp = JacobTermGnd(iL,iM,raaLay2Gnd)

% raaLay2Gnd is the transmission frm layer to ground
% iM has the layer that we differentiate wrt to
% iL has the radiating layer number (1..kProfLayerJac)
% raTemp has the results, apart from the multiplicative constants
%   which are corrected in MinusOne

if (iL < iM)
  raTemp = zeros(10000,1);
else
  raTemp = raaLay2Gnd(:,iL);
  end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

