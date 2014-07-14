
function kcmix = pt2kcmix(ptpro)

% pt2kcmix reads a GENLN-format point profile and returns
% a kcmix-format matlab profile structure
%
% input
%   ptpro  - GENLN format point profile file
%
% output
%   mpro   - matlab kcmix profile structure
%
% bugs
%   doklay is just a fortran wrapper, with all the risks 
%   involved with that sort of thing
%

% get a point profile in matlab format
[plev, temp, gasid, gasmx, lat] = gproread(ptpro);

% call klayers for genln/kcarta input format 
kopt.kvers = 'gen';
pout = doklay(plev, temp, gasid, gasmx, lat, kopt);

% build kcmix profile structure
kcmix.glist = squeeze(pout(1,1,:));
kcmix.mpres = pout(5, :, 1)';
kcmix.mtemp = pout(3, :, 1)';
kcmix.gamnt = squeeze(pout(2, :, :));
kcmix.gpart = squeeze(pout(7, :, :));

% add scott's layer boundaries
nseq = 1:101;
A = -1.5508E-4;
B = -5.5937E-2;
C =  7.4516;
kcmix.plev = ((A*nseq .^2 + B*nseq + C) .^ (7/2))';  % p1 press levels

