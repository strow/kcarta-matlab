% this driver file is used to set up the input parameters for a 
% downlooking (AIRS/IASI/CRiS) computation
% Assumption : user_set_dirs.m has been set correctly!!!!
%
% S. Machado, UMBC, March 2011        sergio@umbc.edu
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS (with examples)
%
% iAirs drives klayers, and eventually the convolver
%   iAirs = 0,-1,+1,2,3  : raw, AIRS, IASI, CRiS
%   example : iAirs = +1;     %%% doing things for AIRS
%
% iHITRAN sets the kCompressed directory, based on HITRAN
%   iHITRAN = 2000,2004,2008 are your options
%
% iMatlab_vs_f77 tells the code whether the database is Matlab or ieee-le 
%   iMatlab_vs_f77 = +1   use Matlab version
%   iMatlab_vs_f77 = -1   use f77 version
%
% fA and fB are start and stop wavenumbers
%   example : fA = 605;  fB = 830; 
%
% iDoJac tells controls the jacobians gasids (-1 for none)
%   iDoJac = -1;                      %% no jacs
%   iDoJac = [iGid1 iGid2 ... iGidN]; %% do jacobians; the iGid tells which
%                                     %% gases to do amt jacs for 
%                                     %% (temp jacs always done)
%   warning : iGid1 = WV includes lines and continuum
%   example : iDoJac = [1 3];
%
% iJacobOutput controls the output jacobians units
%   iJacobOutput = -1;        %% dr/dT, dr/dq
%   iJacobOutput =  0;        %% dr/dT, dr/dq*q
%   iJacobOutput = +1;        %% dBT/dT, dBT/dq*q
%
% CKD is the CKD version : choose 1,2,3,4,5
%   example : CKD = '1';
%
% these next two define where the input rtp file is in
%   dir is the directory where the file is in
%   fin is the actual file
%   example : dirin = 'your_favorite_dir'; 
%             fin = 'pin_feb2002_sea_airsnadir_op.sun.rtp';
%
% iProfRun is which of the rtp profiles to run
%   example iProfRun = 1;
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUTS (with examples)
%
% structures "radsOut" and "jacsOut" are your output variables
%            "ropt0"   and "stuff"   give some useful input info
%
% example if fA,fB = 605,805; each 10000 point kCARTA chunk is 25 cm-1 wide, 
% so there are 9 chunks or 90000 wavenumber points in this run
%
%%%%%% 
%
% radsOut : always produced
%    freqAllChunks                  1x90000          freq      cm-1
%     radAllChunks                  90000x1          radiances mW/cm2/sr/cm-1
% iaa_kcomprstats_AllChunks          2x73            Singular Vectors stats
%
% ropt0 : reproduces important input parameters (from set_dirs) eg
%             kpath: '/yourdir/KCMIX_DATABASE/H2004_matlab'
%            soldir: '/asl/data/kcarta/KCARTADATA/SOLARieee_le/solarV2'
%              cdir: '/asl/data/kcarta/KCARTADATA/General/CKDieee_le'
%           nltedir: [1x60 char]
%    co2ChiFilePath: '/asl/data/kcarta/KCARTADATA/General/ChiFile/'
%            rsolar: 1
%            rtherm: 2
%
% stuff : not too important, duplicates stuff set here (set_input_downlook.m)
%            freqs: [605 805]
%    input_rtpfile: [1x66 char]
%       layersprof: [1x1 struct]
%           iDoJac: [1 2]
%     iJacobOutput: 1
%         iProfRun: 1
%
%%%%%% 
%
% if iDoJac(1) > 0 then jacobians are computed. The output format of the
% jacobians depends on "iJacobOutput"
%    ejacAllChunks: [90000x1]       surface emissivity jacobians
%    qjacAllChunks: [2x90000x96]    gas amount jacs, for each gas in iDoJac
%    sjacAllChunks: [90000x1]       surface temp jacobians
%    tjacAllChunks: [90000x96]      temperature jacobians
%     wgtAllChunks: [90000x96]      weighting functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%% user defined %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% user defined %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% user defined %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% iAirs drives klayers, and ultimately the convolver
iAirs = -1;     %% this is an AERI uplook

% iHITRAN sets the kCompressed directory, based on HITRAN
iHITRAN = 2004;

% iMatlab_vs_f77 : use Matlab (+1) or ieee-le (-1) kcomp database
iMatlab_vs_f77 = +1;   % use Matlab version
iMatlab_vs_f77 = -1;   % use f77 version

% fA and fB are start and stop wavenumbers
fA = 605;  fB = 805; 

% iDoJac tells controls the jacobians gasids (-1 for none)
iDoJac = [1 2];         %% WV (includes continuum) and CO2
iDoJac = [2];           %% CO2
iDoJac = [-1];          %% none

% iJacobOutput controls the output jacobians units
iJacobOutput = +1;        %% dBT/dT, dBT/dq*q

% CKD is the CKD version : choose 24,1,5
CKD = '5';

% these next two define the input dir and rtp file
dirin = '/yourdir/RTPFILES/';
fin = 'uplook_op.rtp';

% iProfRun is which of the rtp profiles to run
iProfRun = 1;
