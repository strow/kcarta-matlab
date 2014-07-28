% this subroutine multiplies the array by -1.0*constant where constant
% depends on whether we are doing d/dT or d/dq
function raResultsX = MinusOne(raTorQ,raResults)

raResultsX = -raResults .* raTorQ;

