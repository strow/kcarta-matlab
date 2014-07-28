function [idchan, freq, coef] = rd_nte_le(fname);

% function [idchan, freq, coef] = rd_nte(fname);
%
% Reads in binary FORTRAN non-LTE data file created by program "wrt_nte.m".
% same as /home/hannon/Fit_deltaR_nonLTE/Src/rd_nte.m and expects one of
% Scott Hannon's big-endian files
%
% Input:
%    fname = {string} name of binary FORTRAN data file to read
%
% Output:
%    idchan   = [nchan x 1] channel ID
%    freq     = [nchan x 1] center frequency
%    coef     = [nchan x 6 or 7] non-LTE coeffcients
%

% Created: 15 March 2005, Scott Hannon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is 4 bytes each for (idchan, freq, & 6 coefs)
% Expected value of ifm = 4*(1 + 1 + 6) = 32 
ifm_exp(1) = 32;

% This is 4 bytes each for (idchan, freq, & 7 coefs)
% Expected value of ifm = 4*(1 + 1 + 7) = 36 
ifm_exp(2) = 36;
% Expected value of ifm = 4*(1 + 1 + 9) = 44 
ifm_exp(2) = 44;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The code below should not require modifications
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d = dir(fname);
nCoeff = -1;
junk(1) = d.bytes/(ifm_exp(1) + 8*0);
junk(2) = d.bytes/(ifm_exp(2) + 9*0);
nchan = round(junk);
if (abs(junk(1) - nchan(1)) < 0.0001)
  disp('looks like 6 coeffs')
  nCoeff = 6;
  xnchan = nchan(1);
  xifm = 36;
elseif (abs(junk(2) - nchan(2)) < 0.0001)
  disp('looks like 7 coeffs')
  nCoeff = 7;
  xnchan = nchan(2);
  xifm = 36;
else
   error('Unexpected file size')
end

ifm_exp = xifm;
nchan = xnchan;
% Open output file
fid=fopen(fname,'r','ieee-le');

% Dimension output arrays
idchan=zeros(nchan,1);
freq=zeros(nchan,1);
coef=zeros(nchan,nCoeff);

% Loop over the channels
for ic=1:nchan

   % Read FORTRAN start-of-record marker
   [ifm,count]=fread(fid,1,'integer*4');
   if (count == 0)
      ic
      disp('The FORTRAN data file contains fewer channels than expected')
   end
   if (ifm ~= ifm_exp)
      ifm
      ifm_exp
      error('FORTRAN start-of-record marker is unexpected size')
   end

   % Read data for this channel
   idchan(ic)=fread(fid,1,'integer*4');
   freq(ic)=fread(fid,1,'real*4');
   coef(ic,:)=fread(fid,[1,nCoeff],'real*4');

   % Read FORTRAN end-of-record marker
   ifm=fread(fid,1,'integer*4');
   if (ifm ~= ifm_exp)
      ifm
      ifm_exp
      error('FORTRAN end-of-record marker is unexpected size')
   end

end % end of loop over bands

fclose(fid);

%%% end of function %%%
