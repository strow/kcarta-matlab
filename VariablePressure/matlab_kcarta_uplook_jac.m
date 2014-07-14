function [rads,jacs] = ...
    matlab_kcarta_downlook_jac(head,prof,aux_struct,ropt0,iDoJac,iJacobOutput);
% function 
%   [rads,jacs] = ...
%  matlab_kcarta_downlook_nojac(head,prof,aux_struct,ropt0,iDoJac,iJacobOutput)
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
%   iDoJac       = list of gasIDS for jacs
%   iJacobOutput = what kind of jacobian output
%
% output
%   rads.freqAllChunks                  1x20000              freq
%   rads.radAllChunks                   20000x1              radiances
%   rads.iaa_kcomprstats_AllChunks          2x73             Sing Vectors stats
%     jacs.ejacAllChunks                  20000x1              emissivity jac
%     jacs.qjacAllChunks                  2x20000x96           gas jacs
%     jacs.sjacAllChunks                  20000x1              stemp jac
%     jacs.tjacAllChunks                  20000x96             tempr jacs
%     jacs.wgtAllChunks                   20000x96             wgt fcns
%

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

fchunk = fA : df*10000 : fB; nchunk = length(fchunk);
absc = []; zang = [];

freqAllChunks = zeros(1,10000*nchunk);
radAllChunks  = zeros(10000*nchunk,1);
if iDebug > 0
  abscAllChunks = zeros(10000*nchunk,nlays);
  end

%% q = gas amt, t = temp, s = surfacetemp, e = surface emiss
qjacAllChunks = zeros(length(iDoJac),nchunk*10000,nlays);
tjacAllChunks = zeros(nchunk*10000,nlays);
wgtAllChunks  = zeros(nchunk*10000,nlays);

iaa_kcomprstats_AllChunks = [];

profileG = op_rtp_to_lbl2(1, refpro.glist, head, prof, refpro);

for cc = 1 : length(fchunk)
  iaCountNumVec = [];
  ff = fchunk(cc);
  absc = zeros(10000,nlays);
  jacTchunk = zeros(10000,nlays);
  chunkindex = (1:10000) + (cc-1)*10000;

  fprintf(1,' chunk %4i \n',ff)
  for jj = 1 : length(gasids)
    gid = gasids(jj);
    %fprintf(1,'chunk %4i, doing gasID = %3i \n',ff,gid);
    clear absG

    if iDebug > 1000 & iDebug < 2000
      fprintf(1,'perturb T( %3i ) by 1 K \n',ind_perturb);
      profile.mtemp(ind_perturb) = profile.mtemp(ind_perturb) + 1;
      profile.mtemp(ind_perturb)
    elseif iDebug > 2000 & gid == iGasDebug
      fprintf(1,'perturb Q %2i (%3i) by 10 percent \n',iGasDebug,ind_perturb);
      profile.gamnt(ind_perturb)*0.1
      profile.gamnt(ind_perturb) = profile.gamnt(ind_perturb)*1.1;
      end

    [freq,gasprofX,absG,jacTG,jacQG,iNumVec] = kcmix2jac(profileG,gid,ff,ropt0,iDoJac,refp,df);
    [aa,iNumLayer] = size(absG);
    if length(intersect(iDoJac,gasids(jj))) == 1 
      iQG = find(gasids(jj) == iDoJac);
      gasprofQG(iQG,:,:) = gasprofX;
      end
    iaCountNumVec(jj) = iNumVec;

    %% for xDebug
    if gid == iGasDebug & iDebug > 0
        k2AllChunks(chunkindex,:) = absG;
        end

    if gid == 1
      copt.cvers = CKD;
      copt.cdir  = cdir;
      copt.cswt  = cswt;
      copt.cfwt  = cfwt;
      %disp('   doing continuum');
      [cont,contjacT,contjacQ] = contjaccalc(profileG, freq, copt, iDoJac);
      jacTG = jacTG + contjacT;  
      if length(intersect(iDoJac,1)) == +1
        jacQG = jacQG + contjacQ;   %% water lines + water cont jac
        end
      absG = absG + cont;
      end

    absc = absc + absG;
    if iDebug > 0
      abscAllChunks(chunkindex,:) = absc;  
      end

    jacTchunk = jacTchunk + jacTG;

    if iDoJac > 0 & length(intersect(iDoJac,gasids(jj))) == 1
      iQG = find(gasids(jj) == iDoJac);
      jacQAllChunks(iQG,chunkindex,:) = jacQG;
      end    

    end    %%% loop on gases

  absc(:,nlays) = absc(:,nlays)*rFracBot;

  jacQG = jacQAllChunks(:,chunkindex,:);
  [allrad25,rad25,zang,rSol25] = rtchunk_uplook(prof, absc, freq , ropt0);
  [qjac,tjac,wgt] = ...
     jac_uplook(freq,zang,rSol25,absc,jacQG,jacTG,prof,iDoJac);
  if iJacobOutput == 0
     [aa,iNumLayer] = size(absc);
     qjac = doQjacOutput(gasprofQG,qjac,iDoJac,0,iNumLayer,freq,rad25);
   elseif iJacobOutput == 1
     [aa,iNumLayer] = size(absc);
     qjac = doQjacOutput(gasprofQG,qjac,iDoJac,1,iNumLayer,freq,rad25);
     tjac = tjac .* (dbtdr(freq,rad25')'*ones(1,iNumLayer));
     end

  qjacAllChunks(:,chunkindex,:) = qjac;
  tjacAllChunks(chunkindex,:)   = tjac;
  wgtAllChunks(chunkindex,:)    = wgt;

  freqAllChunks(chunkindex) = freq;
  radAllChunks(chunkindex) = rad25;

  iaa_kcomprstats_AllChunks = [iaa_kcomprstats_AllChunks; iaCountNumVec];
  end
%%%%%%%%%%%%%%%%%%%% uncompression guts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear lay2spAllChunks atmAllChunks thermAllChunks jacQGAllChunks
clear k2AllChunks radtransdownAllChunks jacQGAllChunks

rads.freqAllChunks             = freqAllChunks;
rads.radAllChunks              = radAllChunks;
if iDebug > 0
  rads.abscAllChunks             = abscAllChunks;
  end
rads.iaa_kcomprstats_AllChunks = iaa_kcomprstats_AllChunks;

jacs.qjacAllChunks = qjacAllChunks;
jacs.tjacAllChunks = tjacAllChunks;
jacs.wgtAllChunks  = wgtAllChunks;
