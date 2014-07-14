% pre-compression transform
kpow = 1/4; 

% temperature tabulation offsets
toffset = [-50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50];

% pressure tabulation offsets (for H2O)
poffset = [0.1, 1.0, 3.3, 6.7, 10.0];

% load reference profile (defines profile structure "refpro")
eval(sprintf('load %s', refp));

ngas = length(prof.glist);  % number of gasses in input profile
nlay = length(prof.mpres);  % number of layers in input profile

%% ropt0.iMatlab_vs_f77 = -1;    %% use f77 binary database
%% ropt0.iMatlab_vs_f77 = +1;    %% use Matlab binary database
if ropt0.iMatlab_vs_f77 == -1
  % kCARTA databases
  %datadir = '/strowdata1/shared/sergio/MATLABCODE/Kcarta/Data';
  %kpathh2o = fullfile(datadir,'v07.ieee-le/h2o.ieee-le');
  %kpathco2 = fullfile(datadir,'v24.ieee-le/co2.ieee-le');
  %kpathetc = fullfile(datadir,'v07.ieee-le/etc.ieee-le');
  kpathh2o = ropt0.kpathh2o;
  kpathhDo = ropt0.kpathhDo;
  kpathco2 = ropt0.kpathco2;
  kpathetc = ropt0.kpathetc;
elseif ropt0.iMatlab_vs_f77 == +1
  kpath = ropt0.kpath;
end
