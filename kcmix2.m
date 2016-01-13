function [absc, fr, iNumVec] = kcmix2(itlo, ithi, twlo, twhi, pi1Out, gidIN, ...
                                  prof, vchunk, ropt0, refp,...
                                  fr,absc, prefix, df)

% function [absc, fr, iNumVec] = kcmix(prof, vchunk, kpath, refp)
% 
% calculate a 25 1/cm "chunk" of mixed absorptions for a
% supplied profile, from tabulated compressed absorptions
%
% INPUTS
%
%    twlo, twhi are temperature interpolation weights
%    itlo, ithi are temperature interpolation indices
%    pi1Out     is the refpro index
%    prof    - matlab profile strucure
%    vchunk  - start frequency of chunk
%    kpath   - path to compressed absorption data
%    refp    - matlab reference profile
%
% OUTPUT
%  
%    absc    - 10^4 x nlay array of mixed absorptios
%    fr      - 10^4 vector of associated frequencies
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

kcompress_inits

% loop on required gas in the supplied profile
xyz = find(prof.glist == gidIN);
for gind = xyz : xyz
  gid = prof.glist(gind);

  % get file name of compressed data for this gas and chunk
  if ropt0.iMatlab_vs_f77 < 0
    cgxfile = get_kcompname_F77(ropt0,vchunk,gid,prefix);
  else
    cgxfile = sprintf('%s/cg%dv%d.mat', kpath, gid, vchunk);
  end

  
  % index of current gas ID in the reference profile
  rgind = find(refpro.glist == gid);

  iNumVec = 0;   %% assume no compressed data

  % check that we have reference and compressed data for this gas
  if ~isempty(rgind) & exist(cgxfile) == 2
    
    fprintf(1,'   found kCompressed file ... %s \n',cgxfile);

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

    % space for compact absorption coeff's for current gas
    kcmp1 = zeros(d, nlay);

    % loop on layer indices
    for Li = 1 : nlay
      iLr = 101 - Li;  % bottom-up layer index for kcarta and refpro

      % get pressure bounding interval and interpolation weight
      % pressures are in decreasing order: i < j implies p(i) > p(j)
      %pL = prof.mpres(Li);  % nominal pressure of mixed layer Li
      %pi1 = pi1Out(Li); pi1 = iLr;

      % get temperature bounding interval and interpolation weights
      % temperatures are in increasing order: i < j implies t(i) < t(j)

      tL = prof.mtemp(Li);  % nominal temperature of mixed layer Li

      if gid ~= 1 & gid ~= 103
        % do pressure and temperature interpolation

	% interpolate four corners in 2-space
	kcmp1(:,Li) = kcomp(:,iLr,itlo(Li)) * twlo(Li) + ...
		      kcomp(:,iLr,ithi(Li)) * twhi(Li);

      else
        % do pressure, temperature, and partial pressure interp

        % get partial pressure interval and interpolation weight
	% (partial pressures are tabulated in increasing order)
        qL = prof.gpart(Li,gind);       % partial pressure, this layer

	% get partial pressure tabulation bounding interval [q1, q2] at p1
	qspan1 = poffset * refpro.gpart(iLr,rgind);
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

        %fprintf(1,'%3i  %8.6f %8.6f %8.6f %8.6f\n',Li,twlo(Li),twhi(Li),qw11,qw12)
        %fprintf(1,'%3i  %8.6f %8.6f\n',Li,twhi(Li),qw12)

	% interpolate temperature and partial pressure
	kcmp1(:,Li) = kcomp(:,iLr,itlo(Li),qi11) * twlo(Li) * qw11 + ...
		      kcomp(:,iLr,ithi(Li),qi11) * twhi(Li) * qw11 + ...
		      kcomp(:,iLr,itlo(Li),qi12) * twlo(Li) * qw12 + ...
		      kcomp(:,iLr,ithi(Li),qi12) * twhi(Li) * qw12;

      end % H2O test

      % scale interpolated compact absorptions by profile gas amount

      kcmp1(:,Li) = kcmp1(:,Li) .* ...
         ((prof.gamnt(Li,gind)./refpro.gamnt(iLr,rgind)) .^ kpow);

    end % layer loop
%error('lkjlkj')


    % accumulate expanded absorptions
    if kpow == 1/4
      od_gas = ((B * kcmp1).^ 2) .^ 2;  % faster when kpow = 1/4
    else
      od_gas = (B * kcmp1).^(1/kpow);  % the general case
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
        od_gas = od_gas.*chi;
      end
    end

    wonk = find(isnan(od_gas));
    if length(wonk) > 0
      fprintf(1,'   warning : found %6i NaNs in ODs for gas % 3i \n',length(wonk),gid);
      od_gas(wonk) = 0.0;
    end

      absc = absc + od_gas;    %%% update absc (output) from the (input) value
% this is debugging WV vs HDO
%     if gid ~= 103
%       absc = absc + od_gas;    %%% update absc (output) from the (input) value
%     elseif gid == 103
%       disp('pah haevy water')
%     end

  end % valid gas ID and compressed data existance check

end % gas loop

