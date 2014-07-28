%% this does the surf emis jacobian
function ejac = surface_emis_jacobian(raFreq,stemp,efine,raThermal,raaLay2Sp);

raSurface = ttorad(raFreq,stemp);
ejac = raaLay2Sp(:,1) .* (raSurface - raThermal/pi);
