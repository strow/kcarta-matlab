function [rCos] = ExpInt3(x)

rCos = ones(size(x)) * (3/5);

doexp = -1;
if doexp > 0  %%%%slow!!!!!!!!!!!!!!!!!!!!!!!
  E1  = expint(x);
  E2 = (exp(-x) - x.*E1)/1;
  E3 = (exp(-x) - x.*E2)/2;
  rCos = -x./(log(2*E3));
  end

if doexp < 0    %%%%%fast!!!!!!!!!!!!!!!!!!!
  % xa  = 0.001:0.001:0.1;  rCosa=ExpInt3(xa);  plot(xa,rCosa);
  % [pa,s] = polyfit(xa,rCosa,5);
  % ynewa = polyval(pa,xa); plot(xa,100*(rCosa-ynewa)./rCosa)
  pa = ...
  [6.725726391714112e+03  -2.059829899353410e+03  2.493354751957636e+02 ...
  -1.627993422390017e+01   9.724649797475841e-01  5.008065113432290e-01];

  % xb = 0.1:0.01:1.0;  rCosb=ExpInt3(xb);  plot(xb,rCosb);
  % [pb,s] = polyfit(xb,rCosb,5);
  % ynewb = polyval(pb,xb); plot(xb,100*(rCosb-ynewb)./rCosb)
  pb = ...
  [1.737868577677329e-01  -5.942422040447611e-01  8.298282122476618e-01 ...
  -6.419981476471418e-01   3.781034365041675e-01  5.138457140182577e-01];

  % xc = 1.0: 0.1: 10.0;  rCosc=ExpInt3(xc);  plot(xc,rCosc);
  % [pc,s] = polyfit(xc,rCosc,5);
  % ynewc = polyval(pc,xc); plot(xc,100*(rCosc-ynewc)./rCosc)
  pc = ...
  [7.021803910136394e-06  -2.357508369924054e-04  3.180595796229321e-03 ...
  -2.266608395564899e-02   1.005876360602864e-01  5.793563003519303e-01];

  % xd = 10.0: 0.1: 50.0;  rCosd=ExpInt3(xd);  plot(xd,rCosd);
  % [pd,s] = polyfit(xd,rCosd,5);
  % ynewd = polyval(pd,xd); plot(xd,100*(rCosd-ynewd)./rCosd)
  pd = ...
  [1.480269235371422e-09  -2.699043936290163e-07   2.000167061444674e-05 ...
  -7.815383163994549e-04   1.780330354645652e-02   7.264461388391468e-01];

  inda = find(x <= 0.1);
  indb = find((x > 0.1)  & (x <= 1.0));
  indc = find((x > 1.0)  & (x <= 10.0));
  indd = find((x > 10.0) & (x <= 50.0));
  inde = find(x > 50.0);

  rCos(inda) = polyval(pa,x(inda));
  rCos(indb) = polyval(pb,x(indb));
  rCos(indc) = polyval(pc,x(indc));
  rCos(indd) = polyval(pd,x(indd));
  rCos(inde) = 1.0*ones(size(inde));

  %ind = find(rCos < 0);
  %if length(ind) > 0
  %  plot(x(ind),rCos(ind),'+',x,rCos)
  %  error('error!!!!!!!!!!')
  %  end

  end
