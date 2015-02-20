function [fr, gasQ, absc, jacTG, jacQG, iNumVec] = kcmix2jac(prof, gidIN, vchunk,...
                                                         ropt0,iDoJac,refp,df)

% function [fr, gasQ, absc, jacTG, jacQG, iNumVec] = kcmix(prof, vchunk, ...
%                 kpath, co2ChiFilePath,iDoJac,refp)
% 
% calculate a 25 1/cm "chunk" of mixed absorptions for a
% supplied profile, from tabulated compressed absorptions
%
% INPUTS
%
%    prof    - matlab profile strucure
%    vchunk  - start frequency of chunk
%    kpath   - path to compressed absorption data
%    iDoJac  - gasID(s) for which we need jacobians [length of array = G]
%    refp    - matlab reference profile
%
% OUTPUT
%  
%    absc    - 10^4 x nlay array of mixed absorptios
%    fr      - 10^4 vector of associated frequencies
%    jacTG   - 10^4 x nlay array of d/dT, always computed
%    jacQG   - 10^4 x nlay array of d/dQ if gasID == iDoJac, zero ow
%    gasQ    - 1 x nlay array of gasprofile if gasID == iDoJac, zero ow
%    iNumVec - number of kComp vectors (0 if none found)
%
% NOTES
%
% The reference profile is the profile that was used in generating
% the coefficient tabulation.  Layers in the reference profile must
% span layers in the input profile.
%
% We assume the reference profile and the coefficient database
% are reliable, so gasses that are not in the reference profile,
% or for which there is no data for a particular 25 1/cm interval, 
% are simply skipped.
%
% Modified so that it includes CO2 chi functions for the 2255,2280,
% 2355-2430 cm-1 regions
%
% PROFILE FORMAT
%
% A Matlab structure is used for the input and reference profiles.
% The following fields are used by kcmix:
%
%    glist  -  ngas vector of HITRAN gas IDs
%    mpres  -  nlay vector of combined gas layer pressures, mb
%    mtemp  -  nlay vector of combined gas layer temperatures, K
%    gamnt  -  nlay x ngas array of gas amounts, kmole/cm^2
%    gpart  -  nlay x ngas array of gas partial pressures, mb
%
% BUGS
%
% default paths for compressed data and the reference profile are 
% currently set to test directories
%
% various parameters, such as temperature and pressure offsets,
% and the compression exponent, are fixed in the code; it would
% be more general to read these in with the compressed data
%

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

% initialize absorption output array
absc = zeros(1e4, nlay);
jacX = zeros(1e4, nlay);
jacTG = zeros(1e4, nlay);
jacQG = zeros(1e4, nlay);
gasQ  = zeros(nlay,1);

% initialize frequency array
fr = vchunk + (0:9999)*df;

%% ropt0.iMatlab_vs_f77 = -1;    %% use f77 binary database
%% ropt0.iMatlab_vs_f77 = +1;    %% use Matlab binary database
if ropt0.iMatlab_vs_f77 == -1
  % kCARTA databases
  kpathh2o = ropt0.kpathh2o;
  kpathhDo = ropt0.kpathhDo;
  kpathco2 = ropt0.kpathco2;
  kpathetc = ropt0.kpathetc;
elseif ropt0.iMatlab_vs_f77 == +1
  kpath = ropt0.kpath;
  end

%iBlah = 0;

% loop on gasses in the supplied profile
xyz = find(prof.glist == gidIN);
for gind = xyz : xyz
  gid = prof.glist(gind);

  % get file name of compressed data for this gas and chunk
  if ropt0.iMatlab_vs_f77 < 0
    cgxfile = get_kcompname_F77(ropt0,vchunk,gid);
  else
    cgxfile = sprintf('%s/cg%dv%d.mat', kpath, gid, vchunk);
    end

  % index of current gas ID in the reference profile
  rgind = find(refpro.glist == gid);

  iNumVec = 0;   %% assume no compressed data

  % check that we have reference and compressed data for this gas
  if ~isempty(rgind) & exist(cgxfile) == 2
    
    %disp('   found kCompressed file ... ');

    % load compressed coefficient file, defines var's:
    %
    %   B       10000 x d         absorption basis
    %   fr          1 x 10000     associated frequencies
    %   gid         1 x 1         HITRAN gas ID
    %   kcomp       d x 100 x 11  compressed coefficients
    %
    if ropt0.iMatlab_vs_f77 < 0
      [fr, fstep, toffset, kcomp, B, gid, ktype] = rdgaschunk_le(cgxfile);
    else
      eval(sprintf('load %s', cgxfile));
      end

    [n, d] = size(B);
    iNumVec = d;   %% we found compressed data

    % divide the reference gas amount out of kcomp
    % (note: it would be faster to do this once, before 
    % the gasses are saved in the compressed database!)

    refgamt2 = ones(d,1) * (refpro.gamnt(:,rgind) .^ kpow)';
    if gid == 1 | gid == 103
      for i = 1 : 55
        kcomp(:,:,i) = kcomp(:,:,i) ./ refgamt2;
      end
    else
      for i = 1 : 11
        kcomp(:,:,i) = kcomp(:,:,i) ./ refgamt2;
      end
    end

    % space for compact absorption coeff's for current gas
    kcmp0 = zeros(d, nlay);    %% need this one for derivatives
    kcmp1 = zeros(d, nlay);

    toffset = toffset';

    % loop on layer indices
    for Li = 1 : nlay
      % get pressure bounding interval and interpolation weight
      % pressures are in decreasing order: i < j implies p(i) > p(j)
      pL = prof.mpres(Li);  % nominal pressure of mixed layer Li

      % get pressure tabulation bounding interval [p1, p2]
      pi1 = max([find(pL <= refpro.mpres); 1]); 
      pi2 = min([find(refpro.mpres <= pL); length(refpro.mpres)]);
      p1 = refpro.mpres(pi1);  % upper pressure bound
      p2 = refpro.mpres(pi2);  % lower pressure bound
      if p1 ~= p2
        % pressure interpolation weight
        pw2 = (pL - p1) / (p2 - p1);
	pw1 = 1 - pw2;
      else
        pw2 = 1; 
	pw1 = 0;
      end

      % get temperature bounding interval and interpolation weights
      % temperatures are in increasing order: i < j implies t(i) < t(j)
