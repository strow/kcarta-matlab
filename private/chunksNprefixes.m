function [prefix,kcartachunks,df,f0] = chunksNprefixes(fA,fB);

% simple function to figure out chunks and prefixes
% input  
%   fA,fB : start and stop freqs
% output
%   prefix : string that tells the code what kComp file names start with
%   kcartachunks : current spectral range chunk file wavenumbers
%   df     : wavenumber spacing of points
%   f0     : first chunk file
%

if fA >= 00080 & fB <= 00150+0.1
  prefix = '/j';
  df = 2.5/10000;  f0 = 80;
  kcartachunks = 00080 : 0002.5 : 00150;
elseif fA >= 00140 & fB <= 00310+0.1
  prefix = '/k';
  df = 5.0/10000;  f0 = 140;
  kcartachunks = 00140 : 0005.0 : 00310;
elseif fA >= 00300 & fB <= 00510+0.1
  prefix = '/p';
  df = 10.0/10000;  f0 = 300;
  kcartachunks = 00300 : 0010.0 : 00510;
elseif fA >= 00500 & fB <= 00605+0.1
  prefix = '/q';
  df = 15.0/10000; f0 = 500;
  kcartachunks = 00500 : 0015.0 : 00605;
elseif fA >= 00605 & fB <= 02830+0.1    %%% default
  prefix = '/r';
  df = 25.0/10000;  f0 = 605;
  kcartachunks = 00605 : 0025.0 : 02830;
elseif fA >= 02830 & fB <= 03580+0.1
  prefix = '/s';
  df = 25.0/10000;  f0 = 2830;
  kcartachunks = 02830 : 0025.0 : 03580;
elseif fA >= 03550 & fB <= 05650+0.1
  prefix = '/m';
  df = 100.0/10000;  f0 = 3550;
  kcartachunks = 03550 : 0100.0 : 05650;
elseif fA >= 05550 & fB <= 08350+0.1
  prefix = '/n';
  df = 150.0/10000;  f0 = 5550;
  kcartachunks = 05550 : 0150.0 : 08350;
elseif fA >= 08250 & fB <= 12250+0.1
  prefix = '/o';
  df = 250.0/10000;  f0 = 8250;
  kcartachunks = 08250 : 0250.0 : 12250;
elseif fA >= 12000 & fB <= 25000+0.1
  prefix = '/v';
  df = 500.0/10000;  f0 = 12000;
  kcartachunks = 12000 : 0500.0 : 25000;
elseif fA >= 25000 & fB <= 44000+0.1
  prefix = '/u';
  df = 1000.0/10000;  f0 = 25000;
  kcartachunks = 25000 : 1000.0 : 44000;
else
  [fA fB]
  error('please check input fA fB');
  end
