
function [tmax, lmax, bmax] = ...
		testchunk(gid, gdir, cdir, vchunk, topts)
			      
% function [tmax, lmax, bmax] = ...
%                 testchunk(gid, gdir, cdir, vchunk, topts)
%
% test one "chunk" (25 wavenumbers) of compressed absorptions 
% against the corresponding monochromatic data; optionally, plot
% errors in a choice of formats
%
% INPUTS
%   gid    -  gas ID
%   gdir   -  path to monochromatic absorption data 
%   cdir   -  path to compressed absorption data 
%   vchunk -  wavenumber start of 25 1/cm chunk
%   topts  -  test options
%
% topts is a structure that can be used to change the default
% test parameters; for example, if the field topts.tlist exists
% then this value will be used in place of the default value for 
% tlist.  Parameters that can be set include:
%
% tlist - list of temperature offset indices to test
% plist - list of partial pressure offset indices to test
% mplot - if 1, do a mesh print of transmittance error
% lplot - if L > 0, print summary error plot for layer L
% 
% OUTPUTS
%   tmax   - overall max transmittance error
%   lmax   - overall max layer-to-space transmittance error
%   bmax   - overall max brightness temperature error
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
% The compressed data is saved in files cg<gid>v<chunk>.mat, with
% similar variables:
%
%   fr        1 x 10000           frequency scale
%   gid       1 x 1               gas ID
%   B     10000 x <d>             basis
%   kcomp   <d> x 100 x 11 x <p>  tabulated absorptions
%
% BUGS
%   hard coded path to reference profile
%

% input defaults
if nargin == 4
  topts.dummy = [];
elseif nargin ~= 5
  error('wrong number of arguments')
end

% test defaults
tlist = 6;   % middle temperature offset index
plist = 3;   % middle partial pressure offset index
mplot = 0;   % flag for mesh print of transmittance error
lplot = 0;   % if non-zero, layer index for summary plots

% override defaults with values passed in as topts fields
optvar = fieldnames(topts);
for i = 1 : length(optvar)
  eval(sprintf('%s = topts.%s;', optvar{i}, optvar{i}));
end

% plist should be 1 except for water
if gid ~= 1
  plist = 1;
end

% pre-compression transform
kpow = 1/4; 

% temperature offsets
toffset = [-50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50];

% pressure offsets (for H2O)
poffset = [0.1, 1.0, 3.3, 6.7, 10.0];

% load reference profile
load /home/motteler/abscmp/refpro
plevs = refpro.mpres;
ptemp = refpro.mtemp;
clear refpro

% initialize overall max error tabulations
tmax = 0;
lmax = 0;
bmax = 0;

% load compressed data; defines kcomp, B, fr, gid
eval(sprintf('load %s/cg%dv%d', cdir, gid, vchunk));
[m,d] = size(B);

fprintf(1, '\ngas %d, vchunk %d\n', gid, vchunk);

% loop on partial pressure tests (the outer loop, since we have 
% to do a separate monochromatic load for each partial pressure)
for pi = plist

  % load monochromatic data; defines k
  if gid == 1
    eval(sprintf('load %s/g%dv%dp%d.mat', gdir, gid, vchunk, pi));
  else
    eval(sprintf('load %s/g%dv%d.mat', gdir, gid, vchunk));
  end

  % loop on temperature tests
  for ti = tlist

    % layer transmittance errors
    ktrue = k(:,:,ti);
    ktrue = ktrue .* (ktrue > 0);
    trtrue = exp(-ktrue);
    trtest = exp(-((B * kcomp(:,:,ti,pi)).^(1/kpow)));
    trerr  = trtrue - trtest;
    tremax = max(max(abs(trerr)));
    trerms = rms(trerr);

    % layer-to-space transmittance errors
    l2strue = fliplr(cumprod(fliplr(trtrue),2));  
    l2stest = fliplr(cumprod(fliplr(trtest),2));
    l2serr  = l2strue - l2stest;
    l2semax = max(max(abs(l2serr)));
    l2serms = rms(l2serr);

    % brightness temp. errors
    onescol = ones(10000,1);
    R = planck(fr', ptemp(1) * onescol);  % surface radiance
    % loop on layers
    for i = 1:100
      R = R .* trtrue(:,i) + ...
         planck(fr', ptemp(i) * onescol) .* (1 - trtrue(:,i));
    end
    Tbtrue = rad2bt(fr, R/1000);

    R = planck(fr', ptemp(1) * onescol);  % surface radiance
    % loop on layers
    for i = 1:100
      R = R .* trtest(:,i) + ...
          planck(fr', ptemp(i) * onescol) .* (1 - trtest(:,i));
    end
    Tbtest = rad2bt(fr, R/1000);

    Tberr  = Tbtrue - Tbtest;
    Tbemax = max(max(abs(Tberr)));
    Tberms = rms(Tberr);

    if gid == 1
      fprintf(1, ...
        'ppres=%4.1f, toff=%3d, max err: lay=%6.4f, l2s=%6.4f, Tb=%4.2f\n', ...
         poffset(pi), toffset(ti), tremax, l2semax, Tbemax);
    else
      fprintf(1, ...
         'toff=%3d, max err: lay=%6.4f, l2s=%6.4f, Tb=%4.2f\n', ...
          toffset(ti), tremax, l2semax, Tbemax);
    end

    % cumumlative error
    tmax = max(tmax, tremax);
    lmax = max(lmax, l2semax);
    bmax = max(bmax, Tbemax);

    % option to plot layer transmittance error
    % (both unweighted and weighted by transmittance derivative)
    if mplot

      % weighting functions
      dtrtrue = diff(trtrue')';

      figure(1)
      subplot(2,1,1)
      mesh(plevs, fr, trerr)
      v = axis; v(2) = 1.1; axis(v);
      title('transmittance error')
      xlabel('torr');
      ylabel('1/cm');

      subplot(2,1,2)
      mesh(plevs(1:99), fr, trerr(:,1:99) .* dtrtrue)
      v = axis; v(2) = 1.1; axis(v);
      title('transmittance error times weighting funcion')
      xlabel('torr');
      ylabel('1/cm');
    end

    % otion to show absorption, absorption^kpow, transmittance, 
    % and transmittance error, for a selected layer
    if lplot ~= 0

      figure(2)
      subplot(2,1,1)
      % semilogy(fr, ktrue(:,lplot))
      plot(fr, ktrue(:,lplot))
      title(sprintf('true k, layer %d', lplot))
      grid

      subplot(2,1,2)
      % semilogy(fr, ktrue(:,lplot).^kpow)
      plot(fr, ktrue(:,lplot).^kpow)
      title(sprintf('k^{1/%d},  layer %d', 1/kpow, lplot))
      xlabel('wavenumber')
      grid 

      figure(3)
      subplot(2,1,1)
      plot(fr, trtrue(:,lplot), fr, trtest(:,lplot))
      title(sprintf('transmittance, layer %d', lplot))
      legend('true trans', 'uncmp trans')
      grid

      subplot(2,1,2)
      plot(fr, trerr(:,lplot))
      title(sprintf('transmittance error, layer %d', lplot))
      title('transmittance error')
      xlabel('wavenumber')
      grid

    end 

    % pause for multiple plot sets
    if (lplot | mplot) & (length(plist) > 1 | length(tlist) > 1)
      input('<cr> to continue > ');
    end

  end % tlist loop

end % plist loop

fprintf(1, 'overall max errors: lay=%6.4f, l2s=%6.4f, Tb=%4.2f\n', ...
	   tmax, lmax, bmax);

