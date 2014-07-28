%% this function computes dBTdr
function y = dbtdr(fr,r);

% these are the first and second Planck constants
r1 = 1.1911E-5;
r2 = 1.4387863;

r3 = r1*r2*(fr.^4)./(r.^2);
r4 = 1 + r1*(fr.^3)./r;
y  = r3./r4./(log(r4).^2);