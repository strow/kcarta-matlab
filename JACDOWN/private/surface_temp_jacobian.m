%% this does the surf temp jacobian
function sjac = surface_temp_jacobian(raFreq,stemp,efine,raaLay2Sp);

% these are the first and second Planck constants
r1 = 1.1911E-5;
r2 = 1.4387863;

raRad = ttorad(raFreq,stemp);
r4 = r2*raFreq/stemp;
r5 = exp(r4);
raRadDT = raRad.*r4'.*r5'./(r5'-1.0)/stemp;

sjac = raRadDT.*efine.*raaLay2Sp(:,1);
