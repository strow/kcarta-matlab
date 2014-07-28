function [f, fstep, toff, K, U, gid, ktype] = rdgaschunk_le(fname);

% function [f, fstep, toff, K, U, gid, ktype] = rdgaschunk_le(fname);
%
% Read a "chunk" of compressed kcarta data for some gas.
% Little-endian version.
%
% Input:
%    fname = [string] name of little-endian kcarta database file to read
%
% Output:
%    f     = double [1 x npts] frequency points {cm^-1}
%    fstep = double [1 x 1] frequency step {cm^-1}
%    toff  = double [1 x ntemp] temperature offsets
%    K     = double [nvec x nlay x ntemp*npp] K matrix (aka kcomp matrix)
%    U     = double [npts x nvec] U matrix (aka B matrix)
%    gid   = integer [1 x 1] HITRAN gas ID
%    ktype = integer [1 x 1] k-data type {1=sqrt, 2=sqrt(sqrt)}
%
% Note: to uncompress, first apply the inverse ktype adjustment to K, and
% then do U*K, giving a [npts x nlay x ntempx*npp] lookup table of optical
% depth for the reference profile at toff.  For gid=1 (water), npp=5,
% while for all other gasses npp=1;
%

% Created: 27 May 2009, Scott Hannon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open file
[fid, msg] = fopen(fname,'r','ieee-le');
if (fid == -1)
   error(msg);
end

% Read header
[ifm,count] = fread(fid,1,'uint32');    % start record marker
if (ifm ~= 52)
   error('Unexpected length of header record')
end
[gid,count] = fread(fid,1,'int32'); % gas ID
[sfreq,count] = fread(fid,1,'float64'); % start freq
[fstep,count] = fread(fid,1,'float64'); % freq step
[npts,count] = fread(fid,1,'int32');    % number of freq points
[nlay,count] = fread(fid,1,'int32');    % number of layers
[ktype,count] = fread(fid,1,'int32');   % kdata type
[k1,count] = fread(fid,1,'int32');      % K1 number of vectors
[k3,count] = fread(fid,1,'int32');      % K3 number of temp offs
[k2,count] = fread(fid,1,'int32');      % K2 number of layers
[u1,count] = fread(fid,1,'int32');      % U1 number of freq points
[u2,count] = fread(fid,1,'int32');      % U2 number of vectors
[ifm,count] = fread(fid,1,'uint32');    % end record marker
%
ntemp = k3;
if (gid == 1 | gid == 103)
   k4 = 5;
else
   k4 = 1;
end
f = sfreq + fstep*(0:round(npts - 1));

% Read temperature offsets
[ifm,count] = fread(fid,1,'uint32');       % start record marker
if (ifm ~= ntemp*8)
   error('Unexpected length of TOFF record')
end
[toff,count] = fread(fid,ntemp,'float64'); % temperature offsets
[ifm,count] = fread(fid,1,'uint32');       % end record marker

% Read K matrix
ifmx = round(k2*k3*8); % exact integer
if (k4 > 1)
   K = zeros(k1,k2,k3,k4);
   for i4=1:k4
      for ivec=1:k1
         [ifm,count] = fread(fid,1,'uint32');                  % start rec mark
         if (ifm ~= ifmx)
            error('Unexpected length of K-matrix')
         end
         for i3=1:k3
            [K(ivec,:,i3,i4),count] = fread(fid,k2,'float64'); % K matrix data
         end
         [ifm,count] = fread(fid,1,'uint32');                  % end rec mark
      end
   end
else
   K = zeros(k1,k2,k3);
   for ivec=1:k1
      [ifm,count] = fread(fid,1,'uint32');               % start record marker
      if (ifm ~= ifmx)
         error('Unexpected length of K-matrix')
      end
      for i3=1:k3
         [K(ivec,:,i3),count] = fread(fid,k2,'float64'); % K matrix data
      end
      [ifm,count] = fread(fid,1,'uint32');               % end record marker
   end
end

% Read U matrix
U = zeros(u1,u2);
ifmx = round(u1*8); % exact integer
for ivec=1:u2
   [ifm,count] = fread(fid,1,'uint32');         % start record marker
   if (ifm ~= ifmx)
disp('u matrix error')
keyboard
      error('Unexpected length of U-matrix')
   end
   [U(:,ivec),count] = fread(fid,u1,'float64'); % U-matrix data
   [ifm,count] = fread(fid,1,'uint32');         % end record marker
end

% Close file
st = fclose(fid);

%%% end of function %%%
