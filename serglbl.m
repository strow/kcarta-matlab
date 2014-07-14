
function [k, fr] = serglbl(prof, vchunk, topts)

% function [k, fr] = serglbl(prof, vchunk, topts)
%
% serglbl -- line by line abs calc on selected profile
%
% serglbl calls Sergio's "run6", "run6co2", and "run6water",
% as relevant (with some some defaults set) on an arbitrary
% profile, and returns the resulting absorptions
%
% inputs
%
%   prof   - matlab profile structure
%   vchunk - starting wavenumber
%   topts  - option to override default parameters
%
% outputs
%
%   k   - 10000 x 100 array of  tabulated absorptions
%   fr  - 1 x 10000 vector,  frequency scale
%
% bugs
%
%   need to cd to appropriate "spectra" dir before calling
%   uses assorted hard-wired paths

% change to lbl work directory
prevdir = pwd;
% cd /home/motteler/sergio/spectra10
cd /carrot/s1/motteler/sergio/spectra11

% some assorted "run6" default parameters are set here;
% the rest are just fixed in the calling arg list, for now

% general "run6.m" (not CO2 or H2O) parameters
str_far = 0;	% min line strength for far wing lines
str_near = 0;	% min line strength for near wing lines
LVG = 'V';	% (L)orentz, Voi(G)t, (V)anHuber
CKD = 1;	% leave on, for N2 and O2

% "run6co2.m" parameters
LVF = 'F';	% (L)orentz, (V)oigt/vaan Huber, (F)ull 

% "run6water.m" parameters
LVG1 = 'V';	% (L)orentz, Voi(G)t, (V)anHuber
CKD1 = -1;	% no continuum--leave off for tabulations
local = 0;	% local lineshape w/o chi

% option to override defaults with topts fields
if nargin == 3
  optvar = fieldnames(topts);
  for i = 1 : length(optvar)
    eval(sprintf('%s = topts.%s;', optvar{i}, optvar{i}));
  end
end

% initialize output array
k = zeros(10000,100);

% temporary local filename for the "run6" input profile
[dtmp, ftmp] = fileparts(tempname);  
ftmp = ['./', ftmp]; 

% loop on profile gasses
for gind = 1:length(prof.glist)

  gid = prof.glist(gind);

  % build an ascii format profile for "run6"
  prof2 = zeros(100,5);
  prof2(:, 1) = (1:100)';			  % layer number
  prof2(:, 2) = prof.mpres;			  % pressure
  prof2(:, 3) = prof.gpart(:, gind);		  % partial pressure
  prof2(:, 4) = prof.mtemp;			  % temperature
  prof2(:, 5) = prof.gamnt(:, gind);		  % gas amount

  v1 = vchunk;
  v2 = v1 + 25;

  % write input profile for "run6"
  eval(sprintf('save %s prof2 -ascii', ftmp)); 

  if gid == 1
              
    % H2O absorption
    [fr, k1] = run6water(gid, v1, v2, 0.0005, 0.1, 0.5, ...
                          1, 1, 2, 25, 5, str_far, str_near, ...
                          LVG1, CKD1, 1, 1, 1, local, ftmp);
  elseif gid == 2

    % CO2 absorption
    [fr, k1] = run6co2(gid, v1, v2, 0.0005, 0.1, 0.5, ...
                       1, 1, 2, 250, 5, str_far, str_near, ...
                       LVF, '1', 'b', ftmp);
  
  else 

    % all other (non xsec) gasses
    [fr, k1] = run6(gid, v1, v2, 0.0005, 0.1, 0.5, ...
                    1, 1, 2, 25, 5, str_far, str_near, ...
	            LVG, CKD, ftmp);
  end

  k = k + k1';

  % give a warning for negative values
  kmin = min(min(k));
  if kmin < 0
    fprintf(2, 'WARNING negative absorptions, GID=%d, %g\n', gid, kmin);
  end

end % gas ID loop

% clean up
if exist(ftmp) == 2
  delete(ftmp);
end

% return to starting dir
cd(prevdir)

