%% this finds the emissivity values, given input freqs
function efine = interp_emiss_rho(freq,efreq,emis,nemis);

X = efreq(1:nemis);
Y =  emis(1:nemis);
efine = interp1(X, Y, freq, 'linear', 'extrap');
%% efine = interp1(prof.efreq,prof.emis,freq);
jj = find(freq < efreq(1));          efine(jj) = emis(1);
jj = find(freq > efreq(nemis));      efine(jj) = emis(nemis);
