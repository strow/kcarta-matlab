
function [absc, fr] = kcmixV1(prof, vchunk, kpath)

% 
%  calculate one 25 1/cm "chunk" of mixed absorptions
%
%  this version assumes a 100-layer input profile, with
%  the same layers as the reference profiles
%
%  inputs
%
%    prof    - profile strucure
%    vchunk  - start freq of chunk
%    kpath   - path to absorption database
%
%  output
%  
%    absc    - 10^4 x nlay array of mixed absorptios
%    fr      - 10^4 vector of associated frequencies
%
%  bugs
%    - hard-coded path to reference profile

% defaults
if nargin < 3
  kpath = '/home/motteler/abstab/kcomp'; 
end

% pre-compression transform
kpow = 1/4; 

% temperature offsets
toffset = [-50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50];

% pressure offsets (for H2O)
poffset = [0.1, 1.0, 3.3, 6.7, 10.0];

% load reference profile
load /home/motteler/abscmp/refpro
refpres = refpro.mpres; % reference profile pressure 
reftemp = refpro.mtemp; % reference profile temperature

ngas = length(prof.glist);  % number of gasses in profile
nlay = length(prof.mpres);  % number of layers in profile

% initialize output array
absc = zeros(1e4, nlay);

% loop on gasses
for gind = 1 : ngas

  gid = prof.glist(gind);

  % see if there is compressed data for this gas and chunk
  cgfile = sprintf('%s/cg%dv%d.mat', kpath, gid, vchunk);

  % check that gas ID is in the reference profile
  rgind = find(refpro.glist == gid);

  % check that we have tabulated data for this gas
  if ~isempty(rgind) & exist(cgfile) == 2

    % load compressed coefficient file, defines var's
    %
    %   B       10000 x d         absorption basis
    %   fr          1 x 10000     associated frequencies
    %   gid         1 x 1         HITRAN gas ID
    %   kcomp       d x 100 x 11  compressed coefficients
    %
    eval(sprintf('load %s', cgfile));
    [n, d] = size(B);

    % fprintf(1, '.');

    % load the reference profile
    % rename reference profile fields
    refpart = refpro.gpart(:,rgind); % ref prof part press
    refamnt = refpro.gamnt(:,rgind); % ref prof gas amount

    % space for compact absorption for current gas
    kcmp1 = zeros(d, nlay);

    % loop on layer indices
    for Li = 1 : nlay
    
      % get temperature interp range and weights
      tspan = toffset + reftemp(Li);  % abs tab temperatures
      tL = prof.mtemp(Li);	   % temperature, this layer
      ti1 = max([find(tspan <= tL), 1]);
      ti2 = min([find(tL <= tspan), length(toffset)]);
      t1 = tspan(ti1);
      t2 = tspan(ti2);
      if t1 < t2
        tw = (tL - t1) / (t2 - t1);  % temperature interp weight
      else 
        tw = 1;
      end

      if gid ~= 1

        % do temperature interpolation

        kcmp1(:,Li) = kcomp(:,Li,ti2) .* tw +  kcomp(:,Li,ti1) .* (1 - tw);

        % temperature interpolation test plot
        % if L == 60
        %   kpt1 = B * kcomp(:,Li,ti1);
        %   kpt2 = B * kcomp(:,Li,ti2);
        %   kptL = B * kcmp1(:,Li);
        %   plot(fr, kpt2, 'r', fr, kptL, 'k', fr, kpt1, 'g')
        %   legend(num2str(round([t2,tL,t1]')));
	%   title('temperature interpolation check')
        % end % test plot

      else

        % do both partial pressure and temperature interpolation

        % get partial pressure interp range and weights
        pspan = poffset * refpart(Li);  % abs tab part press
        pL = prof.gpart(Li,gind);     % part press, this layer
        pi1 = max([find(pspan <= pL), 1]);
        pi2 = min([find(pL <= pspan), length(poffset)]);
        p1 = pspan(pi1);
        p2 = pspan(pi2);
        if p1 < p2
          pw = (log(pL) - log(p1)) / (log(p2) - log(p1)); % pres interp wt
        else
          pw = 1;
        end

	% interpolate spanning temp tab points in part pressure
	kct1 = kcomp(:,Li,ti1,pi2) * pw +  kcomp(:,Li,ti1,pi1) * (1 - pw);
	kct2 = kcomp(:,Li,ti2,pi2) * pw +  kcomp(:,Li,ti2,pi1) * (1 - pw);

	% interpolate part press interp results in temperature
	kcmp1(:,Li) = kct2 * tw + kct1 * (1 - tw);

        % pressure and temperature interpolation test plot
        % if Li == 5
        %   kt1 = B * kct1;
	%   kt1p1 = B * kcomp(:,Li,ti1,pi1);
	%   kt1p2 = B * kcomp(:,Li,ti1,pi2);
        %   kt2 = B * kct2;
	%   kt2p1 = B * kcomp(:,Li,ti2,pi1);
	%   kt2p2 = B * kcomp(:,Li,ti2,pi2);
        %   ktL = B * kcmp1(:,Li);
        %   semilogy(fr, kt2, 'r', fr, kt2p1, 'r--', fr, kt2p2, 'r-.', ...
        %            fr, kt1, 'g', fr, kt1p1, 'g--', fr, kt1p2, 'g-.', ...
        %            fr, ktL, 'k')
        %   legend(num2str([t2,p1/pL,p2/pL,t1,p1/pL,p2/pL,tL]'));
	%   title('pressure and temperature interpolation check')
	%   ylabel('log(k)')
	%   pause
        % end % test plot

      end % H2O test

      % scale interpolated compact absorptions by actual partial press
      kcmp1(:,Li) = ...
         kcmp1(:,Li) .* ((prof.gamnt(Li,gind) / refamnt(Li)) .^ kpow);

    end % layer loop

    % accumulate expanded absorptions
    % absc = absc + (B * kcmp1).^(1/kpow);
    % split up for timing:
    atmp = B * kcmp1;
    % atmp = atmp .^ (1/kpow);
    atmp = (atmp .^ 2) .^ 2;
    absc = absc + atmp;

  end % compressed data existance check

end % gas loop

