
% basic kcrad tests

profile off

% path to kcarta scripts
addpath /home/motteler/radtrans/kctest
addpath /asl/matlab/rtptools

% select a point profile (needs a full path)
% ptpro = input('GENLN2 format point profile > ', 's');
ptpro = '/home/motteler/radtrans/klayers/Data/Pexample/myp1';
% ptpro = '/home/motteler/abscmp/kcmix/refpro.ptpro';

% read point profile as a kcmix structure
p1 = pt2kcmix(ptpro);

% translate point profile to an RTP file
klayin = 'klayin.rtp';
klayout = 'klayout.rtp';
[gdir,gpro,gext]= fileparts(ptpro);
gdir = [gdir,'/'];
gpro = [gpro,gext];
gpro2rtp(gdir, {gpro}, klayin);

% read in the output of gpro2rtp
[head, hattr, prof, pattr] = rtpread2(klayin);

% update the file with fields we need to do a rad calc
head.vcmin = 1005;
head.vcmax = 1055;
for i = 1 : length(prof)
  prof(i).nemis = 3;
  prof(i).efreq = [500, 1500, 2500];
  prof(i).emis = [.96, .97, .98];
  prof(i).spres = 1000;
  prof(i).stemp = 290;
  prof(i).pobs = 0;
end
rtpwrite2(klayin, head, hattr, prof, pattr);

% run klayers on the RTP level profile
% note: set ldry=F to match old klayers driver script "doklay"
rtpcheck(klayin, 'klayers');
klayers = '/asl/packages/klayers/Bin/klayers_airs';
eval(sprintf('!%s fin=%s fout=%s nwant=-1 ldry=F', klayers, klayin, klayout));
% eval(sprintf('!%s fin=%s fout=%s nwant=-1', klayers, klayin, klayout));

% set kcrad options
% kopts.dummy = [];
kopts.cslow = 1;

profile on

% call kcrad to do the radiance calc's
[rad, freq] = kcrad(klayout, kopts);

profile report kcrad
profile off

bt = rad2bt(freq, rad/1000);
plot(freq, bt)

[min(bt), rms(bt), max(bt)]

% clean up
delete(klayin)
delete(klayout)

