if iMatlab_vs_f77 == +1 
   %% use Matlab kComp files
  ropt0.iMatlab_vs_f77 = iMatlab_vs_f77;
  ropt0.kpath          = kpath;
elseif iMatlab_vs_f77 == -1  
  %% use f77 kComp files
  ropt0.iMatlab_vs_f77 = iMatlab_vs_f77;
  ropt0.kpathh2o = kpathh2o;
  ropt0.kpathhDo = kpathhDo;
  ropt0.kpathco2 = kpathco2;
  ropt0.kpathetc = kpathetc;
else
  error('need kComp files to either be Matlab (+1) or f77 ieee-le (-1)')
  end
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
    error('kpath set in user_set_dirs does not exist')
    end
elseif iMatlab_vs_f77 == -1 
  if ~exist(kpathh2o,'dir')
    kpathh2o
    error('kpathh2o set in user_set_dirs does not exist')
  elseif ~exist(kpathco2,'dir')
    kpathco2
    error('kpathco2 set in user_set_dirs does not exist')
  elseif ~exist(kpathetc,'dir')
    kpathetc
    error('kpathetc set in user_set_dirs does not exist')
    end
  end
if ~exist(refp,'file')
  error('refp set in user_set_dirs does not exist')
elseif ~exist(soldir,'dir')
  error('soldir set in user_set_dirs does not exist')
elseif ~exist(cdir,'dir')
  error('cdir set in user_set_dirs does not exist')
elseif ~exist(nltedir,'file')
  error('nltedir set in user_set_dirs does not exist')
elseif ~exist(co2ChiFilePath,'dir')
  error('co2ChiFilePath set in user_set_dirs does not exist')
elseif ~exist(klayers_code.junkdir,'dir')
  error('klayers_code.junkdir set in user_set_dirs does not exist')
elseif ~exist(klayers_code.airs,'file')
  error('klayers_code.airs set in user_set_dirs does not exist')
  end