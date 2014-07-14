
% test kcmix constituent amount and partial pressure calculations
%                                                  p1
%  GENLN level prof  -->  pt2kcmix (old klayers)  ----.
%       |                                             |
%       V                                        p2   V
%   gpro2rtp --> RTP klayers --> unit conversion --> compare


% path to kcarta scripts
addpath /home/motteler/radtrans/kctest
addpath /asl/matlab/rtptools

% select a point profile (needs a full path)
% ptpro = input('GENLN2 format point profile > ', 's');
% ptpro = '/home/motteler/radtrans/klayers/Data/Pexample/myp1';
ptpro = '/home/motteler/abscmp/kcmix/refpro.ptpro';

% read point profile as a kcmix structure
p1 = pt2kcmix(ptpro);

% translate point profile to an RTP file
klayin = 'klayin.rtp';
klayout = 'klayout.rtp';
[gdir,gpro,gext]= fileparts(ptpro);
gdir = [gdir,'/'];
gpro = [gpro,gext];
gpro2rtp(gdir, {gpro}, klayin);

% run klayers on the RTP level profile
% note: set ldry=F to match old klayers driver script "doklay"
rtpcheck(klayin, 'klayers');
klayers = '/asl/packages/klayers/Bin/klayers_airs';
eval(sprintf('!%s fin=%s fout=%s nwant=-1 ldry=F', klayers, klayin, klayout));
% eval(sprintf('!%s fin=%s fout=%s nwant=-1', klayers, klayin, klayout));

% read in the new layer profile
[h2, h2attr, p2, p2attr] = rtpread2(klayout);

p2lay = 1:p2.nlevs-1;  % p2 layer indices
p2lev = 1:p2.nlevs;    % p2 level indices

% convert p2 molecules/cm^2 to kmoles/cm^2
kAvog = 6.022045e26;
p2.gamnt = double(single(p2.gamnt));
p2.gamnt = p2.gamnt(p2lay,:) ./ kAvog;

% convert p2 millibars to atmospheres
p2.plevs = p2.plevs / 1013.25;
p2.plays = p2.plays / 1013.25;

[m,n] = size(p2.gamnt);
p2.gpart = zeros(m,n);

% reconstruct p2 partial pressures
C1 = 1.2027e-12 * 1e6 * 1013.25;
C2 = p2.ptemp(p2lay) ./ (abs(diff(p2.palts(p2lev))) .* C1);
for i = 1 : h2.ngas
  p2.gpart(:,i) =  p2.gamnt(:,i) .* C2;
end

% index into matching levels in p1
p1ind = length(p1.plev) - p2lay;

% compare p1 and p2 levels
% rms((p2.plevs(p2lay) - p1.plev(p1ind+1)) ./ p2.plevs(p2lay))
% [p2.plevs(p2lay), p1.plev(p1ind+1)]

subplot(2,1,1)
plot(p2.plays(p2lay), ...
     (p2.gpart(p2lay,1) - p1.gpart(p1ind,1)) ./ p2.gpart(p2lay,1) )
title('partial pressure comparison, (p2-p1)/p2')
ylabel('relative difference')
grid
% [p2.gpart(p2lay,1), p1.gpart(p1ind,1)]

subplot(2,1,2)
plot(p2.plays(p2lay), ...
     (p2.gamnt(p2lay,1) - p1.gamnt(p1ind,1)) ./ p2.gamnt(p2lay,1) )
title('gas amount comparison, (p2-p1)/p2')
xlabel('pressure, mb')
ylabel('relative difference')
grid
% [p2.gamnt(p2lay,1), p1.gamnt(p1ind,1)]

input('<return> for next plot > ');

subplot(2,1,1)
plot(p2.plays(p2lay), ...
     (p2.plays(p2lay) - p1.mpres(p1ind)) ./ p2.plays(p2lay) );
title('pressure comparison, (p2-p1)/p2')
ylabel('relative difference')
grid

subplot(2,1,2)
plot(p2.plays(p2lay), ...
     (p2.ptemp(p2lay) - p1.mtemp(p1ind)) ./ p2.ptemp(p2lay) );
title('temperature comparison, (p2-p1)/p2')
xlabel('pressure, mb')
ylabel('relative difference')
grid

% clean up
delete(klayin)
delete(klayout)

