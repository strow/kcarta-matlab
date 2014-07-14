
% compare kcmix and kcmix100 at varying layer sets

% compressed data 
kpath = '/asl/data/kcarta/v20.matlab';

% chunk start wavenumber
vchunk = input('chunk wavenumber > ');

% set point profile name
ptpro = '/home/motteler/radtrans/klayers/Data/Pexample/myp1';

% read point profile as a kcmix structure
p1 = pt2kcmix(ptpro);

% specify gas set
gset = input('specify gas set > ');
gset = intersect(gset, p1.glist);
gind = interp1(p1.glist, 1:length(p1.glist), gset, 'nearest')

p1.glist = p1.glist(gind);
p1.gamnt = p1.gamnt(:,gind);
p1.gpart = p1.gpart(:,gind);

% get number of new layers
nlay2 = input('number of new layers > ');

% interpolate to new layers
p2 = vlayers(p1, nlay2);

% old calculation at 100 layers
[a1, freq] = kcmix100(p1, vchunk, kpath);

% profile on
% new calculation at nlay2 layers
[a2, freq] = kcmix(p2, vchunk, kpath);
% profile report

% plot the total column absorption error
%
a1s = sum(a1');
a2s = sum(a2');

figure(1); clf
subplot(2,1,1)
plot(freq, a1s, freq, a2s)
legend('100 layer', sprintf('%d layer', nlay2))
title('total column absorption')

subplot(2,1,2)
plot(freq, a1s - a2s)
title('difference')

% total column RMS relative error
cerr = max((a1s - a2s) ./ a1s);
fprintf(1, 'total col max relative error %.3g\n', cerr);


% plot absorption error for a selected layer
%
% interpolate results back to 100 layers;
% the following only works for single gasses

if length(gind) == 1

  a3 = (interp1(log(p2.mpres), ...
                a2' ./ (p2.gamnt * ones(1,1e4)), ...
                log(p1.mpres) )  .*  (p1.gamnt * ones(1,1e4)) )';
     
  % tlay = 60; % test layer
  tlay = input('test layer > ');

  figure(2); clf
  subplot(2,1,1)
  plot(freq, a1(:,tlay), freq, a3(:,tlay));
  legend('100 layer', sprintf('%d layer', nlay2))
  title(sprintf('absorption at layer %d', tlay))

  subplot(2,1,2)
  plot(freq, a1(:,tlay) - a3(:,tlay));
  title('difference')

  % max relative error
  Lerr = max((a1(:,tlay) - a3(:,tlay)) ./ a1(:,tlay));
  fprintf(1, 'layer %d max relative error %.3g\n', tlay, Lerr);

end

