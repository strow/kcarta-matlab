
function [zang]=vaconv( sva, salt, alt );

% function [zang]=vaconv( sva, salt, alt );
%
% Convert the satellite viewing angle into the local path zenith angle.
%
% Input:
%    sva  : (1 x nobs) satellite/observing viewing angle (degrees)
%    salt : (1 x nobs) satellite/observing altitude (meters)
%    alt  : (nlevs x nobs) local path altitude (meters)
%
% Output:
%    zang : (nlevs x nobs) zenith angle (degrees)
%

% Created by Scott Hannon, 6 June 2002; based on our FORTRAN "vaconv.f"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    The layers of the atmosphere may be considered as concentric
%    rings with some average altitude. A ray traced thru these rings
%    at any viewing angle other than nadir will have a slightly
%    different angle (relative to the outward radial at the point
%    of intersection) in each ring. 
%
%    If the Earth is treated as a perfect sphere of radius RE (hard
%    coded into this routine), then the local angle may be calculated
%    using trigonometry if we know:
%       The satellite viewing angle
%       The satellite's altitude above the Earth's surface
%       The layer's altitude above the Earth's surface.
%
%    The solution uses the law of sines and sin(180 - x) = sin(x)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check input

[nrow,nobs]=size(sva);
if (nrow ~= 1)
   error('sva must be a [1 x nobs] vector')
end

[nrow,ncol]=size(salt);
if (nrow ~= 1)
   error('salt must be a [1 x nobs] vector')
end
if (ncol ~= nobs)
   error('sva and salt must both be [1 x nobs] vectors')
end

[nlevs,ncol]=size(alt);
if (ncol ~= nobs)
   error('alt must be a [nlevs x nobs] matrix')
end


% conv = pi/180 = degrees to radians conversion factor
conv=pi/180;

% re = radius of the Earth (in meters)
re=6.37E+06;


% ra = radius of the point to calc the angle at (in meters)
ra=re + alt;

% rs = radius of the satellite orbit (in meters)
rs=re + ones(nlevs,1)*salt;


% Calc the zenith angle
zang = asin( (rs./ra) .* sin(conv*ones(nlevs,1)*sva) )/conv;


%%% end of function %%%
