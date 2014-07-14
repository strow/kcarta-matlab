
% split solar data up into V2-type 0.0025 1/cm chunks

load fine_solar.mat

% fine_solar.mat contains the variables:
%
%   fout       1x1120001    8960008  double array
%   rout       1x1120001    8960008  double array
%

clist = 605 : 25 : 2805; 

for vc = clist

  sfrq = vc + (0:9999) * 0.0025;

  srad = interp1(fout, rout, sfrq, 'linear');

  eval(sprintf('save solarV2/srad%d sfrq srad', vc));

end

