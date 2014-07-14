
% browse sample profile compared to reference profile

% set point profile name
ptpro = '/home/motteler/asl/radtrans/klayers/Data/Pexample/myp1';

% read point profile as a kcmix structure
p1 = pt2kcmix(ptpro);

load /home/motteler/asl/abscmp/refpro

plot(refpro.mpres, refpro.mtemp, p1.mpres, p1.mtemp)
legend('ref', 'p1')
pause

gind = 4;
semilogy(refpro.mpres, refpro.gamnt(:,gind), p1.mpres, p1.gamnt(:,gind))
legend('ref', 'p1')
title('gas amounts compared')
pause

plot(refpro.mpres, ...
    (refpro.gamnt(:,gind) - p1.gamnt(:,gind)) ./ refpro.gamnt(:,gind));
title('relative gas amount difference')

