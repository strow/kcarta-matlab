hitran = 'H2012';
kcdir  = '/asl/data/kcarta';

opt.CKD = '6';

opt.co2ChiFilePath = fullfile(kcdir,'chifile/');
opt.nltedir        = fullfile(kcdir,'nlte/IASI_may09_nte_7term.be.dat');
opt.soldir         = fullfile(kcdir,'solar');
opt.cdir           = fullfile(kcdir,'ckd');
% self and foreign continuum weights
opt.cswt = 1.0; opt.cfwt = 1.0;   

opt.refp     = fullfile(kcdir,['ref_profs/refprof' hitran '.mat']);
opt.kpathh2o = fullfile(kcdir,[hitran '_IR/h2o']);
opt.kpathhDo = fullfile(kcdir,[hitran '_IR/hdo']);
opt.kpathetc = fullfile(kcdir,[hitran '_IR/etc']);
opt.kpathco2 = fullfile(kcdir,'H1988_IR/co2_umbc_ppmv385');

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
