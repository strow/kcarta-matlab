
load refprof/refgas1
load refprof/refgas2
load refprof/refgas3
load refprof/refgas4
load refprof/refgas5
load refprof/refgas6
load refprof/refgas7
load refprof/refgas8

semilogy(refgas1(:,2), refgas1(:,5), ...
 	 refgas2(:,2), refgas2(:,5), ...
 	 refgas3(:,2), refgas3(:,5), ...
 	 refgas4(:,2), refgas4(:,5), ...
 	 refgas5(:,2), refgas5(:,5), ...
 	 refgas6(:,2), refgas6(:,5), ...
 	 refgas7(:,2), refgas7(:,5), ...
 	 refgas8(:,2), refgas8(:,5));

axis([0, 1.1, 0, 1])

xlabel('pressure (torr ??)');
ylabel('amount (kmol/cm^2 ??)');

glist
legend(a(1).g, a(2).g, a(3).g, a(4).g, a(5).g, a(6).g, a(7).g, a(8).g)

title('Reference Profile Gas Amounts')

grid

