
% NAME
%
%   clist - return list of chunk start frequencies 
%
% SYNOPSIS
%
%   cv = clist(v1, v2, db);
%
% INPUTS
%
%   v1  - lower frequency bound
%   v2  - upper frequency bound 
%   db  - database version 
% 
% OUTPUT
%
%   cv  - a list of chunk starting frequencies
% 
% DESCRIPTION
%
%   clist takes the input frequency interval [v1,v2] and returns
%   a list of starting frequencies for the smallest set of chunks
%   spanning the interval [v1,v2-dv], where dv is the frequency
%   spacing at the end of the last chunk.  Chunk frequencies are 
%   assumed to be integers, and are returned in increasing order.
%
%   The parameter db is the database version; versions 1 and 2
%   use the original uniform 0.0025 wavenumber spacing
%
% BUGS
%
%   This function is just a place holder for a fancier version
%   (coefficient database version 3 and up) that with variable 
%   frequency spacing.
%
% AUTHOR
%
%   H. Motteler, 22 May 02
%   

function  cv = clist(v1, v2, db);

% default to an old-style fixed-spacing grid
if nargin == 2
  db = 2;
end

if db == 1 | db == 2

  % do an old-style fixed-spacing grid

  % round v1 and v2 to the nearest grid points
  dv = 0.0025;
  v1 = round( v1/dv ) * dv;
  v2 = round( v2/dv ) * dv;

  % extend v1 and v2 to fixed chunk boundaries
  v1 = 25 * floor((v1 - 5) / 25) + 5;
  v2 = 25 * ceil((v2 - 5) / 25) + 5;

  % build the output chunk list
  cv = [];
  for v = v1 : 25 : v2 - 25;
    cv = [cv, v];
  end

else

  % use a variable freqency grid

  error(sprintf('unknown database code %d', db));

end

