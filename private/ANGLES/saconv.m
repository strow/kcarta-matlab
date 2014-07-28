
function [zang]=saconv( surfzang, alt );

% function [zang]=saconv( surfzang, alt );
%
% Convert the a surface (alt=0) zenith angle into the zenith angle
% at another altitude.
%
% Input:
%    surfzang : (1     x nobs) surface zenith angle (degrees)
%    alt      : (nlevs x nobs) desired altitude (meters)
%
% Output:
%    zang     : (nlevs x nobs) zenith angle at alt (degrees)
%

% Created: Scott Hannon, 25 Oct 2004 - based on FORTRAN "saconv.f"
% Update: 10 Jul 2009, S.Hannon - update comments to correct dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check input
[nrow,nobs]=size(surfzang);
if (nrow ~= 1)
   error('surfzang must be a [1 x nobs] vector')
end
%
[nlevs,ncol]=size(alt);
if (ncol ~= nobs)
   error('alt must be a [nlevs x nobs] matrix')
end

% conv = pi/180 = degrees to radians conversion factor
conv=pi/180;

% re = radius of the Earth (in meters)
re=6.37E+06;

% ra = radius of the point where to calc the angle at (in meters)
ra=re + alt;

% Calc the zenith angle (in degrees)
zang = asin( (re./ra) .* (ones(nlevs,1)*sin(conv*surfzang)) )/conv;

%%% end of function %%%
