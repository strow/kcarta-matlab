%
% simple demo of kcrad
%

% use the V105 rtp libs
addpath /home/motteler/mot2008/hdf/h4tools

% specify a V105 rtp test file
tfile = 'testpro.rtp';

% set some kcrad options
kopt.rsolar = 0;
kopt.rtherm = 1;
kopt.cvers = '24';
kopt.vcmin = 605;
kopt.vcmax = 2805;

% call kcrad with the profiler
profile on
[rad, freq] = kcrad(tfile, kopt);
profile report

% plot the results
figure(1); clf
plot(freq, rad)
title('kcrad demo with 44 gasses')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

% return

% compare with new kcarta fitting profile 1

addpath /asl/packages/ccast/source

fitpro1 = '/home/motteler/cris/sergio/JUNK2012/convolved_kcarta1.mat';
d1 = load(fitpro1);

bt1 = real(rad2bt(freq, rad));
bt2 = real(rad2bt(d1.w, d1.r));

figure(2); clf
plot(freq, bt1, d1.w, bt2)
title('kcmix demo and kcarta fitting profile 1')
legend('kcmix demo', 'kcarta prof 1', 'location', 'southeast');
xlabel('wavenumber')
ylabel('brightness temp')
grid on; zoom on

