
% test rlayers
%

rtp1 = '/home/motteler/radtrans/kcwrap/test1.rtp'
rtp1 = '/carrot/s1/sergio/Airs/2002/06/13/ecmwf.gran.81_191109.kcarta.rtp'

[h1, ha, p1, pa] = rtpread2(rtp1);

% ropt.nlay2 = p1.nlevs-1;
ropt.nlay2 = 80;
p2 = rlayers(p1, ropt);

return

figure(1); clf

% plot temperature profiles
subplot(2,1,1)
plot(p1.plays(1:p1.nlevs-1), p1.ptemp(1:p1.nlevs-1), ...
     p2.plays(1:p2.nlevs-1), p2.ptemp(1:p2.nlevs-1));
legend('p1', 'p2', 4);
title('temperature')

% plot selected partial pressure profiles
gtst = 1; % gas to plot
% gtst = input('gas to plot > ');
subplot(2,1,2)
semilogy(p1.plays(1:p1.nlevs-1), p1.gamnt(1:p1.nlevs-1, gtst), ...
         p2.plays(1:p2.nlevs-1), p2.gamnt(1:p2.nlevs-1, gtst))
% v = axis; axis([0,1100,v(3:4)])
legend('p1', 'p2', 4);
title(sprintf('gas %d amount', gtst))

