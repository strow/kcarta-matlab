function [rads] = matlab_kcarta_downlook_nojac(head,prof,aux_struct,ropt0);
%
% function [rads]=matlab_kcarta_downlook_nojac(head,prof,aux_struct,ropt0);
%
% input
%   head,prof = head,prof of profile to be processed
%
%   aux_struct : set in set_aux
%     aux_struct.atm.nlays            number of layers
%     aux_struct.atm.rFracBot         fraction of bottom layer
%     aux_struct.atm.fA,fb            start and stop kCARTA chunks
%     aux_struct.cont.CKD,cswt,cfwt   continuum version, self/forn wgts
%     aux_struct.refp                 file with structure ref profiles, 
%                                     list of gasids
%   ropt0        = structure set in set_dirs, 
%                    with kpath,soldir,cdir,nltedir,co2chiDir
%                    also whether or not to do Thermal BackGnd and solar
% output
%   rads.freqAllChunks                  1x20000             freq
%   rads.radAllChunks                   20000x1             radiances
%   rads.iaa_kcomprstats_AllChunks          2x73            Sing Vectors stats

%%%%%%%%%%%%%%%%%%%% uncompression guts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% plus clear sky rad transfer %%%%%%%%%%%%%%%%%%%%%%%%%%%%
co2ChiFilePath = ropt0.co2ChiFilePath;
cdir           = ropt0.cdir;

fA       = aux_struct.atm.fA;
fB       = aux_struct.atm.fB;
df       = aux_struct.atm.df;
f0       = aux_struct.atm.f0;
nlays    = aux_struct.atm.nlays;
rFracBot = aux_struct.atm.rFracBot;
CKD      = aux_struct.cont.CKD;
cswt     = aux_struct.cont.cswt;
cfwt     = aux_struct.cont.cfwt;
refp     = aux_struct.refp;

global iDebug;
ind_perturb = -1;
if iDebug > 1000 & iDebug < 2000
  ind_perturb = iDebug - 1000;    %% perturb LAYTMP this layer if iDebug > 1000
elseif iDebug > 2000 & iDebug < 3000
  ind_perturb = iDebug - 2000;    %% perturb GASAMT this layer if iDebug > 2000
  end
iGasDebug = 2;

%gasids = [[1 : 29],[51 : 63]];
load(refp);
gasids = refpro.glist;

% edit this list to only keep gases you DO want!
% gasids = 1
% disp('>>>>>>>>>>>>>>>> only using gases ...')
% gasids = 103

fchunk = fA : df*10000 : fB; nchunk = length(fchunk);
absc = []; zang = [];

freqAllChunks = zeros(1,10000*nchunk);
radAllChunks  = zeros(10000*nchunk,1);
if iDebug > 0
  abscAllChunks = zeros(10000*nchunk,nlays);
  end

iaa_kcomprstats_AllChunks = [];

profileG = op_rtp_to_lbl2(1, refpro.glist, head, prof, refpro);

for cc = 1 : length(fchunk)
  iaCountNumVec = [];

  ff = fchunk(cc);
  absc = zeros(10000,nlays);
  chunkindex = (1:10000) + (cc-1)*10000;

  fprintf(1,' chunk %4i \n',ff)
  for jj = 1 : length(gasids)
    gid = gasids(jj);
    %fprintf(1,'chunk %4i, doing gasID = %3i \n',ff,gid);
    clear absG

    if iDebug > 1000 & iDebug < 2000
      fprintf(1,'perturb T( %3i ) by 1 K \n',ind_perturb);
      profileG.mtemp(ind_perturb) = profileG.mtemp(ind_perturb) + 1;
      profileG.mtemp(ind_perturb)
    elseif iDebug > 2000 & gid == iGasDebug
      fprintf(1,'perturb Q %2i (%3i) by 10 percent \n',iGasDebug,ind_perturb);
      profileG.gamnt(ind_perturb)*0.1
      profileG.gamnt(ind_perturb) = profileG.gamnt(ind_perturb)*1.1;
      end

    [absG,freq,iNumVec] = kcmix2(profileG, gid, ff, ropt0, refp,df);

    iaCountNumVec(jj) = iNumVec;
    
    if gid == 1
      copt.cvers = CKD;
      copt.cdir  = cdir;
      copt.cswt = 1;
      copt.cfwt = 1;
      cont = contcalc(profileG, freq, copt);
      absG = absG + cont;
      end

    absc = absc + absG;

    end    %%% loop on gases

  absc(:,nlays) = absc(:,nlays)*rFracBot;
  abscAllChunks(chunkindex,:) = absc;  

  profX = prof;
  if iDebug > 1000 & iDebug < 2000
    profX.ptemp(ind_perturb) = profX.ptemp(ind_perturb) + 1;
    [prof.ptemp(ind_perturb) profX.ptemp(ind_perturb)]
    end
  [rad25,therm25,zang] = rtchunk_Tsurf(profX, absc, freq , ropt0);

  freqAllChunks(chunkindex) = freq;
  radAllChunks(chunkindex) = rad25;

  iaa_kcomprstats_AllChunks = [iaa_kcomprstats_AllChunks; iaCountNumVec];
  end
%%%%%%%%%%%%%%%%%%%% uncompression guts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear jacQGAllChunks jacTGAllChunks
clear k2AllChunks jacQGAllChunks jacTGAllChunks

rads.freqAllChunks             = freqAllChunks;
rads.radAllChunks              = radAllChunks;
if iDebug > 0
  rads.abscAllChunks             = abscAllChunks;
  end
rads.iaa_kcomprstats_AllChunks = iaa_kcomprstats_AllChunks;
