function [zang]=sunang_conv( sza, alt );

% function [zang]=sunang_conv( sza, alt );
%
% Convert the solar zenith angle into the local path zenith angle.
%
% Input:
%    sza  : (1 x nobs) satellite/observing viewing angle (degrees)
%    alt  : (nlevs x nobs) local path altitude (meters)
%
% Output:
%    zang : (nlevs x nobs) zenith angle (degrees)
%

% Created by Sergio Machado, July 2003; based on FORTRAN/MATLAB "vaconv.f"
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
%       The sun's altitude above the Earth's surface == inf
%       The layer's altitude above the Earth's surface.
%
%    The solution uses the law of sines and sin(180 - x) = sin(x)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check input

[nrow,nobs]=size(sza);
if (nrow ~= 1)
   error('sza must be a [1 x nobs] vector')
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

% Calc the zenith angle
zang = asin( (re./ra) .* sin(conv*ones(nlevs,1)*sza) )/conv;

%%% end of function %%%
