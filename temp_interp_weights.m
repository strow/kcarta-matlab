function [itlo, ithi, twlo,twhi, pi1Out] = temp_interp_weights(head,prof,refp);

%% based on input profile and TempOffsets for kCompressed database,
%% figure out the temp interpolation weights and indices. These will obviously
%% be the SAME for all gases, for all chunks

load(refp);
gid = 1;
kcprof = op_rtp_to_lbl2(1, gid, head, prof, refpro);

%    kcprof  - [structure] top-down AIRS layers profile with fields:
%       glist  -  [1 x ngas] HITRAN gas IDs
%       mpres  -  [nlay x 1] layers mean pressure {mb}
%       mtemp  -  [nlay x 1] layer mean temperature {K}
%       gamnt  -  [nlay x ngas] layer gas amounts {kilomole/cm^2}
%       gpart  -  [nlay x ngas] layer gas partial pressures {mb}
%% note that kcprof is in same order as prof ie P(1) P(2) etc are same
%% order as PO(1) PO(2) etc

% temperature tabulation offsets
toffset = [-50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50];

% pressure tabulation offsets for H2O (multiplier to ref partial pressure?)
poffset = [0.1, 1.0, 3.3, 6.7, 10.0];

ngas = length(kcprof.glist);  % number of gasses in input profile
nlay = length(kcprof.mpres);  % number of layers in input profile

% Determine temperature interpolation weights for each layer
itwlo = zeros(nlay,1);
itwhi = zeros(nlay,1);
twlo  = zeros(nlay,1);
twhi  = zeros(nlay,1);

for Li = 1:nlay
  iLr = 101 - Li;

  pL = kcprof.mpres(Li);  % nominal pressure of mixed layer Li
  pi1 = max([find(pL <= refpro.mpres); 1]);
  pi1 = iLr; 
 
  pi1Out(Li) = pi1;

  tL = kcprof.mtemp(Li);  % nominal temperature of mixed layer Li
  % get temperature tabulation bounding interval [t11, t12] at p1
  tspan1 = toffset + refpro.mtemp(pi1);
  itlo(Li) = max([find(tspan1 <= tL), 1]);
  ithi(Li) = min([find(tL <= tspan1), length(tspan1)]);
  t11 = tspan1(itlo(Li));  % lower temperature bound at p1
  t12 = tspan1(ithi(Li));  % upper temperature bound at p1
  if t11 ~= t12
    % temperature interpolation weight
    twhi(Li) = (tL - t11) / (t12 - t11);
    twlo(Li) = 1 - twhi(Li);
  else 
    twhi(Li) = 1;
    twlo(Li) = 0;
    end
end

