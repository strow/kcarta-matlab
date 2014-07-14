
function [B,s] = absbasis(gid, gdir, vchunk, bopts)

% function [B,s] = absbasis(gid, gdir, vchunk, bopts)
%
% find a basis for compression of monochromatic absorption coeff's
%
% INPUTS
%   gid     -  gas ID
%   gdir    -  path to monochromatic abs. data 
%   vchunk  -  start of 25 1/cm chunk
%   bopts   -  test options
%
% bopts is a structure that can be used to change the default
% simulation parameters; for example, if the field bopts.tmax
% exists, then this value will be used in place of the default
% value for tmax
%
% OUTPUTS
%   B       -  compression basis
%   s       -  SVD singular values
%
% The tabulated monochromatic absorption data should be in .mat 
% files named either g<gid>v<chunk>.mat, for all gasses but water, 
% or g<gid>v<chunk>p<i>.mat, for water, which is saved as a set
% of partial pressures.  These .mat files contain the variables:
% 
%   fr        1 x 10000     frequency scale
%   gid       1 x 1         gas ID
%   k     10000 x 100 x 11  tabulated absorptions
%   pind      1 x 1         partial pressure index (when relevant)
%
% BUGS
%  - ref profile is loaded from local dir
%  - temp. and pres. offset lists not currently used anywhere
%  - some parameters are embedded in the code, in particular layer 
%    and temperature subsetting; these could be set earlier to be
%    changable via bopts, if desired
%

% input defaults
if nargin == 3
  bopts.dummy = [];
elseif nargin ~= 4
  error('wrong number of arguments')
end

% default parameters
d = 2;	        % initial dimension
dmax = 50;      % max saved dimension
tmax = 0.002;   % max layer transmittance error
lmax = 0.003;   % max layer-to-space transmittance error
bmax = 0.1;     % max brightness temperature error

% override defaults with values passed in as bopts fields
optvar = fieldnames(bopts);
for i = 1 : length(optvar)
  eval(sprintf('%s = bopts.%s;', optvar{i}, optvar{i}));
end

% pre-compression transform
kpow = 1/4; 

% temperature offsets
toffset = [-50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50];

% pressure offsets (for H2O)
poffset = [0.1, 1.0, 3.3, 6.7, 10.0];

% load reference profile
load refpro
plevs = refpro.mpres;
ptemp = refpro.mtemp;
clear refpro

fprintf(1, '\ngas %d, vchunk %d\n', gid, vchunk);

if gid == 1

  % build SVD and test sets for H20

  % specify a subset of layers and temps for the H2O SVD
  % (steps 1:x:100: 3, 9, 11; steps 1:x:99: 7)
  slayind = 1:7:100; % SVD pressure level indices
  stemind = 1:2:11;  % SVD temperature offset indices

  % specify a test set for determining basis dimension
  ttemind = 5; % test set temperature offset index
  tpprind = 3; % test set partial presure index

  ncol1 = length(slayind) * length(stemind); 
  ncol2 = ncol1 * 5;	
  ksvd = zeros(10000, ncol2);

  ktrue = zeros(10000, 100);

  % Loop on partial pressure sets, build SVD and test arrays
  for pind = 1 : 5

    eval(sprintf('load %s/g%dv%dp%d.mat', gdir, gid, vchunk, pind));

    % build SVD set
    ksvd(:, (pind-1)*ncol1+1 : pind*ncol1) = ...
        reshape(k(:,slayind,stemind), 10000, length(slayind)*length(stemind));

    % build test set
    if tpprind == pind 
       ktrue = k(:,:,ttemind);
    end
    clear k
  end

else

  % build SVD and test sets for other gasses

  % specify a subset of layers and temps for the SVD
  slayind = 1:3:100;
  stemind = 1:2:11;

  % specify a test set for determining basis dimension
  ttemind = 5; % test set temperature offset index

  eval(sprintf('load %s/g%dv%d.mat', gdir, gid, vchunk));

  % build SVD set
  ksvd = reshape(k(:, slayind, stemind), 10000, ...
                    length(slayind)*length(stemind));

  % build test set
  ktrue = k(:,:,ttemind);
  clear k
end

% check for negative absorptions 
ksneg = ksvd < 0;
ktneg = ktrue < 0;
if sum(sum(ksneg)) | sum(sum(ktneg))
  fprintf(1, 'WARNING: setting negative tabulated absorptions to zero\n');
  ksvd = ksvd .* ~ksneg;
  ktrue = ktrue .* ~ktneg;
end
clear ksneg ktneg

ksmin = min(min(ksvd));
ktmin = min(min(ktrue));
if ksmin < 0 | ktmin < 0
  fprintf(1, 'WARNING: negative absorptions, %g\n', min(ksmin, ktmin));
  fprintf(1, 'setting negative absorptions to zero for SVD and test\n');
  ksvd = ksvd .* (ksvd > 0);
  ktrue = ktrue .* (ktrue > 0);
end

% apply the pre-SVD transform
ksvd = ksvd .^ kpow;

% do the SVD
[u,s,v] = svd(ksvd, 0);
clear ksvd v
s = diag(s);

% true layer transmittances
trtrue = exp(-ktrue);			      

% true layer-to-space trans.
l2strue = fliplr(cumprod(fliplr(trtrue),2));  

% true radiances and brightness temps
onescol = ones(10000,1);
R = planck(fr', ptemp(1) * onescol);	% surface radiance
% loop on layers
for i = 1:100
  R = R .* trtrue(:,i) + ...
      planck(fr', ptemp(i) * onescol) .* (1 - trtrue(:,i));
end
Tbtrue = rad2bt(fr, R/1000);

% loop on basis dimension
while 1
  B = u(:,1:d);
  Binv = pinv(B);

  % compressed/uncompresed absorptions
  kcomp =  (B * (Binv * (ktrue .^ kpow))) .^ (1/kpow) ;

  % compressed/uncompresed layer transmittances
  trcomp = exp(-kcomp);
  trerr  = trtrue - trcomp;
  tremax = max(max(abs(trerr)));
  trerms = rms(trerr);

  % compressed/uncompresed layer-to-space transmittances
  l2scomp = fliplr(cumprod(fliplr(trcomp),2));
  l2serr  = l2strue - l2scomp;
  l2semax = max(max(abs(l2serr)));
  l2serms = rms(l2serr);

  % compressed/uncompressed brightness temp's
  R = planck(fr', ptemp(1) * onescol);	% surface radiance
  % loop on layers
  for i = 1:100
    R = R .* trcomp(:,i) + ...
        planck(fr', ptemp(i) * onescol) .* (1 - trcomp(:,i));
  end
  Tbcomp = rad2bt(fr, R/1000);
  Tberr  = Tbtrue - Tbcomp;
  Tbemax = max(max(abs(Tberr)));
  Tberms = rms(Tberr);

  fprintf(1, ...
          'dim.=%2d,  max errors:  lay=%6.4f,  l2s=%6.4f,  Tb=%4.2f\n', ...
	   d, tremax, l2semax, Tbemax);

  % test if basis is acceptable, or too large
  if (tremax <= tmax & l2semax <= lmax & Tbemax <= bmax) | d >= dmax
    break
  end

  d = d + 2;
end

