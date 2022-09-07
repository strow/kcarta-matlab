hitran = 'H2016'; opt.CKD = '25'; %% 2019
hitran = 'H2012'; opt.CKD = '6';  %% 2009
hitran = 'H2008'; opt.CKD = '6';  %% 2009

kcdir  = '/asl/data/kcarta';

opt.co2ChiFilePath = fullfile(kcdir,'chifile/');
opt.nltedir        = fullfile(kcdir,'nlte/IASI_may09_nte_7term.be.dat');
opt.soldir         = fullfile(kcdir,'solar');
opt.cdir           = fullfile(kcdir,'ckd');
opt.cdir           = '/asl/data/kcarta_sergio/KCDATA/General/CKDieee_le/';
% self and foreign continuum weights
opt.cswt = 1.0; opt.cfwt = 1.0;   

if strfind(hitran,'H2008')
  %{
  [sergio@taki-usr2 Test]$ ls -lt /asl/data/kcarta//H2008_IR
  total 108
  drwxrwx--- 2 strow pi_strow  4096 Mar 24  2015 hdo
  drwxrwx--- 2 strow pi_strow  4096 Jul 15  2011 co2_hartmann
  drwxrwx--- 2 strow pi_strow 53248 Jul 15  2011 etc
  drwxrwx--- 2 strow pi_strow  4096 Jul 15  2011 h2o
  %}
  opt.refp     = fullfile(kcdir,['ref_profs/refprof' hitran '.mat']);
  opt.kpathh2o = fullfile(kcdir,[hitran '_IR/h2o']);
  opt.kpathhDo = fullfile(kcdir,[hitran '_IR/hdo']);
  opt.kpathetc = fullfile(kcdir,[hitran '_IR/etc']);
  opt.kpathco2 = fullfile(kcdir,'H1988_IR/co2_umbc_ppmv385');
elseif strfind(hitran,'H2012')
  %{
  [sergio@taki-usr2 Test]$ ls -lt /asl/data/kcarta/H2012_IR
  total 116
  drwxrwxr-x 9 strow pi_strow 61440 Jun  2  2017 etc
  drwxrwxr-x 2 strow pi_strow  4096 Jul 28  2015 h2o
  drwxrwxr-x 2 strow pi_strow  8192 Nov  6  2014 hdo
  %}
  opt.refp     = fullfile(kcdir,['ref_profs/refprof' hitran '.mat']);
  opt.kpathh2o = fullfile(kcdir,[hitran '_IR/h2o']);
  opt.kpathhDo = fullfile(kcdir,[hitran '_IR/hdo']);
  opt.kpathetc = fullfile(kcdir,[hitran '_IR/etc']);
  opt.kpathco2 = fullfile(kcdir,'H1988_IR/co2_umbc_ppmv385');
elseif strfind(hitran,'H2016')
  %{
  [sergio@taki-usr2 Test]$ ls -lt /asl/data/kcarta/H2016.ieee-le/IR605/
  total 132
  drwxrwxr-x  2 sergio pi_strow  8192 Mar  1 06:54 h2o_ALLISO.ieee-le
  drwxrwxr-x 20 sergio pi_strow 65536 Dec  3 08:11 etc.ieee-le
  drwxrwxr-x 12 sergio pi_strow  8192 May 22  2018 hdo.ieee-le
  drwxrwxr-x  3 sergio pi_strow    32 Mar 15  2018 lblrtm12.8
  drwxrwxr-x  3 sergio pi_strow    32 Mar 12  2018 HITRAN_LM
  %}
  opt.refp     = fullfile(kcdir,['ref_profs/refprof' hitran '.mat']);
  opt.kpathh2o = fullfile(kcdir,[hitran '.ieee-le/IR605/h2o_ALLISO.ieee-le']);
  opt.kpathhDo = fullfile(kcdir,[hitran '.ieee-le/IR605/hdo.ieee-le']);
  opt.kpathetc = fullfile(kcdir,[hitran '.ieee-le/IR605/etc.ieee-le']);
  opt.kpathco2 = fullfile(kcdir,'H1988_IR/co2_umbc_ppmv385');
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
