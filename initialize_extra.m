%% paths to either the Matlab or f77 kcompressed files
ropt0.iMatlab_vs_f77 = iMatlab_vs_f77;
if iMatlab_vs_f77 == +1 
   %% use Matlab kComp files
  ropt0.kpath          = kpath;
elseif iMatlab_vs_f77 == -1  
  %% use f77 kComp files
  ropt0.kpathh2o = kpathh2o;
  ropt0.kpathhDo = kpathhDo;
  ropt0.kpathco2 = kpathco2;
  ropt0.kpathetc = kpathetc;
else
  error('need kComp files to either be Matlab (+1) or f77 ieee-le (-1)')
end

iNLTE = -1;

ropt0.soldir         = soldir;
ropt0.cdir           = cdir;
ropt0.nltedir        = nltedir;
ropt0.co2ChiFilePath = co2ChiFilePath;
ropt0.iNLTE          = iNLTE;
ropt0.kpathCO2_4umNLTE_OD = kpathCO2_4umNLTE_OD;
ropt0.kpathCO2_4umNLTE_PL = kpathCO2_4umNLTE_PL;

%% path to the EXTRA source files
addpath([dirname(mfilename('fullpath')) '/JACDOWN'])

%% path to the RT source files
addpath([dirname(mfilename('fullpath')) '/private/ANGLES'])
addpath([dirname(mfilename('fullpath')) '/private/BACKGND_THERMAL'])
addpath([dirname(mfilename('fullpath')) '/private/READERS'])
addpath([dirname(mfilename('fullpath')) '/private/JACOBIAN_AUX'])

%% now check that dirs exist
if iMatlab_vs_f77 == +1 
  if ~exist(kpath,'dir')
    fprintf(1,'matlab kcomp kpath = %s \n',kpath)
    error('matlab kcomp kpath set in user_set_dirs does not exist')
  end
elseif iMatlab_vs_f77 == -1 
  if ~exist(kpathh2o,'dir')
    fprintf(1,'f77 kpathh2o = %s \n',kpathh2o)
    error('kpathh2o set in user_set_dirs does not exist')
  elseif ~exist(kpathco2,'dir')
    fprintf(1,'f77 kpathco2 = %s \n',kpathco2)
    error('kpathco2 set in user_set_dirs does not exist')
  elseif ~exist(kpathetc,'dir')
    fprintf(1,'f77 kpathetc = %s \n',kpathetc)
    error('kpathetc set in user_set_dirs does not exist')
  end
end

if ~exist(refp,'file')
  fprintf(1,'refp = %s \n',refp)
  error('refp set in user_set_dirs does not exist')
elseif ~exist(soldir,'dir')
  fprintf(1,'soldir = %s \n',soldir)
  error('soldir set in user_set_dirs does not exist')
elseif ~exist(cdir,'dir')
  fprintf(1,'continuum cdir = %s \n',cdir)
  error('cdir set in user_set_dirs does not exist')
elseif ~exist(nltedir,'file')
  fprintf(1,'nltedir = %s \n',nltedir)
  error('nltedir set in user_set_dirs does not exist')
elseif ~exist(co2ChiFilePath,'dir')
  fprintf(1,'co2ChiFilePath = %s \n',co2ChiFilePath)
  error('co2ChiFilePath set in user_set_dirs does not exist')
elseif ~exist(klayers_code.junkdir,'dir')
  error('klayers_code.junkdir set in user_set_dirs does not exist')
elseif ~exist(klayers_code.airs,'file')
  error('klayers_code.airs set in user_set_dirs does not exist')
end
