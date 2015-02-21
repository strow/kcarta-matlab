% this driver file is used to set up the filedir parameters for kCARTA MATLAB
%
% S. Machado, UMBC, March 2012        sergio@umbc.edu
% jump to START USER SET if you already understand, and want to skip, this intro
%
%%%%%%%%%%%%%%%%  IF iMatlab_vs_f77 == +1 then the Matlab files are %%%%%%%%%%%%%%
%%% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%
% kpath = path to compressed files
% refp  = path to reference profile
%   currently we have the H2000, H2004 and H2008 versions
%   ALL use the UMBC CO2 linemixing database
%
% EXAMPLES : 
%
%%%% H2000
%
% kpath  = '/asl/data/kcarta/v20.matlab';                 
% refp   = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/REFPROF/refprofH2004.mat'; %% H2004 numbers
%
%%%% H2004
%
% compressed co2 abs coeffs assume 370 ppmv
% kpath  = '/asl/data/kcarta/v24.matlab';               %% original H2004
% kpath  = '/dunno_where/KCMIX_DATABASE/H2004_matlab';  %% merging above 
%                                                       %% with updated g1,3,9,12
% refp   = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/REFPROF/refprofH2004.mat'; %% H2004 numbers
%
%%%% H2008
%
% compressed co2 abs coeffs assume 385 ppmv
% kpath = '/dunno_where/KCMIX_DATABASE/H2008_matlab'; %% H2008
%  >>>>>>>>>>>>>>>> warning this uses H04 UMBC-LBL CO2 from /asl/data/kcarta/v24.matlab >>>>>>>>>>>>
% refp   = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/REFPROF/refprofH2008.mat'
%
%%%% H2012
%
% compressed co2 abs coeffs assume 385 ppmv
% kpath = '/dunno_where/KCMIX_DATABASE/H2012_matlab'; %% H2008
%  >>>>>>>>>>>>>>>> warning this uses H04 UMBC-LBL CO2 from /asl/data/kcarta/v24.matlab >>>>>>>>>>>>
% refp   = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/REFPROF/refprofH2012.mat'
%
%%% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%%%%%%%%%%%%%%%%  ELSEIF iMatlab_vs_f77 == -1 then the f77 files are %%%%%%%%%%%%%%
%%% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%  kdatadir = path to ieee-le f77 binary data
%  kpathh2o = subdir to h2o files
%  kpathhDo = subdir to hDo files
%  kpathco2 = subdir to co2 files
%  kpathetc = subdir to all other gases
%
%%%% H200X example
%
%  kdatadir = '/asl/data/kcarta/H200X_IR.v1.ieee_le';
%  kpathh2o = fullfile(kdatadir,'v07.ieee-le/h2o.ieee-le');
%  kpathhDo = fullpath(kcartadir,'/fbin/h2o.ieee-le/');
%  kpathco2 = fullfile(kdatadir,'v24.ieee-le/co2.ieee-le');
%  kpathetc = fullfile(kdatadir,'v07.ieee-le/etc.ieee-le');
%
%
%%% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%
%%%% other possible f77 databases
%    %%% 4 um NLTE : ods and plancks between 1100 - 0.005 mb
%    kpathCO2_4umNLTE_OD = '/asl/data/kcarta/KCARTADATA/NLTE/LA_UA_kcomp/';
%    kpathCO2_4umNLTE_PL = '/asl/data/kcarta/KCARTADATA/NLTE/LA_UA_kcomp/';
%
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/FIR80_150/fbin/'; %    %%% 080-150 cm-1
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/FIR140_310/fbin/';%    %%% 140-310 cm-1
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/FIR300_510/fbin/';%    %%% 300-510 cm-1
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/FIR500_605/fbin/';%    %%% 500-605 cm-1
%        %%% 605-2830 cm-1 : defined above
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/NIR2830_3330/fbin/';%    %%% 2830-3330 cm-1
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/NIR3550_5550/fbin/';%    %%% 3550-5550 cm-1
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/NIR5550_8200/fbin/';%    %%% 5550-8350 cm-1
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/NIR8250_12250/fbin/';%   %%% 8350-12250 cm-1
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/VIS12000_25000/fbin/';%  %%% 12000-25000 cm-1
%    kdatadir = '/other_databases/OLD_RUN8_NIRDATABASE/UV25000_44000/fbin/'; %  %%% 25000-44000 cm-1
%
%    kpathh2o = [kdatadir 'h2o.ieee-le/'];
%    kpathhDo = ['Null'];
%    kpathco2 = [kdatadir 'etc.ieee-le/'];
%    kpathetc = [kdatadir 'etc.ieee-le/'];
%    cdir     = kpathetc;
%
%%%%%%%%%%%%%%%%  ENDIF iMatlab_vs_f77 == +/-1  %%%%%%%%%%%%%%
%
% soldir  = path to solar files
% cdir    = path to continuum files : 
%             we supply CKD24, MTCKD1, our CKD5 ("improved" version of 1)
%   cswt,cfwt = self and forn weights
% nltedir = path and name of NLTE files
% co2ChiFilePath = path to 4 um CO2 files
%
% klayers_code.junkdir = path to scratch space for klayers input/output
% klayers_code.aeri    = path to klayers executable for AERI 
%                           (uplook, finer layers near ground)
% klayers_code.airs    = path to klayers executable for AIRS,IASI/CRiS
%                           (downlook, default klayers layers)
%
% user also needs to set paths to the rtp file handling routines,
% namely rtpread.m and subset_rtp.m
%
% >>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>> >>>>>>>>>>>
% >>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>> >>>>>>>>>>>
% >>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>> >>>>>>>>>>>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% START USER SET %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% required paths/files

