
% test vlayers
%
% call vlayers to interpolate a 100 layer profile to some 
% new number of layers, and then again to interpolate back
%
% plots temperature, partial pressure, and gas amount for
% initial and interpolated profiles

% set point profile name
ptpro = '/home/motteler/radtrans/klayers/Data/Pexample/myp1';

% read point profile as a kcmix structure
p1 = pt2kcmix(ptpro);

% set number of new layers
% nlay = 90;
nlay = input('number of new layers > ');

% interpolate to new layers
p2 = vlayers(p1, nlay);

% interpolate back to 100 layers
p3 = vlayers(p2, 100);

figure(1); clf

% plot temperature profiles
subplot(2,1,1)
plot(p1.mpres, p1.mtemp, p2.mpres, p2.mtemp, p3.mpres, p3.mtemp)
% v = axis; axis([0,1100,v(3:4)])
legend('initial', 'interp', 'reinterp', 4);
title('temperature')

% plot selected partial pressure profiles
gtst = 1; % gas to plot
gtst = input('gas to plot > ');
subplot(2,1,2)
semilogy(p1.mpres, p1.gpart(:,gtst), ...
         p2.mpres, p2.gpart(:,gtst), ...
         p3.mpres, p3.gpart(:,gtst));
% v = axis; axis([0,1100,v(3:4)])
legend('initial', 'interp', 'reinterp', 4);
title(sprintf('gas %d partial pressure', gtst))

figure(2); clf

% plot selected gas amounts
% 
% Note that for gas amounts, the "actual interpolated <n> layer" plot
% will be greater for fewer layers, since the layers are thicker, and
% less for more layers

dz1 = abs(diff(p1.plev));
dz2 = abs(diff(p2.plev));

semilogy(p1.mpres, p1.gamnt(:,gtst), ...
         p2.mpres, p2.gamnt(:,gtst), ':', ...
         p1.mpres, interp1(p2.mpres,p2.gamnt(:,gtst)./dz2,p1.mpres).*dz1, ...
         p3.mpres, p3.gamnt(:,gtst));
% v = axis; axis([0,1100,v(3:4)])
legend(sprintf('initial %d layer', length(p1.mpres)), ...
       sprintf('actual interpolated %d layer', length(p2.mpres)), ...
       sprintf('rescaled interpolated %d layer', length(p2.mpres)), ...
       sprintf('final reinterpolated %d layer', length(p3.mpres)), ...
       4 );

title(sprintf('gas %d amounts by layer', gtst))


% gas amount total column relative errors

sumgerr2 = (sum(p1.gamnt(:,gtst)) - sum(p2.gamnt(:,gtst))) / ...
              sum(p1.gamnt(:,gtst))

sumgerr3 = (sum(p1.gamnt(:,gtst)) - sum(p3.gamnt(:,gtst))) / ...
              sum(p1.gamnt(:,gtst))


% gas amount selected layer relative error (after reinterp)

L = 60:63;
laygerr3 = (sum(p1.gamnt(L,gtst)) - sum(p3.gamnt(L,gtst))) / ...
              sum(p1.gamnt(L,gtst))