%      tL = prof.mtemp(Li) + iBlah;  % nominal temperature of mixed layer Li
      tL = prof.mtemp(Li);  % nominal temperature of mixed layer Li

      % get temperature tabulation bounding interval [t11, t12] at p1
      tspan1 = toffset + refpro.mtemp(pi1);
      ti11 = max([find(tspan1 <= tL), 1]);
      ti12 = min([find(tL <= tspan1), length(tspan1)]);
      t11 = tspan1(ti11);  % lower temperature bound at p1
      t12 = tspan1(ti12);  % upper temperature bound at p1
      if t11 ~= t12
        % temperature interpolation weight
        tw12 = (tL - t11) / (t12 - t11);
	tw11 = 1 - tw12;
        jtw12 = +1/(t12-t11);           jtw11 = -1/(t12-t11);   
      else 
        tw12 = 1;
	tw11 = 0;
        %% probably gonna crash, but I hope this condition never met
        jtw12 = +1/(t12-t11);           jtw11 = -1/(t12-t11);   
      end

      % get temperature tabulation bounding interval [t21, t22] at p2
      tspan2 = toffset + refpro.mtemp(pi2);
      ti21 = max([find(tspan2 <= tL), 1]);
      ti22 = min([find(tL <= tspan2), length(tspan2)]);
      t21 = tspan2(ti21);  % lower temperature bound at p2
      t22 = tspan2(ti22);  % upper temperature bound at p2
      if t21 ~= t22
        % temperature interpolation weight
        tw22 = (tL - t21) / (t22 - t21);
	tw21 = 1 - tw22;
        jtw22 = +1/(t22-t21);           jtw21 = -1/(t22-t21);   
      else 
        tw22 = 1;
	tw21 = 0;
        %% probably gonna crash, but I hope this condition never met
        jtw22 = +1/(t22-t21);           jtw21 = -1/(t22-t21);   
      end

      if gid ~= 1 & gid ~= 103
        % do pressure and temperature interpolation

	% interpolate four corners in 2-space
	kcmp1(:,Li) = kcomp(:,pi1,ti11) * pw1 * tw11 + ...
		      kcomp(:,pi1,ti12) * pw1 * tw12 + ...
		      kcomp(:,pi2,ti21) * pw2 * tw21 + ...
                      kcomp(:,pi2,ti22) * pw2 * tw22;

        wsum = pw1*tw11 + pw1*tw12 + pw2*tw21 + pw2*tw22;
        if ~ (1 - eps <= wsum & wsum <= 1 + eps)
	   fprintf(1, 'error: for regular interp, wsum ~= 1\n');
	   keyboard
           end
 
        jac1(:,Li) = kcomp(:,pi1,ti11) * pw1 * jtw11 + ...
	             kcomp(:,pi1,ti12) * pw1 * jtw12 + ...
                     kcomp(:,pi2,ti21) * pw2 * jtw21 + ...
                     kcomp(:,pi2,ti22) * pw2 * jtw22;

      else
        % do pressure, temperature, and partial pressure interp

        % get partial pressure interval and interpolation weight
	% (partial pressures are tabulated in increasing order)
        qL = prof.gpart(Li,gind);       % partial pressure, this layer

	% get partial pressure tabulation bounding interval [q1, q2] at p1
	qspan1 = poffset * refpro.gpart(pi1,rgind);
        qi11 = max([find(qspan1 <= qL), 1]);
        qi12 = min([find(qL <= qspan1), length(poffset)]);
        q11 = qspan1(qi11);
        q12 = qspan1(qi12);
        if q11 ~= q12
	  % partial pressure interpolation weight
          qw12 = (qL - q11) / (q12 - q11);
	  qw11 = 1 - qw12;
        else
          qw12 = 1;
	  qw11 = 0;
        end

	% get partial pressure tabulation bounding interval [q1, q2] at p2
	qspan2 = poffset * refpro.gpart(pi2,rgind);
        qi21 = max([find(qspan2 <= qL), 1]);
        qi22 = min([find(qL <= qspan2), length(poffset)]);
        q21 = qspan2(qi21);
        q22 = qspan2(qi22);
        if q21 ~= q22
	  % partial pressure interpolation weight
          qw22 = (qL - q21) / (q22 - q21);
	  qw21 = 1 - qw22;
        else
          qw22 = 1;
	  qw21 = 0;
        end

	% interpolate eight corners in 3-space
	kcmp1(:,Li) = kcomp(:,pi1,ti11,qi11) * pw1 * tw11 * qw11 + ...
		      kcomp(:,pi1,ti12,qi11) * pw1 * tw12 * qw11 + ...
		      kcomp(:,pi2,ti21,qi21) * pw2 * tw21 * qw21 + ...
                      kcomp(:,pi2,ti22,qi21) * pw2 * tw22 * qw21 + ...
		      kcomp(:,pi1,ti11,qi12) * pw1 * tw11 * qw12 + ...
		      kcomp(:,pi1,ti12,qi12) * pw1 * tw12 * qw12 + ...
		      kcomp(:,pi2,ti21,qi22) * pw2 * tw21 * qw22 + ...
                      kcomp(:,pi2,ti22,qi22) * pw2 * tw22 * qw22 ;

        wsum = pw1 * tw11 * qw11 + pw1 * tw12 * qw11 + ...
	        pw2 * tw21 * qw21 + pw2 * tw22 * qw21 + ...
		pw1 * tw11 * qw12 + pw1 * tw12 * qw12 + ...
		pw2 * tw21 * qw22 + pw2 * tw22 * qw22 ;

        if ~ (1 - 2*eps <= wsum & wsum <= 1 + 2*eps)
	   fprintf(1, 'error: for H2O interp, wsum ~= 1\n');
	   keyboard
	end

	jac1(:,Li) =  kcomp(:,pi1,ti11,qi11) * pw1 * jtw11 * qw11 + ...
        	      kcomp(:,pi1,ti12,qi11) * pw1 * jtw12 * qw11 + ...
		      kcomp(:,pi2,ti21,qi21) * pw2 * jtw21 * qw21 + ...
                      kcomp(:,pi2,ti22,qi21) * pw2 * jtw22 * qw21 + ...
		      kcomp(:,pi1,ti11,qi12) * pw1 * jtw11 * qw12 + ...
		      kcomp(:,pi1,ti12,qi12) * pw1 * jtw12 * qw12 + ...
		      kcomp(:,pi2,ti21,qi22) * pw2 * jtw21 * qw22 + ...
                      kcomp(:,pi2,ti22,qi22) * pw2 * jtw22 * qw22 ;

      end % H2O test

      % scale interpolated compact absorptions by profile gas amount
      kcmp1(:,Li) = kcmp1(:,Li) .* (prof.gamnt(Li,gind) .^ kpow);
      jac1(:,Li)  = jac1(:,Li)  .* (prof.gamnt(Li,gind) .^ kpow);

    end % layer loop

    % accumulate expanded absorptions
    if kpow == 1/4
      absc = absc + ((B * kcmp1).^ 2) .^ 2;         % faster when kpow = 1/4
      jacTG = jacTG + ((B * kcmp1).*(B * kcmp1).^ 2); % this is the cubic part
      jacX = jacX + (B * jac1);                     % this is d(K)/dT
    else
      absc = absc + (B * kcmp1).^(1/kpow);  % the general case
      error('I have not coded jacs for a general case!!!!')
    end

    jacTG = 4*jacX.*jacTG;

    if length(intersect(iDoJac,gid)) == 1
      gasQ = prof.gamnt(:,gind);
      jacQG = absc./(ones(1e4,1)*gasQ');
      end

    if (gid == 2)
      iChi = -1;
      if vchunk == 2255
        chix = 'co2_4um_fudge_2255_a.txt';
        iChi = +1;
      elseif vchunk == 2280
        chix = 'co2_4um_fudge_2280_a.txt';
        iChi = +1;
      elseif vchunk == 2380
        chix = 'co2_4um_fudge_2380_b.txt';
        iChi = +1;
      elseif vchunk == 2405
        chix = 'co2_4um_fudge_2405_b.txt';
        iChi = +1;
        end
      if iChi > 0
        fprintf(1,'   CO2 chi function for %5i \n',floor(vchunk));
        chi = [ropt0.co2ChiFilePath chix];
        chi = load(chi);
        chi = chi(:,2); chi = chi*ones(1,length(prof.mtemp));
        absc = absc.*chi;
        end
      end
               
  end % valid gas ID and compressed data existance check

end % gas loop