% path to solar files ...
soldir = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/SOLARv2';

% path to continuum files ...
cdir = '/asl/data/kcarta/KCARTADATA/General/CKDieee_le/'
cswt = 1.0; cfwt = 1.0;   %% self and forn weights

% path and name NLTE files ....
nltedir = '/asl/data/kcarta/KCARTADATA/NLTE/SARTA_COEFS/setnte_oct05.le.dat';
kpathCO2_4umNLTE_OD = '/asl/data/kcarta/KCARTADATA/NLTE/LA_UA_kcomp/';
kpathCO2_4umNLTE_PL = '/asl/data/kcarta/KCARTADATA/NLTE/LA_UA_kcomp/';

% path to CO2 chifiles
co2ChiFilePath = '/asl/data/kcarta/KCARTADATA/General/ChiFile/';

%% these are the klayers execs
klayers_code.aeri = '/yourdir/klayersV204/Bin/klayers_aeri999';      %% AERI
klayers_code.airs = '/asl/packages/klayers/Bin/klayers_airs';        %% AIRS
klayers_code.junkdir = '/tmp/';               %% where to put junk files

%% path to compressed files and to ref profile
if iMatlab_vs_f77 == +1 
  str0 = 'MATLAB kComp files';
elseif iMatlab_vs_f77 == -1 
  str0 = 'f77 kComp files';
else
  error('iMatlab_vs_f77 == +1 or -1');
end

if iHITRAN == 2000
  str = ['       --->>> using H2000 kComp Files ... ' str0];
  fprintf(1,'%s \n',str);
  refp   = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/REFPROF/refproTRUE_OLD.mat';
  %% this is for Matlab : iMatlab_vs_f77 == +1 
    kpath  = '/asl/data/kcarta/v20.matlab';                 
  %% this is for    f77 : iMatlab_vs_f77 == -1 
    kdatadir = 'Null'
    kpathh2o = 'Null'
    kpathhDo = 'Null'
    kpathco2 = 'Null'
    kpathetc = 'Null'

elseif iHITRAN == 2004
  str = ['       --->>> using H2004 kComp Files ... ' str0];
  fprintf(1,'%s \n',str);
  refp   = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/REFPROF/refprofH2004.mat';
  %% this is for Matlab : iMatlab_vs_f77 == +1 
  kpath  = '/asl/data/kcarta/v24.matlab';   
  kpath  = '/dunno_where/KCMIX_DATABASE/H2004_matlab';%% merged with new
                                                          %% g1,3,9,12
  %% this is for    f77 : iMatlab_vs_f77 == -1 
  kdatadir = '/asl/data/kcarta/';
  kpathh2o = [kdatadir 'v07.ieee-le/h2o.ieee-le'];
  kpathhDo = 'Null';
  kpathco2 = [kdatadir 'v24.ieee-le/co2.ieee-le'];
  kpathetc = [kdatadir 'v07.ieee-le/etc.ieee-le'];
elseif iHITRAN == 2008
  str = ['       --->>> using H2008 kComp Files ... ' str0];
  fprintf(1,'%s \n',str);
  refp   = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/REFPROF/refprofH2008.mat';
  %% this is for Matlab : iMatlab_vs_f77 == -1 
  kpath = '/dunno_where/KCMIX_DATABASE/H2008_matlab'; 
  %% this is for    f77 : iMatlab_vs_f77 == -1 
  kdatadir = '/asl/data/kcarta/';
  kpathh2o = [kdatadir 'H2008.ieee-le/IR605/h2o_ALLISO.ieee-le/'];
  kpathhDo = [kdatadir 'H2008.ieee-le/IR605/h2o_ALLISO.ieee-le//'];
  kpathco2 = ['/asl/data/kcarta/UMBC_CO2_H1998.ieee-le/CO2ppmv385.ieee-le/'];
  kpathetc = [kdatadir 'H2008.ieee-le/IR605/etc.ieee-le/'];
elseif iHITRAN == 2012
  str = ['       --->>> using H2012 kComp Files ... ' str0];
  fprintf(1,'%s \n',str);
  refp   = '/asl/data/kcarta/KCARTADATA/KCMIX/DATA/REFPROF/refprofH2012.mat';
  %% this is for Matlab : iMatlab_vs_f77 == -1 
  kpath = '/dunno_where/KCMIX_DATABASE/H2012_matlab'; 
  %% this is for    f77 : iMatlab_vs_f77 == -1 
  kdatadir = '/asl/data/kcarta/';
  kpathh2o = [kdatadir 'H2012.ieee-le/IR605/h2o_ALLISO.ieee-le/'];
  kpathhDo = [kdatadir 'H2012.ieee-le/IR605/h2o_ALLISO.ieee-le/'];
  kpathco2 = ['/asl/data/kcarta/UMBC_CO2_H1998.ieee-le/CO2ppmv385.ieee-le/'];
  kpathetc = [kdatadir 'H2012.ieee-le/IR605/etc.ieee-le/'];
end

disp(' ')

addpath /asl/matlib/h4tools        %%% rtpread.m
addpath /asl/matlib/rtptools       %%% subset_rtp.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END USER SET %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
