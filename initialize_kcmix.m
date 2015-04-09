function [nlays,prof,rFracBot,ropt] = initialize_kcmix(prof0,iDownLook,ropt0);

% function [nlays,prof,rFracBot,ropt] = ...
%                  initialize_kcmix(prof0,iDownLook,ropt0);
% sets up some variables, given
%
% input
%   prof0     = rtp structure with current profile
%   iDownLook = +1 for downlook inst, =1 for uplook instr
%   ropt0     = set up structure with soldir, nltedir etc
%
% output
%   nlays     = number of layers
%   prof      = prof0, plus some sanity checks eg zobs, satzen, and ptemp(nlay)
%               set using stemp,spres,p(bottom layer)
%   rFracBot  = fraction of bottom layer
%   ropt      = ropt0 structure, with couple additional variables

prof = prof0;

%% find partial fractions, sets up the code to do the uncompressing
%nlevs = p.nlevs(ip);
nlevs = prof.nlevs;
nlays = nlevs-1;
MGC   = 8.314674269981136;
kAvog = 6.022045e26;

if ~isfield(prof,'zobs') 
  disp(' ------------>>>> warning : setting prof.zobs = 705000')
  prof.zobs = 705000;
end

if ~isfield(prof,'nrho') 
  disp(' ------------>>>> warning : setting prof.nrho = prof.nemis')
  prof.nrho = prof.nemis;
end

if ~isfield(prof,'rfreq') 
  disp(' ------------>>>> warning : setting prof.rfreq = prof.efreq')
  prof.rfreq = prof.efreq;
end

if ~isfield(prof,'plays') 
  prof.plays = zeros(size(prof.plevs));
  plays = prof.plevs;
  playsA = plays(1:100,:)-plays(2:101,:);
  playsB = log(plays(1:100,:)./plays(2:101,:));
  prof.plays(1:100,:) = playsA./playsB;
end

if ~isfield(prof,'pobs') 
  if iDownLook == +1
    disp(' ------------>>>> warning : setting prof.pobs = 0')
    prof.pobs = 000;
  elseif iDownLook == -1
    disp(' ------------>>>> warning : setting prof.pobs = spres')
    prof.pobs = prof.spres;
  end
end

if prof.satzen == -9999 & prof.zobs > 0
  %disp(' ------------>>>> warning : setting prof.satzen = prof.scanang');
  %prof.satzen = prof.scanang;
  prof.satzen = vaconv(prof.scanang, prof.zobs, prof.salti);
  fprintf(1,'WARNING ... set satzen = vaconv(scanang,salti,zobs) = %8.6f \n',prof.satzen)
end

%%% need prof.plevs(nlays) < prof.spres < prof.plevs(nlays+1), which is same as
%%% need prof.plevs(nlevs-1) < prof.spres < prof.plevs(nlevs)
if (prof.plevs(nlays) > prof.spres)
  error('prof.plevs(nlays) > prof.spres');
end
if (prof.plevs(nlevs) < prof.spres)
  error('prof.plevs(nlevs) < prof.spres');
end

rFracBot = ...
   (prof.plevs(nlays)-prof.spres)/(prof.plevs(nlays)-prof.plevs(nlevs));

pr_p2 = prof.plevs(nlevs-1);
pr_p1 = prof.spres;
p1    = (pr_p2 - pr_p1)/log(pr_p2/pr_p1);
t1    = interp1(prof.plays(1:nlays),prof.ptemp(1:nlays),p1,'linear','extrap');
prof.ptemp(nlays) = t1;
fprintf(1,'bottom layer : frac= %8.6f pavg = %8.6f Temp = %8.6f \n',rFracBot,p1,t1);

% add params for solar on/off and backgnd thermal on/off
ropt = ropt0;
if prof.solzen < 90
  ropt.rsolar = +1;  %%sun on
else
  ropt.rsolar = -1;
end

ropt.rtherm = 2;   %% 0,1,2 = none/simple/accurate background thermal

