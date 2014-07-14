%
% NAME
%
%   getsol -- return solar radiance data
%
% SYNOPSIS
%
%   rad = getsol(freq, ropt)
%
% INPUTS
%
%   freq   - requested frequency scale
%   ropt   - optional additional parameters
% 
% OUTPUTS
%
%   rad    - solar radiances at the requested frequency scale
% 
% DESCRIPTION
%
%   getsol reads the solar spectra once and keeps it in a persistent
%   local variable.  Each time it is called it interpolates the saved
%   solar radiances to the requested frequency scale and returns the
%   result.
%
% BUGS
%
%   This procedure is relatively slow, it would be faster to split the 
%   data into 1e4-sized chunks, and do the interpolation (if necessary)
%   ahead of time.
%

function rad = getsol(freq, rotp);

% default location for monochromatic solar data
sfile = 'fine_solar.mat';  

% override defaults with values passed in as ropt fields
if nargin == 2
  optvar = fieldnames(ropt);
  for i = 1 : length(optvar)
    vname = optvar{i};
    % if ~exist(vname, 'var')
    %   warning(sprintf('unexpected option %s', vname))
    % end
    eval(sprintf('%s = ropt.%s;', vname, vname));
  end
end

persistent solfreq solrad

if isempty(solrad)

  fprintf(1, 'reading solar data file %s\n', sfile)

  % a load of the solar data file should return the variables
  %
  %   fout       1x1120001    8960008  double array
  %   rout       1x1120001    8960008  double array
  %
  s = load(sfile);
  solfreq = s.fout;
  solrad = s.rout;
  clear s
end

rad = interp1(solfreq, solrad, freq, 'linear');

