disp('the monochromatics are in')
disp('  radAllChunks , freqAllChunks              : rads, freqs')

iDoJac = stuff.iDoJac;
fA = stuff.freqs(1);  fB = stuff.freqs(2); 
iProfRun = stuff.iProfRun;  ip = iProfRun;
freqs = radsOut.freqAllChunks;

%disp('  (-1) = AERI ')
disp('  (0)  = generic gaussian ')
disp('  (+1) = AIRS ')
disp('  (+2) = IASI ')
disp('  (+3) = CRiS ')
iAirs  = input('Enter instrument : ');

%if iDoJac > 0
%  disp('  qjacAllChunks, tjacAllChunks  : gas jac, temp jac')
%  disp('  wgAllChunks                   : wgt fcn')
%  disp('  if this is a downlook instrument, also have')
%  disp('    sjacAllChunks, ejacAllChunks  : stemp, emissivity jac')
%  end

%if iAirs == -1
%  disp('using AERI convolution with GAUSSIAN')
%  aeri_convolution_results;

if iAirs == 1
  disp('using AIRS convolution')
  airs_convolution_results;
elseif iAirs == 2
  disp('using IASI convolution')
  iasi_convolution_results;
elseif iAirs == 3
  disp('using CRIS convolution')
  cris_convolution_results;
elseif iAirs == 0
  disp('generic convolution!!!')
  generic_convolution_results;
else
  disp(' not a known instrument!!!')
  disp(' not convolving!!!')
  end