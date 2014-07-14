
% make a figure that compares CO2 transmittances,
% absorptions, and fourth root of absorptions

gid = 2;
v1 = 655;
gdir = '/home/motteler/abstab/absdat.co2';
rdir = '/home/motteler/abscmp/old/refprof';

%  load absorptions and frequencies
%  fr            1x10000      80000  double array
%  k         10000x100x11  88000000  double array
eval(['load ', gdir, '/g', num2str(gid), 'v', num2str(v1), '.mat']);

% load the reference profile
eval(sprintf('load %s/refgas%d -ascii', rdir, gid));
eval(sprintf('refgas = refgas%d;', gid));
plevs = refgas(:,2);

% set temperature offsets
toffset = [-50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50];

% tempind=input('temp offset index > ');
tempind = 6;

ktrue = k(:, :, tempind);    % true absorptions
trtrue = exp(-ktrue);	     % true transmittances
l2strue = cumprod(trtrue);   % true layer-to-space trans.

h1 = figure(1); clf;

v1 = 667.1;
v2 = 669.2;

fpind = find(v1 < fr & fr < v2);
fp = fr(fpind);

lset = 1:24:100;

orient tall

subplot(3,1,1)
plot(fp, ktrue(fpind,lset))
title('CO_2 absorption coefficients')
legend('layer 1', 'layer 25', 'layer 49', 'layer 73', 'layer 97')
grid

subplot(3,1,2)
plot(fp, ktrue(fpind,lset).^(1/4))
title('fourth root of coefficients')
legend('layer 1', 'layer 25', 'layer 49', 'layer 73', 'layer 97')
grid

subplot(3,1,3)
plot(fp, trtrue(fpind,lset))
title('corresponding transmittances')
legend('layer 1', 'layer 25', 'layer 49', 'layer 73', 'layer 97')
xlabel('wavenumber')
grid

saveas(h1, 'abspix.fig');

