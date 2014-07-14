%% this simply puts more params into a structure
function aux_struct = set_aux(fA,fB,nlays,rFracBot,CKD,cswt,cfwt,refp);

%% input 
%%
%%   fA,fB     = input freqs : WARNING they may be "reset" here
%%   nlays     = number of layers in profile
%%   rFracBot  = bottom (GND) fractional layer 
%%                (code assumes TOA top layer frac = 1)   
%% continuum
%%     CKD       = continuum version
%%     cswt,cfwt = continuum self and foreign weights
%%   refp      = reference profile path
%%
%% output
%%   aux_struct = structure with above info

[fA1,fB1,prefix,df,f0] = find_chunks(fA,fB);    %%% find needed chunks and prefix

if (fA ~= fA1) 
  fprintf(1,'warning : fA reset from %4i to %4i \n',fA,fA1);
end
if (fB ~= fB1) 
  fprintf(1,'warning : fB reset from %4i to %4i \n',fB,fB1);
end

fA = fA1;
fB = fB1;
%% atmosphere and freqs
aux_struct.atm.fA        = fA;
aux_struct.atm.fB        = fB;

aux_struct.atm.prefix    = prefix;
aux_struct.atm.df        = df;
aux_struct.atm.f0        = f0;

aux_struct.atm.nlays     = nlays;
aux_struct.atm.rFracBot  = rFracBot;

%% continuum
aux_struct.cont.CKD  = CKD;
aux_struct.cont.cswt = cswt;
aux_struct.cont.cfwt = cfwt;

%% refprof name with list of gasids, and structure ref profile
aux_struct.refp      = refp;
