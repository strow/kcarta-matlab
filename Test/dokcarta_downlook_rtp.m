function [rad,jacsOut] = dokcarta_downlook_rtp(h,ha,p,pa,iCurrentProf,opt);

%iCurrentProf = 1;

jacsOut = [];

global iDebug
iDebug = +0;      

% Select kCompressed version of HITRAN

% Start/stop wavenumbers
fA = 605;  fB = 2830; 

% Upwelling radiation
iDownLook = +1;
% Only option, run SARTA NLTE model
opt.iNLTE = -1;   % Do nlte

% iDoJac tells controls the jacobians gasids (-1 for none)
% iDoJac = [1 2]; % WV (includes continuum) and CO2
% iDoJac = [2];   % CO2, etc
%iDoJac = -1;     % Don't do Jacobians
iDoJac = -1;     % Don't do Jacobians

% iJacobOutput controls the output jacobians units
iJacobOutput = +1;  % 1 == dBT/dT, 2? == dBT/dq*q??

for ip = iCurrentProf
%   fprintf(1,'processing profile %5i \n',ip);
   [nlays,p,rFracBot] = initialize_kcmix(p,iDownLook,opt);
% add params for solar on/off and backgnd thermal on/off
   if ( p.solzen >= 0 & p.solzen < 90)
      opt.rsolar = true;  %%sun on
   else
      opt.rsolar = false;
   end
   opt.rtherm = 2;   %% 0,1,2 = none/simple/accurate background thermal
   aux_struct = auxiliary_set(fA,fB,nlays,rFracBot,opt.CKD,opt.cswt,opt.cfwt,opt.refp);
   if iDoJac > 0
      [rad,jacsOut] = downlook_jac(h,p,aux_struct,opt,iDoJac,iJacobOutput);
   else
      [rad] = downlook_nojac(h,p,aux_struct,opt);
   end
end

% % add params for solar on/off and backgnd thermal on/off
% ropt = ropt0;
% if prof.solzen < 90
%   ropt.rsolar = +1;  %%sun on
% else
%   ropt.rsolar = -1;
% end
% 
% ropt.rtherm = 2;   %% 0,1,2 = none/simple/accurate background thermal
% 
