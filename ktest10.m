
% demo of a call to kcrad followed by a convolution

% add local paths
addpath /asl/matlab/sconv
addpath /asl/matlab/h4tools
addpath /asl/matlab/rtptools

% klayers executable
klayers = '/asl/packages/klayers/Bin/klayers_airs';  

% temp files
tmplev = 'tmplev.rtp';  % temporary level profile
tmplay = 'tmplay.rtp';  % temporary layer profile

% default SRF HDF file
% sfile='/asl/data/airs/srf/srftablesV10.hdf';       
sfile='/asl/data/airs/srf/srftables_020614v1.hdf';

% get a profile
% prof = input('profile name > ', 's');
% if isempty(prof)
%   pfile = '/home/motteler/radtrans/kcwrap/test1.rtp';
% end
% pfile = '/carrot/s1/Hannon/Airs/2002/06/14/clearg005_ip.rtp'
% pfile = 'testout.rtp';
pfile = '/carrot/s1/motteler/airs/2002/06/14/clearg005/ckd24/allrad.rtp'

% do a basic sanity check of the proffered profile
if ~rtpcheck(pfile, 'kcarta');
  warning(sprintf('%s failed kcarta RTP check', pfile));
end  

% read the RTP file
fprintf(1, '\nreading the RTP input file ...\n')
[head, hattr, prof, pattr] = rtpread2(pfile);

% prof = prof(123);
% good: 45, 123, 164, 165
for i = 123 : length(prof)
  if abs(prof(i).scanang) < 2
    break
  end
end
i
prof = prof(i);

prof.pfields = 7;

% get the spanning frequency band from the requested channel set
% treat the profile channel set as truth, for now
[v1, v2] = cnum2vspan(head.ichan);
head.vcmin = v1;
head.vcmax = v2;

% run klayers, if we don't have a layer profile
if head.ptype ~= 1

  % we have to run klayers to get a layer profile
  fprintf(1, 'running klayers ...\n')
  rtpwrite2(tmplev, head, hattr, prof, pattr);
  eval(sprintf('!%s fin=%s fout=%s nwant=-1', klayers, tmplev, tmplay));
else
  
  % we already have a layers profile, just write it out  
  rtpwrite2(tmplay, head, hattr, prof, pattr);
end

% read the layers profile in
[head, hattr, prof, pattr] = rtpread2(tmplay);
% prof = rlayers(prof);
% rtpwrite2(tmplay, head, hattr, prof, pattr);

% call kcrad to do the radiance calculation
kopt.rsolar = 0;
kopt.rtherm = 1;
kopt.cvers = '24';
kopt.vcmin = 705;
kopt.vcmax = 805;
% kopt.vcmin = 605;
% kopt.vcmax = 2805;
[rad, freq] = kcrad(tmplay, kopt);

% [rad1, freq] = kcrad(tmplay, kopt);
% kopt.rtherm = 0;
% [rad2, freq] = kcrad(tmplay, kopt);
% plot(freq, rad2bt(freq, rad1/1000) - rad2bt(freq, rad2/1000))
% return

% plot(freq, rad2bt(freq, rad/1000))
% return

% do the convolution, trust the supplied channel list
clist = cfreq2cnum([kopt.vcmin, kopt.vcmax], sfile);
clist = (clist(1)+20) : (clist(2)-20);
% clist = 1:2378;
[rout, fout] = sconv2(rad, freq, clist, sfile);

% kcrad plot data
x1 = fout; 
y1= rad2bt(fout, rout/1000);

% kcarta plot data
x2 = head.vchan(clist); 
y2 = rad2bt(head.vchan(clist), prof.rcalc(clist));

% observed data
x3 = head.vchan(clist); 
y3 = rad2bt(head.vchan(clist), prof.robs1(clist)/1000);

figure(1)
subplot(2,1,1)
plot(x1, y1, 'r', x2, y2, 'g', x3, y3, 'b')
title(sprintf('granule 005 profile %d', i))
legend('kcrad', 'kcarta', 'obs');
xlabel('1/cm')
ylabel('Tb')
grid

subplot(2,1,2)
plot(x1, y1-y3, 'r', x1, y2-y3, 'g', x1, y2-y1, 'y')
legend('kcrad - obs', 'kcarta - obs', 'kcarta - kcrad');
xlabel('1/cm')
ylabel('Tb')
grid

% rms(y2-y3)/rms(y3)
% rms(y1-y3)/rms(y3)